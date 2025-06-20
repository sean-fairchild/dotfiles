# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts).
# Make sure you have a recent version: the code points that Powerline
# uses changed in 2012, and older versions will display incorrectly,
# in confusing ways.
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](https://iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# If using with "light" variant of the Solarized color schema, set
# SOLARIZED_THEME variable to "light". If you don't specify, we'll assume
# you're using the "dark" variant.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'

case ${SOLARIZED_THEME:-dark} in
    light) CURRENT_FG='3';;
    *)     CURRENT_FG='0';;
esac

# Special Powerline characters

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  # NOTE: This segment separator character is correct.  In 2012, Powerline changed
  # the code points they use for their special characters. This is the new code point.
  # If this is not working for you, you probably have an old version of the
  # Powerline-patched fonts installed. Download and install the new version.
  # Do not submit PRs to change this unless you have reviewed the Powerline code point
  # history and have new information.
  # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
  # what font the user is viewing this source code in. Do not replace the
  # escape sequence with a single literal character.
  # Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.
  SEGMENT_SEPARATOR=$'\ue0b0'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  # if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
  #   prompt_segment 237 7 "%(!.%{%F{3}%}.)%n@%m"
  # fi
  case "$OSTYPE" in
    darwin*)  OS_LOGO="\ue29e" ;; 
    linux*)   OS_LOGO="\ue712" ;;
  esac
  prompt_segment 237 7 $OS_LOGO
}

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }
  local ref dirty mode repo_path

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    repo_path=$(git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment 3 0
    else
      prompt_segment 2 $CURRENT_FG
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    if  $(git rev-parse --is-bare-repository) ; then
      mode="[BARE]"
    else
      autoload -Uz vcs_info
        zstyle ':vcs_info:*' enable git
        zstyle ':vcs_info:*' get-revision true
        zstyle ':vcs_info:*' check-for-changes true
        zstyle ':vcs_info:*' stagedstr '✚'
        zstyle ':vcs_info:*' unstagedstr '●'
        zstyle ':vcs_info:*' formats ' %u%c'
        zstyle ':vcs_info:*' actionformats ' %u%c'
      vcs_info
    fi

    echo -n "${ref/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
  fi
}

prompt_jj() {
  change_id=$(jj_prompt_template 'self.change_id().shortest(3)')

if ($(jj show @ -T 'self.empty()' --no-patch) -eq 'true'); then
  segment_color=10
else
  segment_color=166
fi

 
  prompt_segment $segment_color 0
  echo -n $(jj log --ignore-working-copy --no-graph --color always -r @ -T "
        stringify(separate(
                ' ',
                'JJ:',
                bookmarks.join(', '),
                change_id.shortest(),
                ' | ',
                commit_id.shortest(),
                if(conflict, '(conflict)'),
                if(empty, '(empty)'),
                if(divergent, '(divergent)'),
                if(hidden, '(hidden)'),
            )
            )
        ")
}

my_theme_vcs_info() {
  if $(jj --ignore-working-copy >/dev/null 2>&1); then
    prompt_jj
  else
    prompt_git
  fi
}

# PROMPT='$(_my_theme_vcs_info) $'

# prompt_bzr() {
#     (( $+commands[bzr] )) || return
#     if (bzr status >/dev/null 2>&1); then
#         status_mod=`bzr status | head -n1 | grep "modified" | wc -m`
#         status_all=`bzr status | head -n1 | wc -m`
#         revision=`bzr log | head -n2 | tail -n1 | sed 's/^revno: //'`
#         if [[ $status_mod -gt 0 ]] ; then
#             prompt_segment 3 0
#             echo -n "bzr@"$revision "✚ "
#         else
#             if [[ $status_all -gt 0 ]] ; then
#                 prompt_segment 3 0
#                 echo -n "bzr@"$revision

#             else
#                 prompt_segment 2 0
#                 echo -n "bzr@"$revision
#             fi
#         fi
#     fi
# }

# prompt_hg() {
#   (( $+commands[hg] )) || return
#   local rev st branch
#   if $(hg id >/dev/null 2>&1); then
#     if $(hg prompt >/dev/null 2>&1); then
#       if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
#         # if files are not added
#         prompt_segment 1 7
#         st='±'
#       elif [[ -n $(hg prompt "{status|modified}") ]]; then
#         # if any modification
#         prompt_segment 3 0
#         st='±'
#       else
#         # if working copy is clean
#         prompt_segment 2 $CURRENT_FG
#       fi
#       echo -n $(hg prompt "☿ {rev}@{branch}") $st
#     else
#       st=""
#       rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
#       branch=$(hg id -b 2>/dev/null)
#       if `hg st | grep -q "^\?"`; then
#         prompt_segment 1 0
#         st='±'
#       elif `hg st | grep -q "^[MA]"`; then
#         prompt_segment 3 0
#         st='±'
#       else
#         prompt_segment 2 $CURRENT_FG
#       fi
#       echo -n "☿ $rev@$branch" $st
#     fi
#   fi
# }

prompt_user_at_host() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment 4 $CURRENT_FG "%(!.%{%F{3}%}.)%n@%m"
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment 4 $CURRENT_FG '%~'
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    prompt_segment 4 0 "(`basename $virtualenv_path`)"
  fi
}

newline_prompt() {
  prompt_segment 166 0 "$"
  prompt_end
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local -a symbols

  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{1}%}\uf7d3" #✘
  [[ $UID -eq 0 ]] && symbols+="%{%F{3}%}\ufaf5" #⚡
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{6}%}\uf7d0" #⚙

  [[ -n "$symbols" ]] && prompt_segment 166 7 "$symbols"
}

prompt_aws_user() {
  if [[ -n $AWS_PROFILE ]]; then
    prompt_color=109
    prompt_segment $prompt_color 0 "$AWS_PROFILE - $AWS_ACCOUNT_NUMBER"
  fi
}

prompt_k8s_context() {
  current_k8s_context="$(kubectl config current-context -c 2>/dev/null)"
  if [[ $current_k8s_context ]]; then
    prompt_segment 222 0 "k8s context - $current_k8s_context"
  fi
}

prompt_newline() {
  prompt_end
  CURRENT_BG='NONE'
  echo -n "\n"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  echo "\n"
  prompt_status
  prompt_virtualenv
  prompt_context
  # prompt_user_at_host
  prompt_dir
  prompt_newline
  my_theme_vcs_info
  prompt_newline
  prompt_aws_user
  prompt_k8s_context
  # prompt_bzr
  # prompt_hg
  prompt_newline
  newline_prompt
}

PROMPT='%{%f%b%k%}$(build_prompt) '

RPROMPT='$(vi_mode_prompt_info)'

VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
