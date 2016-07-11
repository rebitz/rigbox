% colorSearch_params.m
% Initialize the parameters for all the things

nTargs = 2; % number of targets to put up simultaneously
nLocs = 4; % number of possible locations to put them in
nColors = 2; % quantize colorspace by???
% 2x the number of targets seems to work well

% cue one of the stimulus locations?
cueing = 0;

% keep the chosen stimulus on the screen?
keepOn = 1;

% p(switch in reward anchor)
hazard = 0.2; % this rides on top of the rwd buffer below
% i.e. | rwdBuffer check, this is the hazard rate
minJump = 45; % in dg

% past buffer before switch?
% implemented as at least this % rwds over at least x trials
rwdsRequired = .5; % w/ current params, chance ~20%
trialsRequired = 15;
trSinceMin = 20;

% reward distribution - check out illustrateColorSearchRwds to get a sense of this
rwdStd = 30; % in degrees
maxRwd = 1; % max rwd
minRwd = 0; % max rwd
colorOrientations = 360/(nColors+1):360/(nColors+1):360;
% make a lookup for the rwds, assign each color to some orientation

% set up the colors of the targets
colorSeeds = pickColors(nColors);
colorSeeds = colorSeeds .* 255;

% Number of trials
ntrials = 100;

% Timing window parameters (s)
time2fix = 2;
time2choose = 2;
fixHoldMin = 0.5;
fixHoldMax = 0.7;
targHoldTime = 0.2;
postRewardTime = 0.3;

% Inter-trial interval bounds (s)
itimin = 1.2;
itimax = 1.7;

% time for viewing the cue
cueOnMin = .75;
cueOnMax = 1.25;

% time between cue offset and target onset
targGapMin = 0;
targGapMax = 0;

% Background color
bgcolor = [127 127 127];

% Fixation parameters
fixcolor = [255 255 255];
fixSize = .25; % in dg
fix_err = 4; % in dg

% Target parameters
targcolor = [255 255 255]; % pointless since gabors
targSize = 3;
targ_err = 8; % in dg, for eye

% target locations
%
%       270
%   180     0
%       90
%
rotBy = 0; % rotate first target to?
thetas = [1:360/nLocs:360]+rotBy;
tOffsets = 5; % dg off for the target



% Directory of where the data will be saved to
global gitDir
if IsOSX
    splitChar = '/';
else
    splitChar = '\';
end
dataDirectory = strcat(gitDir,splitChar,'colorSearch',splitChar,'data');
