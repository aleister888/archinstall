hl.window_rule({
	name = "xwayland",
	match = {
		class = "^$",
		title = "^$",
		xwayland = 1,
		float = 1,
		fullscreen = 0,
		pin = 0,
	},
	no_focus = true,
})

hl.window_rule({
	no_blur = true,
	match = {
		xwayland = 1,
		float = 1,
	},
})

require("hyprland.windowrules.size_tags")
require("hyprland.windowrules.workspace_asign")
require("hyprland.windowrules.tag_asign")
require("hyprland.windowrules.browsers")
require("hyprland.windowrules.virtualization")
require("hyprland.windowrules.coding")
require("hyprland.windowrules.xdg_portal")
require("hyprland.windowrules.gaming")
require("hyprland.windowrules.multimedia")

hl.window_rule({
	["hyprbars:no_bar"] = true,
	rounding = 16,
	no_shadow = true,
	match = {
		class = "^(dragon-drop)$",
	},
})

-- Layer rules
hl.layer_rule({
	dim_around = true,
	match = { namespace = "[rw]ofi" },
})
hl.layer_rule({
	dim_around = true,
	match = { namespace = "swaync-control-center" },
})

-- Scratchpads
hl.window_rule({
	match = { title = "scratchpad" },
	tag = "+1/2",
	workspace = "special:scratch",
})

-- Telegram
hl.window_rule({
	name = "telegram",
	match = {
		class = "^(org.telegram.desktop)$",
		initial_title = "^(Telegram)$",
	},
	workspace = "special:scratch",
	no_screen_share = true,
	float = true,
	size = { "(monitor_w*0.2)", "(monitor_h*(1-0.1375))" },
	move = { "(monitor_w*0.025)", "(monitor_h*0.0875)" },
}) -- .025 * 2 + .0875 = .1375
hl.window_rule({
	name = "telegram_media",
	match = {
		class = "^(org.telegram.desktop)$",
		initial_title = "^(Media viewer)$",
	},
	workspace = "special:scratch",
	no_screen_share = true,
	float = true,
	no_initial_focus = false,
	center = true,
	size = { "(monitor_w*0.35)", "(monitor_h*0.75)" },
})

hl.window_rule({
	name = "clocks",
	match = {
		class = "^(org.gnome.clocks)$",
	},
	workspace = "special:scratch",
	float = true,
	size = { 700, 730 },
})

hl.window_rule({
	name = "qalculate",
	match = {
		class = "^(qalculate-gtk)$",
	},
	workspace = "special:scratch",
	float = true,
	size = { 750, 550 },
})

hl.window_rule({
	name = "lienzo",
	match = {
		title = "^(Lienzo en blanco)$",
		class = "^(Tk)$",
	},
	float = true,
	center = true,
	workspace = "special:scratch",
	size = { "(monitor_w*0.6)", "(monitor_h*0.6)" },
	border_size = 0,
	rounding = 0,
})

-- Bluetooth
hl.window_rule({
	match = {
		class = "^(blueman-manager)$",
		title = "^(Dispositivos Bluetooth)$",
	},
	tag = "+1/2",
	workspace = "special:scratch",
	no_initial_focus = false,
})
hl.window_rule({
	match = { class = "^(blueman-sendto)$" },
	float = true,
	workspace = "special:scratch",
})
hl.window_rule({
	match = { title = "^(Select files to send)$" },
	tag = "+1/2",
	dim_around = true,
})

hl.window_rule({
	name = "easyeffects",
	match = { class = "^(com.github.wwmm.easyeffects)$" },
	workspace = "special:scratch",
	float = true,
	center = true,
	size = { "(monitor_w*0.75)", "(monitor_h*0.8)" },
})

hl.window_rule({
	match = { class = "^(org.kde.gwenview)$" },
	tag = "+3/4",
	workspace = "special:scratch",
})

-- LibreOffice
hl.window_rule({
	match = {
		title = "^(LibreOffice)$",
		class = "^()$",
	},
	border_size = 0,
	rounding = 0,
	dim_around = true,
})
hl.window_rule({
	match = { class = "^(libreoffice-.*)$" },
	workspace = "4",
	tile = true,
	fullscreen_state = "0",
})
hl.window_rule({
	match = { title = "^(En ponencia: .*)$" },
	workspace = "14",
	no_initial_focus = true,
})

-- LibreLift
hl.window_rule({
	match = { title = "^(LibreLift)$" },
	float = true,
})

-- Discord
hl.window_rule({
	name = "discord",
	match = { class = "^(discord)$" },
	idle_inhibit = "fullscreen",
	workspace = "6",
	no_initial_focus = true,
	sync_fullscreen = false,
})
hl.window_rule({
	match = { initial_title = "^(Discord Popout)$" },
	no_initial_focus = true,
	pin = true,
	float = true,
})
hl.window_rule({
	match = { initial_title = "^(Discord Updater)$" },
	no_initial_focus = true,
	center = true,
	float = true,
})

hl.window_rule({
	match = { class = "^(org.pulseaudio.pavucontrol)$" },
	fullscreen_state = "1",
	workspace = "special:audio_panel",
})

hl.window_rule({
	match = { title = "^(Guardando como — Krita)$" },
	tag = "+1/2",
})

--hl.window_rule({
--	match = { class = "^(REAPER)$" },
--	workspace = "7",
--	no_initial_focus = true,
--})
--hl.window_rule({
--	name = "yabridge",
--	match = { class = "^(yabridge-host.exe.so)$" },
--	rounding = 0,
--	border_size = 0,
--	no_blur = true,
--	no_shadow = true,
--	no_anim = true,
--	no_initial_focus = true,
--})

hl.window_rule({
	match = { class = "^(LRCGET)$" },
	tag = "+2/3",
	workspace = "7",
})

-- RustDesk
hl.window_rule({
	match = { class = "^(rustdesk)$" },
	tag = "+1/2",
	workspace = "special:scratch",
	suppress_event = "maximize",
})
hl.window_rule({
	match = { title = "^(.* - Remote Desktop - RustDesk)$" },
	workspace = "6",
	tile = true,
})

-- Kdenlive
hl.window_rule({
	name = "kdenlive_first_launch",
	match = {
		class = "^(org.kde.kdenlive)$",
		title = "^(Kdenlive)$",
	},
	pseudo = true,
	workspace = "8",
	no_blur = true,
	border_size = 0,
	no_shadow = true,
})
hl.window_rule({
	name = "kdenlive",
	match = {
		class = "^(org.kde.kdenlive)$",
		title = "^(.* / .*)$",
	},
	pseudo = false,
	workspace = "8",
})
hl.window_rule({
	match = {
		class = "^(org.kde.kdenlive)$",
		title = "^(.* — Kdenlive)$",
	},
	workspace = "8",
})

-- Timeshift
hl.window_rule({
	match = { class = "^(timeshift-gtk)$" },
	tag = "+1/2",
	workspace = "8",
})
hl.window_rule({
	match = {
		class = "^(timeshift-gtk)$",
		title = "^(Restaurar instantánea)$",
	},
	tag = "+1/3",
})

-- Portal GTK (Wayland: LibreOffice)
hl.window_rule({
	match = {
		title = "^(Abrir)$",
		class = "^(soffice)$",
	},
	tag = "+1/2",
})
hl.window_rule({
	match = {
		title = "^(Guardar)$",
		class = "^(soffice)$",
	},
	tag = "+1/2",
})
hl.window_rule({
	match = {
		class = "^(soffice)$",
		title = "^(Pegado especial)$",
	},
	stay_focused = true,
})

-- Auth
hl.window_rule({
	match = { class = "^(org.keepassxc.KeePassXC)$" },
	no_screen_share = true,
})
hl.window_rule({
	name = "keepassxc_unlock",
	match = {
		class = "^(org.keepassxc.KeePassXC)$",
		title = "^(Desbloquear base de datos - KeePassXC)",
	},
	pin = true,
	center = true,
	no_initial_focus = true,
	dim_around = true,
})
hl.window_rule({
	name = "nm_password",
	match = { class = "^(nm-openconnect-auth-dialog)$" },
	pin = true,
	center = true,
	no_initial_focus = true,
	dim_around = true,
})

hl.window_rule({
	match = { class = "^(TuxGuitar)$" },
	workspace = "7",
})
hl.window_rule({
	match = {
		class = "^(TuxGuitar)$",
		title = "^(Measure errors )$",
	},
	tag = "+1/2",
})

hl.window_rule({
	match = { title = "^(Redact)$" },
	tag = "+1/2",
})

-- Disk Utility
hl.window_rule({
	match = { class = "^(org.gnome.DiskUtility)$" },
	workspace = "8",
})
hl.window_rule({
	match = {
		class = "^(org.gnome.DiskUtility)$",
		title = "^(Establecer contraseña)$",
	},
	no_screen_share = true,
})

hl.window_rule({
	match = { class = "^(Nsxiv)$" },
	tile = true,
	fullscreen_state = "0",
})

hl.window_rule({
	match = { class = "^(tauonmb)$" },
	workspace = "1",
	fullscreen_state = "0",
})

-- Keyring
hl.window_rule({
	name = "keyring_login_unlock",
	match = {
		class = "^(gcr-prompter)$",
		title = "^(Unlock Login Keyring)",
	},
	pin = true,
	center = true,
	dim_around = true,
})
hl.window_rule({
	name = "keyring_unlock",
	match = {
		class = "^(gcr-prompter)$",
		title = "^(Unlock Keyring)",
	},
	pin = true,
	center = true,
	dim_around = true,
})

hl.window_rule({
	name = "udiskie",
	match = {
		class = "^(udiskie)$",
		title = "^(udiskie)$",
	},
	no_screen_share = true,
	size = { "(monitor_w*0.25)", "(monitor_h*0.15)" },
	float = true,
	pin = true,
	center = true,
	dim_around = true,
})

-- Ajustes Generales
hl.window_rule({
	match = { class = "^(hyprpolkitagent)$" },
	dim_around = true,
})
hl.window_rule({
	match = { class = "^(hyprland-share-picker)$" },
	tag = "+1/2",
	pin = true,
})
hl.window_rule({
	match = { class = "^(input-remapper-gtk)$" },
	size = { "(monitor_w*0.66)", "(monitor_h*0.75)" },
})
