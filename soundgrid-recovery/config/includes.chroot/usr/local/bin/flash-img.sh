#!/bin/bash

ISO_PATH="/root/sgs.iso"
clear

cat <<'EOF'
%%%%%%%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%
%%%%%%%%%%@%###############################################################%%%%%
%%%%%%%%%@%-                                                              -@%%%%
%%%%%%%%%@=                                                               +@%%%%
%%%%%%%%@#     .        .                .......          .......         #@%%%%
%%%%%%%%@=    =%.      +#       *#    -*#%%@@@@%%*-   .=#%%@@@@@%%#+     :%@%%%%
%%%%%%%@%.    #@+     .%@-     .%@:  =@@%=--:--#@@#  :%@@*==---=*@@@-    =@%%%%%
%%%%%%%@*    :@@#     -@@*     =@@+ .%@@:      -**=  #@@=       .***:    #@%%%%%
%%%%%%%@:    +@@@:    *@@%.    #@@% -@@@=::...      -@@#                .%@%%%%%
%%%%%%@#     =+++=----=+++-----++++..*%%@@@@@%%#*-  #@@+   .+++++++-    =@%%%%%%
%%%%%%@+         :@@@*    -@@@+        ::---==#@@% .%@%:   :***#@@@-    #@%%%%%%
%%%%%@%:          #@@-     %@@:    -++-       =@@# -@@%        -@@%.   :%%%%%%%%
%%%%%@#           +@%.     *@#     *@@*.     :%@@- -@@%=......-%@@=    +@%%%%%%%
%%%%%@+           .%+      :%=     =%@@%%%%%%@@%=  .*%@@@%%%%@@@%=    .%@%%%%%%%
%%%%%@:            :        :       .:-======-:      .--=====--:      =@%%%%%%%%
%%%%@%.                                                               %@%%%%%%%%
%%%%@*                                                               +@%%%%%%%%%
%%%%%#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#@%%%%%%%%%%
%%%%%*%@*%%*@**@#%@##**#%**#@@%**#@#**%#%@*%*#@#%***%%***%***%#%#**#@%%%%%%%%%%%
%%%%@-== +-++:.#-=*:=.=*=:=-%@=:=-=:#:-.##.+..*.+.#=::=+-+.+:=:+.*+.%@%%%%%%%%%%
%%%%@+.=*.-*.+:=#.:#-:=#==-:%@==----*:+.+===++.:=:*-=:==:=:*.*:+.*=-%%%%%%%%%%%%
%%%%%%#%%#%%%@%%%#%@%##%%##%%%%##%%##%@%##%%%%#%%###@%##%%%@%%%%###%%%%%%%%%%%%%
%%%%%@@@@@@@@%@@%@@%@@@@@@@@%%@@@@@@@@%@@@@@@@@@@@@@%@@@@@@%@@@@@@@@%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EOF

echo "Welcome to Waves SoundGrid Server flasher"
sleep 2
echo "This Tool allows you to flash and recover the SGS Firmware in case of a defect Bootdrive"
sleep 1
echo "Starting Process"
sleep 1

echo "🔍 Locating boot device..."

# Get root device (e.g., /dev/sda1 or /dev/nvme0n1p1)
ROOT_DEV=$(findmnt -n -o SOURCE /)

# Strip to base disk (e.g., sda1 → sda)
if [[ "$ROOT_DEV" =~ /dev/([a-zA-Z0-9]+) ]]; then
  ROOT_DEV=${BASH_REMATCH[1]}
fi

# Try to find physical parent if it's a partition
BOOT_DISK=$(lsblk -no PKNAME "/dev/$ROOT_DEV" 2>/dev/null || echo "$ROOT_DEV")

echo "📦 Boot device: /dev/$BOOT_DISK"

# List all non-loop/ram devices (e.g. sdX, nvmeXnY, vdX), include USB
# Exclude the boot device
mapfile -t DISKS < <(
  lsblk -dn -o NAME,TYPE,SIZE,MODEL,TRAN |
  grep -v "^$BOOT_DISK" |
  awk '$2 == "disk" && $5 != "loop" && $5 != "ram" { print $1, $3, $4, $5 }'
)

if [ ${#DISKS[@]} -eq 0 ]; then
  echo "❌ No suitable target disks found."
  exit 1
fi

echo ""
echo "💾 Available target disks:"
for i in "${!DISKS[@]}"; do
  DEVICE=$(echo "${DISKS[$i]}" | awk '{print $1}')
  SIZE=$(echo "${DISKS[$i]}" | awk '{print $2}')
  MODEL=$(echo "${DISKS[$i]}" | cut -d' ' -f3- | sed 's/  */ /g')
  echo "  [$i] /dev/$DEVICE – $SIZE – $MODEL"
done

echo ""
read -p "👉 Select the target disk number: " INDEX

if ! [[ "$INDEX" =~ ^[0-9]+$ ]] || [ "$INDEX" -ge "${#DISKS[@]}" ]; then
  echo "❌ Invalid selection. Aborting."
  exit 1
fi

TARGET_DISK="/dev/$(echo "${DISKS[$INDEX]}" | awk '{print $1}')"

echo ""
echo "⚠️  You selected: $TARGET_DISK"
read -p "Type 'yes' to confirm flashing to this disk: " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
  echo "Aborted by user."
  exit 1
fi

echo ""
echo "🚀 Writing $ISO_PATH to $TARGET_DISK ..."
dd if="$ISO_PATH" of="$TARGET_DISK" bs=4M status=progress oflag=direct conv=fsync

sync
echo "✅ Flash complete."

read -p "Press [r] to reboot or [p] to power off: " ACTION
case "$ACTION" in
    r|R) reboot ;;
    p|P) poweroff ;;
    *) echo "No action taken. You can reboot or power off manually." ;;
esac
