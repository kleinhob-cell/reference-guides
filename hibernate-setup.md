# 💤 Hibernate Setup Checklist — Ubuntu (Swapfile Method)

**Goal:** Enable hibernation with a swapfile sized for full RAM image (≥ RAM size).

---

## 1️⃣ Create Swapfile
~~~
sudo fallocate -l 34G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
~~~

---

## 2️⃣ Get Resume Parameters
~~~
# Swapfile offset
SWAP_OFFSET=$(sudo filefrag -v /swapfile | awk '{if($1=="0:"){print $4}}' | sed 's/\.\.//')

# Root partition UUID
ROOT_UUID=$(findmnt -no UUID -T /)
~~~

---

## 3️⃣ Update GRUB
~~~
sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*/& resume=UUID=$ROOT_UUID resume_offset=$SWAP_OFFSET/" /etc/default/grub
sudo update-grub
~~~

---

## 4️⃣ Reboot & Test
~~~
sudo reboot
sudo systemctl hibernate
~~~
- System should power off completely.  
- On power‑on, session should restore exactly as before.

---

## 5️⃣ Verify (Optional)
~~~
cat /sys/power/resume
~~~
Should match:
```
<root-UUID> <swapfile-offset>
```

---

### Notes
- **Size**: 34 GB chosen for 32 GB RAM + overhead.  
- **Resize**:  
  ~~~
  sudo swapoff /swapfile
  sudo fallocate -l <newsize> /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  ~~~
- **Why swapfile**: Easier to resize, no partition moves, fully supported by Ubuntu.
