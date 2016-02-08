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

gaborTarg = 1;
    % fixed gabor stuff
    % gabor(vhSize, cyclesPer100Pix, orientation, phase, sigma , mean, amplitude);
    gSize = 3; % in deg % change the size w/ the targ window below!
    gCycles = 3; % spatial frequency
    gPhase = 0; % centering
    gSigma = 15; % of window
    gMean = 0.5; % 0.5 % brightness -> currently half of background
    gAmp = 0.5; % CONTRAST!
    gOrientation = 150;
    
rotateForJackpot = 1;
    rotateBy = 90;
    
pChoice = 0.7;
    
% walk up the baground color to neutral gray
bgcolor = repmat(127,1,3);

nDropsJuice = 3;
pJackpot = 0.3;
jackpotMultiple = 3;

% Number of trials
ntrials = 30;

% Timing windows:
targHoldTime = 0.15; % time to hold target fix

fixHoldMin = 0.4; % time to hold fixation
fixHoldMax = 0.75;

targOverlapMin = 0.05; % targ on before fix off t
targOverlapMax = 0.11;

targGapMin = 0.5; % targ off before go cue t
targGapMax = 0.8;

% Fixation size
fixSize = 1; % in dg (radius)

% Target size
targSize = 3;
if gaborTarg; targSize = 5; end

% Allowable error
fix_err = 10; % in dg
targ_err = 12; % in dg

% target locations
nLoc = 8; % number of positions around the circle
nEcc = 1; % number of eccentricities
thetas = [1:360/nLoc:360]; % evenly spaced (degrees)
tOffsets = [8]; % targ offsets/eccentricities (degrees)