% vMIB_params.m
% Initialize the parameters for vMIB task

% Number of trials
ntrials = 10;

global EYEBALL
EYEBALL = 0;

% Is this a test run?
global TESTING
if strcmp(mode, 'TEST')
    TESTING = 1;
else
    TESTING = 0;
end

% Directory of where the data will be saved to
% For Eddy's comp: '/Volumes/data/RigB/Eddy/MIB/Acuity/MIBtask/data'
% For server: 'Z:\RigB\Eddy\MIB\Acuity\MIBtask\data'
% For RigD: 'C:\Eddy\MIB\Acuity\MIBtask\data'
dataDirectory = '/Volumes/data/RigB/Eddy/MIB/Acuity/MIBtask/data';

% Timing window parameters (s)
time2fix = 2;
fixHoldTime = .3;
targHoldTime = .15;

% Fixation parameters
fixcolor = [255 255 255];
fixSize = 1; % in dg
fix_err = 4; % in dg

% Inter-trial interval bounds (s)
itimin = .1;
itimax = .2;

% target locations
%
%       270
%   180     0
%       90
%

theta = [180 0]; % Initial location of targets (degrees)
tOffset = 8; % degrees

% Target features
maxFrames = 200; % # of frames in the movie - make enough that it's not jerky
gSize = [200 200]; % px size of the image
phaseStep = 45; % affects the speed of movement
showTime = 2; % duration stim are on for - REMOVE ME
targ_err = 1; % in dg

% Reward parameters

% Lower and upper bounds on reward contingencies
lowRwd = 10;
highRwd = 90;

% Reward step size
stepSize = 10;

% Variance in random process
stStep = stepSize * 2/3;

% Probability of forced choice trial
p_forced = .1;

% Which display?
screenNumber = 1;

global env

% Setup the environment struct - used by subfunctions
env = Screen('Resolution',screenNumber);
env.screenNumber = screenNumber;
env.distance = 70; % in cm, monkey from screen
env.physicalWidth = 61; % in cm, width of the visible screen
env.colorDepth = 255;

