-- stylua: ignore start
local MOD = "ALT"

-- Abrir documentación
hl.bind(MOD .. " + CTRL + H", hl.dsp.exec_cmd("okular ~/.dotfiles/assets/pdf/help.pdf"))

-- Copiar dibujo al portapapeles
hl.bind(MOD .. " + CTRL + D", hl.dsp.exec_cmd("pgrep canvas-draw || canvas-draw"))

-- Ocultar/Mostrar y Recargar Barra
hl.bind(MOD .. " + B", hl.dsp.exec_cmd("pkill waybar || setsid -f waybar"))
hl.bind(MOD .. " + SHIFT + B", hl.dsp.exec_cmd("killall -SIGUSR2 waybar"))

-- Lanzador de aplicaciones
hl.bind(MOD .. " + P", hl.dsp.exec_cmd("uwsm app -- rofi -show run -theme-str 'listview {lines: 10;}'"))
hl.bind(MOD .. " + SHIFT + P", hl.dsp.exec_cmd("uwsm app -- rofi -show drun -show-icons -theme-str 'listview {lines: 10;}'"))

-- Montar/desmontar dispositivos android
hl.bind(MOD .. " + F5", hl.dsp.exec_cmd("~/.dotfiles/bin/android_mounts/android-mount"))
hl.bind(MOD .. " + SHIFT + F5", hl.dsp.exec_cmd("~/.dotfiles/bin/android_mounts/android-umount"))

-- Forzar salida
hl.bind(MOD .. " + SHIFT + K", hl.dsp.exec_cmd("hyprctl kill"))
hl.bind(MOD .. " + CONTROL + K", hl.dsp.exec_cmd("pkill start-hyprland"))

-- Sistema
hl.bind(MOD .. " + F11", hl.dsp.exec_cmd("powermenu"))
hl.bind(MOD .. " + L", hl.dsp.exec_cmd("lock"))

-- Activar/desactivar decoraciones
-- TODO: Usar lua en vez de un script de bash
--
-- hl.bind(
--     MOD .. " + F12",
--     hl.dsp.exec_cmd("~/.dotfiles/bin/hyprland/toggle-decorations")
-- )

-- Cambiar layout
hl.bind(MOD .. " + SHIFT + E", function()
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
hl.bind(MOD .. " + E", hl.dsp.window.fullscreen({ mode = 0 }))

-- Master/Stack
hl.bind(MOD .. " + SHIFT + minus", hl.dsp.layout("swapwithmaster master"))
hl.bind(MOD .. " + minus", hl.dsp.layout("focusmaster"))
hl.bind(MOD .. " + J", hl.dsp.layout("addmaster"))
hl.bind(MOD .. " + K", hl.dsp.layout("removemaster"))
hl.bind(MOD .. " + U", hl.dsp.layout("mfact -0.05"))
hl.bind(MOD .. " + I", hl.dsp.layout("mfact +0.05"))

-- Gestionar ventanas
hl.bind(MOD .. " + SHIFT + Q", hl.dsp.exec_cmd("hyprclose"))
hl.bind(MOD .. " + CONTROL + S", hl.dsp.window.pin())
hl.bind(MOD .. " + Q", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(MOD .. " + W", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(MOD .. " + Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind(MOD .. " + SHIFT + space", hl.dsp.window.float())

-- Scratchpad
hl.bind(MOD .. " + SHIFT + S", hl.dsp.exec_cmd("~/.dotfiles/bin/hyprland/switch-scratchpad"))
hl.bind(MOD .. " + S", function()
	hl.dispatch(hl.dsp.workspace.toggle_special("scratch"))
	hl.exec_cmd("swaync-client -cp")
end)

-- Mover/redimensionar ventanas con MOD + LMB/RMB (arrastrando)
hl.bind(MOD .. " + CTRL + mouse:272", hl.dsp.window.drag())
hl.bind(MOD .. " + CTRL + mouse:273", hl.dsp.window.resize())

-- Cambiar foco
hl.bind(MOD .. " + comma", hl.dsp.exec_cmd("~/.dotfiles/bin/hyprland/cycle-windows prev"))
hl.bind(MOD .. " + period",	hl.dsp.exec_cmd("~/.dotfiles/bin/hyprland/cycle-windows next"))

-- Mover ventanas
hl.bind(MOD .. " + SHIFT + comma", hl.dsp.layout("swapprev"))
hl.bind(MOD .. " + SHIFT + period", hl.dsp.layout("swapnext"))

-- Aplicaciones
hl.bind(MOD .. " + SHIFT + RETURN", hl.dsp.exec_cmd("$TERMINAL $REGULAR_OPTS"))
hl.bind(MOD .. " + F", hl.dsp.exec_cmd("$TERMINAL $SCRATCH_OPTS $TERMTITLE scratchpad"))
hl.bind(MOD .. " + F3", hl.dsp.exec_cmd("$TERMINAL $REGULAR_OPTS $TERMEXEC lf"))
hl.bind(MOD .. " + SHIFT + F3", hl.dsp.exec_cmd(" ~/.dotfiles/bin/hyprland/open-mounts-folder"))
hl.bind(MOD .. " + F2", hl.dsp.exec_cmd("uwsm app -- librewolf"))
hl.bind(MOD .. " + F4", hl.dsp.exec_cmd("uwsm app -- tauon"))

-- Control multimedia
hl.bind(MOD .. " + Z", hl.dsp.exec_cmd("music-control previous"))
hl.bind(MOD .. " + X", hl.dsp.exec_cmd("music-control next"))
hl.bind(MOD .. " + SHIFT + Z", hl.dsp.exec_cmd("music-control play-pause"))
hl.bind(MOD .. " + SHIFT + X", hl.dsp.exec_cmd("music-control play-pause"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("music-control previous"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("music-control next"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("music-control play-pause"))

-- Audio
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("volinc -n -5"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("volinc -n +5"))
hl.bind(MOD .. " + N", hl.dsp.exec_cmd("volinc -n -5"))
hl.bind(MOD .. " + M", hl.dsp.exec_cmd("volinc -n +5"))

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind(MOD .. " + CONTROL + N", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind(MOD .. " + CONTROL + M", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))

hl.bind(MOD .. " + SHIFT + N", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ 40%"))
hl.bind(MOD .. " + SHIFT + M", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ 60%"))

hl.bind(MOD .. " + SHIFT + A", hl.dsp.exec_cmd("~/.dotfiles/bin/virtualmic/virtualmic-select"))
hl.bind(MOD .. " + A", hl.dsp.exec_cmd("~/.dotfiles/bin/hyprland/audio_panel-toggle"))

-- Portátil — Brillo/Micrófono
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightchange dec"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightchange inc"))
hl.bind("SHIFT + XF86MonBrightnessUp", hl.dsp.dpms({ action = "on" }))
hl.bind("SHIFT + XF86MonBrightnessDown", hl.dsp.dpms({ action = "off" }))

-- Capturas de pantalla
hl.bind("Print", hl.dsp.exec_cmd("screenshot all_clip"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("screenshot selection_clip"))
hl.bind(MOD .. " + O", hl.dsp.exec_cmd("screenshot all_clip"))
hl.bind(MOD .. " + SHIFT + O", hl.dsp.exec_cmd("screenshot selection_clip"))
hl.bind(MOD .. " + CONTROL + O", hl.dsp.exec_cmd("screenshot all_save"))
hl.bind(MOD .. " + SHIFT + CONTROL + O", hl.dsp.exec_cmd("screenshot selection_save"))
hl.bind(MOD .. " + SHIFT + I", hl.dsp.exec_cmd("hyprshot --clipboard-only -m window"))
hl.bind(MOD .. " + SHIFT + CONTROL + I", hl.dsp.exec_cmd("hyprshot -m window"))

-- Workspaces
hl.bind(MOD .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(MOD .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(MOD .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(MOD .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(MOD .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(MOD .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(MOD .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(MOD .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(MOD .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(MOD .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(MOD .. " + apostrophe", hl.dsp.focus({ workspace = 11 }))
hl.bind(MOD .. " + exclamdown", hl.dsp.focus({ workspace = 12 }))
hl.bind(MOD .. " + KP_End", hl.dsp.focus({ workspace = 13 }))
hl.bind(MOD .. " + KP_Down", hl.dsp.focus({ workspace = 14 }))
hl.bind(MOD .. " + KP_Page_Down", hl.dsp.focus({ workspace = 15 }))
hl.bind(MOD .. " + KP_Left", hl.dsp.focus({ workspace = 16 }))
hl.bind(MOD .. " + KP_Begin", hl.dsp.focus({ workspace = 17 }))
hl.bind(MOD .. " + KP_Right", hl.dsp.focus({ workspace = 18 }))
hl.bind(MOD .. " + Left", hl.dsp.focus({ workspace = 13 }))
hl.bind(MOD .. " + Down", hl.dsp.focus({ workspace = 14 }))
hl.bind(MOD .. " + Right", hl.dsp.focus({ workspace = 15 }))
hl.bind(MOD .. " + Prior", hl.dsp.focus({ workspace = 16 }))
hl.bind(MOD .. " + Up", hl.dsp.focus({ workspace = 17 }))
hl.bind(MOD .. " + Next", hl.dsp.focus({ workspace = 18 }))
hl.bind(MOD .. " + SHIFT + 1", hl.dsp.window.move({ follow = false, workspace = 1 }))
hl.bind(MOD .. " + SHIFT + 2", hl.dsp.window.move({ follow = false, workspace = 2 }))
hl.bind(MOD .. " + SHIFT + 3", hl.dsp.window.move({ follow = false, workspace = 3 }))
hl.bind(MOD .. " + SHIFT + 4", hl.dsp.window.move({ follow = false, workspace = 4 }))
hl.bind(MOD .. " + SHIFT + 5", hl.dsp.window.move({ follow = false, workspace = 5 }))
hl.bind(MOD .. " + SHIFT + 6", hl.dsp.window.move({ follow = false, workspace = 6 }))
hl.bind(MOD .. " + SHIFT + 7", hl.dsp.window.move({ follow = false, workspace = 7 }))
hl.bind(MOD .. " + SHIFT + 8", hl.dsp.window.move({ follow = false, workspace = 8 }))
hl.bind(MOD .. " + SHIFT + 9", hl.dsp.window.move({ follow = false, workspace = 9 }))
hl.bind(MOD .. " + SHIFT + 0", hl.dsp.window.move({ follow = false, workspace = 10 }))
hl.bind(MOD .. " + SHIFT + apostrophe", hl.dsp.window.move({ follow = false, workspace = 11 }))
hl.bind(MOD .. " + SHIFT + exclamdown", hl.dsp.window.move({ follow = false, workspace = 12 }))
hl.bind(MOD .. " + SHIFT + KP_End", hl.dsp.window.move({ follow = false, workspace = 13 }))
hl.bind(MOD .. " + SHIFT + KP_Down", hl.dsp.window.move({ follow = false, workspace = 14 }))
hl.bind(MOD .. " + SHIFT + KP_Page_Down", hl.dsp.window.move({ follow = false, workspace = 15 }))
hl.bind(MOD .. " + SHIFT + KP_Left", hl.dsp.window.move({ follow = false, workspace = 16 }))
hl.bind(MOD .. " + SHIFT + KP_Begin", hl.dsp.window.move({ follow = false, workspace = 17 }))
hl.bind(MOD .. " + SHIFT + KP_Right", hl.dsp.window.move({ follow = false, workspace = 18 }))
hl.bind(MOD .. " + SHIFT + Left", hl.dsp.window.move({ follow = false, workspace = 13 }))
hl.bind(MOD .. " + SHIFT + Down", hl.dsp.window.move({ follow = false, workspace = 14 }))
hl.bind(MOD .. " + SHIFT + Right", hl.dsp.window.move({ follow = false, workspace = 15 }))
hl.bind(MOD .. " + SHIFT + Prior", hl.dsp.window.move({ follow = false, workspace = 16 }))
hl.bind(MOD .. " + SHIFT + Up", hl.dsp.window.move({ follow = false, workspace = 17 }))
hl.bind(MOD .. " + SHIFT + Next", hl.dsp.window.move({ follow = false, workspace = 18 }))
-- stylua: ignore end
