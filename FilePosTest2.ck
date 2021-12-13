//find longest sequence of same band windows, set file pos in the middle
[0,2,1,1,1,0,0,1,1,1,1,1,0,0,1,1,0,0,0,1,0] @=> int windows[];
21 => int numWindows;

1 => int bandChoice;
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

<<< startOfLongSeq >>>;
<<< maxLength >>>;