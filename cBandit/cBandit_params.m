% cvMIB_params.m
% Initialize the parameters for vMIB task

% Number of trials
ntrials = 200;

p_probe = 0.9; % p(2 targ choice)

% Directory of where the data will be saved to
dataDirectory = './cBandit/data';

% Timing window parameters (s)
time2fix = 2;
fixHoldTime = .4;
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

theta = [225 45]; % Initial location of targets (degrees)
tOffset = 8; % degrees

% Target features
maxFrames = 200; % # of frames in the movie - make enough that it's not jerky
gSize = [400 400]; % px size of the image
phaseStep = 45; % affects the speed of movement
showTime = 2; % duration stim are on for - REMOVE ME
targ_err = 15; % in dg

% Target colors
color1 = [2/3 4/9 0];
color2 = [1/9 5/9 7/9];
colors = [color1; color2];

% Reward parameters are actually set in open task
walkRewards = 1; % else just deliver at lower and upper bounds
rwdLB = 10; % if ~walkRewards, just assigns to these
rwdUB = 90; %
hazard = 0.15; % p(step), size fixed at 10%
nToGen = 2000; % length of vector to generate

% Probability of target moving location
p_move = .2;