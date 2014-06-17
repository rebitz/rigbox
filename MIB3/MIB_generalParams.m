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

% overlaps
overlapMin = 0;
overlapMax = 0;