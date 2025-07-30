# 🔧 Waves SoundGrid Firmware Recovery Tool

A minimal bootable Linux environment built to **recover or reflash Waves SoundGrid Servers** using a reliable and offline-safe method.

This live ISO is designed for technicians and engineers who need a **failsafe tool to flash firmware images directly** to USB drives or embedded storage on Waves hardware.

---

## 🚀 Features

- 🖥️ **Bootable Debian-based Linux environment**
- 🔐 **Root auto-login** and script autostart — no GUI, no distractions
- 🧠 **Automatically detects all connected disks**, including USB and internal drives
- 🧰 Uses native Linux tools (`dd`, `lsblk`) — no proprietary drivers needed
- 🔒 Excludes the system's boot medium to **prevent accidental overwriting**
- 📴 Works **fully offline** — ideal for controlled studio or field use

---

## 🛠️ Use Cases

- Reflashing bricked SoundGrid Server
- Creating a clean USB recovery stick for firmware repair

---

## 📦 What It Does

At boot:
1. The system **auto-logs in as root**
2. The recovery script `flash-img.sh` **automatically runs** (located in `/usr/local/bin`)
3. You are presented with a **list of available target disks**
4. Upon confirmation, it flashes the embedded image (e.g. `sgs.img`) using `dd`

---

## 🖥️ How to Use

1. 🛠️ Build the ISO (see below)
2. 🔥 Flash it to a USB drive (`dd`, `Rufus`, `balenaEtcher`, etc.)
3. 🖥️ Boot the Waves Server or target PC from this USB
4. 📋 Follow the on-screen instructions to select and flash the firmware

---

## 🧱 Building the ISO

Make sure you have `live-build` installed and are in the root folder of the repo `soundgrid-recovery/`:

```bash
sudo apt install -y live-build
```

Then:

```bash
sudo lb clean
sudo lb config --architecture amd64 --debian-installer none --debian-installer-gui false
sudo lb build
```

Output: 

`live-image-amd64.hybrid.iso`

You can change the Firmware Image by swapping the `sgs.img` in `config/includes.chroot/root/`.
Make sure that the img includes a valid volume (preferably an image from a working server).

## Disclaimer

Right now, the included `sgs.img` is a nonbootable dummy image. 
Due to obvious legal reasons, you'll have to source the image on your own. 
Or, if you own an original Waves SoundGrid Server (with functioning internal USB Stick), generate the boot Image on your own. 
Again, for legal reasons, I can't provide guidance on how to do that.
