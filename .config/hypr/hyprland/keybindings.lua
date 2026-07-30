local config = require("hyprland/config")
local decorations_enabled = true

-- stylua: ignore start
local repo_dir = os.getenv("REPO_DIR") or (os.getenv("HOME") .. "/.dotfiles")
local waybar_css_src_on  = repo_dir .. "/assets/configs/apps/waybar/box_decorations.css"
local waybar_css_src_off = repo_dir .. "/assets/configs/apps/waybar/box_simple.css"
local waybar_css_dst     = os.getenv("HOME") .. "/.config/waybar/waybar_box.css"
-- stylua: ignore end

local function toggle_decorations()
	if decorations_enabled then -- ocultando
		hl.config({
			general = { gaps_in = 0, gaps_out = 0 },
			decoration = { rounding = 0 },
			plugin = {
				-- bug: window top pixels cant be clicked if bar_height is not set to 0
				hyprbars = { enabled = false, bar_height = 0 },
				hyprfocus = { enable = false },
			},
			animations = { enabled = false },
		})
		os.execute(string.format('rm -f "%s"', waybar_css_dst))
		os.execute(
			string.format('cp -f "%s" "%s"', waybar_css_src_off, waybar_css_dst)
		)
	else -- mostrando
		hl.config({
			general = { gaps_in = config.gaps_in, gaps_out = config.gaps_out },
			decoration = { rounding = config.rounding },
			plugin = {
				hyprbars = { enabled = true, bar_height = config.hyprbar_height },
				hyprfocus = { enable = true },
			},
			animations = { enabled = true },
		})
		os.execute(string.format('rm -f "%s"', waybar_css_dst))
		os.execute(
			string.format('cp -f "%s" "%s"', waybar_css_src_on, waybar_css_dst)
		)
	end

	os.execute("pkill -SIGUSR2 waybar 2>/dev/null || true")
	decorations_enabled = not decorations_enabled
end

hl.bind(config.mod .. " + F12", function()
	toggle_decorations()
end)

-- stylua: ignore start
-- Abrir documentación
hl.bind(config.mod .. " + CTRL + H", hl.dsp.exec_cmd("okular ~/.dotfiles/assets/pdf/help.pdf"))

-- Copiar dibujo al portapapeles
hl.bind(config.mod .. " + CTRL + D", hl.dsp.exec_cmd("pgrep canvas-draw || canvas-draw"))

-- Ocultar/Mostrar y Recargar Barra
hl.bind(config.mod .. " + B", hl.dsp.exec_cmd("pkill waybar || setsid -f waybar"))
hl.bind(config.mod .. " + SHIFT + B", hl.dsp.exec_cmd("killall -SIGUSR2 waybar"))

-- Lanzador de aplicaciones
hl.bind(config.mod .. " + P", hl.dsp.exec_cmd("uwsm app -- rofi -show run -theme-str 'listview {lines: 10;}'"))
hl.bind(config.mod .. " + SHIFT + P", hl.dsp.exec_cmd("uwsm app -- rofi -show drun -show-icons -theme-str 'listview {lines: 10;}'"))

-- Montar/desmontar dispositivos android
hl.bind(config.mod .. " + F5", hl.dsp.exec_cmd("~/.dotfiles/bin/android_mounts/android-mount"))
hl.bind(config.mod .. " + SHIFT + F5", hl.dsp.exec_cmd("~/.dotfiles/bin/android_mounts/android-umount"))

-- Forzar salida
hl.bind(config.mod .. " + SHIFT + K", hl.dsp.exec_cmd("hyprctl kill"))
hl.bind(config.mod .. " + CONTROL + K", hl.dsp.exec_cmd("pkill start-hyprland"))

-- Sistema
hl.bind(config.mod .. " + F11", hl.dsp.exec_cmd("powermenu"))
hl.bind(config.mod .. " + L", hl.dsp.exec_cmd("lock"))

-- Cambiar layout
hl.bind(config.mod .. " + SHIFT + E", function()
	local layouts = { "master", "monocle" }
	local workspace = hl.get_active_workspace()
	if hl.get_active_special_workspace() then
		workspace = hl.get_active_special_workspace()
	end

	local next_layout

	if not workspace then
		return
	end

	for i = 1, #layouts do
		if layouts[i] == workspace.tiled_layout then
			local next_layout_idx = (i % #layouts) + 1
			next_layout = layouts[next_layout_idx]
			break
		end
	end

	if workspace.special then
		hl.workspace_rule({
			workspace = tostring(workspace.name),
			layout = next_layout,
		})
	else
		hl.workspace_rule({
			workspace = tostring(workspace.id),
			layout = next_layout,
		})
	end
end)

-- Fullscreen
hl.bind(config.mod .. " + E", hl.dsp.window.fullscreen({ mode = 0 }))

-- Master/Stack
hl.bind(config.mod .. " + SHIFT + minus", hl.dsp.layout("swapwithmaster master"))
hl.bind(config.mod .. " + minus", hl.dsp.layout("focusmaster"))
hl.bind(config.mod .. " + J", hl.dsp.layout("addmaster"))
hl.bind(config.mod .. " + K", hl.dsp.layout("removemaster"))
hl.bind(config.mod .. " + U", hl.dsp.layout("mfact -0.05"))
hl.bind(config.mod .. " + I", hl.dsp.layout("mfact +0.05"))

-- Gestionar ventanas
hl.bind(config.mod .. " + SHIFT + Q", hl.dsp.window.close({ window = "activewindow" }))
hl.bind(config.mod .. " + CONTROL + S", hl.dsp.window.pin())
hl.bind(config.mod .. " + Q", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(config.mod .. " + W", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(config.mod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind(config.mod .. " + SHIFT + space", hl.dsp.window.float())

-- Scratchpad
hl.bind(config.mod .. " + SHIFT + S", hl.dsp.exec_cmd("~/.dotfiles/bin/hyprland/switch-scratchpad"))
hl.bind(config.mod .. " + S", function()
	hl.dispatch(hl.dsp.workspace.toggle_special("scratch"))
	hl.exec_cmd("swaync-client -cp")
end)

-- Mover/redimensionar ventanas con MOD + LMB/RMB (arrastrando)
hl.bind(config.mod .. " + CTRL + mouse:272", hl.dsp.window.drag())
hl.bind(config.mod .. " + CTRL + mouse:273", hl.dsp.window.resize())

-- Cambiar foco
hl.bind(config.mod .. " + comma", hl.dsp.exec_cmd("~/.dotfiles/bin/hyprland/cycle-windows prev"))
hl.bind(config.mod .. " + period",	hl.dsp.exec_cmd("~/.dotfiles/bin/hyprland/cycle-windows next"))

-- Mover ventanas
hl.bind(config.mod .. " + SHIFT + comma", hl.dsp.layout("swapprev"))
hl.bind(config.mod .. " + SHIFT + period", hl.dsp.layout("swapnext"))

-- Aplicaciones
hl.bind(config.mod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("$TERMINAL $REGULAR_OPTS"))
hl.bind(config.mod .. " + F", hl.dsp.exec_cmd("$TERMINAL $SCRATCH_OPTS $TERMTITLE scratchpad"))
hl.bind(config.mod .. " + F3", hl.dsp.exec_cmd("$TERMINAL $REGULAR_OPTS $TERMEXEC lf"))
hl.bind(config.mod .. " + SHIFT + F3", hl.dsp.exec_cmd(" ~/.dotfiles/bin/hyprland/open-mounts-folder"))
hl.bind(config.mod .. " + F2", hl.dsp.exec_cmd("uwsm app -- librewolf"))
hl.bind(config.mod .. " + F4", hl.dsp.exec_cmd("uwsm app -- tauon"))

-- Control multimedia
hl.bind(config.mod .. " + Z", hl.dsp.exec_cmd("music-control previous"))
hl.bind(config.mod .. " + X", hl.dsp.exec_cmd("music-control next"))
hl.bind(config.mod .. " + SHIFT + Z", hl.dsp.exec_cmd("music-control play-pause"))
hl.bind(config.mod .. " + SHIFT + X", hl.dsp.exec_cmd("music-control play-pause"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("music-control previous"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("music-control next"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("music-control play-pause"))

-- Audio
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("volinc -n -5"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("volinc -n +5"))
hl.bind(config.mod .. " + N", hl.dsp.exec_cmd("volinc -n -5"))
hl.bind(config.mod .. " + M", hl.dsp.exec_cmd("volinc -n +5"))

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind(config.mod .. " + CONTROL + N", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind(config.mod .. " + CONTROL + M", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))

hl.bind(config.mod .. " + SHIFT + N", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ 40%"))
hl.bind(config.mod .. " + SHIFT + M", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ 60%"))

hl.bind(config.mod .. " + SHIFT + A", hl.dsp.exec_cmd("~/.dotfiles/bin/virtualmic/virtualmic-select"))
hl.bind(config.mod .. " + A", hl.dsp.exec_cmd("~/.dotfiles/bin/hyprland/audio_panel-toggle"))

-- Portátil — Brillo/Micrófono
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightchange dec"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightchange inc"))
hl.bind("SHIFT + XF86MonBrightnessUp", hl.dsp.dpms({ action = "on" }))
hl.bind("SHIFT + XF86MonBrightnessDown", hl.dsp.dpms({ action = "off" }))

-- Capturas de pantalla
hl.bind("Print", hl.dsp.exec_cmd("screenshot all_clip"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("screenshot selection_clip"))
hl.bind(config.mod .. " + O", hl.dsp.exec_cmd("screenshot all_clip"))
hl.bind(config.mod .. " + SHIFT + O", hl.dsp.exec_cmd("screenshot selection_clip"))
hl.bind(config.mod .. " + CONTROL + O", hl.dsp.exec_cmd("screenshot all_save"))
hl.bind(config.mod .. " + SHIFT + CONTROL + O", hl.dsp.exec_cmd("screenshot selection_save"))
hl.bind(config.mod .. " + SHIFT + I", hl.dsp.exec_cmd("hyprshot --clipboard-only -m window"))
hl.bind(config.mod .. " + SHIFT + CONTROL + I", hl.dsp.exec_cmd("hyprshot -m window"))

-- Workspaces
hl.bind(config.mod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(config.mod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(config.mod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(config.mod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(config.mod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(config.mod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(config.mod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(config.mod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(config.mod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(config.mod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(config.mod .. " + apostrophe", hl.dsp.focus({ workspace = 11 }))
hl.bind(config.mod .. " + exclamdown", hl.dsp.focus({ workspace = 12 }))
hl.bind(config.mod .. " + KP_End", hl.dsp.focus({ workspace = 13 }))
hl.bind(config.mod .. " + KP_Down", hl.dsp.focus({ workspace = 14 }))
hl.bind(config.mod .. " + KP_Page_Down", hl.dsp.focus({ workspace = 15 }))
hl.bind(config.mod .. " + KP_Left", hl.dsp.focus({ workspace = 16 }))
hl.bind(config.mod .. " + KP_Begin", hl.dsp.focus({ workspace = 17 }))
hl.bind(config.mod .. " + KP_Right", hl.dsp.focus({ workspace = 18 }))
hl.bind(config.mod .. " + Left", hl.dsp.focus({ workspace = 13 }))
hl.bind(config.mod .. " + Down", hl.dsp.focus({ workspace = 14 }))
hl.bind(config.mod .. " + Right", hl.dsp.focus({ workspace = 15 }))
hl.bind(config.mod .. " + Prior", hl.dsp.focus({ workspace = 16 }))
hl.bind(config.mod .. " + Up", hl.dsp.focus({ workspace = 17 }))
hl.bind(config.mod .. " + Next", hl.dsp.focus({ workspace = 18 }))
hl.bind(config.mod .. " + SHIFT + 1", hl.dsp.window.move({ follow = false, workspace = 1 }))
hl.bind(config.mod .. " + SHIFT + 2", hl.dsp.window.move({ follow = false, workspace = 2 }))
hl.bind(config.mod .. " + SHIFT + 3", hl.dsp.window.move({ follow = false, workspace = 3 }))
hl.bind(config.mod .. " + SHIFT + 4", hl.dsp.window.move({ follow = false, workspace = 4 }))
hl.bind(config.mod .. " + SHIFT + 5", hl.dsp.window.move({ follow = false, workspace = 5 }))
hl.bind(config.mod .. " + SHIFT + 6", hl.dsp.window.move({ follow = false, workspace = 6 }))
hl.bind(config.mod .. " + SHIFT + 7", hl.dsp.window.move({ follow = false, workspace = 7 }))
hl.bind(config.mod .. " + SHIFT + 8", hl.dsp.window.move({ follow = false, workspace = 8 }))
hl.bind(config.mod .. " + SHIFT + 9", hl.dsp.window.move({ follow = false, workspace = 9 }))
hl.bind(config.mod .. " + SHIFT + 0", hl.dsp.window.move({ follow = false, workspace = 10 }))
hl.bind(config.mod .. " + SHIFT + apostrophe", hl.dsp.window.move({ follow = false, workspace = 11 }))
hl.bind(config.mod .. " + SHIFT + exclamdown", hl.dsp.window.move({ follow = false, workspace = 12 }))
hl.bind(config.mod .. " + SHIFT + KP_End", hl.dsp.window.move({ follow = false, workspace = 13 }))
hl.bind(config.mod .. " + SHIFT + KP_Down", hl.dsp.window.move({ follow = false, workspace = 14 }))
hl.bind(config.mod .. " + SHIFT + KP_Page_Down", hl.dsp.window.move({ follow = false, workspace = 15 }))
hl.bind(config.mod .. " + SHIFT + KP_Left", hl.dsp.window.move({ follow = false, workspace = 16 }))
hl.bind(config.mod .. " + SHIFT + KP_Begin", hl.dsp.window.move({ follow = false, workspace = 17 }))
hl.bind(config.mod .. " + SHIFT + KP_Right", hl.dsp.window.move({ follow = false, workspace = 18 }))
hl.bind(config.mod .. " + SHIFT + Left", hl.dsp.window.move({ follow = false, workspace = 13 }))
hl.bind(config.mod .. " + SHIFT + Down", hl.dsp.window.move({ follow = false, workspace = 14 }))
hl.bind(config.mod .. " + SHIFT + Right", hl.dsp.window.move({ follow = false, workspace = 15 }))
hl.bind(config.mod .. " + SHIFT + Prior", hl.dsp.window.move({ follow = false, workspace = 16 }))
hl.bind(config.mod .. " + SHIFT + Up", hl.dsp.window.move({ follow = false, workspace = 17 }))
hl.bind(config.mod .. " + SHIFT + Next", hl.dsp.window.move({ follow = false, workspace = 18 }))
-- stylua: ignore end
