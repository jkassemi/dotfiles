-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- On a line with reported errors, open a small floating buffer with the full error message
vim.api.nvim_set_keymap("n", ";o", "<cmd>lua vim.diagnostic.open_float()<CR>", { noremap = true, silent = true })

-- On a line with reported errors, open a small floating buffer with the full error message
vim.api.nvim_set_keymap("n", ";r", "<cmd>lua vim.lsp.buf.code_action()<CR>", { noremap = true, silent = true })

-- -- Go to the definition. If multiple definitions are found, opens results in quickfix
-- vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = false })
--
-- -- Go to the references. If multiple references are found, opens results in quickfix
-- vim.api.nvim_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { noremap = true, silent = false })

-- Almost :Vex, but keeps teh quickfix open
vim.api.nvim_set_keymap("n", ";h", "<cmd>Lexplore %:h<CR>", { noremap = true, silent = true })

-- Delete all other buffers
vim.api.nvim_set_keymap("n", "bD", "<cmd>%bd|e#<CR>", { noremap = true, silent = true })

--- Enter key provides hover information on currently focused object
--- but we don't want it to trigger when we're in the quickfix window!
function trigger_hover_syntax()
  local ft = vim.bo.filetype
  local qf_title = vim.fn.getqflist({ title = 1 }).title

  -- Don't trigger hover in quickfix window or quickfix browser
  if ft == "qf" then
    if qf_title == "Quickfix List Browser" then
      -- In quickfix browser - switch to selected list
      local cursor_line = vim.fn.line(".")
      local items = vim.fn.getqflist({ items = 1 }).items
      if items[cursor_line] and items[cursor_line].lnum then
        local list_nr = items[cursor_line].lnum
        vim.cmd("silent! " .. list_nr .. "chi")
        vim.cmd("cclose")
        vim.cmd("copen")
      end
    else
      -- Regular quickfix - just jump to location
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
    end
  else
    -- Normal buffer - trigger hover
    hover_trigger = 0
    vim.lsp.buf.hover()
  end
end

-- Trigger hover (see ~/.config/nvim/init.lua) on enter
-- vim.api.nvim_set_keymap("n", "<CR>", [[<Cmd>lua trigger_hover_syntax()<CR>]], { noremap = true, silent = true })

vim.cmd([[
  augroup QuickfixConfig
    autocmd!
    autocmd FileType qf setlocal winheight=20
    autocmd FileType qf setlocal winminheight=20
  augroup END
]])

-- Function to resize quickfix window to half the screen
_G.resize_quickfix = function()
  local win_height = vim.api.nvim_win_get_height(0)
  local qf_height = math.floor(win_height / 2)
  vim.cmd("resize " .. qf_height)
end

-- Autocommand to resize quickfix window when it's opened
vim.cmd([[
  augroup ResizeQuickfix
    autocmd!
    autocmd FileType qf lua _G.resize_quickfix()
  augroup END
]])
