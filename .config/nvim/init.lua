vim.opt.backup = false
vim.opt.writebackup = false

-- If this many milliseconds nothing is typed the swap file will be
--	written to disk (see crash-recovery).  Also used for the
--	CursorHold autocommand event.
-- https://neovim.io/doc/user/options.html#'updatetime' 
vim.opt.updatetime = 300

-- Always show the signcolumn, otherwise it would shift the text each time
-- diagnostics appeared/became resolved
-- https://neovim.io/doc/user/options.html#'signcolumn'
vim.opt.signcolumn = 'yes'

-- Print the line number in front of each line.  When the 'n' option is
--	excluded from 'cpoptions' a wrapped line will not use the column of
--	line numbers.
-- https://neovim.io/doc/user/options.html#'number'
vim.opt.number = true

-- yank and paste from system keyboard by setting clipboard option to unnamed
-- https://neovim.io/doc/user/options.html#'clipboard'
vim.api.nvim_set_option("clipboard", "unnamed")


-- shortcut: yank the relative file path for the current file
vim.keymap.set("n", "yp", function() 
	local filepath = vim.fn.fnamemodify(vim.fn.expand('%'), ":~:.")
	vim.fn.setreg('+', filepath)
end)

-- shortcut: previous buffer
vim.keymap.set("n", "<Left>", ":bn<cr>", { silent = true})

-- shortcut: next buffer
vim.keymap.set("n", "<Right>", ":bp<cr>", { silent = true})

-- shortcut: swap
vim.keymap.set("n", ";;", ":b#<cr>", { silent = true})


-- Autocomplete
function _G.check_back_space()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Use K to show documentation in preview window
function _G.show_docs()
  local cw = vim.fn.expand('<cword>')
  if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
    vim.api.nvim_command('h ' .. cw)
  elseif vim.api.nvim_eval('coc#rpc#ready()') then
    vim.fn.CocActionAsync('doHover')
  else
    vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
  end
end

local function bootstrap_pckr()
  local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"

  if not vim.loop.fs_stat(pckr_path) then
    vim.fn.system({
      'git',
      'clone',
      "--filter=blob:none",
      'https://github.com/lewis6991/pckr.nvim',
      pckr_path
    })
  end

  vim.opt.rtp:prepend(pckr_path)
end

bootstrap_pckr()

require('pckr').add{
  { "nvim-telescope/telescope.nvim", branch = "0.1.x", requires = {"nvim-lua/plenary.nvim"},
	config = function()
		-- basic telescope configuration
		require("telescope").setup({
			extensions = {
					coc = {
						theme = 'ivy',
						prefer_locations = true,
						push_cursor_on_edit = true,
						timeout = 3000,
					}
				}
		})

		local builtin = require("telescope.builtin")

		vim.keymap.set("n", "fff", builtin.find_files, {})
		vim.keymap.set("n", "ffx", builtin.live_grep, {})
		vim.keymap.set("n", "ffl", builtin.buffers, {})
	end
  };

  {'neoclide/coc.nvim', branch = 'release', 
  	config = function()
		-- Use Tab for trigger completion with characters ahead and navigate
		-- NOTE: There's always a completion item selected by default, you may want to enable
		-- no select by setting `"suggest.noselect": true` in your configuration file
		-- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
		-- other plugins before putting this into your config

		local keyset = vim.keymap.set
		local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
		keyset('i', '<TAB>', 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
		keyset('i', '<S-TAB>', [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

		-- Make <CR> to accept selected completion item or notify coc.nvim to format
		-- <C-g>u breaks current undo, please make your own choice
		keyset('i', '<cr>', [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

		-- Use <c-j> to trigger snippets
		keyset('i', '<c-j>', '<Plug>(coc-snippets-expand-jump)')
		-- Use <c-space> to trigger completion
		keyset('i', '<c-space>', 'coc#refresh()', { silent = true, expr = true })

		-- Use `[g` and `]g` to navigate diagnostics
		-- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
		keyset('n', '[g', '<Plug>(coc-diagnostic-prev)', { silent = true })
		keyset('n', ']g', '<Plug>(coc-diagnostic-next)', { silent = true })

		-- GoTo code navigation
		keyset('n', 'gd', '<Plug>(coc-definition)', { silent = true })
		keyset('n', 'gy', '<Plug>(coc-type-definition)', { silent = true })
		keyset('n', 'gi', '<Plug>(coc-implementation)', { silent = true })
		keyset('n', 'gr', '<Plug>(coc-references)', { silent = true })


		keyset('n', 'K', '<CMD>lua _G.show_docs()<CR>', { silent = true })


		-- Highlight the symbol and its references on a CursorHold event(cursor is idle)
		vim.api.nvim_create_augroup('CocGroup', {})
		vim.api.nvim_create_autocmd('CursorHold', {
		  group = 'CocGroup',
		  command = "silent call CocActionAsync('highlight')",
		  desc = 'Highlight symbol under cursor on CursorHold'
		})


		-- Symbol renaming
		keyset('n', '<leader>rn', '<Plug>(coc-rename)', { silent = true })


		-- Formatting selected code
		keyset('x', '<leader>f', '<Plug>(coc-format-selected)', { silent = true })
		keyset('n', '<leader>f', '<Plug>(coc-format-selected)', { silent = true })


		-- Setup formatexpr specified filetype(s)
		vim.api.nvim_create_autocmd('FileType', {
		  group = 'CocGroup',
		  pattern = 'typescript,json,python',
		  command = "setl formatexpr=CocAction('formatSelected')",
		  desc = 'Setup formatexpr specified filetype(s).'
		})

		-- Update signature help on jump placeholder
		vim.api.nvim_create_autocmd('User', {
		  group = 'CocGroup',
		  pattern = 'CocJumpPlaceholder',
		  command = "call CocActionAsync('showSignatureHelp')",
		  desc = 'Update signature help on jump placeholder'
		})

		-- Apply codeAction to the selected region
		-- Example: `<leader>aap` for current paragraph
		local opts = { silent = true, nowait = true }
		keyset('x', '<leader>a', '<Plug>(coc-codeaction-selected)', opts)
		keyset('n', '<leader>a', '<Plug>(coc-codeaction-selected)', opts)

		-- Remap keys for apply code actions at the cursor position.
		keyset('n', '<leader>ac', '<Plug>(coc-codeaction-cursor)', opts)
		-- Remap keys for apply source code actions for current file.
		keyset('n', '<leader>as', '<Plug>(coc-codeaction-source)', opts)
		-- Apply the most preferred quickfix action on the current line.
		keyset('n', '<leader>qf', '<Plug>(coc-fix-current)', opts)

		-- Remap keys for apply refactor code actions.
		keyset('n', '<leader>re', '<Plug>(coc-codeaction-refactor)', { silent = true })
		keyset('x', '<leader>r', '<Plug>(coc-codeaction-refactor-selected)', { silent = true })
		keyset('n', '<leader>r', '<Plug>(coc-codeaction-refactor-selected)', { silent = true })

		-- Run the Code Lens actions on the current line
		keyset('n', '<leader>cl', '<Plug>(coc-codelens-action)', opts)


		-- Map function and class text objects
		-- NOTE: Requires 'textDocument.documentSymbol' support from the language server
		keyset('x', 'if', '<Plug>(coc-funcobj-i)', opts)
		keyset('o', 'if', '<Plug>(coc-funcobj-i)', opts)
		keyset('x', 'af', '<Plug>(coc-funcobj-a)', opts)
		keyset('o', 'af', '<Plug>(coc-funcobj-a)', opts)
		keyset('x', 'ic', '<Plug>(coc-classobj-i)', opts)
		keyset('o', 'ic', '<Plug>(coc-classobj-i)', opts)
		keyset('x', 'ac', '<Plug>(coc-classobj-a)', opts)
		keyset('o', 'ac', '<Plug>(coc-classobj-a)', opts)


		-- Remap <C-f> and <C-b> to scroll float windows/popups
		---@diagnostic disable-next-line: redefined-local
		local opts = { silent = true, nowait = true, expr = true }
		keyset('n', '<C-f>', 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
		keyset('n', '<C-b>', 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
		keyset('i', '<C-f>',
		  'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
		keyset('i', '<C-b>',
		  'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
		keyset('v', '<C-f>', 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
		keyset('v', '<C-b>', 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)


		-- Use CTRL-S for selections ranges
		-- Requires 'textDocument/selectionRange' support of language server
		keyset('n', '<C-s>', '<Plug>(coc-range-select)', { silent = true })
		keyset('x', '<C-s>', '<Plug>(coc-range-select)', { silent = true })


		-- Add `:Format` command to format current buffer
		vim.api.nvim_create_user_command('Format', "call CocAction('format')", {})

		-- " Add `:Fold` command to fold current buffer
		vim.api.nvim_create_user_command('Fold', "call CocAction('fold', <f-args>)", { nargs = '?' })

		-- Add `:OR` command for organize imports of the current buffer
		vim.api.nvim_create_user_command('OR', "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

		-- Add (Neo)Vim's native statusline support
		-- NOTE: Please see `:h coc-status` for integrations with external plugins that
		-- provide custom statusline: lightline.vim, vim-airline

		-- vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")

		-- Mappings for CoCList
		-- code actions and coc stuff
		---@diagnostic disable-next-line: redefined-local
		local opts = { silent = true, nowait = true }
		-- Show all diagnostics
		keyset('n', '<space>a', ':<C-u>CocList diagnostics<cr>', opts)
		-- Manage extensions
		keyset('n', '<space>e', ':<C-u>CocList extensions<cr>', opts)
		-- Show commands
		keyset('n', '<space>c', ':<C-u>CocList commands<cr>', opts)
		-- Find symbol of current document
		keyset('n', '<space>o', ':<C-u>CocList outline<cr>', opts)
		-- Search workspace symbols
		keyset('n', '<space>s', ':<C-u>CocList -I symbols<cr>', opts)
		-- Do default action for next item
		keyset('n', '<space>j', ':<C-u>CocNext<cr>', opts)
		-- Do default action for previous item
		keyset('n', '<space>k', ':<C-u>CocPrev<cr>', opts)
		-- Resume latest coc list
		keyset('n', '<space>p', ':<C-u>CocListResume<cr>', opts)

	end
	};
  { "fannheyward/telescope-coc.nvim", requires={"neoclide/coc.nvim", "nvim-telescope/telescope.nvim"}, 
		config = function()
			require("telescope").load_extension("coc")
		end
	};

  {'vim-airline/vim-airline', branch = 'master', requires={
	"airblade/vim-gitgutter", 
	"mhinz/vim-signify",
	"neoclide/coc-git",
	"lewis6991/gitsigns.nvim"},
	config = function()
		vim.cmd([[
		  let g:airline#extensions#tabline#enabled = 1
		  let g:airline#extensions#tabline#buffers_label = ''
		  let g:airline#extensions#tabline#show_buffers = 1
		  let g:airline#extensions#tabline#show_tab_nr = 1
		  let g:airline#extensions#tabline#show_tab_type = 'buffer'
		]])
	end
  };
  {'vim-airline/vim-airline-themes', branch = 'master', requires={"vim-airline/vim-airline"}, config=function()
	vim.cmd([[
		AirlineTheme apprentice
	]])
  end
  };
  { "ThePrimeagen/harpoon", branch = "harpoon2", requires = {"nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim"},
  	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		local list = harpoon:list('ffh')
		local pickers = require("telescope.pickers")
		local conf = require("telescope.config").values
		local finders = require("telescope.finders")

		local function toggle_telescope(harpoon_files)
		    local file_paths = {}
		    for _, item in ipairs(harpoon_files.items) do
			table.insert(file_paths, item.value)
		    end

		    pickers.new({}, {
			prompt_title = "Harpoon",
			finder = finders.new_table({
			    results = file_paths,
			}),
			previewer = conf.file_previewer({}),
			sorter = conf.generic_sorter({}),
		    }):find()
		end

		vim.keymap.set("n", "mm", function()
			list:add()
			local item = vim.fn.expand('%:p') .. ':' .. vim.fn.line('.') 
			vim.notify("harpoon <-- " .. item, vim.log.levels.INFO)
		end)

		vim.keymap.set("n", "md", function()
			list:clear()
			vim.notify("harpoon <-- {}", vim.log.levels.INFO)
		end)

		vim.keymap.set("n", "ffm", function() toggle_telescope(list) end,
		    { desc = "Open harpoon window" })

		vim.keymap.set("n", "<C-h>", function() list:select(2) end)
		vim.keymap.set("n", "<C-t>", function() list:select(2) end)
		vim.keymap.set("n", "<C-n>", function() list:select(3) end)
		vim.keymap.set("n", "<C-s>", function() list:select(4) end)

		-- Toggle previous & next buffers stored within Harpoon list
		vim.keymap.set("n", "<C-S-P>", function() list:prev() end)
		vim.keymap.set("n", "<C-S-N>", function() list:next() end)
			
		M = {}

		M.changed_files = function(opts)
			local base_branch = vim.g.telescope_changed_files_base_branch or "master"
			local command = "git diff --name-only $(git merge-base HEAD " .. base_branch .. " )"
			local handle = io.popen(command)
			local result = handle:read("*a")
			handle:close()

			local files = {}
			for token in string.gmatch(result, "[^%s]+") do
			   table.insert(files, token)
			end

			opts = opts or {}

			pickers.new(opts, {
				prompt_title = "changed files",
				finder = finders.new_table {
					results = files,
				},
				previewer = conf.file_previewer({}),
				sorter = conf.generic_sorter(opts),
			}):find()
		end

		M.choose_base_branch = function(opts)
		  opts = opts or {}
		  builtin.git_branches({
		    attach_mappings = function(prompt_bufnr, map)
		      actions.select_default:replace(function()
			actions.close(prompt_bufnr)
			local selection = action_state.get_selected_entry()
				vim.g.telescope_changed_files_base_branch = selection.value
				M.base_branch = selection.value
		      end)
		      return true
		    end,
		  })
		end

		vim.keymap.set("n", "ffg", M.changed_files)
	end
	};

  { "numirias/semshi",
	run = function()
		vim.cmd("UpdateRemotePlugins")
	end
  };

  { "nvim-treesitter/nvim-treesitter", requires = { "ThePrimeagen/harpoon", "nvim-telescope/telescope.nvim" },
  	run = function()
		local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
		ts_update()
	end,

	config = function()
		local configs = require('nvim-treesitter.configs')

		configs.setup({
			ensure_installed = { "lua", "vim", "vimdoc", "python" },
			auto_install = false, -- TODO: should show this in the airline if we're missing support
			sync_install = false,
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
  };
}

