# mine_conf

One folder, one script: my complete Hyprland rice for **CachyOS** (works on any
Arch-based distro). Everything is here — Hyprland, Waybar, mako, kitty,
alacritty, ghostty, wofi, tmux, zsh + Starship, Neovim, fonts, wallpapers and
the little helper scripts the bar depends on.

## Quick start

```bash
cd ~/mine_conf
./install.sh
```

Log out and back in when it finishes. That's it.

### Options

| Flag | What it does |
| --- | --- |
| `--dry-run` | Print every action, change nothing |
| `--no-packages` | Configs only (packages already installed) |
| `--no-configs` | Packages only |
| `--no-apps` | Skip Firefox, Brave and Discord |
| `--no-nvim` | Skip the headless Neovim plugin bootstrap |
| `--iwd` | Make iwd the NetworkManager Wi-Fi backend (needed by `impala`) |
| `--help` | Show usage |

Typical re-apply after editing a config:

```bash
./install.sh --no-packages --no-nvim
```

## What the script does

1. **Packages** — 72 packages from the CachyOS/Arch repos (Hyprland stack,
   Waybar, terminals, tmux/zsh, fonts, audio, Bluetooth, NetworkManager,
   screenshot/clipboard tools, daily CLI tools, plus Firefox/Brave/Discord).
   Missing AUR packages are installed with `yay`/`paru` if available.
2. **Oh My Zsh** — installed unattended if `~/.oh-my-zsh` is absent.
3. **Backups** — anything that would be overwritten is copied to
   `~/.mine_conf-backups/<timestamp>/` first (only files that actually differ).
4. **Configs** — `config/*` → `~/.config/*`, `home/*` → `~/.`.
5. **Wallpaper** — detects the connected monitor name (e.g. `eDP-1`) and
   renders `hyprpaper.conf` with a real absolute wallpaper path.
6. **Services** — enables NetworkManager, Bluetooth, mako and hypridle.
7. **Fonts** — refreshes the font cache and checks for JetBrainsMono Nerd Font.
8. **Shell** — switches the login shell to zsh when needed.
9. **tmux** — clones TPM and installs resurrect / continuum / sensible.
10. **Neovim** — boots `nvim --headless` once so `vim.pack` restores plugins
    from `nvim-pack-lock.json`.
11. **Verify** — runs `hyprctl configerrors` when inside a Hyprland session.

## Layout

```
mine_conf/
├── install.sh              # the only thing you run
├── README.md
├── config/                 # becomes ~/.config/
│   ├── hypr/               # hyprland.conf, hyprlock, hypridle, hyprpaper, mocha colors
│   │   └── scripts/        # clipboard-history, dnd-toggle, idle-toggle, toggle-waybar
│   ├── waybar/             # config, style.css, mocha.css, scripts/
│   ├── kitty/              # kitty.conf + Catppuccin Mocha
│   ├── alacritty/          # alacritty.toml + Catppuccin Mocha
│   ├── ghostty/            # config
│   ├── wofi/               # launcher config + style
│   ├── mako/               # notification theme + Do Not Disturb mode
│   ├── micro/              # editor settings
│   ├── nvim/               # init.lua + lua/ + pack lock (plugins rebuilt on first run)
│   ├── backgrounds/        # lock-screen wallpaper
│   ├── starship.toml       # Catppuccin Mocha prompt
│   └── xdg-terminals.list  # kitty as default terminal
├── home/
│   ├── .tmux.conf          # Ctrl+a prefix, vim keys, resurrect/continuum, cheatsheet
│   └── .zshrc              # omz, autosuggestions, zoxide, Starship, tat(), conda guard
└── wallpapers/
    └── jet-trail.jpg       # installed to ~/.config/backgrounds/
```

## Keys

| Keys | Action |
| --- | --- |
| `Super + Q` | kitty |
| `Super + E` | nautilus |
| `Super + R` | wofi launcher |
| `Super + C` | close window |
| `Super + F` | fullscreen |
| `Super + Shift + L` | lock (hyprlock) |
| `Super + V` | clipboard history (cliphist + wofi) |
| `Ctrl + Esc` | hide/show Waybar |
| `Print` | screenshot (output) |
| `Shift + Print` | screenshot (region) |
| `Super + Print` | screenshot (window) |
| `Ctrl + .` | Do Not Disturb toggle |
| `Ctrl + Super + I` | pause/resume idle actions |
| `Ctrl + ,` | clear notifications |
| `Super + 1..0` | workspaces |
| `Super + H/J/K/L` | focus left/down/up/right |
| `Super + Ctrl + H/J/K/L` | resize window |
| `Super + S` | scratchpad |

tmux: prefix is `Ctrl+a` (fallback `Ctrl+\`), `|` / `-` split, `Ctrl+h/j/k/l`
pane navigation (nvim-aware), `prefix + ?` opens the cheatsheet, `prefix + I`
installs plugins.

## Notes

- **Wi-Fi / impala** — Waybar's network icon opens `impala`, which drives
  `iwd`. Run `./install.sh --iwd` once (or
  `sudo ~/.config/waybar/scripts/setup-iwd.sh`) to switch NetworkManager's
  backend. If your card dislikes iwd, right-click the icon to toggle Wi-Fi and
  use `~/.config/waybar/scripts/wifi-menu` (rofi + nmcli) instead.
- **Monitor** — `hyprland.conf` uses `preferred` mode at scale `1.2`, so it
  adapts to any panel. The installer fills in `hyprpaper.conf` with the first
  connected output; edit it if you have several monitors.
- **Conda** — the `.zshrc` block only activates when miniconda/anaconda exists
  under `~/Storage`, `~/miniconda3` or `~/anaconda3`.
- **Neovim** — `pack/` is intentionally not bundled (70 MB). The lock file
  restores every plugin on first launch.
- **Restore a backup** — configs are plain copies, so:
  `cp -a ~/.mine_conf-backups/<timestamp>/. ~/`
