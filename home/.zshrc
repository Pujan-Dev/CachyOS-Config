# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme is handled by Starship (see the bottom of this file), so the
# Oh My Zsh theme is disabled to avoid a double prompt.
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change the frequency the auto-updater is run (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line to set how old an update must be before it's applied, manually or via the auto-updater (in days).
# zstyle ':omz:update' cooldown 10

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
if [[ -d "$ZSH" ]]; then
    plugins=(git sudo extract z)
    source "$ZSH/oh-my-zsh.sh"
else
    # Oh My Zsh is missing (fresh machine): keep completion working anyway.
    autoload -Uz compinit && compinit -i
fi

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# ─────────────────────────────────────────────────────────────────────────────
# HISTORY
# ─────────────────────────────────────────────────────────────────────────────

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS INC_APPEND_HISTORY SHARE_HISTORY

# ─────────────────────────────────────────────────────────────────────────────
# PLUGINS (system packages)
# ─────────────────────────────────────────────────────────────────────────────

[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] \
  && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

[ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ] \
  && source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# Syntax highlighting must be sourced last (before the prompt).
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] \
  && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ─────────────────────────────────────────────────────────────────────────────
# EDITOR
# ─────────────────────────────────────────────────────────────────────────────

export EDITOR="nvim"
export VISUAL="nvim"

# ─────────────────────────────────────────────────────────────────────────────
# TMUX
#   tat [name] — attach to (or create) a tmux session for the current folder.
#                The session is named after the folder you're standing in, so
#                each project gets its own session and its panes start in $PWD.
# ─────────────────────────────────────────────────────────────────────────────

tat() {
  local name="${1:-${PWD:t}}"
  name="${name//[^[:alnum:]_-]/_}"   # tmux is happier without odd characters
  [[ -z "$name" ]] && name="tmux"

  if [[ -n "$TMUX" ]]; then
    # Already inside tmux: create the session in the background if needed,
    # then jump to it instead of trying to nest a client.
    tmux has-session -t "=$name" 2>/dev/null \
      || tmux new-session -d -s "$name" -c "$PWD"
    tmux switch-client -t "=$name"
  else
    tmux new-session -A -s "$name" -c "$PWD"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# ZOXIDE — smart cd: `cd <name>` jumps, `cdi` for interactive picker
# ─────────────────────────────────────────────────────────────────────────────

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# ─────────────────────────────────────────────────────────────────────────────
# STARSHIP PROMPT (Catppuccin Mocha — see ~/.config/starship.toml)
# ─────────────────────────────────────────────────────────────────────────────

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# >>> conda initialize >>>
# Only activates when a conda install actually exists, so a fresh machine
# without miniconda still opens a fast, clean shell.
__conda_sh=""
for __conda_dir in "$HOME/Storage/miniconda3" "$HOME/miniconda3" "$HOME/anaconda3"; do
  if [[ -f "$__conda_dir/etc/profile.d/conda.sh" ]]; then
    __conda_sh="$__conda_dir/etc/profile.d/conda.sh"
    break
  fi
done
[[ -n "$__conda_sh" ]] && source "$__conda_sh"
unset __conda_sh __conda_dir
# <<< conda initialize <<<


# OpenCode CLI (installed under ~/.opencode/bin)
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"
