function GoNoGo

disp("Make sure you run this file while you're in the gonogo directory!!!")
%%%%% define parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% system - position of photodiode may change with different systems
%           childrens device = 0
%           nlx device = 1
%           sam's computer = 2

system = 2;
numblocks = 7; % default = 7 *** NOTE: numblocks MUST BE EQUAL TO numtrials
numtrials = 7; % default = 7 *** until sam fixes the code because whoever
%                                coded this task was lazy 

% run task
GoNoGo_main(system, numblocks, numtrials)

end