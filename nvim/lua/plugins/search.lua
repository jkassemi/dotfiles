return {
  "nvim-telescope/telescope.nvim",
  keys = {
    {
      ";f",
      function()
        require("telescope.builtin").find_files({})
      end,
      desc = "Find File",
    },

    {
      ";x",
      function()
        require("telescope.builtin").live_grep({})
      end,
      desc = "Grep",
    },

    {
      ";l",
      function()
        require("telescope.builtin").buffers({})
      end,
      desc = "Buffers",
    },
  },
  opts = function()
    local select_one_or_multi = function(prompt_bufnr)
      local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
      local multi = picker:get_multi_selection()
      if not vim.tbl_isempty(multi) then
        require("telescope.actions").close(prompt_bufnr)
        for _, j in pairs(multi) do
          if j.path ~= nil then
            vim.cmd(string.format("%s %s", "edit", j.path))
          end
        end
      else
        require("telescope.actions").select_default(prompt_bufnr)
      end
    end

    return {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          i = {
            ["<CR>"] = select_one_or_multi,
          },
        },
      },
      pickers = {
        find_files = {
          theme = "ivy",
        },
        live_grep = {
          theme = "ivy",
        },
        buffers = {
          theme = "ivy",
        },
      },
    }
  end,
}
