export ZSH="/home/mikael/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# TMUX -Automatically start tmux
ZSH_TMUX_AUTOSTART=true

# Enable command auto-correction.
ENABLE_CORRECTION="true"

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

plugins=(git node tmux zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

## FZF FUNCTIONS ##

# fo [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fo() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# fh [FUZZY PATTERN] - Search in command history
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# fbr [FUZZY PATTERN] - Checkout specified branch
# Include remote branches, sorted by most recent commit and limited to 30
fgb() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# tm [SESSION_NAME | FUZZY PATTERN] - create new tmux session, or switch to existing one.
# Running `tm` will let you fuzzy-find a session mame
# Passing an argument to `ftm` will switch to that session if it exists or create it otherwise
ftm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}

# tm [SESSION_NAME | FUZZY PATTERN] - delete tmux session
# Running `tm` will let you fuzzy-find a session mame to delete
# Passing an argument to `ftm` will delete that session if it exists
ftmk() {
  if [ $1 ]; then
    tmux kill-session -t "$1"; return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux kill-session -t "$session" || echo "No session found to delete."
}

# fuzzy grep via rg and open in vim with line number
fgr() {
  local file
  local line

  read -r file line <<<"$(rg --no-heading --line-number $@ | fzf -0 -1 | awk -F: '{print $1, $2}')"

  if [[ -n $file ]]
  then
     vim $file +$line
  fi
}


# Preferred editor
EDITOR='nvim'

# Set location of z installation
$HOME/z.sh

# Aliases
alias y="yarn"
alias yd="yarn dev"
alias ys="set BROWSER=NONE && yarn start"
alias yc="yarn test:coverage"
alias yu="yarn test:update"
alias yw="yarn test:watch"
alias yj="yarn json-server"
alias g:clear="git branch | grep -v 'master' | grep -v 'development' | xargs git branch -D"
alias dual-monitor="xrandr --output HDMI2 --right-of eDP1 --auto"
alias mux=tmuxinator
alias shot="gnome-screenshot -i &"
eval "$(pyenv init -)"

# Reload ~/.tmux/.tmux.conf
tmux source-file ~/.tmux/.tmux.conf

# Mapping .nvm in zsh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

source ~/.profile

# Set Path to Ruby
export PATH="/home/mikael/.gem/ruby/2.7.0/bin:$PATH"

# Enabled true color support for terminals
export NVIM_TUI_ENABLE_TRUE_COLOR=1
fpath=($fpath "/home/mikael/.zfunctions")

