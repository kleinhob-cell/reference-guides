# Dual‑Boot Maintenance & mt76 Wi‑Fi/Bluetooth Setup

## 1. Kernel & Header Prep
Always make sure the matching Ubuntu kernel headers are installed for your running kernel:

    sudo apt install linux-headers-$(uname -r)

Verify /lib/modules/$(uname -r)/build points to the headers:

    ls -l /lib/modules/$(uname -r)/build

If not, fix it:

    sudo rm /lib/modules/$(uname -r)/build
    sudo ln -s /usr/src/linux-headers-$(uname -r) /lib/modules/$(uname -r)/build

---

## 2. Building mt76 from Upstream
If DKMS fails due to kernel API changes:

    sudo dkms remove -m mt76 -v 1.0 --all
    sudo rm -rf /usr/src/mt76-1.0
    cd ~
    rm -rf mt76
    git clone https://github.com/openwrt/mt76.git
    cd mt76
    make
    sudo make install
    sudo modprobe mt76

Check Wi‑Fi:

    nmcli device status

---

## 3. GRUB Default Boot
List menu entries:

    sudo grep "menuentry '" /boot/grub/grub.cfg | nl -v 0

Edit /etc/default/grub:

    GRUB_DEFAULT=<entry_number_for_kernel>
    GRUB_TIMEOUT=3

Update GRUB:

    sudo update-grub

---

## 4. Bluetooth Checks

Ubuntu:

    bluetoothctl list
    rfkill list bluetooth

Windows (PowerShell Admin):

    Get-PnpDevice -Class Bluetooth
    Get-Service bthserv

---

## 5. After Kernel Upgrades
1. Install matching headers.
2. Test Wi‑Fi and Bluetooth.
3. If Wi‑Fi fails, rebuild mt76 from upstream.
4. Re‑check GRUB default if you want to keep booting the new kernel.

---

## 6. Quick Recovery Commands
If Wi‑Fi disappears after a kernel update:

    sudo modprobe mt76
    nmcli device status

If that fails, rebuild mt76 from upstream.

---

## 7. Known Issues & Fixes

| Error / Symptom | Cause | Fix |
|-----------------|-------|-----|
| WARNING: Module.symvers is missing / ERROR: modpost: ... undefined! | Kernel headers incomplete or build symlink points to wrong location. | Install matching headers: `sudo apt install linux-headers-$(uname -r)` Reset symlink: `sudo rm /lib/modules/$(uname -r)/build && sudo ln -s /usr/src/linux-headers-$(uname -r) /lib/modules/$(uname -r)/build` |
| Error! Bad return status for module build after DKMS build | mt76 DKMS source too old for current kernel API. | Remove old DKMS source: `sudo dkms remove -m mt76 -v 1.0 --all && sudo rm -rf /usr/src/mt76-1.0` Clone latest: `git clone https://github.com/openwrt/mt76.git && cd mt76 && make && sudo make install` |
| Wi‑Fi interface missing after kernel update | New kernel installed but mt76 not rebuilt. | Rebuild from upstream as above, or re‑add to DKMS if desired. |
| Bluetooth adapter missing in Ubuntu | rfkill blocking or driver not loaded. | Check: `rfkill list bluetooth` Unblock: `sudo rfkill unblock bluetooth` Restart service: `sudo systemctl restart bluetooth` |
| Bluetooth missing in Windows | Driver issue or disabled in BIOS. | In Windows Device Manager, check under Bluetooth. If missing, install latest OEM driver or enable in BIOS. |

---

## 8. Maintenance Tips
- After every kernel upgrade:
  1. Install matching headers.
  2. Test Wi‑Fi and Bluetooth.
  3. If Wi‑Fi fails, rebuild mt76 from upstream.
- Keep a local copy of this file in reference-guides/dualboot/ so you can follow it step‑by‑step.
- Optional: Add the upstream mt76 repo as a DKMS module so it auto‑rebuilds on kernel upgrades.

---

## 9. Optional — Re‑Integrating Upstream mt76 into DKMS
If you want mt76 to rebuild automatically on kernel upgrades:

    cd ~/mt76
    sudo dkms add .
    sudo dkms build mt76/$(git rev-parse --short HEAD)
    sudo dkms install mt76/$(git rev-parse --short HEAD)

Note: Using the git commit hash as the DKMS version keeps it clear which upstream snapshot you’re on. When updating, git pull in ~/mt76, then sudo dkms remove the old version and re‑add/build/install the new one.
