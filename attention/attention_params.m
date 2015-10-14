% attention_params.m
% Initialize the parameters for all things attention task

nTargs = 4; % number of targets
nLocs = 4; % number of locations

% cue one of the stimulus locations?
cueing = 1;

% keep the chosen stimulus on the screen?
keepOn = 1;

% stimulus contrast levels
% contrastBounds = [.2 .5];
contrastBounds = [.2 .5];
contrastLevels = 3; % n pts btw

% p(switch in reward anchor)
hazard = 0.25; % this rides on top of the rwd buffer below
% i.e. | rwdBuffer check, this is the hazard rate
minJump = 45; % in dg

% past buffer before switch?
% implemented as at least this % rwds over at least x trials
rwdsRequired = .5; % w/ current params, chance ~20%
trialsRequired = 15;
trSinceMin = 20;

% rwdsRequired = .2;
% trialsRequired = 5;
% trSinceMin = 5;

% reward distribution - check out illustrateAttnRwds to get a sense of this
rwdStd = pi/6; % in radians
rwdScale = 1; % maxtrwd ish

% fixed gabor stuff
% gabor(vhSize, cyclesPer100Pix, orientation, phase, sigma , mean, amplitude);
gSize = 3; % in deg, superceeded by targSize below
gCycles = 3; % spatial frequency
gPhase = 0; % centering
gSigma = 15; % of window
gMean = 0.5; % 0.5 % brightness -> currently half of background
gAmp = 0.5; % CONTRAST!

% set up the orientations of the targets
orientationBounds = [1 180];
orientationBins = 50; % discretize into
tmp = ([orientationBounds(1):range(orientationBounds)/(orientationBins-1):orientationBounds(2)]);
orientationSeeds = floor(tmp+mean(diff(tmp)/orientationBins));

% Number of trials
ntrials = 100;

% Timing window parameters (s)
time2fix = 2;
time2choose = 2;
fixHoldMin = 0.5;
fixHoldMax = 0.7;
targHoldTime = 0.2;
postRewardTime = 0.3;

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

% Inter-trial interval bounds (s)
itimin = 1.2;
itimax = 1.7;

% target locations
%
%       270
%   180     0
%       90
%
rotBy = 0; % rotate first target to?
thetas = [1:360/nLocs:360]+rotBy;
tOffsets = 5; % dg off for the target
targ_err = 8; % in dg, for eye


% Directory of where the data will be saved to
global gitDir
if IsOSX
    splitChar = '/';
else
    splitChar = '\';
end
dataDirectory = strcat(gitDir,splitChar,'attention',splitChar,'data');
