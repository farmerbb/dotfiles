<<'##################################################'

# To install, run the following:

echo '' >> ~/.bashrc
echo 'for i in linux-generic crosh; do' >> ~/.bashrc
echo '  source /media/removable/SD\ Card/Other\ Stuff/Linux/Bash\ Configs/bashrc-additions-$i.sh' >> ~/.bashrc
echo 'done' >> ~/.bashrc

##################################################

export PATH="/usr/local/bin:/usr/bin:/bin:/opt/bin"
export LD_LIBRARY_PATH="/usr/local/lib64"
export CROS_USER_ID_HASH=$(ls /home/user)

# for i in {1..2}; do
#   source /media/removable/SD\ Card/Other\ Stuff/Chrome\ OS/Chronos\ Home\ Directory/rootfs-modifications-pt$i.sh
# done

alias crosh=".crosh"
# alias chrx="sh /home/chronos/user/chroot.sh"
alias renice-crosvm='for i in $(pidof crosvm); do sudo renice -n -4 -p $i; done'

virtualhere-server() {
  IP=$(ip addr | grep 192.168 | cut -d' ' -f 6 | cut -d'/' -f 1 | sed 's/$/:7575/g')
  sudo iptables -I INPUT -p tcp --dport 7575 -j ACCEPT

  if [[ ! -f /usr/bin/vhusbdx86_64 ]]; then
    sudo cp /media/removable/SD\ Card/Other\ Stuff/Utilities/VirtualHere/vhusbdx86_64 /usr/bin
    sudo chmod +x /usr/bin/vhusbdx86_64
  fi

  [[ -z $(pgrep vhusbdx86_64) ]] && sudo vhusbdx86_64 -b

  echo "Hub addresses:"
  echo
  echo "100.115.92.1:7575"
  echo "$IP"
}

rootfs-modifications-pt1() {
  sudo crossystem dev_boot_signed_only=0
  sudo /usr/libexec/debugd/helpers/dev_features_rootfs_verification

  for i in 2 4; do
    sudo /usr/share/vboot/bin/make_dev_ssd.sh --partitions $i --save_config /home/chronos/user/kernel_params >/dev/null 2>&1
#   sed -i '$ s/$/ i915.enable_dbc=N elevator=deadline/' /home/chronos/user/kernel_params.$i
    sed -i '$ s/$/ noibrs noibpb nopti nospectre_v2 nospectre_v1 l1tf=off nospec_store_bypass_disable no_stf_barrier mds=off tsx=on tsx_async_abort=off mitigations=off/' /home/chronos/user/kernel_params.$i
    sudo /usr/share/vboot/bin/make_dev_ssd.sh --partitions $i --set_config /home/chronos/user/kernel_params >/dev/null 2>&1
    rm /home/chronos/user/kernel_params.$i
  done

# sudo sed -i 's/"ANDROID_DEBUGGABLE": false/"ANDROID_DEBUGGABLE": true/g' /usr/share/arcvm/config.json

  printf "Press Enter to reboot..."
  read _
  sudo reboot
}

rootfs-modifications-pt2() {
  sudo /usr/libexec/debugd/helpers/dev_features_ssh

# echo "fs.inotify.max_user_watches = 524288" | sudo tee /etc/sysctl.d/idea.conf > /dev/null
# echo -e "kernel.sysrq=1\nvm.vfs_cache_pressure=500\nvm.swappiness=100\nvm.dirty_background_ratio=1\nvm.dirty_ratio=50" | sudo tee /etc/sysctl.d/custom.conf > /dev/null
# sudo sed -i "s/-e //g" /etc/sysctl.d/custom.conf

  echo "vm.swappiness=100" | sudo tee /etc/sysctl.d/custom.conf > /dev/null
  echo 100 | sudo tee /proc/sys/vm/swappiness > /dev/null
# sudo sysctl --system > /dev/null

  sudo mv /usr/bin/crosh /usr/bin/.crosh
  echo "cd ~ && /bin/bash" | sudo tee /usr/bin/crosh > /dev/null
  sudo chmod +x /usr/bin/crosh

  echo 'chronos ALL=(ALL) NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo > /dev/null

  rm -f /home/chronos/user/.bash_logout

# cd
# ln -sfn /home/chronos/user/Downloads Download
# ln -sfn /media/removable/sdcard sdcard
# ln -sfn /mnt/stateful_partition/chrx chrx

# cd /etc/init
# for i in read write; do
#   sudo cp arc-myfiles-$i.conf arc-myfiles-$i.conf.old
#   sudo sed -i 's/UMASK=227/UMASK=027/g' arc-myfiles-$i.conf
#   sudo sed -i 's/ANDROID_MEDIA_UID=1023/ANDROID_ROOT_UID=0/g' arc-myfiles-$i.conf
#   sudo sed -i 's/ANDROID_MEDIA_GID=1023/ANDROID_EVERYBODY_GID=9997/g' arc-myfiles-$i.conf
#   sudo sed -i 's/"${ANDROID_MEDIA_UID}" "${ANDROID_MEDIA_GID}"/"${ANDROID_ROOT_UID}" "${ANDROID_EVERYBODY_GID}"/g' arc-myfiles-$i.conf
# done

# echo "--ash-enable-cursor-motion-blur" | sudo tee -a /etc/chrome_dev.conf > /dev/null

  sudo tune2fs -m 0 /dev/nvme0n1p1 >/dev/null 2>&1

  [[ -f ~/.ssh/authorized_keys ]] && \
  echo "$(cat ~/.ssh/authorized_keys)" | sudo tee -a /usr/share/chromeos-ssh-config/keys/authorized_keys > /dev/null

# printf "Press Enter to reboot..."
# read _
# sudo reboot
}

reclaim-vm-memory() (
  reclaim-vm-memory-internal() {
    nice -20 concierge_client --reclaim_vm_memory --name=$1 --cryptohome_id=$CROS_USER_ID_HASH
  }

  [[ -z $1 ]] && reclaim-vm-memory-internal arcvm && reclaim-vm-memory-internal termina
  [[ ! -z $1 ]] && reclaim-vm-memory-internal $1
)
