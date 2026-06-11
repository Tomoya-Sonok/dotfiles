return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-web-devicons" },
    keys = {
      { "md", "<cmd>RenderMarkdown toggle<cr>", desc = "RenderMarkdown toggle", ft = "markdown" },
    },
    opts = {
      checkbox = {
        checked = { scope_highlight = "@markup.strikethrough" },
        custom = {
          -- デフォルトの`[-]`であるtodoは削除
          todo = { raw = "", rendered = "", highlight = "" },
          canceled = {
            raw = "[-]",
            rendered = "󱘹",
            scope_highlight = "@markup.strikethrough",
          },
        },
      },
    },
  },
}
