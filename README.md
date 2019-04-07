# Tick Tick
Written by Calum Lindsay.  
 A while ago I stumbled across [this paper](http://algorithmicbotany.org/papers/lsfp.pdf) and was intrigued so I made this small program capable of generating some of the fractals described in the paper copying a few of the patterns in the paper and attempting a couple of my own. It's not very easy to read however as it was never really intended to be but I think I might come back to it and tidy up because it's really quite a fascinating subject.

## How to run it
You will need the LÖVE Engine to run it which you can get [here](https://love2d.org "LÖVE 2D's Homepage"). Download any of the zipped versions, extract them and drag the folder containing Lovely Snake's source code onto the "love.exe" executable.

## Controls
- Up and Down to zoom in and out
- Left and Right to step generator back and forward
- Comma and Dot to change generators

## Possible future improvements / problems
- Tidy & Comment 
- Make a generator class
- Why not push actor:getCopy() onto stack instead of actors fields
- Optimize to allow more steps without lag