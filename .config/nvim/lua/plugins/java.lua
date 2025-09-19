return {
	{
		"mfussenegger/nvim-jdtls",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		ft = "java",
		config = function()
			local jdtls = require("jdtls")
			local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()

			local blink_status_ok, blink = pcall(require, "blink.cmp")
			if blink_status_ok then
				lsp_capabilities = vim.tbl_deep_extend("force", {}, lsp_capabilities, blink.get_lsp_capabilities())
			end

			local mason_share = vim.fn.expand("$HOME/.local/share/nvim/mason")
			local jdtls_path = mason_share .. "/bin/jdtls"
			local lombok_path = mason_share .. "/packages/jdtls/lombok.jar"
			local debug_pattern = mason_share .. "/packages/java-debug-adapter/extension/server/*.jar"
			local test_pattern = mason_share .. "/packages/java-test/extension/server/*.jar"

			-- Bundles para debug
			local bundles = {
				vim.fn.glob(debug_pattern, 1), -- único jar
			}
			vim.list_extend(bundles, vim.split(vim.fn.glob(test_pattern, 1), "\n"))

			-- Configuración LSP
			local config = {
				cmd = {
					jdtls_path,
					("--jvm-arg=-javaagent:%s"):format(lombok_path),
				},
				capabilities = lsp_capabilities,
				root_dir = require("jdtls.setup").find_root({ ".git", "pom.xml", "build.gradle" }),
				data_dir = vim.fn.stdpath("cache") .. "/jdtls",
				init_options = {
					bundles = bundles,
				},
			}

			-- Iniciar JDTLS
			jdtls.start_or_attach(config)
			-- Configurar DAP para Java
			jdtls.setup_dap({ hotcodereplace = "auto" })

			-- Tests
			local dap = require("dap")
			dap.defaults.fallback.focus_terminal = false
			dap.defaults.fallback.terminal_win_cmd = "5new"

			-- Ejecutar test
			vim.keymap.set("n", "<leader>tc", function()
				jdtls.test_class()
				dap.repl.open({ height = 7 })
			end, { noremap = true, silent = true })

			-- Ocultar resultados del test
			vim.keymap.set("n", "<leader>td", function()
				-- Cerrramos la terminal
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					local name = vim.api.nvim_buf_get_name(buf)
					if name:match("dap%-terminal") then
						vim.api.nvim_buf_delete(buf, { force = true })
					end
				end
				-- Cerramos el reply
				dap.repl.close()
			end, { noremap = true, silent = true })
		end,
	},
}
