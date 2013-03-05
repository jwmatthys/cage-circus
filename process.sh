#!/bin/bash
i=1;
for file in orig_audio/*.wav;
do ffmpeg -i "$file" -ac 1 -ar 44100 ../data/$i.wav; i=`expr $i + 1`;
done
normalize-audio data/*.wav
