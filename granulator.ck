// HID
Hid hi;
HidMsg msg;

// which keyboard
0 => int device;
// get from command line
if( me.args() ) me.arg(0) => Std.atoi => device;

// open keyboard (get device number from command line)
if( !hi.openKeyboard( device ) ) me.exit();
<<< "keyboard '" + hi.name() + "' ready", "" >>>;


1000 => int gDuration;
100 => int gGap;
10 => int maxGrains;
3 => int maxFiles;
12 => int polyphony;
0 => int index;

SndBuf sampleBufs[maxGrains];
SndBuf envBufs[maxGrains];
int notes[polyphony][2];
SndBuf sounds[maxFiles][maxGrains];

string filepaths[maxFiles];
"/Users/jakubwalerstein/Documents/Development/ChucK/Granulator/samples/018_low-glass-bow_stereo.aif" => filepaths[0];
"/Users/jakubwalerstein/Documents/Development/ChucK/Granulator/samples/000_tanpura.wav" => filepaths[1];
"/Users/jakubwalerstein/Documents/Development/ChucK/Granulator/samples/001_musicbox.aif" => filepaths[2];


//sample: buffer containing source sample
//envelope: buffer containing envelope
//position: starting file position in source sample
//rate: playback speed of source sample
//duration: duration of grain playback
fun void grain(SndBuf sample, SndBuf envelope, int position, float rate, float gain, float pan, int duration)
{  
    //addNote(me.Id()) => int status;
    //<<< status >>>;
    
    Gain g;
    gain => g.gain; 
    g => Pan2 p => dac;
    pan => p.pan;
    sample => g;
    envelope => g;
    //3 is multiplication operation
    3 => g.op;
    
    position => sample.pos;
    rate => sample.rate;
    1 => sample.loop;
    0 => envelope.pos;
    (envelope.length() / (ms*duration)) => envelope.rate; 
    duration::ms => now; //will play one grain duration gdur
    
}

//adds note to notes array, returns false if full.
//fun int addNote(int _shredId, int _key)
//{
//    for (0 => int note; note < notes.length(); note++)
//    {
//        if (notes[note][0] == 0) 
//        {
//            notes[note][0] = _shredId;
//            notes[note][1] = _key;
//            return 1;
//        }   
//    }
//    return 0;
//}

//removes note from note array and stops shred
//fun int removeNote(int _key)
//{
//   for (0 => int note; note < notes.length(); note++)
//    {
//        if (notes[note][1] == key) 
//        {
//            Machine.remove(notes[note][0]);
//            return 1;
//        }   
//    }
//    return 0;
//}

while (true)
{
    
    for (0 => int i; i < maxGrains; i++)
    {
        Math.random2f( -1.0, 1.0 ) => float gPan;
        Math.random2f(0, 1) => float gGain;
        Math.random2(0,2) => int sound; //choose sound file randomly
        filepaths[sound] => sounds[sound][i].read;
        "/Users/jakubwalerstein/Documents/Development/ChucK/Granulator/grainEnv/gEnv_gauss.aif" => envBufs[i].read;
        spork ~ grain(sounds[sound][i], envBufs[i], 10000, 1, gGain, gPan, gDuration); 
        gGap::ms => now;
    }
    
    
    15::ms => now;
    
}


1::day => now;

//while( true )
//{
    // wait for event
 //   hi => now;
    
    // get message
//    while( hi.recv( msg ) )
//    {
        // check
//        if( msg.isButtonDown() )
//        {
            //Std.mtof( msg.which + 45 ) => float freq;
            //if( freq > 20000 ) continue;
            
            //freq => organ.freq;
            //.5 => organ.gain;
            //1 => organ.noteOn;
            
            //80::ms => now;
            
//            for (0 => int i; i < maxGrains; i++)
//            {
//                Math.random2f( -1.0, 1.0 ) => float gPan;
//                Math.random2f(0, 1) => float gGain;
//               "/Users/jakubwalerstein/Documents/Development/ChucK/Granulator/samples/018_low-glass-bow_stereo.aif" => sampleBufs[i].read;
//                "/Users/jakubwalerstein/Documents/Development/ChucK/Granulator/grainEnv/gEnv_gauss.aif" => envBufs[i].read;
//                spork ~ grain(sampleBufs[i], envBufs[i], 10000, 1, gGain, gPan, gDuration); 
//                gGap::ms => now;
//            }
//        }
//        else
//        {
            //0 => organ.noteOff;
            
//        }
//    }
//}


