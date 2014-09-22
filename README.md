ECE382_Lab2
===========
##Subroutines - "Cryptography"
###Purpose
Practice programming skills by writing subroutines, using both call-by-reference and call-by-value to pass information to the subroutines
###Preliminary Design
I created the following flowchart to try and guide me in my work:
![alt text](https://github.com/mbergstedt/ECE382_Lab2/blob/master/Flowchart.JPG?raw=true)

The initial flowchart is incorrect, since the pass by reference should be before the first subroutine, and the pass by value should be inside of the first subroutine.  In my flowchart, I have them swapped.
###Hardware Design
The hardware for this lab is just the chip plugged into the computer.
###Debugging
I ran the debugger for each part that I wrote.  I primarily used the debugger to check that my method for finding the length of the message, and later the length of the key, ran correctly.  Initially, the value was one too high because I was using the wrong jump for the situation, using a jhs rather than a jne.  I also used the debugger at the beginning of my first subroutine, and I ran through each line of the routine to see that it was running correctly.  When I tested A functionality, I encountered a problem where one of the values would be reset to al zeros, which would run the program without end.
###Testing Methodology/Results
I used the provided encrypted messages for each of the functionalities.  After finishing the run through, I would go to the start of RAM in memory and change the viewing method to character.  Correct answers presented logical messages in RAM.  For A functionality, using the hint from B functionality, I ran through the code for a space, and found the value for the first part of the key.  I then used the parts of the message that I had and saw that I needed to run through the vowels.  After testing my first vowel, I obtained the full message.
###Observations/Conclusions
When I started coding for A functionality, I encountered an issue where one of my values got reset incorrectly and presented the issue of entering an unintentional infinite loop.  Because I hadn't been checking the value, the program had been going through a different process than I had intended and it had been breaking the program.  Additionally, I noticed in solving the first two functionalities that the final character had been a #.  Therefore, when I went to try to find the key for A functionality, I tried using the code for a #.  However, these results gave jumbled answers and I tested for spaces.
###Documentation
None
