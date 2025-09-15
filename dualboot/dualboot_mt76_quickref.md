# Dual‑Boot mt76 Quick‑Reference

## 1. Kernel headers
    sudo apt install linux-headers-$(uname -r)
    ls -l /lib/modules/$(uname -r)/build
    sudo rm /lib/modules/$(uname -r)/build
    sudo ln -s /usr/src/linux-headers-$(uname -r) /lib/modules/$(uname -r)/build

## 2. Build mt76 from upstream
    sudo dkms remove -m mt76 -v 1.0 --all
    sudo rm -rf /usr/src/mt76-1.0
    cd ~
    rm -rf mt76
    git clone https://github.com/openwrt/mt76.git
    cd mt76
    make
    sudo make install
    sudo modprobe mt76
    nmcli device status

## 3. GRUB default boot
    sudo grep "menuentry '" /boot/grub/grub.cfg | nl -v 0
    sudo nano /etc/default/grub
    # set: GRUB_DEFAULT=<number> and GRUB_TIMEOUT=3
    sudo update-grub

## 4. Bluetooth checks
Ubuntu:
    bluetoothctl list
    rfkill list bluetooth

Windows (PowerShell Admin):
    Get-PnpDevice -Class Bluetooth
    Get-Service bthserv

## 5. Quick recovery
    sudo modprobe mt76
    nmcli device status
