% for this specific monkey, set some additional parameters

% Number of trials
ntrials = 70;

% WHAT MODE ARE WE IN?
fixationMode = 1;
    fixationP = 1;
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
    graceTime = 0.04;

toggle = true;

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
    
pChoice = 100; % 0 = single target  
    
% walk up the baground color to neutral gray
bgcolor = repmat(100,1,3);
targcolor = repmat(255,1,3); % pre go, if not gabor
targcolor2 = repmat(255,1,3); % post go, if not gabor

%tmp = pickColors(2).*255;

% tmp = [    0.6902    0.2506    0.2006;...
%     0.0119    0.4219    0.5024].*255;

tmp = [    0.9403    0.3526    0.4246;...
    0.1016    0.5926    0.5181].*255;

% targcolor = pickColors(1)*255;
% altTargColor = repmat(255,1,3);

targcolor = tmp(1,:);
altTargColor = tmp(2,:);

nDropsJuice = 1;
juiceForLow = true;
juiceForAcq = false;
juiceForFixed = false; % after overlap
    dropsForFixedSeed = [-0.5 1];
    noErrForFixed = true;
%pJackpot = 0;
jackpotMultiple = 4;
    pJackpot = .5; % jackpot likelihood on forced trials
    
errorSecs = 0.2;

% Timing windows:
targHoldTime = 0.08; % time to hold target fix
penalizeShortRTTime = 0.03; % no acceptable RTs less than this number

fixHoldMin = 0.24;%3;%24; % time to hold fixation
fixHoldMax = 0.36;%5;%39;

targOverlapMin = 0.05; % targ on before fix off t
targOverlapMax = 0.11;

targGapMin = 0.5; % targ off before go cue t
targGapMax = 0.8;

% Fixation size
fixSize = 1; % in dg (radius), og fix size
shrinkFixSize = .6;

% Target size
targSize = 2.5;
if gaborTarg; targSize = 7; end % not implemented!!!

% Allowable error
fix_err = 4.5; % in dg was: 4.5
targ_err = 6; % in dg

% target locations
nLoc = 2; % number of positions around the circle
startAt = 15;
nEcc = 1; % number of eccentricities
thetas = [startAt:360/nLoc:360]; % evenly spaced (degrees)
tOffsets = [5]; % targ offsets/eccentricities (degrees)

itimin = .28;
itimax = .45;

%nLoc = 2;
%thetas = [46 226];

% side bias correction stuff
forceLoc = 0 % use a particular location for forced trials?
forceTargs = [1,1,2]; % which targ locs to force - thetas(forceTargs)
randomizeAlt = 1; % put the alternatives anywhere else on the screen?
    % else, always 180deg away
rwdBonusForcedTargs = 0; % reward for choices to forced targs?
    rwdBonusNJuices = 0;
%pChoice = 0; % 1-p(forced)
