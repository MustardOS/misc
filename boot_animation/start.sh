#!/system/bin/sh

# Do NOT modify anything below, or do, just have fun with it.
DIR=/misc/boot_anim
THM=$DIR/theme/$1
MOTO=/sys/class/power_supply/battery/moto

# Configure ALSA symlinks since the system placed them in weird locations
mkdir /usr/share && mkdir /usr/share/alsa
ln -s /system/usr/alsa.conf /usr/share/alsa/alsa.conf &
ln -s /system/usr/cards /usr/share/alsa/cards &
ln -s /system/usr/pcm /usr/share/alsa/pcm

process_rumble() {
    while IFS= read -r line; do
        case "$line" in
            ""|"#"* ) continue ;;
            * )
                STRENGTH=$(echo "$line" | busybox awk '{print $1}')
                LENGTH=$(echo "$line" | busybox awk '{print $2}')
                PAUSE=$(echo "$line" | busybox awk '{print $3}')

                echo "$STRENGTH" > "$MOTO" & busybox sleep "$LENGTH"
                echo 0 > "$MOTO" & busybox sleep "$PAUSE"
                ;;
        esac
    done < "$THM"/rumble.txt
}

if [ -f $THM/config.txt ]; then
	# Grab the configuration of the theme specified
	source $THM/config.txt

	if [ $SOUND = true ]; then
		$DIR/bin/mp3play $THM/chime.mp3 &
	fi

	if [ "$RUMBLE" = true ] && [ -f $THM/rumble.txt ]; then
		process_rumble &
	fi

	# Okay let's make the magic happen!
	busybox seq 1 $LOOP | while read -r _; do
		for F in $(busybox seq 1 $END_FRAME); do
			$DIR/bin/fbim $THM/"$F".png &
			busybox sleep $TIMING
		done
	done
else
	busybox printf "No theme specified!\n"
fi
