% MIBreplay_params.m
% Initialize the parameters for replay task

MIB_generalParams; % shared with MIB3

randChoices = 1;

% Number of trials
ntrials = 100;

p_probe = 0.9; % means only show 1 target

% Directory of where the data will be saved to
global gitDir
if IsOSX
    splitChar = '/';
else
    splitChar = '\';
end
dataDirectory = strcat(gitDir,splitChar,'MIBreplay',splitChar,'data');

% Directory of where the data to be replayed lives
replayDirectory = strcat(gitDir,splitChar,'MIB3',splitChar,'data');

% Cue parameters
cOffset = 1;
cueWidth = 3;
cueLatencyMin = 0.1;
cueLatencyMax = 0.25;
cueOnT = 0.25;
cuecolor = [255 255 255];

% Reward parameters
rwdCorrect = 100;
rwdWrong = 0;
rwds = [rwdCorrect rwdWrong];
