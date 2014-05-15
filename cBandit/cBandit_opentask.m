% cvMIB_opentask.m
% Initializes the screen for the vMIB task, the data output, the target
% stimuli, and the reward contingencies used throughout the task

% Set the ITI for the first trial.
iti = itimin + ((itimax - itimin) .* rand(1,1));

% reset rewards count for the current block
rewards = 0;
correctTrials = 1;

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

% initialize colors for saving
colorvar = strcat(filestart,'_colors');
rwdvar = strcat(filestart,'_rwds');

if sum(strcmp(files,filestart))<1 % but if we're wrong
    % this is the case of a whole new file
    mkdir(filestart)
    trueFirst = 1; % actually the first block w/ this name
    % so shuffle the colors accordingly to counterbalance across
    colors = colors(Shuffle(1:size(colors,1)),:);
    % and make the reward schedule for the day
    %
    %
    if walkRewards;
        [t1Rwd,t2Rwd] = generateWalkForBandit(hazard,nToGen ,[rwdLB rwdUB]);
    else % randomly assign the two bounds to the values
        [t1Rwd,t2Rwd] = generateBlockForBandit(hazard, nToGen ,[rwdLB rwdUB], minContinuousValues);
        % fu = Shuffle([rwdLB rwdUB]);
        % t1Rwd = repmat(fu(1),1,nToGen);
        % t2Rwd = repmat(fu(2),1,nToGen);
    end
    
    % make a struct w/ rewards
    rwds.t1Rwd = t1Rwd;
    rwds.t2Rwd = t2Rwd;
    rwds.counter = correctTrials;
    
    %    !!!!!!!!!!!!!!!!!!!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

dataDirectory = strcat(dataDirectory,'\',filestart);
cd(dataDirectory)

if trueFirst
    save(colorvar,'colors'); % save the colors if we just generated them
    save(rwdvar,'rwds');
else
    load(colorvar); % load the colors if this is a repeated block
    load(rwdvar); % also the reward vector w/ correct trial counter
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

t1origin = [t1x,t1y]+origin;
t2origin = [t2x,t2y]+origin;

targOrigins = [t1origin; t2origin];

gRect1 = [t1origin-gSize/2 t1origin+gSize/2];
gRect2 = [t2origin-gSize/2 t2origin+gSize/2];

targBoxes = [gRect1; gRect2];

targ_err = deg2px(targ_err, env)./2;

errorSize = deg2px(fixSize, env)./2;
errorRect = [origin origin] + [-errorSize -errorSize errorSize errorSize];

%% Assign initial targ location
curTargLoc = randi(length(theta));
curTargOri = targOrigins(curTargLoc, :);
curTargBox = targBoxes(curTargLoc, :);
curTargKey = targKeys(curTargLoc);

%% Create MIB target movies
% l1c1 -> location 1, color 1
[l1c1, l1c2, l2c1, l2c2] = deal(NaN(ceil(360/phaseStep),1));

phase = 0;  % init phase

% Create all frames of each targ movie
movies = zeros(2, 2, 360/phaseStep);
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
    
    % Make cur frame for targ 1
    frame4 = gaborColored(gSize, colors(1, :), 2, t2orientation, phase, 20, 0.5, 0.5);
    frame4 = frame4 .* env.colorDepth;
    movies(2, 1, i) = Screen('MakeTexture',w,frame4);
    
    % Make cur frame for targ 2
    frame5 = gaborColored(gSize, colors(2, :), 2, t2orientation, phase, 20, 0.5, 0.5);
    frame5 = frame5 .* env.colorDepth;
    movies(2, 2, i) = Screen('MakeTexture',w,frame5);
    
end

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
