#!/bin/sh

PDF=$(echo "$0" | awk -F/ '{print $NF}')
HD=$(dirname "$0")

CFW="/mnt/mmc/CFW/config"

COUNT=0

# add the PDF reader to coremapping
awk 'NR==3{print "      \"MANUALS\": \"/bin/sh\","} 1' "$CFW"/coremapping.json > "$CFW"/tempCM.txt
mv tempCM.txt "$CFW"/coremapping.json

# go to PDF folder
cd "$HD"/PDF || exit

# refresh pdfs
for F in ./*.pdf; do
	F_noex=${F%.*}
	if ! [ -f ../"$F_noex".sh ]; then
    		cp "$HD"/PDF/template.sh ../"$F_noex".sh
	fi
	COUNT=$((COUNT+1))
done

# delete itself
if [ $COUNT -gt 0 ]; then
	rm -f "$0"
fi

exit
