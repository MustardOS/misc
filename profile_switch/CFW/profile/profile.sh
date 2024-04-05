#!/bin/sh

MMC="/mnt/mmc"
PROF_DIR="$MMC/CFW/profile"
CURRENT_PROFILE=$(cat "$PROF_DIR/.current")
NEW_PROFILE="$1"

[ "$CURRENT_PROFILE" = "$NEW_PROFILE" ] && exit

cd "$MMC" || exit

cd "$MMC/CFW"
set -- "skin" "Saves"
for D; do
	SRC="$MMC/$D"
	DES="$PROF_DIR/$CURRENT_PROFILE/$D"

	cp -rf "$SRC" "$DES"
	rm -rf "$SRC"

	if [ ! -e "$PROF_DIR/$NEW_PROFILE/$D" ] && [ "$D" = "skin" ]; then
		mkdir -p "$PROF_DIR/$NEW_PROFILE/$D/system"
		cp -rf "$PROF_DIR/init/skin"/* "$PROF_DIR/$NEW_PROFILE/$D"
	fi

	if [ ! -e "$PROF_DIR/$NEW_PROFILE/$D" ] && [ "$D" = "Saves" ]; then
		mkdir -p "$PROF_DIR/$NEW_PROFILE/$D/CurrentProfile/lists"
		mkdir -p "$PROF_DIR/$NEW_PROFILE/$D/CurrentProfile/saves"
		mkdir -p "$PROF_DIR/$NEW_PROFILE/$D/CurrentProfile/states"
		cp -rf "$PROF_DIR/init/Saves"/* "$PROF_DIR/$NEW_PROFILE/$D"
	fi

	SRC="$PROF_DIR/$NEW_PROFILE/$D"
	DES="$MMC/$D"

	cp -rf "$SRC" "$DES"
	rm -rf "$SRC"
done

cd "$MMC/CFW/retroarch" || exit

set -- ".retroarch"
for D; do
	SRC="$D"
	DES="./profile/$CURRENT_PROFILE/$D"

	cp -rf "$SRC" "$DES"
	rm -rf "$SRC"

	if [ ! -e "$PROF_DIR/$NEW_PROFILE/$D" ] && [ "$D" = ".retroarch" ]; then
		mkdir -p "$PROF_DIR/$NEW_PROFILE/$D"
		cp -rf "$PROF_DIR/init/retroarch"/* "$PROF_DIR/$NEW_PROFILE/$D"
	fi

	SRC="$PROF_DIR/$NEW_PROFILE/$D"
	DES="./$D"

	cp -rf "$SRC" "$DES"
	rm -rf "$SRC"
done

echo "$NEW_PROFILE" > "$PROF_DIR/.current"

