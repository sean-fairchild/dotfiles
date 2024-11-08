return {
  {
    "SidOfc/carbon.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    keys = {
      {
        "<leader>e",
        function()
          require("carbon").toggle_sidebar({ bang = true })
        end,
        desc = "Toggle Carbon",
      },
    },
    opts = {},
    config = function()
      require("carbon").setup({})
    end,
  },
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
}