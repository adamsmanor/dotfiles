#!/bin/bash

##
# Set up environment variables
##

export PATH=${PATH}:${HOME}/bin
export LESS=-N
export MANPAGER="/usr/bin/less -nis"
export EDITOR=vi

alias ll="ls -Flha"
alias dir="ls -Flha"
alias ls="ls -Fa"

# define colors
C_DEFAULT="\[\e[m\]"
C_WHITE="\[\e[1m\]"
C_BLACK="\[\e[30m\]"
C_RED="\[\e[31m\]"
C_GREEN="\[\e[32m\]"
C_YELLOW="\[\e[33m\]"
C_BLUE="\[\e[34m\]"
C_PURPLE="\[\e[35m\]"
C_CYAN="\[\e[36m\]"
C_LIGHTGRAY="\[\e[37m\]"
C_DARKGRAY="\[\e[1;30m\]"
C_LIGHTRED="\[\e[1;31m\]"
C_LIGHTGREEN="\[\e[1;32m\]"
C_LIGHTYELLOW="\[\e[1;33m\]"
C_LIGHTBLUE="\[\e[1;34m\]"
C_LIGHTPURPLE="\[\e[1;35m\]"
C_LIGHTCYAN="\[\e[1;36m\]"
C_BG_BLACK="\[\e[40m\]"
C_BG_RED="\[\e[41m\]"
C_BG_GREEN="\[\e[42m\]"
C_BG_YELLOW="\[\e[43m\]"
C_BG_BLUE="\[\e[44m\]"
C_BG_PURPLE="\[\e[45m\]"
C_BG_CYAN="\[\e[46m\]"
C_BG_LIGHTGRAY="\[\e[47m\]"

# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	DEFAULT_COLOR="\033[0m"
	GIT_PROMPT_COLOR="\033[37m"
	if [ ! "${BRANCH}" == "" ]; then
		status=`git status 2>&1 | tee`
		dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
		untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
		ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
		newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
		renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
		deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
		bits=''
		if [ "${renamed}" == "0" ]; then
			bits=">${bits}"
			GIT_PROMPT_COLOR="\033[32m" # green
		fi
		if [ "${ahead}" == "0" ]; then
			bits="*${bits}"
			GIT_PROMPT_COLOR="\033[34m" # blue
		fi
		if [ "${newfile}" == "0" ]; then
			bits="+${bits}"
			GIT_PROMPT_COLOR="\033[32m" # green
		fi
		if [ "${untracked}" == "0" ]; then
			bits="?${bits}"
			GIT_PROMPT_COLOR="\033[33m" # yellow
		fi
		if [ "${deleted}" == "0" ]; then
			bits="x${bits}"
			GIT_PROMPT_COLOR="\033[31m" # red
		fi
		if [ "${dirty}" == "0" ]; then
			bits="!${bits}"
			GIT_PROMPT_COLOR="\033[35m" # purple
		fi
		if [ ! "${bits}" == "" ]; then
			bits=" ${bits}"
		fi
		echo -e "$GIT_PROMPT_COLOR[${BRANCH}${bits}]$DEFAULT_COLOR "
	else
		echo ""
	fi
}

function prompt_command {
	EXIT=$?
	local XTERM_TITLE="\e]2;\u@\H:\w\a"
 
	local BGJOBS_COLOR="$C_DARKGRAY"
	local BGJOBS=""
	if [ "$(jobs | head -c1)" ]; then BGJOBS=" $BGJOBS_COLOR(bg:\j)"; fi
 
	local DOLLAR_COLOR="$C_GREEN"
	if [[ ${EUID} == 0 ]] ; then DOLLAR_COLOR="$C_RED"; fi
	local DOLLAR="$DOLLAR_COLOR\\\$"
 
	local USER_COLOR="$C_GREEN"
	if [[ ${EUID} == 0 ]]; then USER_COLOR="$C_BG_RED$C_BLACK"; fi
 
	local ARROW_COLOR="$C_GREEN"
	if [[ $EXIT != 0 ]]; then ARROW_COLOR="$C_RED"; fi
	arrow_character=$'\xe2\x86\x92'
	local ARROW="$ARROW_COLOR$arrow_character "

	local GIT="\`parse_git_branch\`"

	local SHORTPATH="\`echo \"${PWD/$HOME/~}\" | sed \"s:\([^/]\)[^/]*/:\1/:g\"\`"

	PS1="$XTERM_TITLE$ARROW$USER_COLOR\u$C_GREEN\[\e[m\] $C_CYAN$SHORTPATH$C_DEFAULT $GIT\n$DOLLAR$BGJOBS \[\e[m\]"
}
export PROMPT_COMMAND=prompt_command

# taken from http://www.cyberciti.biz/faq/linux-unix-colored-man-pages-with-less-command/
man() {
	env \
	LESS_TERMCAP_mb=$(printf "\e[1;31m") \
	LESS_TERMCAP_md=$(printf "\e[1;31m") \
	LESS_TERMCAP_me=$(printf "\e[0m") \
	LESS_TERMCAP_se=$(printf "\e[0m") \
	LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
	LESS_TERMCAP_ue=$(printf "\e[0m") \
	LESS_TERMCAP_us=$(printf "\e[1;32m") \
	man "$@"
}

##
# clean up whiteboard photos (requires ImageMagick)
# taken from https://gist.github.com/lelandbatey/8677901
##
whiteboard () {
	convert "$1" -morphology Convolve DoG:15,100,0 -negate -normalize -blur 0x1 -channel RBG -level 60%,91%,0.1 "$2"
}

##
# Load any platform-specific resources
##

arch=$(uname -s)
machinearch=$(uname -m)
[ -f $HOME/.bashd/extra_$arch.bashrc ] && . $HOME/.bashd/extra_$arch.bashrc
[ -f $HOME/.bashd/extra_${arch}_${machinearch}.bashrc ] && . $HOME/.bashd/extra_${arch}_${machinearch}.bashrc

