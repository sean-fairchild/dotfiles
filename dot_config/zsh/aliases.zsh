# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias vi=nvim
alias n=nvim
alias zshrc="n ~/.zshrc"
alias vimrc="n ~/.config/nvim/init.lua"
alias za="zellij attach --create ${PWD##*/}"

alias kx=kubectx

# JJ aliases

alias jjf="jj git fetch"
alias jjs="jj st"
alias jjn="jj git fetch && jj new 'trunk()'"

# AWSD
alias lmdev="awsd lmdev"
alias lmdev_new="awsd lmdev_new"
alias lmdev_admin_new="awsd lmdev_admin_new"
alias lmqa="awsd lmqa"
alias lmprod="awsd lmprod"

