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
			jdtls.setup_dap({ hotcodereplace = "auto" })

			-- Tests
			local dap = require("dap")
			dap.defaults.fallback.focus_terminal = false
			dap.defaults.fallback.terminal_win_cmd = "5new"

			-- Ejecutar test
			vim.keymap.set("n", "<localleader>G", function()
				jdtls.test_class()
				dap.repl.open({ height = 7 })
			end, { noremap = true, silent = true })

			-- Ocultar resultados del test (terminal y reply)
			vim.keymap.set("n", "<localleader>h", function()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					local name = vim.api.nvim_buf_get_name(buf)
					if name:match("dap%-terminal") then
						vim.api.nvim_buf_delete(buf, { force = true })
					end
				end
				dap.repl.close()
			end, { noremap = true, silent = true })

			_G.java_term_buf = _G.java_term_buf or nil
			_G.java_term_win = _G.java_term_win or nil
			_G.java_term_job_id = _G.java_term_job_id or nil

			local function create_terminal()
				vim.cmd("botright vsplit | vertical resize " .. math.floor(vim.o.columns * 0.40) .. " | terminal")
				_G.java_term_buf = vim.api.nvim_get_current_buf()
				_G.java_term_win = vim.api.nvim_get_current_win()
				_G.java_term_job_id = vim.b.terminal_job_id
			end

			-- Función toggle
			function ToggleJavaTerminal()
				-- Si está visible, cerramos (ocultamos) la ventana
				if _G.java_term_win and vim.api.nvim_win_is_valid(_G.java_term_win) then
					vim.api.nvim_win_close(_G.java_term_win, true)
					_G.java_term_win = nil
				-- Si existe el búfer pero no la ventana, abrir split y mostrarlo
				elseif _G.java_term_buf and vim.api.nvim_buf_is_valid(_G.java_term_buf) then
					vim.cmd("botright vsplit | vertical resize " .. math.floor(vim.o.columns * 0.40))
					vim.api.nvim_win_set_buf(0, _G.java_term_buf)
					_G.java_term_win = vim.api.nvim_get_current_win()
				else
					create_terminal()
				end
			end

			-- Ejecutar la clase actual
			vim.keymap.set("n", "<localleader>g", function()
				-- Comprobamos que la clase tenga método main
				local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
				local has_main = false
				for _, line in ipairs(buf_lines) do
					if line:match("public%s+static%s+void%s+main") then
						has_main = true
						break
					end
				end
				if not has_main then
					vim.api.nvim_err_writeln("La clase actual no tiene un método main")
					return
				end

				local jdtls_setup = require("jdtls.setup")
				local project_dir = jdtls_setup.find_root({ ".git", "pom.xml", "build.gradle" })
				local file_path = vim.api.nvim_buf_get_name(0)

				-- Clase y paquete
				local rel_path = file_path:sub(#project_dir + 1)
				rel_path = rel_path:gsub("^/src/main/java/", ""):gsub("%.java$", "")
				local class = rel_path:gsub("/", ".")

				-- Memoria inicial 1G, hasta la mitad del sistema
				local mem_total_kb
				for line in io.lines("/proc/meminfo") do
					mem_total_kb = line:match("^MemTotal:%s+(%d+)")
					if mem_total_kb then
						mem_total_kb = tonumber(mem_total_kb)
						break
					end
				end
				local mem_total_gb = mem_total_kb / 1024 / 1024
				local mem_half_gb = math.floor(mem_total_gb / 2)
				local mem_flags = "-Xms1g -Xmx" .. mem_half_gb .. "g"

				local exec_flags = mem_flags .. " -XX:+ShowCodeDetailsInExceptionMessages -cp"

				local function escape_path(path)
					return '"' .. path:gsub('"', '\\"') .. '"'
				end
				local project_dir_escaped = escape_path(project_dir)

				local compile_cmd, class_dir
				if vim.fn.filereadable(project_dir .. "/pom.xml") == 1 then -- Maven
					compile_cmd = string.format("cd %s && mvn compile", project_dir_escaped)
					class_dir = project_dir .. "/target/classes"
				elseif vim.fn.filereadable(project_dir .. "/build.gradle") == 1 then -- Gradle
					compile_cmd = string.format("cd %s && ./gradlew build", project_dir_escaped)
					class_dir = project_dir .. "/build/classes/java/main"
				else
					vim.api.nvim_err_writeln("No se detectó pom.xml ni build.gradle en el proyecto")
					return
				end

				if vim.fn.isdirectory(class_dir) ~= 1 then
					vim.api.nvim_err_writeln(
						"No se encontró el directorio con las clases compiladas, compila manualmente primero"
					)
					return
				end

				local class_dir_escaped = escape_path(class_dir)
				-- Ejecutar con assertions activadas
				local run_cmd = string.format(
					"cd %s; time java -ea %s %s %s",
					project_dir_escaped,
					exec_flags,
					class_dir_escaped,
					class
				)
				local term_cmd = string.format("clear; %s; echo '+%s'; %s\n", compile_cmd, run_cmd, run_cmd)

				local function close_previous_run()
					if _G.java_term_win and vim.api.nvim_win_is_valid(_G.java_term_win) then
						vim.api.nvim_win_close(_G.java_term_win, true)
					end
					if _G.java_term_job_id then
						vim.fn.jobstop(_G.java_term_job_id)
						_G.java_term_job_id = nil
					end
				end

				local function run_in_terminal(cmd)
					close_previous_run()
					create_terminal()
					vim.api.nvim_chan_send(_G.java_term_job_id, cmd)
				end

				run_in_terminal(term_cmd)
			end, { noremap = true, silent = false })

			-- Keymap para togglear
			vim.keymap.set("n", "<localleader>t", ToggleJavaTerminal, { noremap = true, silent = true })
		end,
	},
}
