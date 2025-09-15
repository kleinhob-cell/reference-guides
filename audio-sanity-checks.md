# 🎧 Audio Sanity Checks — CM106 + Fifine → studio_bus

Quick reference to verify that your audio wiring is correct and both channels are working as intended.

---

## 1️⃣ Check loopbacks

```bash
pactl list short modules | grep module-loopback
```
✅ Expected output:
- **Left**: alsa_input.usb-0d8c_USB_Sound_Device-00.analog-stereo.X → studio_bus (rate=48000)
- **Right**: alsa_input.usb-Fifine_Microphones_fifine_Microphone_REV1.0-00.analog-stereo → studio_bus (rate=48000)
- Exactly **two** loopbacks, no .monitor sources, no duplicates.

## 2️⃣ Live monitor test
```bash
parec -d studio_bus.monitor --channels=2 --format=s16le --rate=48000 | \
pacat --channels=2 --format=s16le --rate=48000
```
🎯 **Expected**:
- Play audio on WorkMac → **Left** channel only
- Speak into Fifine → **Right** channel only
Press **Ctrl +C** to stop.

## 3️⃣ Service status check
```bash
systemctl --user status audio-wireup.service
```
✅ **Expected**:
- Active: inactive (dead) with status=0/SUCCESS (normal for a one‑shot service)
- Log lines showing:
  - Left  = alsa_input.usb-0d8c_USB_Sound_Device...
  - Right = alsa_input.usb-Fifine_Microphones...

## 4️⃣ If something’s wrong

- **Restart service:**
```bash
systemctl --user restart audio-wireup.service
```
- **Remove ghost loopbacks:**
```bash
pactl list short modules | grep module-loopback | awk '{print $1}' | while read id; do pactl unload-module "$id"; done
systemctl --user restart audio-wireup.service
```
- **Check device profiles in pavucontrol:**
  - CM106: Profile = **Analog Stereo Input**, Port = **Line In**
  - Fifine: Profile = **Analog Stereo Input**

## 5️⃣ Visual confirmation in Helvum
- CM106 FL → studio_bus FL
- Fifine FR → studio_bus FR
- studio_bus.monitor → your app

💡 Tip: This setup is locked to 48 kHz for both devices to avoid resampling issues.


---