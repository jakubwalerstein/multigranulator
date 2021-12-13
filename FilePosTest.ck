0.0 => float lowBandMin;
250.0 => float lowBandMax;
250.0 => float midBandMin;
2500.0 => float midBandMax;
2500.0 => float hiBandMin;
12000.0 => float hiBandMax;
1 => int bandChoice;

SndBuf s => FFT fft =^ Centroid cent => blackhole;

"/Users/jakubwalerstein/Documents/Development/ChucK/Granulator/samples/lowhi.wav" => s.read;

// set parameters
512 => fft.size;
// set hann window
Windowing.hann(512) => fft.window;
// compute srate
second / samp => float srate;

s.samples() => int numSamples;
fft.size() => int fftSamples;

<<< s.samples() >>>;

s.samples() / fft.size() => int numWindows;
float windows[numWindows];

<<<srate>>>;

if (numWindows > 1)
{
    for (0 => int i; i < numWindows; i++)
    {
        cent.upchuck();
        // print out centroid
        //<<< "frequency:", cent.fval(0) * srate / 2>>>;
        //<<< "centroid val", cent.fval(0) >>>;
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
    
    <<< "start of long seq", startOfLongSeq >>>;
    <<< "max length", maxLength >>>;
    
    startOfLongSeq + (maxLength / 2) => int windowPos;
    windowPos * fft.size() => int filePos;
    <<< "filepos", filePos >>>;
}
else 
{
    //in this case, the file is too short to make an informed choice, beginning of buffer is returned 
    <<< "File is too short to analyze" >>>;
}