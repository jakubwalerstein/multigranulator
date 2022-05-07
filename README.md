# multigranulator
A granulator written in ChucK with some novel features

Start by downloading ChucK from this link, then install
https://chuck.cs.princeton.edu/release/

granulator_multi.ck is the file to run here, use on the command line like this:

chuck granulator_multi.ck:"examplefilepath.wav":mid:"anotherfilepath.wav":low

Each file should have either "low", "mid", "high", or "beginning" written after it. 
This is used to determine where to set the file position used by the granulator.
"low" chooses a section with lots of low frequency content.
"mid" chooses a section with lots of mid frequency content.
"high" chooses a section with lots of high frequency content.
"beginning" places the file position at the beginning of the file.
This feature works best on tonal sounds without much noise. 

Add as many files as you want! Just try to avoid very short files (under 1 second) or very long files (analysis time increases linearly). 

Sessions are automatically recorded as files written to the output folder. 

Enjoy!