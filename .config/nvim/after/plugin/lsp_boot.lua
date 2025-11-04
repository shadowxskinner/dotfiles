-- Force-load the plugins (Lazy can defer them otherwise)
pcall(function() require("lazy").load({ plugins = { "mason.nvim", "mason-lspconfig.nvim", "nvim-lspconfig" } }) end)

-- Mason core
local ok_mason, mason = pcall(require, "mason")
if ok_mason then mason.setup() end

-- Ensure pyright is installed (non-blocking if already done)
local ok_mlsp, mlsp = pcall(require, "mason-lspconfig")
if ok_mlsp then
  mlsp.setup({ ensure_installed = { "pyright" } })
end

-- Start LSPs per filetype if nothing is attached yet
local ok_lsp, lsp = pcall(require, "lspconfig")
if ok_lsp then
  local function start_if_none(ft, server, cfg)
    if vim.bo.filetype ~= ft then return end
    local attached = vim.lsp.get_clients({ bufnr = 0 })
    if next(attached) ~= nil then return end
    if lsp[server] and not lsp[server].manager then
      lsp[server].setup(cfg or {})
    end
    vim.defer_fn(function()
      pcall(vim.cmd, "LspStart " .. server)
    end, 50)
  end

  vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
      start_if_none("python", "pyright", {})
      start_if_none("lua", "lua_ls", { settings = { Lua = { diagnostics = { globals = { "vim" } } } } })
      start_if_none("bash", "bashls", {})
      start_if_none("json", "jsonls", {})
      start_if_none("yaml", "yamlls", {})
      start_if_none("typescript", "ts_ls", {})
      start_if_none("javascript", "ts_ls", {})
    end,
  })
end
