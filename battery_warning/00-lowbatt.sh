#!/system/bin/sh

PERCENT=30	# What capacity level should this script run at? 30 is default.
SLEEP=300	# How many seconds should the script sleep before checking the battery capacity again
REPEAT=5	# How many times should the sequence repeat?

# Try not to modify anything below if you can help it.
# ---------------------------------------------------------------------
#

batt_seq() {
	busybox seq 1 $REPEAT | while read -r _; do
		busybox sleep 0.5
		echo 1 > /sys/class/backlight/backlight.2/bl_power
		busybox sleep 0.2
		echo 0 > /sys/class/backlight/backlight.2/bl_power
	done
}

while true; do
	busybox sleep $SLEEP
	CAPACITY=$(cat /sys/class/power_supply/battery/capacity)
	if [ $CAPACITY -le $PERCENT ]; then batt_seq; fi
done &
