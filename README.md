# multigranulator
A granulator written in ChucK with some novel features

granulator_multi.ck is the file to run here, use on the command line like this:

chuck granulator_multi.ck:"examplefilepath.wav":mid:"anotherfilepath.wav":low

each file should have either "low", "mid", "high", or "beginning" written after it. this is used to determine where to set the file position used by the granulator
"low" chooses a section with lots of low frequency content
"mid" chooses a section with lots of mid frequency content
"high" chooses a section with lots of high frequency content
"beginning" places the file position at the beginning of the file

add as many files as you want! just try to avoid very short files (under 1 second) or very long files (analysis time increases linearly)
