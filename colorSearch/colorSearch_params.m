% colorSearch_params.m
% Initialize the parameters for all the things
nDropsJuice = 4;

% Number of trials
ntrials = 250;

nTargs = 3; % number of targets to put up simultaneously
nLocs = 3; % number of possible locations to put them in
nColors = nTargs*1; % quantize colorspace by???
% 2x the number of targets seems to work well in mTurk
nColors = round(nColors);

% pick a particular seed to start? just comment out to choose randomly
seedSeed = 180;
nextSeed = 90;

% cue one of the stimulus locations?
cueing = 0; % JUST PUTS THE TARGS UP BEFORE THE GO

% forced choice trials?
pForced = 0.0;
forceBest = true; % else, force random choices

% keep the chosen stimulus on the screen?
keepOn = 1;

% p(switch in reward anchor)
hazard = 0.1; % this rides on top of the rwd buffer below
% i.e. given rwdBuffer check OK, this is the hazard rate
minJump = 45; % in dg

% past buffer before switch?
% implemented as at least this % rwds over at least x trials
rwdsRequired = .75; % 
trialsRequired = 20;
trSinceMin = trialsRequired;

% reward distribution - check out illustrateColorSearchRwds to get a sense of this
rwdStd = 10; % 30; % in degrees
maxRwd = 1; % max rwd
minRwd = .25; % min probability of rwd
colorOrientations = 360/(nColors+1):360/(nColors+1):360;
% make a lookup for the rwds, assign each color to some orientation

% set up the colors of the targets
%colorSeeds = pickColors(nColors);
colorSeeds = [    0.0891    0.5564    0.4819;...
    0.5189    0.3961    0.8037;...
    0.7389    0.3923    0.1933];

% colorSeeds = [    0.0111    0.4197    0.5256;...
%     0.5677    0.2564    0.5042;...
%     0.4483    0.3313    0.1135];
colorSeeds = colorSeeds .* 255;

% Timing window parameters (s)
time2fix = 5;
time2choose = 2;
fixHoldMin = 0.32;%6;%0.5;
fixHoldMax = 0.55;%93;%0.7;
targHoldTime = 0.19; % CAUTION!! WE NEED TO BRING THIS UP!

% Inter-trial interval bounds (s)
postRewardTime = .5; % to keep collecting pupil size? % changed to +.95 on 11/8/16
itimin = 0.1;%.25;
itimax = 0.3;%.75;

% time for viewing the cue - NO CUE IS CURRENTLY IMPLEMENTED
cueOnMin = .05;
cueOnMax = .1;

% time between cue offset and target onset
targGapMin = .1;
targGapMax = .2;

% Background color
bgcolor = [127 127 127];

% Fixation parameters
fixcolor = [255 255 255];
fixSize = .5; % in dg
shrinkFixBy = .2; % pcnt to decriment fixation by
fix_err = 4; %4.5 % in dg

% Target parameters
targcolor = [255 255 255]; % pointless since gabors
targSize = 3;
targ_err = 6.5; %6.5 % in dg, for eye

% turn off fixation when the targets appear?
fixOffAtTargOn = false;

% target locations
%
%       270
%   180     0
%       90
%
rotBy = 45; % rotate first target to?
thetas = [1:360/nLocs:360]+rotBy;
tOffsets = 5.5; % dg off for the target

% Directory of where the data will be saved to
global gitDir
if IsOSX
    splitChar = '/';
else
    splitChar = '\';
end
dataDirectory = strcat(gitDir,splitChar,'colorSearch',splitChar,'data');
