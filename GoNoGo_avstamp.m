clear all; close all; clc

% filename
% filename = 'C:\Users\Grid Lab\Documents\MATLAB\GoNoGo\'; % small computer
filename = 'C:\Users\sunh20\Documents\Projects\gonogo\'; % sam's comupter
% filename = 'C:\Users\eblab\Documents\Projects\gonogo\'; % nlx computer
imgbasepath = filename;         % base path for images
addpath(genpath(filename))       % add psychtoolbox things
subjectID = input('subject ID? ','s');
electrodeside = input('Electrode side? ', 's'); %electrode side of brain - use keyboard with other hand
handedness = input('Hand used? ', 's');
trialno = input('Trial number? '); %how many times have we run task
filename = strcat(filename,subjectID, num2str(trialno));

%which hand are we working with?
% hand = input('Which hand are we working with? 0 for left, 1 for right: ');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Open connection with TDT and begin program
% DA = actxcontrol('TDevAcc.X');
% 
% %initiates a connection with an OpenWorkbench server. The connection adds a client to the server
% DA.ConnectServer('Local');
% 
% %throws error if there was a problem connecting
% if DA.CheckServerConnection==0
%     error('Client application not connect to server')
% end
% 
% % DA.SetTankName('GIVEMETHEPATH');
% 
% tdt_datafile = DA.GetTankName;


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
red = [1 0 0];

%Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black, [], 32, 2);

%Flip to clear
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

%Query max priority level
topPriorityLevel = MaxPriority(window);

%Get center coordinates of window
[xcenter, ycenter] = RectCenter(windowRect);

%Set blend function for the screen
Screen('BlendFunction',window,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');

% Init audio for timestamping
% InitializePsychSound
% InitializePsychSound(1)  %for really low latency

% soundfilename = 'C:\Users\gridlab\Documents\MATLAB\GoNoGo\1volt.wav';
% [sounddata,soundfreq] = audioread(soundfilename);
% nrchannels = 1;  %file is mono, not stereo
% reps = 1;  %only play the sound once each time it is called
% pahandle = PsychPortAudio('Open', [], [], 1, soundfreq, nrchannels);
% PsychPortAudio('FillBuffer', pahandle, sounddata');

HideCursor

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

%define the destination rectangle for the images
dstRect = [0 0 s1 s2];
dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);

%define timestamping rectangle
ts_s1 = round(screenXpixels/20);
tsdstRect = [0 0 ts_s1 ts_s1];
tsdstRect = CenterRectOnPointd(tsdstRect, screenXpixels-round(ts_s1/2), screenYpixels-round(ts_s1/2));

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

numtrials = 7;
numblocks = 7;

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

%fixation cross coordinates
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];

fixCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;

%----------------------------------------------------------------------
%                       Task Loop
%----------------------------------------------------------------------

%wait until recording has started
DrawFormattedText(window, 'Please wait',...
    'center', 'center', white);
Screen('Flip', window);

%if OpenWorkbench is not in Record mode, then this will set it to record
%then stores the time of recording start relative to the rest of the events
%that occur
% if DA.GetSysMode ~= 3
%     
%     DA.SetSysMode(3);
%     
%     while DA.GetSysMode ~= 3
%         pause(.1)
%     end
%     
%     TDT_recording_start = GetSecs;
%     
% %     % Disarm the stim - MAY NOT NEED TO DO THIS!
% %     DA.SetTargetVal('RZ5D.ArmSystem', 0);
% 
% end

%Instructions
DrawFormattedText(window, 'You will either see a picture of a \n\n lion or a bear.\n\n If you see the lion, press spacebar.\n\n If you see the bear, do nothing!\n\n Press spacebar to continue',...
    'center', 'center', white);
Screen('Flip', window);
KbStrokeWait;

%present until subject is ready; press any key to continue
DrawFormattedText(window, 'Press spacebar to begin',...
    'center', 'center', white);
Screen('Flip', window);
KbStrokeWait;

%try a couple of different timestamping methods
streamstart_time = GetSecs;
tic
for block = 1:numblocks
    
    for trial = 1:numtrials
        
        %timestamp trial start
%         timestamps(trial,1,block) = GetSecs;
        Screen('FillRect',window,black);
        Screen('FillRect', window, white, tsdstRect);
        [timestamps(trial,1,block),~,~,~,~] = Screen('Flip', window);
        %send the "sound" as event timestamp
%         soundstamps(trial,1,block) = PsychPortAudio('Start', pahandle, reps, 0, 1);
%         PsychPortAudio('Stop', pahandle);
        
        %Cue to determine whether a response has been made
        respToBeMade = true;
        
        %Flip again to sync to vertical retrace at same time as drawing
        %fixation cross
        %timestamp fix presentation
        Screen('DrawLines', window, fixCoords,...
            lineWidthPix, white, [xCenter yCenter], 2);
        Screen('FillRect', window, white, tsdstRect);
        [timestamps(trial,2,block),~,~,~,~] = Screen('Flip', window);
%         soundstamps(trial,2,block) = PsychPortAudio('Start', pahandle, reps, 0, 1);
%         PsychPortAudio('Stop', pahandle);
        
        % Now we present the hold interval with fixation point minus one frame
        % because we presented the fixation point once already when getting a
        % time stamp
        for frame = 1:holdTimeFrames - 1
            
            % Draw the fixation point
            Screen('DrawLines', window, fixCoords,...
                lineWidthPix, white, [xCenter yCenter], 2);
            
            %Flip to the screen
            Screen('Flip', window);
        end
        
        if stim_inds(trial,block)==1  %Go trial - lions are go
            
            Screen('DrawTexture', window, lion_texture, [], dstRect, 0);
            Screen('FillRect', window, white, tsdstRect);
            [timestamps(trial,3,block),~,~,~,~] = Screen('Flip', window);
%             soundstamps(trial,3,block) = PsychPortAudio('Start', pahandle, reps, 0, 1);
%             PsychPortAudio('Stop', pahandle);
            
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
                    Screen('DrawTexture', window, lion_texture, [], dstRect, 0);
                    Screen('FillRect', window, white, tsdstRect);
                    Screen('Flip', window);
%                     soundstamps(trial,4,block) = PsychPortAudio('Start', pahandle, reps, 0, 1);
%                     PsychPortAudio('Stop', pahandle);
                    respToBeMade = false;
                end
                
                Screen('DrawTexture', window, lion_texture, [], dstRect, 0);
                Screen('Flip', window);
                
                spTimeFramescheck = spTimeFramescheck + 1;
                
            end
            
        else  % NoGo trial - bears are NoGo
            
            Screen('DrawTexture', window, bear_texture, [], dstRect, 0);
            Screen('FillRect', window, white, tsdstRect);
            [timestamps(trial,3,block),~,~,~,~] = Screen('Flip', window);
%             soundstamps(trial,3,block) = PsychPortAudio('Start', pahandle, reps, 0, 1);
%             PsychPortAudio('Stop', pahandle);
            
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
                    Screen('FillRect', window, white, tsdstRect);
                    Screen('Flip', window);
%                     soundstamps(trial,4,block) = PsychPortAudio('Start', pahandle, reps, 0, 1);
%                     PsychPortAudio('Stop', pahandle);
                    respToBeMade = false;
                end
                
                Screen('DrawTexture', window, bear_texture, [], dstRect, 0);
                Screen('Flip', window);
                
                spTimeFramescheck = spTimeFramescheck + 1;
                
            end
        end
        
        %timestamp trial end, display trial number
%         timestamps(trial,5,block) = GetSecs;
        Screen('FillRect',window,black);
        Screen('FillRect', window, white, tsdstRect);
        [timestamps(trial,5,block),~,~,~,~] = Screen('Flip', window);
%         soundstamps(trial,5,block) = PsychPortAudio('Start', pahandle, reps, 0, 1);
%         PsychPortAudio('Stop', pahandle);
        disp(trial)
        
    end
end

% PsychPortAudio('Close');

DrawFormattedText(window, 'Thanks for playing!',...
    'center', 'center', white);
Screen('Flip', window);

% %if OpenWorkbench is in Record mode, then this will set it to Standby
% %then stores the time of recording stop relative to the rest of the events
% %that occur
% if DA.GetSysMode ~= 1
%     
%     DA.SetSysMode(1);
%     
%     while DA.GetSysMode ~= 1
%         pause(.1)
%     end
%     
%     TDT_recording_stop = GetSecs;
%     
% %     % Disarm the stim - MAY NOT NEED TO DO THIS!
% %     DA.SetTargetVal('RZ5D.ArmSystem', 0);
% 
% end
% 
% % Close ActiveX connection:
% DA.CloseConnection
% if DA.CheckServerConnection == 0
%     display('Server was disconnected');
% end
% clear DA

KbStrokeWait;
ShowCursor;
sca;

save(filename)
