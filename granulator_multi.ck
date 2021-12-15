//set defaults
1000 => int gDuration; //in samples
100 => int gGap; //in samples
10 => int maxGrains; //number of simultaneous grains
3 => int maxFiles; //number of input files
300 => int grainSpray; //amount file selection is allowed to vary by

//band cutoffs in Hz
0.0 => float lowBandMin;
250.0 => float lowBandMax;
250.0 => float midBandMin;
2500.0 => float midBandMax;
2500.0 => float hiBandMin;
25000.0 => float hiBandMax;

if (me.args())
{
    if (me.args() % 2 != 0)
    {
        <<< "Please check number of arguments!" >>>;
        me.exit();
    }
    me.args() / 2 => maxFiles;
}

"/Users/jakubwalerstein/Documents/Development/ChucK/Granulator/envelopes/gEnv_blackman.aif" => string envelopeFilepath;
SndBuf envBufs[maxGrains];
SndBuf sounds[maxFiles][maxGrains];//store sound buffers for each sound's grains
int soundsFilePos[maxFiles][2];//store file positions for each sound, as well as sample length

string sampleFilepaths[maxFiles];
int sampleBandChoice[maxFiles];

if (me.args())
{
    for (0 => int k; k < me.args(); k++)
    {
        me.arg(k) => sampleFilepaths[k/2];
        me.arg(k+1) => string bandInt;
        if (bandInt == "low")
        {
            0 => sampleBandChoice[k/2];
        }
        else if (bandInt == "mid")
        {
            1 => sampleBandChoice[k/2];
        }
        else if (bandInt == "high")
        {
            2 => sampleBandChoice[k/2];
        }
        else if (bandInt == "beginning")
        {
            -1 => sampleBandChoice[k/2];
        }
        else 
        {
            <<< "Bands can only be low, mid, or high! Alternatively, type beginning to start at the beginning of a file." >>>;
            me.exit();
        }
        k++;
    }
}
else 
{
    //use default files
    "/Users/jakubwalerstein/Documents/Development/ChucK/Granulator/samples/018_low-glass-bow_stereo.aif" => sampleFilepaths[0];
    "/Users/jakubwalerstein/Documents/Development/ChucK/Granulator/samples/000_tanpura.wav" => sampleFilepaths[1];
    "/Users/jakubwalerstein/Documents/Development/ChucK/Granulator/samples/001_musicbox.aif" => sampleFilepaths[2];
    -1 => sampleBandChoice[0];
    -1 => sampleBandChoice[1];
    -1 => sampleBandChoice[2];
    <<< "Default files selected" >>>;
}

<<< "Analyzing input files..." >>>;

//sample: buffer containing source sample
//envelope: buffer containing envelope
//position: starting file position in source sample
//rate: playback speed of source sample
//duration: duration of grain playback
fun void grain(SndBuf sample, SndBuf envelope, int position, float rate, float gain, float pan, int duration)
{  
    Gain g;
    gain => g.gain; 
    g => Pan2 p => JCRev rev => dac; //panning per grain
    pan => p.pan;
    0.0 => rev.mix;//set reverb mix
    sample => g;
    envelope => g;
    //3 is multiplication operation, applies selected envelope to grain
    3 => g.op;
    
    position => sample.pos;
    rate => sample.rate;
    1 => sample.loop;
    0 => envelope.pos;
    (envelope.length() / (ms*duration)) => envelope.rate; //change envelope playback rate to match input file
    duration::ms => now; //will play one grain duration
    
}

//fileName: filename to analyze
//bandChoice: 0 means low freq, 1 means mid freq, 2 means hi freq, -1 means no preference
//returns int filepos that fulfills bandchoice
fun int chooseFilePos(string fileName, int bandChoice)
{
    if (bandChoice == -1)
    {
        //user has asked for filepos to be placed at beginning of file
        return 0;
    }
    
    SndBuf s => FFT fft =^ Centroid cent => blackhole;
    
    fileName => s.read;
    
    // set parameters
    512 => fft.size;
    // set hann window
    Windowing.hann(512) => fft.window;
    // compute srate
    second / samp => float srate;
    
    s.samples() / fft.size() => int numWindows;
    float windows[numWindows];
    
    if (numWindows > 1)
    {
        //populate windows[]
        for (0 => int i; i < numWindows; i++)
        {
            cent.upchuck();
            // print out centroid
            //<<< "frequency:", cent.fval(0) * srate / 2>>>;
            
            cent.fval(0) * srate / 2 => float windowFreq;
            float windowBand;
            
            if (cent.fval(0) == 0.5)
            {
                -1 => windows[i];
                //<<< "No strong frequency detected" >>>;
            }
            else if (windowFreq > lowBandMin && windowFreq <= lowBandMax)
            {
                0 => windows[i];
            }
            else if (windowFreq > midBandMin && windowFreq <= midBandMax)
            {
                1 => windows[i];
            }
            else if (windowFreq > hiBandMin && windowFreq <= hiBandMax)
            {
                2 => windows[i];
            }
            else
            {
                -1 => windows[i];
                //<<< "Out of range frequency detected" >>>;
            }
            
            //<<< "window", i, "band", windows[i] >>>;
            
            // advance time
            fft.size()::samp => now;
        }
        
        //find longest sequence of same band windows, set file pos in the middle
        0 => int maxLength;
        0 => int currentLength;
        0 => int startOfCurrentSeq;
        0 => int startOfLongSeq;
        for (0 => int j; j < numWindows; j++)
        {
            if (windows[j] == bandChoice)
            {
                //set start of current sequence 
                if (currentLength == 0)
                {
                    j => startOfCurrentSeq;
                }
                
                currentLength++;
                
                if (currentLength >= maxLength)
                {
                    currentLength => maxLength;
                    if (startOfCurrentSeq != startOfLongSeq)
                    {
                        startOfCurrentSeq => startOfLongSeq;
                    }
                }
            }
            else 
            {
                0 => currentLength;
            }   
        }
        
        startOfLongSeq + (maxLength / 2) => int windowPos;
        windowPos * fft.size() => int filePos;
        <<< "File position chosen: sample number", filePos, "of", s.samples() >>>;
        return filePos;
    }
    else 
    {
        //in this case, the file is too short to make an informed choice, beginning of buffer is returned 
        <<< "File is too short to analyze" >>>;
        return 0; 
    }
}

fun int varyFilePos(int filePos, int sampleLength, string fileName)
{
    Math.random2(filePos-grainSpray,filePos+grainSpray) => int newFilePos;
    
    if (newFilePos < 0)
    {
        0 => newFilePos;
    }
    if (newFilePos > (sampleLength - gDuration))
    {
        (sampleLength - gDuration) => newFilePos;
    }
    return newFilePos;
}

//select a file position for each input file
for (0 => int j; j < maxFiles; j++)
{
    chooseFilePos(sampleFilepaths[j], sampleBandChoice[j]) => soundsFilePos[j][0]; //write filepos to array
    SndBuf tmp;
    sampleFilepaths[j] => tmp.read;
    if (tmp.samples() < gDuration)
    {
        <<< "File is too short! Please choose a longer sound file." >>>;
        me.exit();
    }
    tmp.samples() => soundsFilePos[j][1]; //write total number of samples to array
}


//chooseFilePos(sampleFilepaths[0], 0) => soundsFilePos[0];
//chooseFilePos(sampleFilepaths[1], 1) => soundsFilePos[1];
//chooseFilePos(sampleFilepaths[2], 2) => soundsFilePos[2];
//<<< soundsFilePos[0], soundsFilePos[1], soundsFilePos[2] >>>; 

//main loop
while (true)
{
    for (0 => int i; i < maxGrains; i++)
    {
        Math.random2f( -1.0, 1.0 ) => float gPan; //vary pan randomly
        Math.random2f(0.5, 1) => float gGain; //vary gain randomly
        Math.random2(0,maxFiles-1) => int soundChoice; //choose sound file randomly
        Math.random2f(0.99,1.01) => float rate; //vary pitch randomly
        sampleFilepaths[soundChoice] => sounds[soundChoice][i].read;
        varyFilePos(soundsFilePos[soundChoice][0], soundsFilePos[soundChoice][1], sampleFilepaths[soundChoice]); 
        envelopeFilepath => envBufs[i].read;
        spork ~ grain(sounds[soundChoice][i], envBufs[i], soundsFilePos[soundChoice][0], rate, gGain, gPan, gDuration); 
        gGap::ms => now;
    }
    
    
    15::ms => now;
    
}


1::day => now;




