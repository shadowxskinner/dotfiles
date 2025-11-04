local ok_lsp, lsp = pcall(require, "lspconfig")
if not ok_lsp then return end
local util = require("lspconfig.util")

-- Fallback: use common markers, otherwise the file's directory (or CWD)
local function fallback_root(fname)
  return util.root_pattern(
    "pyproject.toml","setup.py","setup.cfg","requirements.txt","Pipfile","pyrightconfig.json",
    "package.json","tsconfig.json","jsconfig.json",
    ".stylua.toml","stylua.toml",".editorconfig",
    ".git"
  )(fname) or util.path.dirname(fname) or vim.fn.getcwd()
end

-- Re-declare servers with our root_dir fallback (safe if they were already set)
local servers = {
  pyright = {},
  ts_ls   = {},
  bashls  = {},
  jsonls  = {},
  yamlls  = {},
  lua_ls  = { settings = { Lua = { diagnostics = { globals = { "vim" } } } } },
}

for name, cfg in pairs(servers) do
  if lsp[name] then
    lsp[name].setup(vim.tbl_deep_extend("force", cfg, { root_dir = fallback_root }))
  end
end

-- If nothing is attached when a buffer opens, try to start the matching server
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python","lua","bash","sh","json","yaml","javascript","typescript","javascriptreact","typescriptreact" },
  callback = function(args)
    if next(vim.lsp.get_clients({ bufnr = args.buf })) ~= nil then return end
    local ft = vim.bo[args.buf].filetype
    local map = {
      python = "pyright",
      lua = "lua_ls",
      bash = "bashls", sh = "bashls",
      json = "jsonls",
      yaml = "yamlls",
      javascript = "ts_ls", javascriptreact = "ts_ls",
      typescript = "ts_ls", typescriptreact = "ts_ls",
    }
    local srv = map[ft]
    if srv then pcall(vim.cmd, "LspStart " .. srv) end
  end,
})
