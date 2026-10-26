-- ============================================================================
-- Comentarios - nativo de Neovim (sin plugin)
-- ============================================================================
-- Desde nvim 0.10, `gc` (operador), `gcc` (línea) y `gc` en visual vienen de
-- serie y usan el 'commentstring' del lenguaje bajo el cursor (treesitter), así
-- que Comment.nvim sobraba. Lo único que se pierde es el comentario de bloque
-- (gbc/gb): no hay equivalente nativo.
--
-- No es un plugin: este archivo solo conserva <leader>/ y devuelve un spec
-- vacío para lazy.
-- ============================================================================

vim.keymap.set("n", "<leader>/", "gcc", { remap = true, desc = "Comentar/descomentar línea" })
vim.keymap.set("x", "<leader>/", "gc", { remap = true, desc = "Comentar/descomentar selección" })

return {}
