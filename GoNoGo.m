function GoNoGo

clear all; close all; clc
disp("Make sure you run this file while you're in the gonogo directory!!!")
%%%%% define parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% photod_loc - position of photodiode may change with different systems
%              childrens device/default = right/R
%              nlx device = left/L
% numblocks - number of blocks
% numtrials - number of trials in a block
saveOn = 0;         % true = 1, false = 0
photod_loc = 'L';   % responses = 'R' or 'L'
numblocks = 2;      % default = 7 *** NOTE: numblocks MUST BE EQUAL TO numtrials
numtrials = 2;      % default = 7 *** until sam fixes the code because whoever
                    % coded this task was lazy 

% run task
GoNoGo_main(saveOn, photod_loc, numblocks, numtrials)

end