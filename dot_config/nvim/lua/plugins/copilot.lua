local MODEL = "gpt-4o-copilot"
return {
  {
    "zbirenbaum/copilot.lua",
    config = function()
      require("copilot").setup({
        copilot_model = MODEL,
      })
    end,
    optional = true,
    opts = function()
      require("copilot.api").status = require("copilot.status")
    end,
  },
}
