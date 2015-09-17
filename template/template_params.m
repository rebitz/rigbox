% template_params.m
% Initialize the parameters for template attention task

nTargs = 2;

% mask the stimuli? 
masking = 1;

% what to ask about after?
queryDir = 1;
queryLoc = 1;

% gabor stuff
% gabor(vhSize, cyclesPer100Pix, orientation, phase, sigma , mean,
% amplitude);
gSize = 10; % in deg, superceeded by targSize below
gCycles = 5;
gPhase = 0;
gSigma = 15;
gMean = 0.5;
gAmp = 0.5;

% trial conditions
pSwitch = 0.7; % lik of a change at any location
pValid = 0.8; % given a change, lik that it will be at the valid

% set up the orientations of the targets
tmp = ([1:170/nTargs:170]); if nTargs == 2; tmp = tmp+45; end
orientationSeeds = floor(tmp+mean(diff(tmp)/nTargs));

% make the targets/sample 1 at fixed diff from template?
fixedOffsetsFromTemplate = 1; % logical
fixedOffset = 10; % magnitude of the fixed offset, if selected above
% it's +/- 5 degrees from here

% if they're noisy instead,
orientationSigma = 5; % var in template-to-targ orientations

% now for the changes
noiseSigma = 30; % was: 45; % change magnitudes
% *(1/2) is the +/-
% PROB can take this down to 20-30deg

% Number of trials
ntrials = 50;

% Directory of where the data will be saved to
global gitDir
if IsOSX
    splitChar = '/';
else
    splitChar = '\';
end
dataDirectory = strcat(gitDir,splitChar,'template',splitChar,'data');

% Timing window parameters (s)
time2fix = 2;
time2choose = 2;
fixHoldMin = 0.5;
fixHoldMax = 0.7;
targHoldTime = 0.2;

% time for viewining of the template
templateOnMin = .75;
templateOnMax = 1.25;

% time between template offset and target onset
targGapMin = 0.5;
targGapMax = 1;

% time to show first sample (from 1st target on)
maskGapMin = 0.2;
maskGapMax = 0.3;

% time before 2nd sample (from 1st target on)
targSwitchMin = 0.4;
targSwitchMax = 0.5;

% Background color
bgcolor = [127 127 127];

% Fixation parameters
fixcolor = [255 255 255];
fixSize = .25; % in dg
fix_err = 4; % in dg

% Target parameters
targSize = 10; % only controls the width
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

if nTargs == 3; rotBy = 45;
else rotBy = 0; end
thetas = [0:360/nTargs:359]+rotBy;
tOffsets = [5];
targ_err = 8; % in dg, for eye
