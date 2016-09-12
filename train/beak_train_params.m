% for this specific monkey, set some additional parameters

% WHAT MODE ARE WE IN?
fixationMode = 1;
targetMode = 1; % targ on at all?
    % this guy supercedes all that come below it
    saccadeMode = 1; % reward for making saccades
overlapMode = 1; % targ on before fix off?
targOnAfterGo = 1; % have the target on after fix off go cue?
    % combining these two is a simple overlap task
memoryMode = 0; % turn targ off at any point before fix off?
    % if this is set to 1, then there is an overlap by default
rmTargB4Rwd = 0; % 1 = targ off b4 rwd, else, targ on until after rwd
gracePeriod = 0;
    graceTime = 0.04;
    
pRepeat = 0.35;
    anyRepeat = false;
    
gaborTarg = 0; % superceeded by below!
    pGaborTarg = 0;
    % fixed gabor stuff
    % gabor(vhSize, cyclesPer100Pix, orientation, phase, sigma , mean, amplitude);
    gSize = 2; % in deg % change the size w/ the targ window below!
    gCycles = 3; % spatial frequency
    gPhase = 0; % centering
    gSigma = 15; % of window 
    gMean = 0.5; % 0.5 % brightness -> currently half of background
    gAmp = 0.4; % CONTRAST!
        gPreAmp = 0.05;
        preTargTime = .2;
    gOrientation = 80;
    
rotateForJackpot = 1;
    rotateBy = 90;
    
pChoice = 0; % 0 = single target  
    
% walk up the baground color to neutral gray
bgcolor = repmat(30,1,3);
targcolor = repmat(255,1,3); % pre go, if not gabor
targcolor2 = repmat(255,1,3); % post go, if not gabor

nDropsJuice = 2;
juiceForLow = true;
juiceForAcq = false;
juiceForFixed = false; % after overlap
    dropsForFixedSeed = [-0.5 1];
    noErrForFixed = true;
%pJackpot = 0;
jackpotMultiple = 2;

errorSecs = 0.2;

% Number of trials
ntrials = 100;

% Timing windows:
targHoldTime = 0.13; % time to hold target fix
penalizeShortRTTime = 0.03; % no acceptable RTs less than this number

fixHoldMin = 0.20; % time to hold fixation
fixHoldMax = 0.35;

targOverlapMin = 0.05; % targ on before fix off t
targOverlapMax = 0.11;

targGapMin = 0.5; % targ off before go cue t
targGapMax = 0.8;

% Fixation size
fixSize = 1.1; % in dg (radius)
shrinkFixSize = .7;

% Target size
targSize = 1.1;
if gaborTarg; targSize = 7; end % not implemented!!!

% Allowable error
fix_err = 6; % in dg
targ_err = 10; % in dg

% target locations
nLoc = 8; % number of positions around the circle
nEcc = 1; % number of eccentricities
thetas = [1:360/nLoc:360]; % evenly spaced (degrees)
tOffsets = [6]; % targ offsets/eccentricities (degrees)

itimin = .15;
itimax = .25;

%nLoc = 2;
%thetas = [46 226];

% side bias correction stuff
forceLoc = 0 % use a particular location for forced trials?
forceTargs = [1,1,2]; % which targ locs to force - thetas(forceTargs)
randomizeAlt = 1; % put the alternatives anywhere else on the screen?
    % else, always 180deg away
rwdBonusForcedTargs = 0; % reward for choices to forced targs?
    rwdBonusNJuices = 0;
pChoice = 0; % 1-p(forced)
pJackpot = .25; % jackpot likelihood on forced trials