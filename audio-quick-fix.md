# 🔧 Audio Quick‑Fix — CM106 + Fifine → studio_bus

Use this when your audio routing breaks after a hot‑plug, device rename, or PipeWire hiccup.

---

## 1️⃣ Restart the wiring service

```bash
systemctl --user restart audio-wireup.service
```
This will:
- Unload any stale loopbacks
- Re‑detect CM106 and Fifine capture sources
- Re‑wire them to studio_bus at 48 kHz

## 2️⃣ Verify loopbacks
```bash
pactl list short modules | grep module-loopback
```
✅ **Expected:**
- **Left**: alsa_input.usb-0d8c_USB_Sound_Device-00.analog-stereo.X → studio_bus (rate=48000)
- **Right**: alsa_input.usb-Fifine_Microphones_fifine_Microphone_REV1.0-00.analog-stereo → studio_bus (rate=48000)
- Exactly **two** loopbacks, no .monitor sources, no duplicates.

## 3️⃣ Live monitor test
```bash
parec -d studio_bus.monitor --channels=2 --format=s16le --rate=48000 | \
pacat --channels=2 --format=s16le --rate=48000
```
🎯 **Expected:**
- Play audio on WorkMac → **Left** channel only
- Speak into Fifine → **Right** channel only

Press **Ctrl +C** to stop.

## 4️⃣ If still broken

- **Ghost loopbacks:**
```bash
pactl list short modules | grep module-loopback | awk '{print $1}' | while read id; do pactl unload-module "$id"; done
systemctl --user restart audio-wireup.service
```
- **No CM106 or Fifine source found:**
  Check pavucontrol → Configuration tab:
  - CM106: Profile = **Analog Stereo Input**, Port = **Line In**
  - Fifine: Profile = **Analog Stereo Input**
- **Gain too low:**
  In pavucontrol → Input Devices, raise volume sliders for both devices.

💡 Tip: This quick‑fix is safe to run anytime — it won’t harm your routing and will always leave you with a clean, correct setup.

---