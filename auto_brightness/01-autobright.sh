#!/system/bin/sh

TARGET_TIME="2200"		# Change this to your desired target time. This is in 24 hour notation.
REDUCTION_SCALE=1.1		# Change this to your desired brightness reduction factor (1.1 is default).
MIN_BRIGHTNESS=16		# Minimum allowed brightness value. Can be between 0-1024.
SLEEP_TIMER=600			# Change this to your desired sleep timer in seconds (default is 10 minutes).

# Try not to modify anything below if you can help it.
# ---------------------------------------------------------------------
#

while true; do
    CURRENT_TIME=$(busybox date +%H%M)
    BRIGHTNESS=$(busybox cat /sys/class/backlight/backlight.2/brightness)

    if [ "$CURRENT_TIME" -ge "$TARGET_TIME" ]; then
        if [ "$BRIGHTNESS" -gt "$MIN_BRIGHTNESS" ]; then
            NEW_BRIGHTNESS=$(busybox awk -v b="$BRIGHTNESS" -v r="$REDUCTION_SCALE" 'BEGIN {printf "%.0f\n", (b/r)}')
            if [ "$NEW_BRIGHTNESS" -lt "$MIN_BRIGHTNESS" ]; then NEW_BRIGHTNESS="$MIN_BRIGHTNESS"; fi
            echo "$NEW_BRIGHTNESS" > /sys/class/backlight/backlight.2/brightness
        fi
    fi

    busybox sleep "$SLEEP_TIMER"
done &
