% cvMIB_params.m
% Initialize the parameters for vMIB task

randChoices = 1;

% Number of trials
ntrials = 100;

p_probe = 0.1;

% Directory of where the data will be saved to
global gitDir
if IsOSX
    splitChar = '/';
else
    splitChar = '\';
end
dataDirectory = strcat(gitDir,splitChar,'MIBreplay',splitChar,'data');

% Directory of where the data to be replayed lives
replayDirectory = strcat(gitDir,splitChar,'MIB3',splitChar,'data');

% Timing window parameters (s)
time2fix = 2;
fixHoldMin = .65;
fixHoldMax = .85;
targHoldTime = .20;

% Fixation parameters
fixcolor = [255 255 255];
fixSize = .5; % in dg
fix_err = 3.5; % in dg

% Inter-trial interval bounds (s)
itimin = .5;
itimax = 1;

% Cue parameters
cOffset = 1;
cueWidth = 3;
cueLatencyMin = 0.1;
cueLatencyMax = 0.25;
cueOnT = 0.25;
cuecolor = [255 255 255];

% target locations
%
%       270
%   180     0
%       90
%

        % T1  T2 T3
theta = [240 120 0]; % Initial location of targets (degrees)
tOffset = 8; % degrees

% Target features
maxFrames = 200; % # of frames in the movie - make enough that it's not jerky
gSize = [400 400]; % px size of the image
phaseStep = 20; % affects the speed of movement
showTime = 2; % duration stim are on for - REMOVE ME
targ_err = 10; % in dg

% Reward parameters
rwdCorrect = 100;
rwdWrong = 0;
rwds = [rwdCorrect rwdWrong];
