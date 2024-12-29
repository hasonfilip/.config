require "nvchad.mappings"

local map = vim.keymap.set


local function toggle_line_numbers()
    if vim.wo.relativenumber then
        vim.wo.relativenumber = false
        vim.wo.number = true
    else
        vim.wo.relativenumber = true
        vim.wo.number = true
    end
end

-- ; or : to enter command mode
map("n", ";", ":", { desc = "CMD enter command mode" })

-- Alt+k to accept copilot suggestion
map("i", "<A-k>", function()
  vim.fn.feedkeys(vim.fn['copilot#Accept'](), '')
end, { desc = "Copilot Accept", replace_keycodes = true, nowait = true, silent = true, expr = true, noremap = true })

-- Alt+o to enable/disable copilot
local copilot_on = true
vim.api.nvim_create_user_command("CopilotToggle", function()
	if copilot_on then
		vim.cmd("Copilot disable")
		print("Copilot OFF")
	else
		vim.cmd("Copilot enable")
		print("Copilot ON")
	end
	copilot_on = not copilot_on
end, { nargs = 0 })
map("n", "<A-o>", ":CopilotToggle<CR>", { desc = "Copilot Toggle" })
map("i", "<A-o>", "<Esc>:CopilotToggle<CR>a", { desc = "Copilot Toggle" })

-- Ctrl+c to copy to system clipboard
map('v', '<C-c>', '"+y', { noremap = true, silent = true })

-- Map <leader>+j to switch to the previous buffer
map('n', '<leader>j', ':bprev<CR>', { noremap = true, silent = true, desc = "Go to previous buffer" })

-- Map <leader>+k to switch to the next buffer
map('n', '<leader>k', ':bnext<CR>', { noremap = true, silent = true, desc = "Go to next buffer" })

-- Delete previous word in insert mode with Ctrl + Backspace
map('i', '<C-BS>', '<C-w>', { noremap = true, silent = true, desc = "Delete previous word" })

-- Delete next word in insert mode with Ctrl + Delete
map('i', '<C-Del>', '<C-o>dw', { noremap = true, silent = true, desc = "Delete next word" })


-- Alt+r to toggle relative/absolute line numbers
map('n', '<A-r>', toggle_line_numbers, { noremap = true, silent = true, desc = "Toggle relative/absolute line numbers" })

-- Ctrl+z to select all lines 
map('n', "<C-z>", "ggVG", { desc = "Selct all lines" })
-- map('n', "<C-z>", ":%y+<CR>", { desc = "Copy all lines" })
