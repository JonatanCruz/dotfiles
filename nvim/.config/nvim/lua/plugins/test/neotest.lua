-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 🧪 NEOTEST - Testing Framework Interactivo
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Framework completo para testing con UI profesional, watch mode y debugging
-- Soporta Jest y Vitest con auto-detección de framework

return {
	-- ╭─────────────────────────────────────────────────────────────────────╮
	-- │ Core Dependencies                                                   │
	-- ╰─────────────────────────────────────────────────────────────────────╯
	{
		"nvim-neotest/nvim-nio",
		lazy = true,
	},

	{
		"nvim-lua/plenary.nvim",
		lazy = true,
	},

	-- ╭─────────────────────────────────────────────────────────────────────╮
	-- │ Neotest Core                                                        │
	-- ╰─────────────────────────────────────────────────────────────────────╯
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			-- Adaptadores de testing
			"nvim-neotest/neotest-jest",
			"marilari88/neotest-vitest",
		},

		-- Lazy loading: cargar solo cuando se ejecuten comandos de testing
		keys = {
			{
				"<leader>tt",
				function()
					require("neotest").run.run()
				end,
				desc = "🧪 Test: Ejecutar test más cercano",
			},
			{
				"<leader>tf",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "📄 Test: Ejecutar tests del archivo",
			},
			{
				"<leader>ta",
				function()
					require("neotest").run.run(vim.fn.getcwd())
				end,
				desc = "🌍 Test: Ejecutar todos los tests",
			},
			{
				"<leader>tl",
				function()
					require("neotest").run.run_last()
				end,
				desc = "🔄 Test: Ejecutar último test",
			},
			{
				"<leader>ts",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "📊 Test: Toggle resumen",
			},
			{
				"<leader>to",
				function()
					require("neotest").output.open({ enter = true })
				end,
				desc = "📝 Test: Abrir output",
			},
			{
				"<leader>tO",
				function()
					require("neotest").output_panel.toggle()
				end,
				desc = "📋 Test: Toggle panel output",
			},
			{
				"<leader>tw",
				function()
					require("neotest").watch.toggle()
				end,
				desc = "👁️  Test: Toggle watch mode",
			},
			{
				"<leader>twf",
				function()
					require("neotest").watch.toggle(vim.fn.expand("%"))
				end,
				desc = "👁️  Test: Watch archivo actual",
			},
			{
				"<leader>td",
				function()
					require("neotest").run.run({ strategy = "dap" })
				end,
				desc = "🐛 Test: Debug test más cercano",
			},
			{
				"<leader>tS",
				function()
					require("neotest").run.stop()
				end,
				desc = "⏹️  Test: Detener tests",
			},
			{
				"<leader>tp",
				function()
					require("neotest").jump.prev({ status = "failed" })
				end,
				desc = "⬆️  Test: Test fallido anterior",
			},
			{
				"<leader>tn",
				function()
					require("neotest").jump.next({ status = "failed" })
				end,
				desc = "⬇️  Test: Test fallido siguiente",
			},
		},

		config = function()
			local neotest = require("neotest")

			-- ╭─────────────────────────────────────────────────────────────╮
			-- │ Configuración de Adaptadores                                │
			-- ╰─────────────────────────────────────────────────────────────╯
			local adapters = {
				-- Jest Adapter: Para proyectos con Jest
				require("neotest-jest")({
					jestCommand = "npm test --",
					jestConfigFile = "jest.config.js",
					-- Soportar jest.config.ts también
					env = { CI = true },
					cwd = function()
						return vim.fn.getcwd()
					end,
				}),

				-- Vitest Adapter: Para proyectos con Vitest
				require("neotest-vitest")({
					-- Auto-detección de vitest.config.js/ts
					vitestCommand = "npx vitest",
					-- Filtrar por archivo actual
					filter_dir = function(name)
						return name ~= "node_modules"
					end,
				}),
			}

			-- ╭─────────────────────────────────────────────────────────────╮
			-- │ Configuración Principal                                      │
			-- ╰─────────────────────────────────────────────────────────────╯
			neotest.setup({
				adapters = adapters,

				-- ═══════════════════════════════════════════════════════════
				-- Icons personalizados (Dracula theme compatible)
				-- ═══════════════════════════════════════════════════════════
				icons = {
					passed = "✅",
					running = "🔄",
					failed = "❌",
					skipped = "⏸️",
					unknown = "❓",
					running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
					-- Iconos para el árbol de tests
					child_indent = "│",
					child_prefix = "├",
					collapsed = "─",
					expanded = "╮",
					final_child_indent = " ",
					final_child_prefix = "╰",
					non_collapsible = "─",
					notify = "",
					watching = "👁️",
				},

				-- ═══════════════════════════════════════════════════════════
				-- Virtual Text: Resultados inline en el código
				-- ═══════════════════════════════════════════════════════════
				floating = {
					border = "rounded",
					max_height = 0.6,
					max_width = 0.6,
					options = {},
				},

				-- ═══════════════════════════════════════════════════════════
				-- Highlights y UI
				-- ═══════════════════════════════════════════════════════════
				highlights = {
					adapter_name = "NeotestAdapterName",
					border = "NeotestBorder",
					dir = "NeotestDir",
					expand_marker = "NeotestExpandMarker",
					failed = "NeotestFailed",
					file = "NeotestFile",
					focused = "NeotestFocused",
					indent = "NeotestIndent",
					marked = "NeotestMarked",
					namespace = "NeotestNamespace",
					passed = "NeotestPassed",
					running = "NeotestRunning",
					select_win = "NeotestWinSelect",
					skipped = "NeotestSkipped",
					target = "NeotestTarget",
					test = "NeotestTest",
					unknown = "NeotestUnknown",
					watching = "NeotestWatching",
				},

				-- ═══════════════════════════════════════════════════════════
				-- Summary Window: Árbol de tests
				-- ═══════════════════════════════════════════════════════════
				summary = {
					enabled = true,
					animated = true,
					follow = true,
					expand_errors = true,
					mappings = {
						attach = "a",
						clear_marked = "M",
						clear_target = "T",
						debug = "d",
						debug_marked = "D",
						expand = { "<CR>", "<2-LeftMouse>" },
						expand_all = "e",
						jumpto = "i",
						mark = "m",
						next_failed = "J",
						output = "o",
						prev_failed = "K",
						run = "r",
						run_marked = "R",
						short = "O",
						stop = "u",
						target = "t",
						watch = "w",
					},
					open = "botright vsplit | vertical resize 50",
				},

				-- ═══════════════════════════════════════════════════════════
				-- Output: Panel de logs y resultados
				-- ═══════════════════════════════════════════════════════════
				output = {
					enabled = true,
					open_on_run = false, -- No abrir automáticamente
				},

				output_panel = {
					enabled = true,
					open = "botright split | resize 15",
				},

				-- ═══════════════════════════════════════════════════════════
				-- Quick Fix: Poblar lista con errores
				-- ═══════════════════════════════════════════════════════════
				quickfix = {
					enabled = true,
					open = false, -- No abrir automáticamente
				},

				-- ═══════════════════════════════════════════════════════════
				-- Watch Mode: Testing continuo
				-- ═══════════════════════════════════════════════════════════
				watch = {
					enabled = true,
					symbol_queries = {
						-- Queries de treesitter para detectar símbolos
						javascript = [[
              ;; query
              ((identifier) @symbol)
            ]],
						typescript = [[
              ;; query
              ((identifier) @symbol)
            ]],
					},
				},

				-- ═══════════════════════════════════════════════════════════
				-- Diagnostic Integration: Signs en gutter
				-- ═══════════════════════════════════════════════════════════
				diagnostic = {
					enabled = true,
					severity = vim.diagnostic.severity.ERROR,
				},

				-- ═══════════════════════════════════════════════════════════
				-- Running: Configuración de ejecución
				-- ═══════════════════════════════════════════════════════════
				run = {
					enabled = true,
				},

				-- ═══════════════════════════════════════════════════════════
				-- Status: Información de estado
				-- ═══════════════════════════════════════════════════════════
				status = {
					enabled = true,
					virtual_text = true,
					signs = true,
				},

				-- ═══════════════════════════════════════════════════════════
				-- Strategies: Integración con DAP para debugging
				-- ═══════════════════════════════════════════════════════════
				strategies = {
					integrated = {
						height = 40,
						width = 120,
					},
				},

				-- ═══════════════════════════════════════════════════════════
				-- Discovery: Auto-detección de tests
				-- ═══════════════════════════════════════════════════════════
				discovery = {
					enabled = true,
					concurrent = 1,
				},

				-- ═══════════════════════════════════════════════════════════
				-- Log Level: Para debugging
				-- ═══════════════════════════════════════════════════════════
				log_level = vim.log.levels.WARN,
			})

			-- ╭─────────────────────────────────────────────────────────────╮
			-- │ Configuración de Highlights (Dracula theme)                 │
			-- ╰─────────────────────────────────────────────────────────────╯
			vim.api.nvim_set_hl(0, "NeotestPassed", { fg = "#50fa7b", bold = true }) -- Verde Dracula
			vim.api.nvim_set_hl(0, "NeotestFailed", { fg = "#ff5555", bold = true }) -- Rojo Dracula
			vim.api.nvim_set_hl(0, "NeotestRunning", { fg = "#ffb86c", bold = true }) -- Naranja Dracula
			vim.api.nvim_set_hl(0, "NeotestSkipped", { fg = "#6272a4", bold = true }) -- Gris Dracula
			vim.api.nvim_set_hl(0, "NeotestUnknown", { fg = "#8be9fd" }) -- Cyan Dracula
			vim.api.nvim_set_hl(0, "NeotestWatching", { fg = "#bd93f9" }) -- Púrpura Dracula

			-- ╭─────────────────────────────────────────────────────────────╮
			-- │ Configuración de Signs en Gutter                            │
			-- ╰─────────────────────────────────────────────────────────────╯
			vim.fn.sign_define("neotest_passed", { text = "✅", texthl = "NeotestPassed" })
			vim.fn.sign_define("neotest_failed", { text = "❌", texthl = "NeotestFailed" })
			vim.fn.sign_define("neotest_running", { text = "🔄", texthl = "NeotestRunning" })
			vim.fn.sign_define("neotest_skipped", { text = "⏸️", texthl = "NeotestSkipped" })
			vim.fn.sign_define("neotest_unknown", { text = "❓", texthl = "NeotestUnknown" })

			-- ╭─────────────────────────────────────────────────────────────╮
			-- │ Auto-comandos para mejor experiencia                        │
			-- ╰─────────────────────────────────────────────────────────────╯
			local augroup = vim.api.nvim_create_augroup("NeotestConfig", { clear = true })

			-- Auto-abrir summary en proyectos de testing
			vim.api.nvim_create_autocmd("BufEnter", {
				group = augroup,
				pattern = { "*.test.js", "*.test.ts", "*.spec.js", "*.spec.ts" },
				callback = function()
					-- Mostrar hint de keybinding
					vim.notify("💡 Tip: <leader>ts para toggle summary", vim.log.levels.INFO)
				end,
			})
		end,
	},
}
