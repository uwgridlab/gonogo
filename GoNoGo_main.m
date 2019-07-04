function GoNoGo_main(photod_loc, numblocks, numtrials)

% Notes: 
% This is a cut version of the GoNoGo_avstamp.m file, deleted commented
% code + audio files + variables that were not being used/did not seem
% too important. Original code is present if needed.
% This function depends on GoNoGo.m to provide appropriate inputs
% in order to run. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Please navigate to subject data folder')
disp('This will be where the output data files will go')
path_data = uigetdir;

imgbasepath = strcat(pwd,'\');  % base path for images
subjectID = input('subject ID? ','s');
electrodeside = input('Electrode side? ', 's'); % electrode side of brain - use keyboard with other hand
handedness = input('Hand used? ', 's');
trialno = input('Trial number? '); % how many times have we run task
filename = strcat(path_data,'\',subjectID,num2str(trialno));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup PTB with some default values
PsychDefaultSetup(2);

% give praise to rngesus and show our faith by seeding
% may not be used but what the hey
% lol did james write this 
rng('shuffle')

%set screen num to secondary monitor if one is connected
screenNumber = max(Screen('Screens'));
% screenNumber = 1;  %weirdness with how tms task computer assigns window numbers

%define black, white and grey
white = WhiteIndex(screenNumber);
grey = white/2;
black = BlackIndex(screenNumber);

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black, [], 32, 2);

% Flip to clear
Screen('Flip', window);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

%Query frame duration
ifi = Screen('GetFlipInterval', window);

%Set text size and font
Screen('TextSize', window, 60);
Screen('TextFont', window, 'Ariel');

%Set blend function for the screen
Screen('BlendFunction',window,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');

% HideCursor

%load images
bear_imgloc = strcat(imgbasepath,'bear.jpg');
lion_imgloc = strcat(imgbasepath,'lion.jpg');

bear_img = imread(bear_imgloc);
lion_img = imread(lion_imgloc);

% Make images into textures
bear_texture = Screen('MakeTexture', window, bear_img);
lion_texture = Screen('MakeTexture', window, lion_img);

% Get the size of the image (all should be same size)
[s1, s2, s3] = size(bear_img);

% define the destination rectangle for the images
dstRect = [0 0 s1 s2];
dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);

% define timestamping rectangle
% childrens - rectangle on lower right corner
% NLX - rectangle on lower left corner
ts_s1 = round(screenXpixels/20);
tsdstRect = [0 0 ts_s1 ts_s1]; 
if photod_loc == 'L'
    tsdstRect = CenterRectOnPointd(tsdstRect, round(ts_s1/2), screenYpixels-round(ts_s1/2));
elseif photod_loc == 'R'
    tsdstRect = CenterRectOnPointd(tsdstRect, screenXpixels-round(ts_s1/2), screenYpixels-round(ts_s1/2));
else
    disp('Error: please check photod_loc variable and ensure it is either R or L')
    clear all % to exit screen
    return
end

% Here we check if the image is too big to fit on the screen and abort if
% it is
if s1 > screenYpixels || s2 > screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------
%                       Trial information
%----------------------------------------------------------------------

% init data matrices
timestamps = nan(numtrials,5,numblocks);
% soundstamps = nan(numtrials,5,numblocks); % not using this rn
subj_resp = cell(numtrials,numblocks);

% randomize presentation
% code considers each column of stim_inds to be index of trials for a block
stim_inds = ones(numtrials,numblocks);

% pick [numblocks] random integers from interval of [numtrials]
% chooses random no-go indices - TODO make this adjustable 
chosen = randi(numtrials,1,numblocks);

% will only work for square stim_inds because I'm tired and lazy
% TODO - make more flexible
for i = 1:length(chosen)
    stim_inds(chosen(i),i) = 0;
end

%1 in stim_ind is go trial, 0 is NoGo trial

%----------------------------------------------------------------------
%                       Timing Information
%----------------------------------------------------------------------

%hold time, rule presentation, ISD, and stimulus presentation time in seconds and frames

%hold time
holdTimeSecs = 1.0;
holdTimeFrames = round(holdTimeSecs/ifi);

%maximum rule and stimulus/response presentation length
spTimeSecs = 1.0;
spTimeFrames = round(spTimeSecs/ifi);

%Number of frames to wait before re-drawing
waitframes = 1.0;

%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

%Defined keyboard keys that are listened for.

escapeKey = KbName('ESCAPE');
spaceKey = KbName('space');

%----------------------------------------------------------------------
%                       Fixation Cross
%----------------------------------------------------------------------

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)

% fixation cross coordinates
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];

fixCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;

%----------------------------------------------------------------------
%                       Task Loop
%----------------------------------------------------------------------

% wait until recording has started
DrawFormattedText(window, 'Please wait',...
    'center', 'center', white);
Screen('Flip', window);

% Instructions
DrawFormattedText(window, 'You will either see a picture of a \n\n lion or a bear.\n\n If you see the lion, press spacebar.\n\n If you see the bear, do nothing!\n\n Press spacebar to continue',...
    'center', 'center', white);
Screen('Flip', window);
KbStrokeWait;

% present until subject is ready; press any key to continue
DrawFormattedText(window, 'Press spacebar to begin',...
    'center', 'center', white);
Screen('Flip', window);
KbStrokeWait;

% try a couple of different timestamping methods
streamstart_time = GetSecs;
tic
for block = 1:numblocks
    
    for trial = 1:numtrials
        
        % timestamp trial start
        % timestamps(trial,1,block) = GetSecs; % TODO what happened here?
        Screen('FillRect',window,black);
        Screen('FillRect', window, white, tsdstRect); % flash
        [timestamps(trial,1,block),~,~,~,~] = Screen('Flip', window);
        
        % Cue to determine whether a response has been made
        respToBeMade = true;
        
        % Flip again to sync to vertical retrace at same time as drawing
        %fixation cross
        % timestamp fix presentation
        Screen('DrawLines', window, fixCoords,...
            lineWidthPix, white, [xCenter yCenter], 2);
        Screen('FillRect', window, white, tsdstRect); % flash 
        [timestamps(trial,2,block),~,~,~,~] = Screen('Flip', window);
        
        % Now we present the hold interval with fixation point minus one frame
        % because we presented the fixation point once already when getting a
        % time stamp
        for frame = 1:holdTimeFrames - 1
            
            % Draw the fixation point
            Screen('DrawLines', window, fixCoords,...
                lineWidthPix, white, [xCenter yCenter], 2);
            
            % Flip to the screen
            Screen('Flip', window);
        end
        
        if stim_inds(trial,block)==1  %Go trial - lions are go
            
            Screen('DrawTexture', window, lion_texture, [], dstRect, 0);
            Screen('FillRect', window, white, tsdstRect); % flash
            [timestamps(trial,3,block),~,~,~,~] = Screen('Flip', window);
            
            spTimeFramescheck = 1;
            
            while spTimeFramescheck < spTimeFrames
                
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(escapeKey)
                    subj_resp{trial,block} = 'Esc';
                    ShowCursor;
                    sca;
                    return
                elseif keyCode(spaceKey)
                    subj_resp{trial,block} = 'G';
                    timestamps(trial,4,block) = secs;
                    Screen('DrawTexture', window, lion_texture, [], dstRect, 0);
                    Screen('FillRect', window, white, tsdstRect); % flash 
                    Screen('Flip', window);
                    respToBeMade = false;
                end
                
                Screen('DrawTexture', window, lion_texture, [], dstRect, 0);
                Screen('Flip', window);
                
                spTimeFramescheck = spTimeFramescheck + 1;
                
            end
            
        else  % NoGo trial - bears are NoGo
            
            Screen('DrawTexture', window, bear_texture, [], dstRect, 0);
            Screen('FillRect', window, white, tsdstRect); % flash
            [timestamps(trial,3,block),~,~,~,~] = Screen('Flip', window);
            
            spTimeFramescheck = 1;
            
            while spTimeFramescheck<spTimeFrames
                
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(escapeKey)
                    subj_resp{trial,block} = 'Esc';
                    ShowCursor;
                    sca;
                    return
                elseif keyCode(spaceKey)
                    subj_resp{trial,block} = 'G';
                    timestamps(trial,4,block) = secs;
                    Screen('DrawTexture', window, bear_texture, [], dstRect, 0);
                    Screen('FillRect', window, white, tsdstRect); % flash 4 (?) times?
                    Screen('Flip', window);
                    respToBeMade = false;
                end
                
                Screen('DrawTexture', window, bear_texture, [], dstRect, 0);
                Screen('Flip', window);
                
                spTimeFramescheck = spTimeFramescheck + 1;
                
            end
        end
        
        Screen('FillRect',window,black);
        Screen('FillRect', window, white, tsdstRect); % flash
        [timestamps(trial,5,block),~,~,~,~] = Screen('Flip', window);
        disp(trial)
        
    end
end

DrawFormattedText(window, 'Thanks for playing!',...
    'center', 'center', white);
Screen('Flip', window);

KbStrokeWait;
ShowCursor;
sca;

save(filename)
end
