% posner_params.m
% Initialize the parameters for posner task

% Number of trials
ntrials = 200;

% Directory of where the data will be saved to
global gitDir
if IsOSX
    splitChar = '/';
else
    splitChar = '\';
end
dataDirectory = strcat(gitDir,splitChar,'express',splitChar,'data');

imageDirectory = strcat(gitDir,splitChar,'express',splitChar,'stimuli');
imStr = '.JPG';

% p(moving location)
pMove = 0.5; % need the location to move more frequently
% 50% is equivalent to random target position

% reward values (probabilities)
rwds = [0.1 0.5 0.9];

% trials before a change in rwd contingencies
minBlockTrials = 20;

% Timing window parameters (s)
time2fix = 2;
time2choose = 1;
fixHoldMin = 0.5;
fixHoldMax = 0.7;
targHoldTime = 0.2;

targGapMin = 0.2;
targGapMax = 0.2;

% Background color
bgcolor = [127 127 127];

% Fixation parameters
fixcolor = [255 255 255];
fixSize = .5; % in dg
fix_err = 4; % in dg

% Target parameters
targSize = 1; % how big we going here?
targColors = [0.97 0.72 0.72;...
              0    0.92 0   ;...
              0.42 0.89 0.89];
targColors = targColors*255;
% used colorFaceMatch to generate these on my laptop

% Inter-trial interval bounds (s)
itimin = 1.2;
itimax = 1.7;

% target locations
%
%       270
%   180     0
%       90
%

thetas = [0 180];
tOffsets = [10];
targ_err = 8; % in dg
