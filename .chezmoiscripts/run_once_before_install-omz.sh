#!/bin/sh

if [ ! -e "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  exit 0
else
  echo '\~/.oh-my-zsh directory exists'
fi
