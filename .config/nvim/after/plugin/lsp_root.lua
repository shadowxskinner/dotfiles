local util = require("lspconfig.util")
local fallback = function(fname)
  return util.root_pattern(
    "pyproject.toml","setup.py","setup.cfg","requirements.txt","Pipfile",
    "package.json","tsconfig.json","jsconfig.json",
    ".stylua.toml","stylua.toml",".editorconfig",".git"
  )(fname) or util.path.dirname(fname)
end

local lsp = require("lspconfig")
for name, cfg in pairs({
  pyright = {},
  ts_ls = {},
  bashls = {},
  jsonls = {},
  yamlls = {},
  lua_ls = { settings = { Lua = { diagnostics = { globals = { "vim" } } } } },
}) do
  lsp[name].setup(vim.tbl_deep_extend("force", cfg, { root_dir = fallback }))
end
