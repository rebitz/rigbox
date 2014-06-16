% cvMIB_params.m
% Initialize the parameters for vMIB task

% Number of trials
ntrials = 200;

p_probe = 0.1;

% Directory of where the data will be saved to
global gitDir
if IsOSX
    splitChar = '/';
else
    splitChar = '\';
end
dataDirectory = strcat(gitDir,splitChar,'MIB3',splitChar,'data');

% overlaps
overlapMin = 0;
overlapMax = 0;

% Timing window parameters (s)
time2fix = 2;
fixHoldMin = .5;
fixHoldMax = .7;
targHoldTime = .20;

% Fixation parameters
fixcolor = [255 255 255];
fixSize = .5; % in dg
fix_err = 3; % in dg

% Inter-trial interval bounds (s)
itimin = .5;
itimax = 1;

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

% Target colors
color1 = [2/3 4/9 0];
color2 = [1/9 5/9 7/9];
color3 = [7/9 1/3 8/9];
colors = [color1; color2; color3];

% Reward parameters
walkRewards = 1; % else just deliver at lower and upper bounds
rwdLB = 10; % lower bound, if ~walkRewards, just assigns to these
rwdUB = 90; % % upper bound
hazard = 0.15; % p(step), size fixed at 10%
hazard = 0.02; % works well for the block style
nToGen = 2000; % length of vector to generate
minContinuousValues = 100; % n trials w/ no switches in block version


% Lower and upper bounds on reward contingencies
rwd1 = 20;
rwd2 = 50;
rwd3 = 80;
rwds = [rwd1 rwd2 rwd3];

% Probability of target moving location
p_move = .2;