#!/bin/sh
#
# ROM SHUFFLER
# Author: adixal
# Created: 24-April-2023 1:22PM
# Modified: 1-May-2023 12:08PM
#
# External Requirements: jq
#
# This is a script that will run through available ROMs in both TF1 and TF2 SD Cards.
# It will then grab the directory name and rom. The directory name is parsed through
# jq and the coremapping.json file that is provided in GarlicOS. It will then run
# RetroArch with the required configuration.
#
# It will always look at TF1 before TF2.
#
# shellcheck disable=SC2016,SC2086
#

TF1=/mnt/mmc
TF2=/mnt/SDCARD

UB=/usr/bin
CM=$TF1/CFW/config/coremapping.json

RA=$TF1/CFW/retroarch
RS="$(dirname $0)"
TF=$TF1

# Read the exclude file for use in functions
EXCLUDE=$(cat "$RS/EXCLUDE.txt")
OPT=""
for EXC in $EXCLUDE; do OPT="$OPT -name $EXC -o"; done
OPT=$(echo "${OPT% -o}" | $UB/awk '{$1=$1};1')

count() {
	$UB/find "$1"/Roms -maxdepth 2 '(' $OPT ')' -prune -o -type f -print | $UB/sort | $UB/uniq | $UB/wc -l
}

shuffle() {
	ROM=$($UB/find "$1"/Roms -maxdepth 2 '(' $OPT ')' -prune -o -type f -print | $UB/sort | $UB/uniq | $UB/awk 'BEGIN { srand(); } { if(rand() <= 1/NR) file = $0; } END { if(file) print file; else print "NOTHING"; }')

	MAP=$(echo "$ROM" | $UB/awk -F/ '{print $(NF-1)}')
	CORE=$("$RS"/jq --arg map "$MAP" -r '.[$map]' "$CM")
}

TF1_COUNT=$(count "$TF1")
TF2_COUNT=$(count "$TF2")

for _ in 1 2 3 4 5; do
	RAN=$($UB/awk 'BEGIN { srand(); print int(rand()*4096) }')

	if [ $TF1_COUNT -gt 0 ] && [ $TF2_COUNT -gt 0 ]; then
		if [ $((RAN %2)) -eq 0 ]; then
			TF=$TF1
		else
			TF=$TF2
		fi
	elif [ $TF2_COUNT -gt 0 ]; then
		TF=$TF2
	fi

	./printstr "       Shuffling...       " & sleep 1
	shuffle "$TF"

	if [ "$ROM" != "NOTHING" ]; then break; fi
done

# Got nothing? Then just give up I suppose.
if [ "$ROM" = "NOTHING" ]; then
	./printstr "    Nothing Found...    " & sleep 1
	exit 1
fi

# Do we have something? Great! Let's play!
$RA/retroarch --load-menu-on-error --appendconfig=$RA/.retroarch/volume.cfg -L "$RA/.retroarch/cores/$CORE" "$ROM"
