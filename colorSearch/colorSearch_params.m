% colorSearch_params.m
% Initialize the parameters for all the things
nDropsJuice = 4;

% Number of trials
ntrials = 250;

nTargs = 3; % number of targets to put up simultaneously
nLocs = 3; % number of possible locations to put them in
nColors = nTargs*1; % quantize colorspace by???
% 2x the number of targets seems to work well in mTurk
nColors = round(nColors); % target options
nProbeColors = 15;

% pick a particular seed to start? just comment out to choose randomly
seedSeed = 270;
nextSeed = 90;

% forced choice trials?
pForced = 0.0;
forceBest = true; % else, force random choices

% keep the chosen stimulus on the screen?
keepOn = 1;

% p(switch in reward anchor)
hazard = 0.08; % this rides on top of the rwd buffer below
% i.e. given rwdBuffer check OK, this is the hazard rate
minJump = 45; % in dg

% past buffer before switch?
% implemented as at least this % rwds over at least x trials
rwdsRequired = .75; % 
trialsRequired = 20;
trSinceMin = trialsRequired;

% reward distribution - check out illustrateColorSearchRwds to get a sense of this
rwdStd = 10; % 30; % in degrees
maxRwd = .95; % max rwd
minRwd = .15; % min probability of rwd
colorOrientations = 360/(nColors+1):360/(nColors+1):360;
% make a lookup for the rwds, assign each color to some orientation

% seed random
rng('shuffle');

% set up the colors of the targets
%colorSeeds = pickColors(nColors);
%colorSeeds = pickColorsFromOrientations(stimulusOrientations);
colorSeeds = [    0.1107    0.5549    0.4332;...
    0.4630    0.4097    0.8341;...
    0.7737    0.3807    0.2056];

% colorSeeds = [    0.0111    0.4197    0.5256;...
%     0.5677    0.2564    0.5042;...
%     0.4483    0.3313    0.1135];
colorSeeds = colorSeeds .* 255;

% Timing window parameters (s)
time2fix = 5;
time2choose = 2;
fixHoldMin = 0.44;%6;%0.5;
fixHoldMax = 0.76;%93;%0.7;
targHoldTime = 0.19; % CAUTION!! WE NEED TO BRING THIS UP!

% Inter-trial interval bounds (s)
postRewardTime = .5; % to keep collecting pupil size? % changed to +.95 on 11/8/16
itimin = 0.1;%.25;
itimax = 0.3;%.75;

% cues/probe stimuli during fixation?
cueing = 1; % JUST PUTS THE TARGS UP BEFORE THE GO

% timings and options for probes
cueOpts = pickColors(nProbeColors)*255;
%cueOrientations = 360/(nProbeColors+1):360/(nProbeColors+1):360;
%cueOpts = pickColorsFromOrientation(cueOrientations);
nCues = [1,2,3];
cueOnMin = .09;
cueOnMax = .09;

% time between cue offset and cue/target onset
cueGapMin = .16;
cueGapMax = .31;

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
