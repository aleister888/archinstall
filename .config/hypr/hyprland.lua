hl.env("HIDE_NOTIFICATIONS", "swaync-client --hide-all")
hl.env("HYPRSUNSET_CMD", "hyprsunset -t 4000 -g 80")
hl.env("INITIAL_WORKSPACE", "2")

require("hyprland.keybindings")
require("hyprland.appearance")
require("hyprland.monitors")
require("hyprland.windowrules")

hl.config({
	misc = {
		disable_hyprland_logo = true,
		enable_anr_dialog = false,
		enable_swallow = true,
		swallow_regex = "^kitty$",
	},
})

hl.config({
	master = {
		new_status = "slave",
		mfact = 0.5,
	},
})

hl.config({
	input = {
		kb_layout = "es",
		repeat_rate = 50,
		repeat_delay = 300,
		accel_profile = "flat",
		sensitivity = 0.6,

		touchpad = {
			natural_scroll = false,
			disable_while_typing = false,
		},
	},
})

hl.gesture({
	fingers = 4,
	direction = "vertical",
	action = function()
		hl.exec_cmd("lock")
	end,
})

hl.config({
	binds = {
		scroll_event_delay = 300,
	},
})

hl.config({
	ecosystem = {
		no_update_news = true,
	},
})

-- stylua: ignore start
hl.on("hyprland.start", function()
	hl.exec_cmd("~/.dotfiles/bin/hyprland/apply-gsettings")
	hl.exec_cmd("dconf write /org/gnome/desktop/interface/color-scheme \"'prefer-dark'\"")
	hl.exec_cmd("xrdb ~/.config/Xresources")
	hl.exec_cmd("systemctl --user start swaync")
	hl.exec_cmd("uwsm app -- /usr/lib/geoclue-2.0/demos/agent")
	hl.exec_cmd("uwsm app -- gnome-keyring-daemon --start --foreground --components=secrets")
	hl.exec_cmd("nwg-look -a")
	-- hl.exec_cmd("uwsm app -- wl-clip-persist --clipboard regular")
	hl.exec_cmd("uwsm app -- hyprpaper")
	hl.exec_cmd("uwsm app -- file-handler")
	hl.exec_cmd("uwsm app -- $HYPRSUNSET_CMD")
	hl.exec_cmd("uwsm app -- ~/.dotfiles/bin/virtualmic/sink-check")
	hl.exec_cmd("uwsm app -- ~/.dotfiles/bin/hyprland/autostart")
	hl.exec_cmd("uwsm app -- ~/.dotfiles/bin/hyprland/hyprland-socket2")
	hl.exec_cmd("~/.dotfiles/bin/virtualmic/virtualmic-setup")
	hl.exec_cmd("~/.dotfiles/bin/swaync/presentation-toggle")
	hl.exec_cmd('eval "$(ssh-agent -s)"')
	hl.dispatch(hl.dsp.focus({ workspace = os.getenv("INITIAL_WORKSPACE") }))
	hl.exec_cmd("setsid -f hyprpm reload")
	hl.exec_cmd("rm -f ~/.cache/wofi*")

	-- Debe ejecutarse siempre al final
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")
end)
-- stylua: ignore end
