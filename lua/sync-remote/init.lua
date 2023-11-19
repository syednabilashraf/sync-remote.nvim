local M = {}
local config = {}
local cwd = vim.loop.cwd()
local plugin_file_path = debug.getinfo(1, "S").source:sub(2)
local plugin_directory_path = vim.fn.fnamemodify(plugin_file_path, ":h")
local scripts_path = plugin_directory_path .. "/scripts"

local function isPackageInstalled(packageName)
	local command = "which " .. packageName
	local handle = io.popen(command)
	local result = handle:read("*a")
	handle:close()
	return result ~= ""
end

local function loadWatcher(callback)
	if not isPackageInstalled("watchman") then
		vim.notify("watchman is not installed", vim.log.levels.ERROR, { title = "sync-remote dependency error" })
		error("watchman is not installed")
	end

	local local_folder_path = config.local_root
	local remote_folder_path = config.remote_root
	local watcher_script_path = scripts_path .. "/watcher.sh "
	local watch_command = "watchman -- trigger "
		.. local_folder_path
		.. " rsync -- bash "
		.. watcher_script_path
		.. remote_folder_path

	vim.fn.jobstart(watch_command, {
		on_exit = function()
			vim.notify("Loaded watcher in " .. local_folder_path, vim.log.levels.INFO)
			callback()
		end,
	})
end

local function removeWatcher(callback)
	local local_folder_path = config.local_root
	local watch_command = "watchman watch-del " .. local_folder_path

	vim.fn.jobstart(watch_command, {
		on_exit = function()
			callback()
		end,
	})
end

local function loadConfig()
	local configFilePath = cwd .. "/.nvim/config.txt"
	local file = io.open(configFilePath, "r")

	if not file then
		local missing_config_message = ".nvim/config.txt file not found in current working directory. \n If the current working directory is the local folder you wish to sync with remote, \n then you should add the config file here: "
			.. cwd
		vim.notify(missing_config_message, vim.log.levels.ERROR, { title = "Missing config error" })
		error(missing_config_message)
	else
		for line in file:lines() do
			if not line:match("^#") then
				local key, value = line:match("([^=]+)=(.+)")
				if key and value then
					config[key] = value
				end
			end
		end
		file:close()
		if next(config) == nil then
			vim.notify(".nvim/config.txt file is empty!", vim.log.levels.ERROR, { title = "sync-remote config error" })
		elseif not config.local_root then
			vim.notify(
				"local_root is not defined in config file!",
				vim.log.levels.ERROR,
				{ title = "sync-remote config error" }
			)
		elseif not config.remote_root then
			vim.notify(
				"remote_root is not defined in config file!",
				vim.log.levels.ERROR,
				{ title = "sync-remote config error" }
			)
		else
			config.local_root = config.local_root:gsub("~", os.getenv("HOME")) .. "/"
			config.remote_root = config.remote_root .. "/"
		end
	end
end

local function isConfigFileLoaded()
	if not config.local_root and not config.remote_root then
		vim.notify(
			"Please run SyncRemoteStart to load config file in " .. cwd,
			vim.log.levels.ERROR,
			{ title = "Missing config file", height = 40 }
		)
		return false
	end
	return true
end

function M.loadPlugin()
	vim.notify("Initializing sync-remote", vim.log.levels.INFO)
	loadConfig()
	if config.remote_root and config.local_root then
		loadWatcher(function()
			vim.notify("Completed initializing!", vim.log.levels.INFO)
		end)
	end
end

local function sync(source, destination)
	local rsync_command = "rsync -rzu --delete --no-whole-file " .. source .. "/ " .. destination .. "/"
	print("Sync start", rsync_command)
	vim.fn.jobstart(rsync_command, {
		on_exit = function()
			vim.notify("Sync complete ", vim.log.levels.INFO)
		end,
		on_stderr = function()
			print("Sync failed " .. rsync_command)
		end,
	})
end

function M.syncRemoteUp()
	if not isConfigFileLoaded() then
		return
	end

	local local_folder_path = config.local_root
	local remote_folder_path = config.remote_root
	sync(local_folder_path, remote_folder_path)
end

function M.syncRemoteDown()
	if not isConfigFileLoaded() then
		return
	end
	local local_folder_path = config.local_root
	local remote_folder_path = config.remote_root

	if isPackageInstalled("watchman") then
		removeWatcher(function()
			sync(remote_folder_path, local_folder_path)
		end)
		return loadWatcher()
	end

	sync(remote_folder_path, local_folder_path)
end

function M.syncRemoteFileUp()
	if not isConfigFileLoaded() then
		return
	end
	local current_file_path = vim.fn.expand("%:p")
	local local_root = config.local_root
	local remote_root = config.remote_root
	if current_file_path:find(local_root) then
		local common_path = current_file_path:gsub("^" .. local_root, ""):gsub("^/", "")
		local remote_file_path = remote_root .. "/" .. common_path
		sync(current_file_path, remote_file_path)
	end
end

function M.setup()
	vim.cmd([[command! SyncRemoteStart lua require('sync-remote').loadPlugin()]])
	vim.cmd([[command! SyncRemoteFileUp lua require('sync-remote').syncRemoteFileUp()]])
	vim.cmd([[command! SyncRemoteUp lua require('sync-remote').syncRemoteUp()]])
	vim.cmd([[command! SyncRemoteDown lua require('sync-remote').syncRemoteDown()]])
end

return M
