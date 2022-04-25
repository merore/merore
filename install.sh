#!/bin/bash

rm -f ~/.bashrc
rm -f ~/.dircolors
rm -f ~/.vimrc
rm -rf ~/.vim/autoload
rm -rf ~/.vim/colors
rm -rf ~/.vim/plugged
rm -rf ~/wk/merore

mkdir -pv ~/wk
git clone -o ~/wk/merore git@github.com:merore/merore.git

mkdir -pv ~/.vim
ln -s ~/wk/merore/vim/vim.rc ~/.vimrc
ln -s ~/wk/merpre/vim/autoload ~/.vim/autoload
ln -s ~/wk/merore/vim/colors ~/.vim/colors
ln -s ~/wk/merore/vim/plugged ~/.vim/plugged

ln -s ~/wk/merore/bash/bash.rc ~/.bashrc
ln -s ~/wk/merore/bash/dircolors ~/.dircolors
