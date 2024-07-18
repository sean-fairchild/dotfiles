return {
  "zbirenbaum/copilot.lua",
  enabled = true,
  config = function()
    -- vim.g.copilot_no_tab_map = true
    -- vim.g.copilot_assume_mapped = true
    vim.g.copilot_proxy = os.getenv("PGE_PROXY")
    vim.g.copilot_proxy_strict_ssl = false
    -- vim.keymap.set("i", "<M-\\>", "<Plug>(copilot-dismiss)", { silent = true })

    -- vim.g.copilot_filetypes = {
    --   markdown = true,
    -- }
    require("copilot").setup({})
  end,
}
