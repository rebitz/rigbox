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
pMove = 0.05;

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
fix_err = 3; % in dg

% Target parameters
targSize = 6; % only controls the width
targcolor = [255 255 255];

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
