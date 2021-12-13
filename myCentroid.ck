SndBuf s => FFT fft =^ Centroid cent => blackhole;

//"/Users/jakubwalerstein/Documents/Development/ChucK/Granulator/samples/sine.wav" => s.read;
"/Users/jakubwalerstein/Documents/Development/ChucK/Granulator/samples/lowmidhi.wav" => s.read;

// set parameters
512 => fft.size;
// set hann window
Windowing.hann(512) => fft.window;
// compute srate
second / samp => float srate;

s.samples() => int numSamples;
fft.size() => int fftSamples;

s.samples() / fft.size() => int numLoops;
<<< s.samples() >>>;
<<< fft.size() >>>;
<<< numLoops >>>;
<<< s.length() >>>; 

for (0 => int i; i < numLoops; i++)
{
   cent.upchuck();
    // print out centroid
    <<< cent.fval(0) * srate / 2>>>;
    
    // advance time
    fft.size()::samp => now;
}

