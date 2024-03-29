# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

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

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

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
plugins=(git tmux zsh-autocomplete fast-syntax-highlighting)

GITSTATUS_LOG_LEVEL=DEBUG

ZSH_TMUX_AUTOSTART=true

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=yellow"

zstyle ':autocomplete:*' min-input 1

zstyle ':autocomplete:recent-dirs' backend zoxide

source $ZSH/oh-my-zsh.sh

#compdef toggl
_toggl() {
  eval $(env COMMANDLINE="${words[1,$CURRENT]}" _TOGGL_COMPLETE=complete-zsh  toggl)
}
if [[ "$(basename -- ${(%):-%x})" != "_toggl" ]]; then
  compdef _toggl toggl
fi

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# FUNTCIONS

# --fzf--

# fzf Man search
function fman() {
	man -k . | fzf -q "$1" --prompt='man> ' --preview $'echo {} | tr -d \'()\' | awk \'{printf "%s ", $2} {print $1}\' | xargs -r man | col -bx | bat -l man -p --color always' | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
}

function ftldr() {
	tldr -l | fzf --preview 'tldr {} --color=always | bat --color=always --language=man --plain' --preview-window '50%,rounded,<50(up,border-bottom)' --prompt="ﳁ TLDR >"
}

function fzf-docs() {
	batman="man {1} | col -bx | bat -l man -p --color always"
	man -k . | sort \
		| awk -v cyan=$(tput setaf 6) -v blue=$(tput setaf 4) -v res=$(tput sgr0) -v bld=$(tput bold) '{ $1=cyan bld $1; $2=res blue;} 1' \
		| fzf -q "$1" --ansi --tiebreak=begin --prompt=' Man > ' --preview-window '50%,rounded,<50(up,border-bottom)' --preview "${batman}" \
			--bind "enter:execute(man {1})" \
			--bind "alt-c:+change-preview(cht.sh {1})+change-prompt(ﯽ Cheat > )" \
			--bind "alt-m:+change-preview(${batman})+change-prompt( Man > ')" \
			--bind "alt-t:+change-preview(tldr --color=always {1})+change-prompt(ﳁ TLDR >)"
	zle reset-prompt
}

bindkey '^[h' fzf-docs
zle -N fzf-docs

function fzf-rg(){
	declare preview='bat --color=always --style=header,numbers -H {2} {1} | grep -C3 {q}'

	while getopts ':1' x; do
		case "$x" in
			1) list_files=1
			preview='bat --color=always --style=header,numbers {1} | grep -C3 {q}'
			;;
		esac
	done
	shift $(( OPTIND -1 ))
	unset x OPTARG OPTIND

	rg --color=always -n ${list_files:+-1} "$1" 2> /dev/null |
		fzf -d: \
		--ansi \
		--query="$1" \
		--phony \
		--bind="change:reload:rg -n ${list_files:+-1} --color=always {q}" \
		--bind='enter:execute:v {1}' \
		--preview="[[ -n {1} ]] && $preview"
}

# fzf-yay integration from the fzf wiki
function yzf() {
	pos=$1
	shift
	sed "s/ /\t/g" | 
		fzf --nth=$pos --multi --history="${FZF_HISTDIR:-$XDG_STATE_HOME/fzf}/history-yzf$pos" --preview-window=60%,border-left --ansi "$@" | cut -f$pos | xargs
}

# List installable packages into fzf and install selection
function yas(){
	cache_dir="/tmp/yas-$USER"
	test "$1" = "-y" && rm -rf "$cache_dir" && shift
	mkdir -p "$cache_dir"
	preview_cache="$cache_dir/preview_{2}"
	list_cache="$cache_dir/list"
	{ test "$(cat "$list_cache$@" | wc -l)" -lt 50000 && rm "$list_cache$@"; } 2>/dev/null
	pkg=$( (cat "$list_cache$@" 2>/dev/null || { pacman --color=always -Sl "$@"; yay --color=always -Sl aur "$@" } | sed 's/ [^ ]*unknown-version[^ ]*//' | tee "$list_cache$@") |
		yzf 2 --tiebreak=index --preview="cat $preview_cache 2>/dev/null | grep -v 'Querying' | grep . || yay --color always -Si {2} | tee $preview_cache")
	if test -n "$pkg"
		then echo "Installing $pkg"
			cmd="yay -S $pkg"
			print -s "$cmd"
			eval "$cmd"
			rehash
	fi
}

# List installed packages into fzf and remove selection 
function yar(){
	pkg=$(yay --color=always -Q "$@" | yzf 1 --tiebreak=length --preview="yay --color always -Qli {1}")
	if test -n "$pkg"
		then echo "Removing $pkg..."
			cmd="yay -R --cascade --recursive $pkg"
			print -s "$cmd"
			eval "$cmd"
	fi
}

# Cd to bookmarked folders
unalias cdg 2> /dev/null
 function cdg(){
	local dest_dir=$(cdscuts_glob_echo | fzf)
	if [[ $dest_dir != '' ]]; then
		echo "$dest_dir"
		z "$dest_dir"
	fi
}

# --nnn--

# Auto cd on quit for nnn
function n(){
    # Block nesting of nnn in subshells
    if [[ "${NNNLVL:-0}" -ge 1 ]]; then
        echo "nnn is already running"
        return
    fi

    # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
    # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
    # see. To cd on quit only on ^G, remove the "export" and make sure not to
    # use a custom path, i.e. set NNN_TMPFILE *exactly* as follows:
    #     NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    # The backslash allows one to alias n to nnn if desired without making an
    # infinitely recursive alias
    \nnn "$@"

    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}

# ALIASES

# Aliases for Windows Programs

# Windows powershell
alias -g wpsh="pwsh.exe -noLogo"

# NCR Tools and Programs
alias ptest="proptest.exe &"

# Winget
alias -g wg="pwsh.exe -noprofile /c winget.exe"
alias wgf="sed -e '1,3d' <<< $(wg 'search' '--query' '`"`"') | tac | fzf" 

# Aliases for built in programs
alias mkdir="mkdir -pv" # Mkdir with default arguments
alias mount="mount | column -t" # Output mount in a more readable format

# Easier Navigation Upwards
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Aliases for default replacement programs

# Exa
alias la="exa -a --icons --group-directories-first"
alias ls="exa --icons --group-directories-first"
alias ll="exa -hl --icons --group-directories-first"
alias lt="exa -T --icons --group-directories-first"
alias llt="exa -lT --icons --group-directories-first"
alias lla="exa -ahl --icons --group-directories-first"

# bat
alias cat="bat"

# wsl-sudo
alias wudo="python3 ~/source/python/wsl-sudo/wsl-sudo.py"

# fzf
alias fzfp="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' --preview-window=right,60%,border-sharp" # Fuzzy search with file previews in bat
alias fzh="history | fzf" # Fuzzy history Search
alias fzm="fman" # Fuzzy man page search
alias fzt="ftldr" # Fuzzy tldr page search

# Path Additions
path+=('/var/lib/flatpak/exports/bin')
path+=('/home/sm185592/.cargo/bin')
path+=('/home/sm185592/.local/bin')

[ -f "/home/sm185592/.ghcup/env" ] && source "/home/sm185592/.ghcup/env" # ghcup-env

# Dotnet paths
export PATH=$PATH:$HOME/.dotnet/tools
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT

# EXPORTS

# Gpg
export GPG_TTY=$TTY

# Advertise True Colour Support
export COLORTERM=truecolor

# nnn
export NNN_FCOLORS='c1e2272e0060330fc6d6abc4'
export NNN_ARCHIVE="\\.(7z|a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzma|lzo|rar|rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)$"
export NNN_PLUG="p:preview-tui"

export LANG=en_GB.UTF-8

export MANPAGER="sh -c 'col -bx | bat -l man -p --paging always'"
export MANRORROPT="-c"

export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

# fzf
export FZF_DEFAULT_OPTS=" \
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
	--color=border:#313244"

export FZF_HISTDIR="/home/sm185592/.local/state/fzf"

# Activate Zoxide
eval "$(zoxide init zsh)"

# Zoxide alias
alias cd="z"

if [ -d "/home/sm185592/.tools/finplat-tools-shared/" ]; then

    # Ensure the GPG-Agent is started
    if ! pgrep -x -u "${USER}" gpg-agent &> /dev/null; then
	gpg-connect-agent /bye &> /dev/null
    fi

    # Add the Linux finplat-tools-shared to the path
    path+=('/home/sm185592/.tools/finplat-tools-shared/')

    # Remove the winfows finplat-tools-shared directory from the path
	export PATH=$(echo $PATH | sd ':/mnt/c/tools/finplat-tools-shared' '')
fi


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


