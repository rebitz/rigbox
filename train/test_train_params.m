% for this specific monkey, set some additional parameters

% WHAT MODE ARE WE IN?
fixationMode = 1;
targetMode = 1; % targ on at all?
    % this guy supercedes all that come below it
overlapMode = 0; % targ on before fix off?
targOnAfterGo = 1; % have the target on at fix off go cue?
memoryMode = 0; % turn targ off at any point before fix off?
    % if this is set to 1, then there is an overlap by default

pJackpot = 0.1;
nJackpotDrops = 10;

% Number of trials
ntrials = 100;

% Timing windows:
targHoldTime = 0.15; % time to hold target fix

fixHoldMin = 0.4; % time to hold fixation
fixHoldMax = 0.8;

targOverlapMin = 0.3; % targ on before fix off t
targOverlapMax = 0.4;

targGapMin = 0.5; % targ off before go cue t
targGapMax = 0.8;

% Fixation size
fixSize = 1; % in dg

% Target size
targSize = 3;

% Allowable error
fix_err = 3; % in dg
targ_err = 8; % in dg

% target locations
nLoc = 8; % number of positions around the circle
nEcc = 1; % number of eccentricities
thetas = [1:360/nLoc:360]; % evenly spaced (degrees)
tOffsets = [8]; % targ offsets (degrees)