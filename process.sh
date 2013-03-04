#!/bin/bash
i=1;
for file in *.wav;
do ffmpeg -i "$file" -ar 44100 $i.wav; i=`expr $i + 1`;
done
normalize-audio *.wav
