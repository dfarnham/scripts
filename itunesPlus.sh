#!/bin/sh

# System Version: macOS 10.14.4
# Kernel Version: Darwin 18.5.0
# Convert wav/aiff/flac to iTunes Plus .m4a

for file in "$@"
do
    ext=`echo "$file" | sed 's/.*\.//'`
    if [ $ext = 'wav' -o $ext = 'aiff' -o $ext = 'flac' ]; then
        extensionless=`dirname "$file"`/`basename "$file" $ext`
        m4a="${extensionless}m4a"
        caf="${extensionless}caf"

        if [ $ext = 'flac' ]; then
            data="${extensionless}wav"
            echo afconvert -d LEI16 -f WAVE $file $data
            afconvert -d LEI16 -f WAVE "$file" "$data"
        else
            data=$file
        fi

        # convert the WAVE/AIFF file to an intermediate .caf file
        echo afconvert $data $caf -d 0 -f caff --soundcheck-generate
        afconvert "$data" "$caf" -d 0 -f caff --soundcheck-generate

        # convert the intermediate .caf file to iTunes Plus format
        echo afconvert $caf -d aac -f m4af -u pgcm 2 --soundcheck-read -b 256000 -q 127 -s 2 $m4a
        afconvert "$caf" -d aac -f m4af -u pgcm 2 --soundcheck-read -b 256000 -q 127 -s 2 "$m4a"

        # remove the intermediate .caf file
        /bin/rm -f "$caf"

        # remove the intermediate .wav file if it was created from a .flac file
        if [ $ext = 'flac' ]; then
            /bin/rm -f "$data"
        fi
    fi
done
