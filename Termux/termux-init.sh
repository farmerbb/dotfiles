#!/data/data/com.termux/files/usr/bin/bash

mkdir -p $HOME/.termux/
rm -f $HOME/.bashrc
rm -f $HOME/.termux/termux.properties

echo "export PS1='\[\033]0;\u@\h:\w\007\]\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '" >> $HOME/.bashrc
echo "extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]" >> $HOME/.termux/termux.properties
