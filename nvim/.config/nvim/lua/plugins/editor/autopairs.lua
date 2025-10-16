-- ============================================================================
-- Autopairs - Autocompletado de pares
-- ============================================================================
-- Cierra automáticamente paréntesis, corchetes, llaves y comillas.
-- Documentación: https://github.com/windwp/nvim-autopairs
-- ============================================================================

return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    check_ts = true, -- Usa treesitter para mejor contexto
    ts_config = {
      lua = { "string" }, -- No agrega pares en strings de lua
      javascript = { "template_string" },
    },
  },
  config = function(_, opts)
    local autopairs = require("nvim-autopairs")
    autopairs.setup(opts)

    -- Integración con nvim-cmp
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    local cmp = require("cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end,
}
