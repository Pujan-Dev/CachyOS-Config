#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  mine_conf — one-shot Hyprland setup for CachyOS / Arch
#
#  Installs every package this rice needs, copies all configs into place
#  (with timestamped backups), prepares fonts, wallpapers, tmux plugins and
#  the user services that Waybar/Hyprland expect.
#
#  Usage:
#     ./install.sh                 full install (packages + configs + extras)
#     ./install.sh --dry-run       show every action, change nothing
#     ./install.sh --no-packages   configs only (packages already installed)
#     ./install.sh --no-configs    packages only
#     ./install.sh --no-apps       skip browsers / Discord
#     ./install.sh --no-nvim       skip the headless Neovim plugin bootstrap
#     ./install.sh --iwd           make iwd the NetworkManager Wi-Fi backend
#                                  (needed by impala; can drop Wi-Fi on some cards)
#     ./install.sh --help
# ─────────────────────────────────────────────────────────────────────────────
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SCRIPT_DIR/config"
HOME_SRC="$SCRIPT_DIR/home"
WALL_SRC="$SCRIPT_DIR/wallpapers"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/.mine_conf-backups/$STAMP"

DRY_RUN=0
DO_PACKAGES=1
DO_CONFIGS=1
DO_APPS=1
DO_NVIM=1
DO_IWD=0

# ── pretty output ────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    B=$'\e[1m'; DIM=$'\e[2m'; R=$'\e[0m'
    GREEN=$'\e[32m'; YELLOW=$'\e[33m'; RED=$'\e[31m'; BLUE=$'\e[34m'
else
    B=''; DIM=''; R=''; GREEN=''; YELLOW=''; RED=''; BLUE=''
fi
step() { printf '\n%s==>%s %s%s%s\n' "$BLUE" "$R" "$B" "$*" "$R"; }
info() { printf '    %s\n' "$*"; }
ok()   { printf '  %s✔%s %s\n' "$GREEN" "$R" "$*"; }
warn() { printf '  %s!%s %s\n' "$YELLOW" "$R" "$*" >&2; }
die()  { printf '\n%s✖ %s%s\n' "$RED" "$*" "$R" >&2; exit 1; }
run() {
    if (( DRY_RUN )); then
        printf '  %s[dry-run]%s %s\n' "$DIM" "$R" "$*"
    else
        "$@"
    fi
}
try() {  # like run, but the caller decides what a failure means
    if (( DRY_RUN )); then
        printf '  %s[dry-run]%s %s\n' "$DIM" "$R" "$*"
        return 0
    fi
    "$@"
}
trap 'die "failed at line $LINENO (see the error above)"' ERR

# ── arguments ────────────────────────────────────────────────────────────────
usage() { sed -n '2,21p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0; }
while (( $# )); do
    case "$1" in
        --dry-run)      DRY_RUN=1 ;;
        --no-packages)  DO_PACKAGES=0 ;;
        --no-configs)   DO_CONFIGS=0 ;;
        --no-apps)      DO_APPS=0 ;;
        --no-nvim)      DO_NVIM=0 ;;
        --iwd)          DO_IWD=1 ;;
        -h|--help)      usage ;;
        *) die "unknown option: $1  (try --help)" ;;
    esac
    shift
done

# ── sanity checks ────────────────────────────────────────────────────────────
[[ $EUID -ne 0 ]] || die "run this as your normal user, not root (sudo is used when needed)"
[[ -f /etc/os-release ]] || die "cannot detect the OS"
# shellcheck disable=SC1091
. /etc/os-release
case " ${ID:-} ${ID_LIKE:-} " in
    *arch*|*cachyos*) : ;;
    *) warn "this is tuned for CachyOS/Arch (detected: ${PRETTY_NAME:-unknown})" ;;
esac
command -v pacman >/dev/null || die "pacman not found — this installer targets Arch-based systems"
[[ -d "$CONFIG_SRC" && -d "$HOME_SRC" ]] || die "config/ or home/ missing next to install.sh"

# Ask for sudo once, up front, so the run doesn't stall halfway through.
if (( ! DRY_RUN )) && (( DO_PACKAGES || DO_CONFIGS )); then
    sudo -v || die "sudo is required to install packages and enable services"
fi

# ── package lists ────────────────────────────────────────────────────────────
CORE_PKGS=(
    # Hyprland stack
    hyprland hyprpaper hypridle hyprlock hyprshot
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    polkit-kde-agent qt5ct qt6ct qt5-wayland qt6-wayland
    # bar + launchers + notifications
    waybar wofi rofi mako libnotify
    # terminals
    kitty alacritty ghostty
    # shell / prompt / tmux
    zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting
    zsh-history-substring-search starship zoxide tmux
    # clipboard, screenshots
    cliphist wl-clipboard grim slurp
    # hardware + audio + network
    brightnessctl playerctl upower acpi
    pipewire pipewire-pulse wireplumber sof-firmware alsa-utils
    pavucontrol
    networkmanager bluez bluez-utils iwd impala
    # daily tools
    btop neovim micro nautilus
    jq curl wget git base-devel less man-db unzip zip openssh
    fzf ripgrep fd eza bat
    # fonts (Nerd Font is mandatory for the glyphs in Waybar/tmux/starship)
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
)
APP_PKGS=(firefox brave-bin discord)

if (( DO_APPS == 0 )); then APP_PKGS=(); fi

pkg_in_repos() { pacman -Si "$1" >/dev/null 2>&1; }

install_packages() {
    step "Packages"
    local -a wanted=("${CORE_PKGS[@]}" "${APP_PKGS[@]}")
    local -a in_repo=() missing=()

    for p in "${wanted[@]}"; do
        if pkg_in_repos "$p"; then in_repo+=("$p"); else missing+=("$p"); fi
    done

    if ((${#in_repo[@]})); then
        info "installing ${#in_repo[@]} packages from the official repos"
        if (( ! DRY_RUN )); then sudo pacman -S --needed --noconfirm "${in_repo[@]}"; else
            printf '  %s[dry-run]%s sudo pacman -S --needed --noconfirm %s\n' "$DIM" "$R" "${in_repo[*]}"
        fi
        ok "official packages done"
    fi

    if ((${#missing[@]})); then
        local aur=""
        for h in yay paru; do command -v "$h" >/dev/null && { aur=$h; break; }; done
        if [[ -n "$aur" ]]; then
            info "installing from AUR with $aur: ${missing[*]}"
            run "$aur" -S --needed --noconfirm "${missing[@]}"
            ok "AUR packages done"
        else
            warn "not found in the repos and no AUR helper installed: ${missing[*]}"
            warn "install yay/paru and re-run, or skip these packages"
        fi
    fi
}

# ── config helpers ───────────────────────────────────────────────────────────
backup_path() {
    local target="$1"
    [[ -e "$target" ]] || return 0
    local rel="${target#"$HOME"/}"
    run mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    run cp -a "$target" "$BACKUP_DIR/$rel"
    (( DRY_RUN )) || printf '  %sbackup%s %s\n' "$DIM" "$R" "$rel"
}

changed() {  # changed <src> <dst> -> 0 if different / missing
    local src="$1" dst="$2"
    [[ -e "$dst" ]] || return 0
    if [[ -d "$src" ]]; then
        ! diff -rq "$src" "$dst" >/dev/null 2>&1
    else
        ! cmp -s "$src" "$dst"
    fi
}

copy_tree() {  # copy_tree <src-dir> <dst-dir>
    local src="$1" dst="$2"
    if changed "$src" "$dst"; then
        backup_path "$dst"
        run mkdir -p "$dst"
        run cp -a "$src/." "$dst/"
        ok "${dst#"$HOME"/}"
    else
        info "unchanged: ${dst#"$HOME"/}"
    fi
}

copy_file() {  # copy_file <src-file> <dst-file>
    local src="$1" dst="$2"
    if changed "$src" "$dst"; then
        backup_path "$dst"
        run mkdir -p "$(dirname "$dst")"
        run cp -a "$src" "$dst"
        ok "${dst#"$HOME"/}"
    else
        info "unchanged: ${dst#"$HOME"/}"
    fi
}

install_configs() {
    step "Configs"
    local d
    for d in hypr waybar kitty alacritty ghostty wofi mako micro backgrounds; do
        [[ -d "$CONFIG_SRC/$d" ]] && copy_tree "$CONFIG_SRC/$d" "$HOME/.config/$d"
    done

    # Neovim: copy the config only — never the 70 MB plugin directory, and
    # never back that directory up (vim.pack rebuilds it on first launch).
    if [[ -d "$CONFIG_SRC/nvim" ]]; then
        run mkdir -p "$HOME/.config/nvim"
        copy_file "$CONFIG_SRC/nvim/init.lua"            "$HOME/.config/nvim/init.lua"
        copy_file "$CONFIG_SRC/nvim/nvim-pack-lock.json" "$HOME/.config/nvim/nvim-pack-lock.json"
        copy_file "$CONFIG_SRC/nvim/.stylua.toml"        "$HOME/.config/nvim/.stylua.toml"
        copy_tree "$CONFIG_SRC/nvim/lua"                 "$HOME/.config/nvim/lua"
    fi

    [[ -f "$CONFIG_SRC/starship.toml" ]]      && copy_file "$CONFIG_SRC/starship.toml" "$HOME/.config/starship.toml"
    [[ -f "$CONFIG_SRC/xdg-terminals.list" ]] && copy_file "$CONFIG_SRC/xdg-terminals.list" "$HOME/.config/xdg-terminals.list"
    [[ -f "$HOME_SRC/.tmux.conf" ]]           && copy_file "$HOME_SRC/.tmux.conf" "$HOME/.tmux.conf"
    [[ -f "$HOME_SRC/.zshrc" ]]               && copy_file "$HOME_SRC/.zshrc" "$HOME/.zshrc"

    if (( ! DRY_RUN )); then
        chmod +x "$HOME"/.config/hypr/scripts/* "$HOME"/.config/waybar/scripts/* 2>/dev/null || true
        mkdir -p "$HOME/Pictures/Screenshots"
    fi
}

# ── wallpaper + hyprpaper ────────────────────────────────────────────────────
detect_monitor() {
    local name=""
    if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
        name="$(hyprctl monitors -j 2>/dev/null \
            | jq -r 'sort_by(.focused) | reverse | .[0].name // empty' 2>/dev/null || true)"
    fi
    if [[ -z "$name" ]]; then
        for d in /sys/class/drm/card*-*/status; do
            [[ -f "$d" ]] || continue
            if [[ "$(cat "$d")" == "connected" ]]; then
                name="$(basename "$(dirname "$d")")"
                name="${name#card[0-9]*-}"
                break
            fi
        done
    fi
    printf '%s' "${name:-eDP-1}"
}

setup_wallpaper() {
    step "Wallpaper"
    local monitor wall
    monitor="$(detect_monitor)"
    wall="$HOME/.config/backgrounds/jet-trail.jpg"

    if [[ -f "$WALL_SRC/jet-trail.jpg" ]]; then
        run cp -a "$WALL_SRC/jet-trail.jpg" "$wall"
    elif [[ ! -f "$wall" ]]; then
        warn "no wallpaper found — hyprpaper will use a solid colour"
        wall="$HOME/.config/backgrounds/shaded.png"
    fi

    if (( ! DRY_RUN )); then
        sed -e "s|__MONITOR__|$monitor|g" -e "s|__WALLPAPER__|$wall|g" \
            "$CONFIG_SRC/hypr/hyprpaper.conf" > "$HOME/.config/hypr/hyprpaper.conf"
    fi
    ok "monitor $monitor → ${wall#"$HOME"/}"
}

# ── post-install extras ──────────────────────────────────────────────────────
setup_services() {
    step "Services"
    local sys_units=(NetworkManager bluetooth)
    local u
    for u in "${sys_units[@]}"; do
        if systemctl list-unit-files "$u.service" >/dev/null 2>&1; then
            if try sudo systemctl enable --now "$u.service"; then
                ok "$u.service enabled"
            else
                warn "could not enable $u.service (enable it manually if needed)"
            fi
        else
            warn "$u.service not present"
        fi
    done

    # user units used by the rice
    if systemctl --user list-unit-files mako.service >/dev/null 2>&1; then
        if try systemctl --user enable --now mako.service; then
            ok "mako.service enabled"
        else
            warn "could not enable mako.service"
        fi
    fi
    if systemctl --user list-unit-files hypridle.service >/dev/null 2>&1; then
        if try systemctl --user enable hypridle.service; then
            ok "hypridle.service enabled"
        else
            warn "could not enable hypridle.service"
        fi
    fi
}

setup_fonts() {
    step "Fonts"
    if command -v fc-cache >/dev/null 2>&1; then
        run fc-cache -f
    fi
    if command -v fc-match >/dev/null 2>&1; then
        local family
        family="$(fc-match -f '%{family}' 'JetBrainsMono Nerd Font' 2>/dev/null || true)"
        if [[ "$family" == *JetBrainsMono*Nerd* ]]; then
            ok "Nerd Font available ($family)"
        else
            warn "JetBrainsMono Nerd Font not found — glyphs may show as boxes"
        fi
    fi
}

setup_shell() {
    step "Login shell"
    local current
    current="$(getent passwd "$USER" | cut -d: -f7)"
    if [[ "$current" == */zsh ]]; then
        ok "zsh is already the login shell"
    else
        info "switching $USER from $current to /usr/bin/zsh"
        if try sudo chsh -s /usr/bin/zsh "$USER"; then
            ok "shell changed — takes effect next login"
        else
            warn "chsh failed — run: sudo chsh -s /usr/bin/zsh $USER"
        fi
    fi
}

setup_omz() {
    step "Oh My Zsh"
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        ok "already installed"
        return 0
    fi
    if (( DRY_RUN )); then
        info "[dry-run] install oh-my-zsh (unattended)"
        return 0
    fi
    if command -v curl >/dev/null 2>&1 && \
       curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh \
         | RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -s -- --unattended >/dev/null 2>&1; then
        ok "oh-my-zsh installed"
    else
        warn "oh-my-zsh install failed — .zshrc falls back to plain zsh completion"
    fi
}

setup_tmux() {
    step "tmux plugins (TPM)"
    if ! command -v tmux >/dev/null 2>&1; then
        warn "tmux not installed — skipping"
        return
    fi
    local tpm="$HOME/.tmux/plugins/tpm"
    if [[ ! -d "$tpm/.git" ]]; then
        run mkdir -p "$HOME/.tmux/plugins"
        run git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm"
    fi
    if (( ! DRY_RUN )) && [[ -x "$tpm/bin/install_plugins" ]]; then
        if timeout 180 "$tpm/bin/install_plugins" >/dev/null 2>&1; then
            ok "tmux plugins installed (resurrect, continuum, sensible)"
        else
            warn "plugin install failed — open tmux and press prefix + I"
        fi
    fi
}

setup_nvim() {
    (( DO_NVIM )) || return 0
    step "Neovim plugins (vim.pack)"
    command -v nvim >/dev/null 2>&1 || { warn "nvim not installed — skipping"; return; }
    if (( DRY_RUN )); then
        info "[dry-run] nvim --headless '+qa'"
        return
    fi
    if timeout 240 nvim --headless "+qa" >/dev/null 2>&1; then
        ok "Neovim packs ready"
    else
        warn "Neovim bootstrap failed — run 'nvim' once (it retries automatically)"
    fi
}

setup_iwd() {
    (( DO_IWD )) || return 0
    step "iwd backend for NetworkManager"
    local s="$HOME/.config/waybar/scripts/setup-iwd.sh"
    [[ -x "$s" ]] || die "setup-iwd.sh missing"
    run sudo "$s"
}

verify() {
    step "Verify"
    if command -v hyprctl >/dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        local errors
        errors="$(hyprctl configerrors 2>/dev/null || true)"
        if [[ -z "$errors" ]]; then ok "Hyprland config parses with no errors"; else warn "hyprctl configerrors:"; printf '%s\n' "$errors"; fi
    else
        info "not inside a Hyprland session — log out and back in to test"
    fi
    if command -v waybar >/dev/null 2>&1; then
        if waybar --version >/dev/null 2>&1; then ok "waybar $(waybar --version 2>/dev/null | head -1)"; fi
    fi
}

summary() {
    cat <<EOF

${B}Done.${R}  Backup of anything replaced: ${DIM}${BACKUP_DIR#"$HOME"/}${R}

${B}Next steps${R}
  1. Log out and back in (Hyprland session) — or reboot.
  2. On first login: Waybar, mako and hypridle start automatically.
  3. In tmux press ${B}Ctrl+a I${R} if plugins are not there.
  4. Re-render configs any time with: ${B}./install.sh --no-packages${R}

${B}Handy keys${R}
  Super+Q      terminal (kitty)           Super+R   launcher (wofi)
  Super+E      files (nautilus)           Super+C   close window
  Ctrl+Esc     toggle Waybar              Super+Shift+L  lock
  Print        screenshot → ~/Pictures/Screenshots
  Ctrl+.       Do Not Disturb             Ctrl+Super+I  idle on/off
EOF
}

# ── main ─────────────────────────────────────────────────────────────────────
(( DRY_RUN )) && warn "dry run — nothing will be modified"
info "source: $SCRIPT_DIR"
(( DRY_RUN )) || mkdir -p "$BACKUP_DIR"

(( DO_PACKAGES )) && install_packages
(( DO_CONFIGS ))  && setup_omz
(( DO_CONFIGS ))  && { install_configs; setup_wallpaper; }
(( DO_CONFIGS ))  && { setup_services; setup_fonts; setup_shell; }
(( DO_CONFIGS ))  && { setup_tmux; setup_nvim; setup_iwd; }
(( DO_CONFIGS ))  && verify

printf '\n'
summary
