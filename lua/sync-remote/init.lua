local M = {}
local config = {}
local cwd = vim.loop.cwd()

local function loadConfig()
	local configFilePath = cwd .. "/.nvim/config.txt"
	local file = io.open(configFilePath, "r")

	if file then
		for line in file:lines() do
			if not line:match("^#") then
				local key, value = line:match("([^=]+)=(.+)")
				if key and value then
					config[key] = value
				end
			end
		end
		file:close()
		config.local_root = config.local_root:gsub("~", os.getenv("HOME"))
	end
end

local function isConfigFileValid()
	if next(config) == nil then
		vim.notify(
			".nvim/config.txt file not found in current working directory. If the current working directory is the local folder you wish to sync with remote, then you can add the config file here: "
				.. cwd
		)
		return false
	end
end

function M.setup()
	loadConfig()

	vim.cmd([[command! SyncRemoteFileUp lua require('sync-remote').syncRemoteFileUp()]])

	vim.cmd([[command! SyncRemoteUp lua require('sync-remote').syncRemoteUp()]])

	vim.cmd([[command! SyncRemoteDown lua require('sync-remote').syncRemoteDown()]])
end

function M.syncRemoteUp()
	if not isConfigFileValid() then
		return
	end

	local local_folder_path = config.local_root
	local remote_folder_path = config.remote_root
	local rsync_command = "rsync -vz --no-whole-file " .. local_folder_path .. " " .. remote_folder_path
	print("Sync start", rsync_command)
	vim.fn.jobstart(rsync_command, {
		on_exit = function()
			print("Sync complete", local_folder_path)
		end,
		on_stderr = function(_, data)
			print("Sync failed", rsync_command)
			if data and #data > 0 then
				print("Error output:", data)
			end
		end,
	})
end

function M.syncRemoteDown()
	if not isConfigFileValid() then
		return
	end

	local local_folder_path = config.local_root
	local remote_folder_path = config.remote_root
	local rsync_command = "rsync -vz --no-whole-file " .. remote_folder_path .. " " .. local_folder_path
	print("Sync start", rsync_command)
	vim.fn.jobstart(rsync_command, {
		on_exit = function()
			print("Sync complete", local_folder_path)
		end,
		on_stderr = function(_, data)
			print("Sync failed", rsync_command)
			if data and #data > 0 then
				print("Error output:", data)
			end
		end,
	})
end

function M.syncRemoteFileUp()
	if not isConfigFileValid() then
		return
	end
	local current_file_path = vim.fn.expand("%:p")
	local local_root = config.local_root
	local remote_root = config.remote_root
	if current_file_path:find(local_root) then
		local common_path = current_file_path:gsub("^" .. local_root, ""):gsub("^/", "")

		local remote_file_path = remote_root .. "/" .. common_path
		local rsync_command = "rsync -vz --no-whole-file " .. current_file_path .. " " .. remote_file_path
		print("Sync start", rsync_command)
		vim.fn.jobstart(rsync_command, {
			on_exit = function()
				print("Sync complete", common_path)
			end,
			on_stderr = function(_, data)
				print("Sync failed", rsync_command)
				if data and #data > 0 then
					print("Error output:", data)
				end
			end,
		})
	end
end

return M
