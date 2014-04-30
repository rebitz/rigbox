% vMIB_opentask.m
% Initializes the screen for the vMIB task, the data output, the target
% stimuli, and the reward contingencies used throughout the task

% Initialize trial number
trialnum = 0;

% Flag to keep running task
continue_running = 1;

% Set the ITI for the first trial.
iti = itimax + (itimin - itimax) .* rand(1,1);

%% Initialize screen and keyboard fns

Screen('CloseAll'); % Screen clear
warning('off','MATLAB:dispatcher:InexactMatch');
warning('off','MATLAB:dispatcher:InexactCaseMatch');
Screen('Preference','VisualDebugLevel', 0);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'SkipSyncTests',1);

% Create new window and record size
[w, rect] = Screen('OpenWindow',env.screenNumber,env.colorDepth/2); % window Idx

global env
[env.screenWidth, env.screenHeight] = WindowSize(w);

% Define origin of screen
origin = [(rect(3) - rect(1))/2 (rect(4) - rect(2))/2];

% Reseed random
%RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
rng('shuffle');

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

%% Ensure output

% Initialize outputs
global task_data;
task_data = struct();
global trial_data;
trial_data = struct([]);

% Create directory where data will be stored
cd(dataDirectory)
try
    if ~exist(filename, 'dir')
        mkdir(filename)
    end
end

cd(filename)
backhome = pwd;

save params

c = clock;
save starttime c

% Connection with Eyelink if not in testing mode
if ~TESTING
    if ~Eyelink('IsConnected');
        Eyelink('Initialize');
    end
    EYEBALL = Eyelink('IsConnected');
end

if EYEBALL
    
    % Get origin
    eyeparams.origin = origin;
    
    Eyelink('Command', 'screen_pixel_coords = %d %d %d %d', ...
        rect(1), rect(2), rect(3), rect(4) );
    EYELINK('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA,PUPIL');
    edfname = 'ef.edf';
    EYELINK('openfile',edfname);
    
    % Calibrate tracker
    EYELINK('StartSetup');
    EYELINK('DriftCorrStart', origin(1), origin(2));
    EYELINK('ApplyDriftCorr');
    
    % Start of the task
    taskstart = Getsecs;
    
elseif ~TESTING
    
    % If Eyelink can't initialize: report error and quit
    disp('Eyelink failed to initialize, check connections');
    return;
    
end;

% Name datafile in case it was forgotten
if ~exist('filename')
    disp('Subject name not provided, using unnamed as name')
    subject = sprintf('unnamed');
else
    subject = filename;
end;

%% Setup MIB target stimuli

% Movement always tangent to the circle
% Orientation should be between 0 and 90 to make sure we know direction

%   NEED RIGHT GABOR.M to make this work -> orientation = orientation+90;

% Get orientations for targ1 and targ2
orientations = theta;
orientations(orientations >= 180) = orientations(orientations >= 180)-180;
t1orientation = orientations(1);
t2orientation = orientations(2);

% Convert targ features to appropriate units
theta = deg2rad(theta);
tOffset = deg2px(tOffset, env);

% Setup stimuli and fixation rects
fixSize = deg2px(fixSize, env)./2;
fixRect = [origin origin] + [-fixSize -fixSize fixSize fixSize];
fix_err = deg2px(fix_err, env)./2;

[t1x, t1y] = pol2cart(theta(1),tOffset);
[t2x, t2y] = pol2cart(theta(2),tOffset);

t1origin = [t1x,t1y]+origin;
t2origin = [t2x,t2y]+origin;

gRect1 = [t1origin-gSize/2 t1origin+gSize/2];
gRect2 = [t2origin-gSize/2 t2origin+gSize/2];

targ_err = deg2px(targ_err, env)./2;

%% Create MIB target movies

[t1,t2] = deal(NaN(ceil(360/phaseStep),1));

phase = 0;  % init phase

% Create all frames of each targ movie
for i = 1:(360/phaseStep);
    
    phase = phase + phaseStep;
    
    % Make cur frame for targ 1
    frame1 = gabor(gSize, 2, t1orientation, phase, 20, 0.5, 0.5);
    frame1 = frame1 .* env.colorDepth;
    t1(i) = Screen('MakeTexture',w,frame1);
    
    % Make cur frame for targ 2
    frame2 = gabor(gSize, 2, t2orientation, phase, 20, 0.5, 0.5);
    frame2 = frame2 .* env.colorDepth;
    t2(i) = Screen('MakeTexture',w,frame2);
    
end

%% Generate reward contingencies

% Sow the initial rwd seeds
T1seed = lowRwd + randi(highRwd);
T2seed = lowRwd + randi(highRwd);

[T1vals,T2vals] = deal(NaN(1,ntrials));

T1vals(1) = T1seed; T2vals(1) = T2seed;

% Fill in the rest of the rwds for the rest of the trials
for i = 2:ntrials;
    
    T1step = stStep.*randn(1);%,ntrials);
    T1step = round(T1step*(stepSize))./(stepSize);
    T2step = stStep.*randn(1);%,ntrials);
    T2step = round(T2step*stepSize)./stepSize;
    
    if T1vals(i-1)+T1step > lowRwd && T1vals(i-1)+T1step < highRwd
        T1vals(i) = T1vals(i-1)+T1step;
    else
        T1vals(i) = T1vals(i-1);
    end
    
    if T2vals(i-1)+T2step > lowRwd && T2vals(i-1)+T2step < highRwd
        T2vals(i) = T2vals(i-1)+T2step;
    else
        T2vals(i) = T2vals(i-1);
    end
    
end

%% Make Eyelink start recording

if EYEBALL
    Eyelink('startrecording');
end
