% for this specific monkey, set some additional parameters

% WHAT MODE ARE WE IN?
fixationMode = 1;
targetMode = 1; % targ on at all?
    % this guy supercedes all that come below it
overlapMode = 1; % targ on before fix off?
targOnAfterGo = 1; % have the target on after fix off go cue?
    % combining these two is a simple overlap task
memoryMode = 0; % turn targ off at any point before fix off?
    % if this is set to 1, then there is an overlap by default
rmTargB4Rwd = 0; % 1 = targ off b4 rwd, else, targ on until after rwd
gracePeriod = 0;
    graceTime = 0.04;
    
pRepeat = .5;

gaborTarg = 1;
    % fixed gabor stuff
    % gabor(vhSize, cyclesPer100Pix, orientation, phase, sigma , mean, amplitude);
    gSize = 3; % in deg % change the size w/ the targ window below!
    gCycles = 2.5; % spatial frequency
    gPhase = 180; % centering
    gSigma = 15; % of window
    gMean = 0.5; % 0.5 % brightness -> currently half of background
    gAmp = 0.5; % CONTRAST!
    gOrientation = 55; % for low reward
    % next, go to 30, +95 jack
    
rotateForJackpot = 1;
    rotateBy = 60;
    
pChoice = 0.8;
    
% walk up the baground color to neutral gray
bgcolor = repmat(127,1,3);

nDropsJuice = 1;
pJackpot = 0.3; % on forced trials
jackpotMultiple = 12  ;%3;

% Number of trials
ntrials = 100;

% Timing windows:
targHoldTime = 0.125; % time to hold target fix

fixHoldMin = 0.42; % time to hold fixation
fixHoldMax = 0.7;

targOverlapMin = 0.075; % targ on before fix off t
targOverlapMax = 0.1;

targGapMin = 0.5; % targ off before go cue t
targGapMax = 0.8;

% Fixation size
fixSize = .8; % in dg (radius)
shrinkFixSize = .6;

% Target size
targSize = 3;
if gaborTarg; targSize = 7; end

% Allowable error
fix_err = 6; % in dg
targ_err = 12; % in dg

% target locations
nLoc = 8; % number of positions around the circle
nEcc = 1; % number of eccentricities
thetas = [1:360/nLoc:360]; % evenly spaced (degrees)
tOffsets = [7]; % targ offsets/eccentricities (degrees)

%nLoc = 2;
%thetas = [46 226];

% side bias correction stuff
forceLoc = 1 % use a particular location for forced trials?
forceTargs = [1,1,2]; % which targ locs to force - thetas(forceTargs)
randomizeAlt = 1; % put the alternatives anywhere else on the screen?
    % else, always 180deg away
rwdBonusForcedTargs = 0; % reward for choices to forced targs?
    rwdBonusNJuices = 0;
pChoice = 1; % 1-p(forced)
pJackpot = .8; % jackpot likelihood on forced trials