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

			-- Ejecutar la clase actual
			vim.keymap.set("n", "<localleader>g", function()
				local jdtls_setup = require("jdtls.setup")
				local project_dir = jdtls_setup.find_root({ ".git", "pom.xml", "build.gradle" })
				local file_path = vim.api.nvim_buf_get_name(0)

				-- Clase y paquete
				local rel_path = file_path:sub(#project_dir + 1)
				rel_path = rel_path:gsub("^/src/main/java/", ""):gsub("%.java$", "")
				local class = rel_path:gsub("/", ".")

				local exec_flags = "-XX:+ShowCodeDetailsInExceptionMessages -cp"

				-- Determinamos como compilar las clases y el directorio de salida
				if vim.fn.filereadable(project_dir .. "/pom.xml") == 1 then -- Maven
					compile_cmd = string.format("cd %s && mvn compile", project_dir)
					class_dir = project_dir .. "/target/classes"
				elseif vim.fn.filereadable(project_dir .. "/build.gradle") == 1 then -- Gradle
					compile_cmd = string.format("cd %s && ./gradlew build", project_dir)
					class_dir = project_dir .. "/build/classes/java/main"
				else
					vim.api.nvim_err_writeln("No se detectó pom.xml ni build.gradle en el proyecto")
					return
				end

				if vim.fn.isdirectory(class_dir) ~= 1 then
					vim.api.nvim_err_writeln("No se encontró el directorio con las clases compiladas")
					return
				end

				local run_cmd = string.format("cd %s && time java %s %s %s", project_dir, exec_flags, class_dir, class)

				-- Compilar y ejecutar
				local term_cmd = string.format('%s && echo "+ %s" && %s', compile_cmd, run_cmd, run_cmd)
				vim.cmd("botright vsplit | vertical resize " .. math.floor(vim.o.columns * 0.40))
				vim.cmd("terminal " .. term_cmd)
				--vim.cmd("startinsert")
			end, { noremap = true, silent = false })

			-- Ejecutar test
			vim.keymap.set("n", "<localleader>G", function()
				jdtls.test_class()
				dap.repl.open({ height = 7 })
			end, { noremap = true, silent = true })

			-- Ocultar resultados del test
			vim.keymap.set("n", "<localleader>h", function()
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
