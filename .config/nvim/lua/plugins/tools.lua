return {
  { "mason-org/mason.nvim" },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "pyright",
        "lua_ls",
        "bashls",
        "jsonls",
        "yamlls",
        "ts_ls", -- (new name for tsserver in lspconfig)
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
        lua_ls  = { settings = { Lua = { diagnostics = { globals = { "vim" } } } } },
        bashls  = {},
        jsonls  = {},
        yamlls  = {},
        ts_ls   = {},
      },
    },
  },
}
