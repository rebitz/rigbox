% cvMIB_opentask.m
% Initializes the screen for the vMIB task, the data output, the target
% stimuli, and the reward contingencies used throughout the task

% Set the ITI for the first trial.
iti = itimin + ((itimax - itimin) .* rand(1,1));

% reset rewards count for the current block
rewards = 0;
correctTrials = 1; % only resets if true first

% target keys
targKeys = [up left right];

%% Ensure output

% Initialize outputs
global task_data;
task_data = struct();
global trial_data;
trial_data = struct([]);

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

% assume this is not the actual first run
trueFirst = 0;
files = dir;
files = {files([files.isdir]==1).name};

if sum(strcmp(files,filestart))<1 % but if we're wrong
    mkdir(filestart)
    trueFirst = 1; % actually the first block w/ this name
    
    % go grab the choice vector that we want to replay
    cd(replayDirectory)
    files = dir;
    folders = {files([files.isdir]).name};
    folders = folders(cellfun(@isempty,strfind(folders,'.')));
    pickFolders = randperm([1:length(folders)]);
    cd(folders{pickFolders(1)}); % now we're in a particular session
    
    replayConcatBlocks;
    
    t1Rwd = choices == 1;
    t2Rwd = choices == 2;
    t3Rwd = choices == 3;
    % if no choice was made, no reward is available?
    
    % make a struct w/ rewards
    rwds.t1Rwd = t1Rwd;
    rwds.t2Rwd = t2Rwd;
    rwds.t3Rwd = t3Rwd;
    rwds.counter = correctTrials;
    rwds.choices = choices;
end

dataDirectory = strcat(dataDirectory,splitChar,filestart);
cd(dataDirectory)

% initialize colors for saving
rwdvar = strcat(filestart,'_rwds');

if trueFirst
    save(rwdvar,'rwds'); % save the reward vectors we just generated
else
    load(rwdvar); % load the reward vector w/ correct trial counter
end

zpad = '_00';

if ~isdir(filename)
    mkdir(filename)
else
    i = 1;

    filename = strcat(filestart,zpad,num2str(i));
    while isdir(filename)
        i = i+1;
        if i > 10
            zpad = '_0';
        end
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
orientations = theta;
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

t1Rect = [t1origin-gSize/2 t1origin+gSize/2];
t2Rect = [t2origin-gSize/2 t2origin+gSize/2];
t3Rect = [t3origin-gSize/2 t3origin+gSize/2];

targ_err = deg2px(targ_err, env)./2;

errorSize = deg2px(fixSize, env)./2;
errorRect = [origin origin] + [-errorSize -errorSize errorSize errorSize];

% cue rectangles
cOffset = deg2px(cOffset, env);

[c1x, c1y] = pol2cart(theta(1),cOffset);
[c2x, c2y] = pol2cart(theta(2),cOffset);
[c3x, c3y] = pol2cart(theta(3),cOffset);

c1end = [c1x, c1y] + origin;
c2end = [c2x, c2y] + origin;
c3end = [c3x, c3y] + origin;

cueBox1 = [origin c1end];
cueBox2 = [origin c2end];
cueBox3 = [origin c3end];

%% Create MIB target movies
% l1c1 -> location 1, color 1
[t1Mov,t2Mov,t3Mov] = deal(NaN(ceil(360/phaseStep),1));

phase = 0;  % init phase

% Create all frames of each targ movie
movies = zeros(3, 3, 360/phaseStep);
for i = 1:(360/phaseStep);
    
    phase = phase + phaseStep;
    
    % Make cur frame for targ 1
    frame = gabor(gSize, 2, t1orientation, phase, 20, 0.5, 0.5);
    frame = frame .* env.colorDepth;
    t1Mov(i) = Screen('MakeTexture',w,frame);
    
    % Make cur frame for targ 2
    frame = gabor(gSize, 2, t2orientation, phase, 20, 0.5, 0.5);
    frame = frame .* env.colorDepth;
    t2Mov(i) = Screen('MakeTexture',w,frame);
    
    % Make cur frame for targ 3
    frame = gabor(gSize, 2, t3orientation, phase, 20, 0.5, 0.5);
    frame = frame .* env.colorDepth;
    t3Mov(i) = Screen('MakeTexture',w,frame);
    
end

%% Make Eyelink start recording

if EYEBALL
    Eyelink('startrecording');
end

%% Save all the task data

task_data.firstBlock = trueFirst;
task_data.ntrialsSpecified = ntrials;
task_data.eyeball = EYEBALL;
task_data.testing = TESTING;
task_data.dataDir = dataDirectory;
task_data.filename = filename;

task_data.time2fix = time2fix;
task_data.fixHoldMin = fixHoldMin;
task_data.fixHoldMax = fixHoldMax;
task_data.cueLatencyMin = fixHoldMin;
task_data.cueLatencyMax = fixHoldMax;
task_data.cueOnTime = cueOnT;

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

