% cvMIB_opentask.m
% Initializes the screen for the vMIB task, the data output, the target
% stimuli, and the reward contingencies used throughout the task

% Initialize trial number
trialnum = 0;

% Flag to keep running task
continue_running = 1;

% Set the ITI for the first trial.
iti = itimin + ((itimax - itimin) .* rand(1,1));

%% Initialize screen and keyboard fns

Screen('CloseAll'); % Screen clear
warning('off','MATLAB:dispatcher:InexactMatch');
warning('off','MATLAB:dispatcher:InexactCaseMatch');
Screen('Preference','VisualDebugLevel', 0);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'SkipSyncTests',1);

% setup the global environmental variables
global env w

% open the DIO, make sure we can access everything
setupDIO;
env.allDIOclosed = flags;
env.nports = nports;
env.digOut = digOut;

% Create new window and record size
[w, rect] = Screen('OpenWindow',env.screenNumber,env.colorDepth/2); % window Idx
[env.screenWidth, env.screenHeight] = WindowSize(w);

% %Set priority for script execution to realtime priority:
% priorityLevel=MaxPriority(w);
% Priority(priorityLevel);

% open the DIO, make sure we can access everything
%setupDIO;
%env.allDIOclosed = flags;
%env.nports = nports;
%env.digOut = digOut;

% Define origin of screen
origin = [(rect(3) - rect(1))/2 (rect(4) - rect(2))/2];

% Reseed random
% RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));

% Switch KbName into unified mode: It will use the names of the OS-X
% platform on all platforms in order to make this script portable:
KbName('UnifyKeyNames');
space = KbName('SPACE');
esc = KbName('ESCAPE');
right = KbName('RightArrow');
left = KbName('LeftArrow');
up = KbName('UpArrow');
down = KbName('DownArrow');
shift = KbName('RightShift');
stopkey = KbName('ESCAPE');
juicekey = KbName('f1');

targKeys = [up left right];

%% Ensure output

% Initialize outputs
global task_data;
task_data = struct();
global trial_data;
trial_data = struct([]);

% Connection with Eyelink if not in testing mode
if EYEBALL
    try       
        if Eyelink('IsConnected') ~= 1
            disp('Trying to connect to Eyelink, attempt #1(/2):');
            r = Eyelink('Initialize');
            if r ~= 0
                WaitSecs(.5) % wait half a sec and try again
                disp('Trying to connect to Eyelink, attempt #2(/2):');
                r = Eyelink('Initialize');
            end
        elseif Eyelink('IsConnected') == 1
            r = 0; % means OK initialization
        end

        if r == 0;
            disp('Eyelink successfully initialized!')
            % Get origin
            eyeparams.origin = origin;

            Eyelink('Command', 'screen_pixel_coords = %d %d %d %d', ...
                rect(1), rect(2), rect(3), rect(4) );
            Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA,PUPIL');
            edfname = 'ef.edf';
            Eyelink('openfile',edfname);

            % Calibrate tracker
            Eyelink('StartSetup');
            Eyelink('DriftCorrStart', origin(1), origin(2));
            Eyelink('ApplyDriftCorr');

            % Start of the task
            taskstart = GetSecs;
        elseif r ~= 0
            % If Eyelink can't initialize: report error and quit
            disp('Eyelink failed to initialize, check connections');
            continue_running = 0;
        end

    catch
        % If Eyelink can't initialize: report error and quit
        disp('Eyelink failed to initialize, check connections');
        continue_running = 0;
    end
end

% Name datafile in case it was forgotten
if ~exist('filename')
    disp('Subject name not provided, using unnamed as name')
    subject = sprintf('unnamed');
else
    subject = filename;
end;

% Create directory where data will be stored
filestart = filename;
filename = strcat(filename,'_001');

cd(dataDirectory)

trueFirst = 0;
files = dir;
files = {files([files.isdir]==1).name};

colorvar = strcat(filestart,'_colors');

if sum(strcmp(files,filestart))<1
    mkdir(filestart)
    trueFirst = 1; % actually the first block w/ this name
    % so shuffle the colors accordingly to counterbalance across
    colors = colors(Shuffle(1:size(colors,1)),:);
end

dataDirectory = strcat(dataDirectory,'\',filestart);
cd(dataDirectory)

if trueFirst
    save(colorvar,'colors'); % save the colors if we just generated them
else
    load(colorvar); % load the colors if this is a repeated block
end

zpad = '_00';

if ~isdir(filename)
    mkdir(filename)
else
    i = 1;
    if i > 10
        zpad = '_0';
    end
    filename = strcat(filestart,zpad,num2str(i));
    while isdir(filename)
        i = i+1;
        filename = strcat(filestart,zpad,num2str(i));
    end
    mkdir(filename);
end

cd(filename)
backhome = pwd;

%% Setup MIB target stimuli

% Movement always tangent to the circle
% Orientation should be between 0 and 90 to make sure we know direction

%   NEED RIGHT GABOR.M to make this work -> orientation = orientation+90;

% Get orientations for targs
orientations = -1*theta;
%orientations(orientations >= 180) = -1*orientations(orientations >= 180);
t1orientation = orientations(1);
t2orientation = orientations(2);
t3orientation = orientations(3);

% Convert targ features to appropriate units
theta = deg2rad(theta);
tOffsetDG = tOffset;
tOffset = deg2px(tOffset, env);

% For diode testing
diodeRect = [(rect(3)-60) (rect(4)-60) rect(3) rect(4)];
diodeColor = [255 255 255];

% Setup stimuli and fixation rects
fixSize = deg2px(fixSize, env)./2;
fixRect = [origin origin] + [-fixSize -fixSize fixSize fixSize];
fix_err = deg2px(fix_err, env)./2;

[t1x, t1y] = pol2cart(theta(1),tOffset);
[t2x, t2y] = pol2cart(theta(2),tOffset);
[t3x, t3y] = pol2cart(theta(3),tOffset);

t1origin = [t1x,t1y]+origin;
t2origin = [t2x,t2y]+origin;
t3origin = [t3x,t3y]+origin;

targOrigins = [t1origin; t2origin; t3origin];

gRect1 = [t1origin-gSize/2 t1origin+gSize/2];
gRect2 = [t2origin-gSize/2 t2origin+gSize/2];
gRect3 = [t3origin-gSize/2 t3origin+gSize/2];

targBoxes = [gRect1; gRect2; gRect3];

targ_err = deg2px(targ_err, env)./2;

errorSize = deg2px(fixSize, env)./2;
errorRect = [origin origin] + [-errorSize -errorSize errorSize errorSize];

%% Assign initial targ location
curTargLoc = randi(3);
curTargOri = targOrigins(curTargLoc, :);
curTargBox = targBoxes(curTargLoc, :);
curTargKey = targKeys(curTargLoc);

%% Create MIB target movies
% l1c1 -> location 1, color 1
[l1c1, l1c2, l1c3, l2c1, l2c2, l2c3, l3c1, l3c2, l3c3] = deal(NaN(ceil(360/phaseStep),1));

phase = 0;  % init phase

% Create all frames of each targ movie
movies = zeros(3, 3, 360/phaseStep);
for i = 1:(360/phaseStep);
    
    phase = phase + phaseStep;
    
    % Make cur frame for location 1, color 1
    frame1 = gaborColored(gSize, colors(1, :), 2, t1orientation, phase, 20, 0.5, 0.5);
    frame1 = frame1 .* env.colorDepth;
    movies(1, 1, i) = Screen('MakeTexture',w,frame1);
    
    % Make cur frame for targ 2
    frame2 = gaborColored(gSize, colors(2, :), 2, t1orientation, phase, 20, 0.5, 0.5);
    frame2 = frame2 .* env.colorDepth;
    movies(1, 2, i) = Screen('MakeTexture',w,frame2);
    
    % Make cur frame for targ 3
    frame3 = gaborColored(gSize, colors(3, :), 2, t1orientation, phase, 20, 0.5, 0.5);
    frame3 = frame3 .* env.colorDepth;
    movies(1, 3, i) = Screen('MakeTexture',w,frame3);
    
    % Make cur frame for targ 1
    frame4 = gaborColored(gSize, colors(1, :), 2, t2orientation, phase, 20, 0.5, 0.5);
    frame4 = frame4 .* env.colorDepth;
    movies(2, 1, i) = Screen('MakeTexture',w,frame4);
    
    % Make cur frame for targ 2
    frame5 = gaborColored(gSize, colors(2, :), 2, t2orientation, phase, 20, 0.5, 0.5);
    frame5 = frame5 .* env.colorDepth;
    movies(2, 2, i) = Screen('MakeTexture',w,frame5);
    
    % Make cur frame for targ 3
    frame6 = gaborColored(gSize, colors(3, :), 2, t2orientation, phase, 20, 0.5, 0.5);
    frame6 = frame6 .* env.colorDepth;
    movies(2, 3, i) = Screen('MakeTexture',w,frame6);
    
    % Make cur frame for targ 1
    frame7 = gaborColored(gSize, colors(1, :), 2, t3orientation, phase, 20, 0.5, 0.5);
    frame7 = frame7 .* env.colorDepth;
    movies(3, 1, i) = Screen('MakeTexture',w,frame7);
    
    % Make cur frame for targ 2
    frame8 = gaborColored(gSize, colors(2, :), 2, t3orientation, phase, 20, 0.5, 0.5);
    frame8 = frame8 .* env.colorDepth;
    movies(3, 2, i) = Screen('MakeTexture',w,frame8);
    
    % Make cur frame for targ 3
    frame9 = gaborColored(gSize, colors(3, :), 2, t3orientation, phase, 20, 0.5, 0.5);
    frame9 = frame9 .* env.colorDepth;
    movies(3, 3, i) = Screen('MakeTexture',w,frame9);
    
end

%% make audo feedback

makeAudioFeedback;
env.rwdSound = rwdSound;
env.norwdSound = norwdSound;
env.soundSF = sf;

rewards = 0;

%% Make Eyelink start recording

if EYEBALL
    Eyelink('startrecording');
end

%% Save all the task data

task_data.firstBlockOfColors = trueFirst;
task_data.ntrialsSpecified = ntrials;
task_data.eyeball = EYEBALL;
task_data.testing = TESTING;
task_data.dataDir = dataDirectory;
task_data.filename = filename;

task_data.time2fix = time2fix;
task_data.fixHoldTime = fixHoldTime;
task_data.fixcolor = fixcolor;
task_data.fixSize = fixSize;
task_data.fix_err = fix_err;
task_data.fix_loc = origin;

task_data.itimin = itimin;
task_data.itimax = itimax;

task_data.theta = theta;
task_data.tOffset = tOffset;
task_data.targEcc = tOffsetDG;
task_data.maxFrames = maxFrames;
task_data.gSize = gSize;
task_data.phaseStep = phaseStep;

task_data.showTime = showTime;
task_data.targHoldTime = targHoldTime;
task_data.targ_err = targ_err;
task_data.t1origin = t1origin;
task_data.t2origin = t2origin;
task_data.t3origin = t3origin;

task_data.rwds = rwds;

task_data.screenNumber = env.screenNumber;
task_data.env = env;

if EYEBALL 
    r = Eyelink('RequestTime');
    if r == 0
        WaitSecs(0.1); %superstition
        beforeTime = GetSecs();
        trackerTime = Eyelink('ReadTime'); % in ms
        afterTime = GetSecs();
        
        pcTime = mean([beforeTime,afterTime]); % in s
        task_data.pcTime = pcTime;
        task_data.trackerTime = trackerTime;
        task_data.trackerOffset = pcTime - (trackerTime./1000);
        % would make legit time = (eyeTimestamp/1000)+offset
    end
end

cd(backhome)
save(strcat(filename,'task_data'), 'task_data');
