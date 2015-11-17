# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias grep='grep --color=auto'

export PS1="[\[\e[35m\u\e[0m\]@\e[33m\h\e[0m \e[36m\W\e[0m]\$ "

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export TERM=xterm-256color

