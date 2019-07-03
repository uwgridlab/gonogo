# Go/No Go task implemented using Psychtoolbox-3 
## Created by Kelly Collins + James Wu + potentially others
## Modified by Samantha Sun

An image of a bear or lion will appear one at a time on the screen, and the participant is instructed to press the spacebar as soon as they see an image of a lion and do nothing when a bear appears. 

Running this code requires installation of Psychtoolbox (necessary files included in the repo)
To run this code, navigate to the directory and open **GoNoGo.m**. This code contains parameters that the user can change based on the system that the code is being run on. After running the code, it will ask you to navigate to a data save directory and then proceed to run the task. To exit the task at any time, press the "Esc" key.
The original code is GoNoGo_avstamp.m (with minor modifications) and can be run standalone. 

Notes:
- "handedness" variable indicates which hand pt is using for that trial, Kelly recommends doing 2x for each hand (4 trials total)
- There used to be an audio input version where we ask subject to verbally say "lion" or "bear" into a microphone input

TODO:
- make ratio of go-no go adjustable ~ line 119 in GoNoGo_main.m
- right now it's hardcoded such that numblocks and numtrials MUST be the same, so make this more flexible ~ line 123 in GoNoGo_main.m
- figure out what the timestamps variable does + why some are commented out
