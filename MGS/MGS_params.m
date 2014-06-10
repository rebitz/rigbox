% posner_params.m
% Initialize the parameters for posner task

% Which display?
screenNumber = 1;

% Number of trials
ntrials = 200;

% Directory of where the data will be saved to
global gitDir
if IsOSX
    splitChar = '/';
else
    splitChar = '\';
end
dataDirectory = strcat(gitDir,splitChar,'MGS',splitChar,'data');

% Timing window parameters (s)
time2fix = 2;
time2choose = 1;
fixHoldMin = 0.4;
fixHoldMax = 0.8;
targHoldTime = 0.2;
targOverlapMin = 0.3;
targOverlapMax = 0.4;
targGapMin = 0.5;
targGapMax = 0.8;

% Background color
bgcolor = [127 127 127];

% Fixation parameters
fixcolor = [255 255 255];
fixSize = .5; % in dg
fix_err = 3; % in dg

% Target parameters
targSize = 1;
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

nLoc = 8; % number of positions around the circle
nEcc = 2; % number of eccentricities
thetas = [0:360/nLoc:359]; % evenly spaced (degrees)
tOffsets = [8,12]; % targ offsets (degrees)
targ_err = 8; % in dg
