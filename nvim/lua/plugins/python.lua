return {
  -- add pyright to lspconfig
  -- {
  --   "neovim/nvim-lspconfig",
  --   ---@class PluginLspOpts
  --   opts = {
  --     ---@type lspconfig.options
  --     servers = {
  --       -- pyright will be automatically installed with mason and loaded with lspconfig
  --       pyright = {
  --         venvPath = "/Users/james/.pyenv/versions",
  --         venv = "3.11.6",
  --       },
  --     },
  --   },
  -- },
  --
  -- {
  --   "stevearc/conform.nvim",
  --   opts = {
  --     formatters = {
  --       black = {
  --         format_on_save = true,
  --       },
  --
  --       isort = {
  --         format_on_save = true,
  --       },
  --     },
  --   },
  -- },

  {
    "neovim/nvim-lspconfig",
    config = function()
      --capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      require("lspconfig").pyright.setup({
        -- capabilities = capabilities,
        cmd = { "/Users/james/bin/helix-python-wrapper", "/opt/homebrew/bin/pyright-langserver", "--stdio" },
        settings = {
          python = {
            analysis = {
              diagnosticMode = "workspace",
            },
          },
        },
      })

      require("lspconfig").jedi_language_server.setup({
        cmd = { "/Users/james/bin/helix-python-wrapper", "/Users/james/.pyenv/versions/hx/bin/jedi-language-server" },
      })

      require("lspconfig").pylsp.setup({
        cmd = { "/Users/james/bin/helix-python-wrapper", "/Users/james/.pyenv/versions/hx/bin/pylsp" },
      })

      vim.api.nvim_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "gr", "<cmd>Telescope lsp_references<CR>", { noremap = true, silent = true })
      -- require("lspconfig").pylyzer.setup({})
    end,
  },

  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = {
  --     setup = {
  --       config = function()
  --         capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
  --         require("lazyvim.util").lsp.on_attach(function(client)
  --           client.capabilities = capabilities
  --         end)
  --       end,
  --     },
  --   },
  -- },
}
