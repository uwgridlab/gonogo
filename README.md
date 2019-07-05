# Go/No Go task implemented using Psychtoolbox-3 
*Created by Kelly Collins + James Wu + potentially others*

*Modified by Samantha Sun*

An image of a bear or lion will appear one at a time on the screen, and the participant is instructed to press the spacebar as soon as they see an image of a lion and do nothing when a bear appears. 

Running this code requires installation of Psychtoolbox and other software. Full instructions [here](http://psychtoolbox.org/download.html#upgrading). MUST install GStreamer + follow directions VERY CAREFULLY or be prepared for lots of headaches (I did it so you don't have to).

Alternatively, you can download the files in the [GridLabGradKids Shared Drive](https://drive.google.com/drive/u/1/folders/0AEG4iQaImNUJUk9PVA) (contact someone for access). These are download files for Psychtoolbox and GStreamer. Make sure you read the README and follow instructions to download.


To run this code, navigate to the directory and open **GoNoGo.m**. This code contains parameters that the user can change based on the system that the code is being run on. After running the code, it will ask you to navigate to a data save directory and then proceed to run the task. To exit the task at any time, press the "Esc" key.

The original code is GoNoGo_avstamp.m (with minor modifications) and can be run standalone. Make sure you change the filename variable to the gonogo directory on your computer.

Notes:
- "handedness" variable indicates which hand pt is using for that trial, Kelly recommends doing 2x for each hand (4 trials total)
- There used to be an audio input version where we ask subject to verbally say "lion" or "bear" into a microphone input

Troubleshooting:
- If Screen() isn't working, may need to update graphics card to most recent version (+ reset)
- If the text in the program looks wonky, make sure you installed [GStreamer](http://gstreamer.freedesktop.org/download/) correctly (ref download instructions). If you swear you did it correctly, check that the MATLAB path will search the GStreamer directory. 

TODO:
- make ratio of go-no go adjustable ~ line 119 in GoNoGo_main.m
- right now it's hardcoded such that numblocks and numtrials MUST be the same, so make this more flexible ~ line 123 in GoNoGo_main.m
- figure out what the timestamps variable does + why some are commented out
