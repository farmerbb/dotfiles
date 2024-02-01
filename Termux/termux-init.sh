#!/data/data/com.termux/files/usr/bin/bash

echo "export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" > $HOME/.bashrc
echo '"\e[A": history-search-backward' > ~/.inputrc
echo '"\e[B": history-search-forward' >> ~/.inputrc
echo '"\eOA": history-search-backward' >> ~/.inputrc
echo '"\eOB": history-search-forward' >> ~/.inputrc

termux-setup-storage
rm -r ~/storage

rm -rf ~/.ssh
cp -r /sdcard/Network\ Config/ssh ~/.ssh
sed -i "s/  Control/# Control/g" ~/.ssh/config
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*

cp -r /sdcard/Settings/Termux/rish* .
chmod +x rish
