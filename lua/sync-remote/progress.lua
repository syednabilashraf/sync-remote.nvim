local M = {}

local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

local sync_notification = {
	id = nil,
	spinner = nil,
	message = nil,
}

local function update_progress()
	if sync_notification.spinner then
		local new_spinner = (sync_notification.spinner + 1) % #spinner_frames
		sync_notification.spinner = new_spinner

		sync_notification.id = vim.notify(sync_notification.message, nil, {
			title = "Sync progress",
			hide_from_history = true,
			icon = spinner_frames[new_spinner],
			replace = sync_notification.id,
		})

		vim.defer_fn(function()
			update_progress()
		end, 100)
	end
end

function M:show_sync_in_progress()
	sync_notification.id = vim.notify("Sync progress: ", vim.log.levels.INFO, {
		title = "Sync progress",
		icon = spinner_frames[1],
		timeout = false,
		hide_from_history = false,
	})

	sync_notification.spinner = 1
	update_progress()
end

function M:remove_sync_in_progress()
	sync_notification.id = nil
	sync_notification.spinner = nil
end

function M:get_notification_state()
	return sync_notification
end

function M:set_message(message)
	sync_notification.message = message
end

return M
