#!/bin/sh

PDF=$(echo "$0" | awk -F/ '{print $NF}')
HD=$(dirname "$0")

# go to PDF folder
cd "$HD"/PDF || exit

# refresh pdfs
for F in ./*.pdf; do
	F_noex=${F%.*}
	if ! [ -f ../"$F_noex".sh ]; then
    		cp ../"$PDF" ../"$F_noex".sh
	fi
done

# launch it
./fbpdf "./${PDF%.sh}.pdf"
wait
exit
