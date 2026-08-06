return {
  -- Helm chart template syntax highlighting (gotmpl + yaml)
  { "towolf/vim-helm", ft = "helm" },

  -- add treesitter parsers used by helm templates
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "gotmpl",
        "yaml",
      })
    end,
  },
}
