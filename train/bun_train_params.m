 % for this specific monkey, set some additional parameters

% WHAT MODE ARE WE IN?
fixationMode = 1;
targetMode = 1; % targ on at all?
    % this guy supercedes all that come below it
    saccadeMode = 1; % reward for making saccades
overlapMode = 0; % targ on before fix off?
targOnAfterGo = 1; % have the target on after fix off go cue?
    % combining these two is a simple overlap task
memoryMode = 0; % turn targ off at any point before fix off?
    % if this is set to 1, then there is an overlap by default
rmTargB4Rwd = 0; % 1 = targ off b4 rwd, else, targ on until after rwd
gracePeriod = 0;
    graceTime = 0.05;
    
pRepeat = 0.35; % on error, likelihood of repeating trial
    anyRepeat = false;
    
gaborTarg = 0;
    % fixed gabor stuff
    % gabor(vhSize, cyclesPer100Pix, orientation, phase, sigma , mean, amplitude);
    gSize = 3; % in deg % change the size w/ the targ window below!
    gCycles = 2.5; % spatial frequency
    gPhase = 180; % centering
    gSigma = 15; % of window
    gMean = 0.5; % 0.5 % brightness -> currently half of background
    gAmp = 0.30; % CONTRAST!
        gPreAmp = 0.05;
        preTargTime = .2;
    gOrientation = 150; % for low reward
    % next, go to 30, +95 jack
    
rotateForJackpot = 1;
    rotateBy = -115;
    
%pChoice = 0.8;
    
% walk up the baground color to neutral gray
bgcolor = repmat(127,1,3);
targcolor = repmat(156,1,3); % pre go, if not gabor
%targcolor2 = repmat(157,1,3); % post go, if not gabor

% reaward by color:

% he struggled with these:
%altTargColor = [   87.7077   78.2042  169.5884]; % lavender
%targcolor = [84.2319   93.1761   31.4657]; % brown

tmp = pickColors(2);
targcolor = [tmp(1,:)].*255;
altTargColor = [tmp(2,:)].*255;

% this pair is really hard for him:
%targcolor = [147.9239 74.0094 33.7077];
%altTargColor = [19.3113 97.9448 175.5220];
%altTargColor = pickColors(1)*255;

%targcolor = [179.0738 60.1442 79.3118];
%altTargColor = [12.5237 108.6660 89.2817];

mixWeight = 0;%.85; % 1 = all targ color, 0 = none
ogFixColor = fixcolor;
fixcolor = ((1-mixWeight).*fixcolor) + (mixWeight.*targcolor);

nDropsJuice = 3; % for target acquisition
juiceForLow = false;
juiceForAcq = false;
juiceForFixed = false; % after overlap
    dropsForFixedSeed = [-0.5 1];
    noErrForFixed = true;
% pJackpot = 0.3; % on forced trials
jackpotMultiple = 2.25; % will give nDrops + nDrops jackpot times

% Number of trials
ntrials = 80;

% Timing windows:
targHoldTime = 0.125; % time to hold target fix
penalizeShortRTTime = 0.08; % no acceptable RTs less than this number

fixHoldMin = 0.35;%42; % time to hold fixation
fixHoldMax = 0.65;%7;

targOverlapMin = 0.15; %0.3;% 0.12; % targ on before fix off t
targOverlapMax = 0.3; %0.55;%0.15;
    % with juiceForFixed, this is + whatever time it takes to deliver juice

targGapMin = 0.5; % targ off before go cue t
targGapMax = 0.8;

% Fixation size
fixSize = .8; % in dg (radius)
shrinkFixSize = .6;

% Target size
targSize = 3;
if gaborTarg; targSize = 7; end

% Allowable error
fix_err = 4.5; % in dg
targ_err = 8; % in dg

% target locations
nLoc = 8; % number of positions around the circle
nEcc = 1; % number of eccentricities
thetas = [1:360/nLoc:360]; % evenly spaced (degrees)
tOffsets = [6]; % targ offsets/eccentricities (degrees)

itimin = .9;
itimax = 1.3;

nLoc = 2;
%thetas = [136 316]; % UR,DL
thetas = [46 226];

% side bias correction stuff
forceLoc = 0 % use a particular location for forced trials?
forceTargs = [1,1,2]; % which targ locs to force - thetas(forceTargs)
randomizeAlt = 1; % put the alternatives anywhere else on the screen?
    % else, always 180deg away
rwdBonusForcedTargs = 0; % reward for choices to forced targs?
    rwdBonusNJuices = 0;
pChoice = .65; % 1-p(forced)
pJackpot = 1; % jackpot likelihood on forced trials