// Cage Circus Maker -------------------------------------------
//
// by Joel Matthys
//
// No rights reserved. All code is in public domain.
//
// TODO:
// Return to reading all SFs (not just random selection)
// Possibility of organizing into chapters?

welcomeMessage();

0 => int voices;
5 => int totalMins;
30 => int max_sf_per_min;
0 => int recording;
5 => int minClipLen;
60 => int maxClipLen;
25 => int percentSilence;

if (me.args()>0) me.arg(0) => Std.atoi => voices;
if (me.args()>1) me.arg(1) => Std.atoi => totalMins;
if (me.args()>2) me.arg(2) => Std.atoi => percentSilence;
if (me.args()>3)
{
    1 => recording;
    me.arg(3) => Std.atoi => Math.srandom;
}

0.45 => dac.gain;
totalMins*minute => dur totalLength;

int files_per_min[totalMins];
int totalSounds;
setFiles_Per_Min();

// temp is just here to get the file length
SndBuf temp => blackhole;
WvOut2 out;

me.sourceDir() + "/data/" => string path;

if (recording)
{
    dac => out => blackhole;
    path+"laurencircus_"+me.arg(3) => out.wavFilename;
}

spork ~ status(minute);
render();

// FUNCTIONS ----------------------------------------------------------------

fun void render()
{
    for (int j; j<totalSounds; j++)
    {
        Math.random2(0,voices-1) => int i;
        path + Std.itoa(i+1) + ".wav" => string fn;
        fn => temp.read;
        dur testStart, testLen;
        int testMin;
        do
        {
            lowRand(minClipLen,maxClipLen)::second => testLen;
            if (temp.length() < testLen) temp.length() => testLen;
            Math.random2f(0,1) * (totalLength - testLen) => testStart;
            (testStart / minute) $ int => testMin;
        } while (files_per_min[testMin] <= 0);

        files_per_min[testMin]--;
        spork ~ playFile(fn, testStart, testLen);
    }
    (totalLength+2::second) => now;
}

fun void playFile (string filename, dur start, dur len)
{
    //<<< "playing",filename,"at time",start/second >>>;
    start => now;
    SndBuf file => ADSR adsr => Pan2 pan => dac;
    filename => file.read;
    file.samples() => int totalSamp;
    (len / samp)$int => int chunkSamp;
    Math.random2(0, totalSamp - chunkSamp) => file.pos;

    if (maybe & maybe) 1::ms => adsr.attackTime;
    else lowRand(0,0.5) * len => adsr.attackTime;
    0::samp => adsr.decayTime;
    if (maybe & maybe) 1::ms => adsr.releaseTime;
    else lowRand(0,0.5) * len => adsr.releaseTime;

    1 => adsr.sustainLevel;
    1 => adsr.keyOn;
    0 => file.pos;
    if (maybe) spork ~ stereoMotion (pan, len);
    else Math.random2f(-1,1) => pan.pan;
    (len - adsr.attackTime()) => now;
    1 => adsr.keyOff;
    adsr.releaseTime() => now;
    1::second => now;
}

fun void stereoMotion(Pan2 p, dur len)
{
    Envelope env => blackhole;
    Math.random2f(-1,1) => env.value;
    Math.random2f(-1,1) => env.target;
    len => env.duration;
    while (true)
    {
        env.value() => p.pan;
        1::ms => now;
    }
}

fun float lowRand (float low, float high)
{
    return Math.min(Math.random2f(low,high), Math.random2f(low,high));
}

fun void status (dur updateInterval)
{
    now => time startTime;
    while (true)
    {
        <<< "Progress:",((now-startTime) / minute)$int,"minutes elapsed" >>>;
        updateInterval => now;
    }
}

fun void welcomeMessage()
{
    <<< "\nCageMixer","\n" >>>;
    <<< "  Arguments:","" >>>;
    <<< "   1. number of sound files to process","" >>>;
    <<< "   2. total length in minutes","" >>>;
    <<< "   3. percentage of silence","" >>>;
    <<< "   4. random seed - also activates WavOut\n","">>>;
}

fun void setFiles_Per_Min()
{
    for (int i; i < totalMins; i++)
    {
        lowRand(1, max_sf_per_min) $ int => int formval;
        formval => files_per_min[i];
    }
    int testMin;
    repeat ((percentSilence * 0.01 * totalMins) $ int)
    {
        do
        {
            Math.random2(0,totalMins-1) => testMin;
        }
        while (files_per_min[testMin] <= 0);
        0 => files_per_min[testMin];
    }
    for (int i; i < totalMins; i++)
    {
        files_per_min[i] +=> totalSounds;
        <<< "FORM: playing", files_per_min[i] ,"audio file at minute", i >>>;
    }
    <<< "total soundfiles to play:", totalSounds >>>;
}
