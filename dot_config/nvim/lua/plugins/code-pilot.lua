return {}
-- local asdf_node = io.popen("asdf where nodejs 16.20.1"):read("*a"):gsub("[\n\r]", "")
-- return {
--   "zbirenbaum/copilot.lua",
--   opts = {
--     suggestion = {
--       enabled = true,
--       auto_trigger = true,
--       keymap = {
--         accept = "<C-l>",
--         accept_word = false,
--         accept_line = false,
--         next = "<C-]>",
--         prev = "<C-[>",
--         dismiss = "<C-x>",
--       },
--     },
--     panel = {
--       enabled = true,
--       auto_refresh = true,
--     },
--     filetypes = {
--       markdown = true,
--       help = true,
--       gitcommit = true,
--     },
--     copilot_node_command = asdf_node .. "/bin/node",
--   },
-- }
