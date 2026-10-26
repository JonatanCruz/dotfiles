-- ============================================================================
-- Treesitter - Resaltado de sintaxis inteligente
-- ============================================================================
-- Parser de sintaxis avanzado para mejor resaltado y comprensión del código.
-- Documentación: https://github.com/nvim-treesitter/nvim-treesitter
--
-- ESTADO (nvim 0.12, rama master de nvim-treesitter):
--  - master está congelada y sus módulos no son compatibles con 0.12: el
--    select de textobjects (`vaf`) revienta con "attempt to call method
--    'start'" (TSNode cambió de API). Por eso aquí NO se usan sus módulos
--    (highlight/indent/incremental_selection/textobjects).
--  - El resaltado lo arranca nvim de forma nativa (vim.treesitter.start) en
--    cada FileType, que es además lo que pide la rama main. nvim-treesitter
--    queda como instalador de parsers (:TSInstall, :TSUpdate, ensure_installed).
--  - Antes de este cambio las opciones nunca se aplicaban (faltaba
--    main = "nvim-treesitter.configs"): solo resaltaba lua, por el ftplugin
--    nativo, y los textobjects/incremental_selection no existían.
--  - Pendiente: migrar a main. Exige el CLI tree-sitter (>= 0.25) para
--    compilar parsers, que hoy no está instalado, y nvim-treesitter-textobjects
--    en main tiene otra API (mapeos a mano).
-- ============================================================================

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    -- Solo instalación de parsers; los módulos de master quedan apagados.
    require("nvim-treesitter.configs").setup({
      ensure_installed = require("config.constants").treesitter.ensure_installed,
      highlight = { enable = false },
      indent = { enable = false },
    })

    local function start(buf)
      -- pcall: sin parser para el filetype (p. ej. python si no está en
      -- ensure_installed) simplemente no resalta, sin error.
      pcall(vim.treesitter.start, buf)
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterNativo", { clear = true }),
      callback = function(ev)
        start(ev.buf)
      end,
      desc = "Resaltado treesitter nativo",
    })

    -- El plugin se carga en BufReadPost, después del FileType del primer
    -- buffer: arrancarlo también en los ya abiertos.
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
        start(buf)
      end
    end
  end,
}
