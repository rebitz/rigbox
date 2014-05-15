% cvMIB_params.m
% Initialize the parameters for vMIB task

% Number of trials
ntrials = 100;

p_probe = 0.9; % p(2 targ choice)

% Directory of where the data will be saved to
global gitDir
if IsOSX
    splitChar = '/';
else
    splitChar = '\';
end
dataDirectory = strcat(gitDir,splitChar,'cBandit',splitChar,'data');

% Timing window parameters (s)
time2fix = 2;
fixHoldTime = .4;
targHoldTime = .20;

% Fixation parameters
fixcolor = [255 255 255];
fixSize = .5; % in dg
fix_err = 4; % in dg

% Inter-trial interval bounds (s)
itimin = 1;
itimax = 1.5;

% target locations
%
%       270
%   180     0
%       90
%

theta = [225 45]; % Initial location of targets (degrees)
tOffset = 8; % degrees

% Target features
maxFrames = 200; % # of frames in the movie - make enough that it's not jerky
gSize = [400 400]; % px size of the image
phaseStep = 45; % affects the speed of movement
showTime = 2; % duration stim are on for - REMOVE ME
targ_err = 15; % in dg

% Target colors
% color1 = [2/3 4/9 0];
% color2 = [1/9 5/9 7/9];
color1 = [0 4/9 1]; % orange/blue
color2 = [7/9 2/9 7/9]; % pink/green
colors = [color1; color2];

% Reward parameters are actually set in open task
walkRewards = 0; % else just deliver at lower and upper bounds
rwdLB = 10; % lower bound, if ~walkRewards, just assigns to these
rwdUB = 90; % % upper bound
hazard = 0.15; % p(step), size fixed at 10%
hazard = 0.02; % works well for the block style
nToGen = 2000; % length of vector to generate
minContinuousValues = 100; % n trials w/ no switches in block version

% Probability of target moving location
p_move = .2;