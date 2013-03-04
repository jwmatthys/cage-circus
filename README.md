cage-circus
===========

ChucK code for constructing chance-based sound file from many source wav files.

Use:
1. .process.sh
   convert all wav files into correct format

2. chuck lauren:<number_of_soundfiles>:<length_in_min>:<percent_silence>:<seed>
   example: chuck lauren:160:60:30:4 -s

3. output is written to laurencircus_<seed>.wav
