disp('hi OuterSpace rig!')

global env

% Setup the environment struct - used by many task functions
env.screenNumber = 2;
env.resolution = Screen('Resolution',env.screenNumber);
env.width = env.resolution.width;
env.distance = 70; % in cm, monkey from screen
env.physicalWidth = 61; % in cm, width of the visible screen
env.colorDepth = 255;
env.rigID = 'OuterSpace'; %

% juicer stuff
env.juicePort = hex2dec('DFF8');
env.rwdBit = 1;
env.rwdDuration = 30; % in ms
env.rwdDelay = 55; % in ms
env.defaultRwdDrops = 1;

if exist('monk')==1 && strcmp(monk,'beak')
    env.rwdDuration = 200; % in ms
    env.rwdDelay = 5; % in ms
end

% eyelink stuff
env.eyeToTrack = 'RIGHT'; % if not binocular
env.binocularEye = 'NO'; % 'NO' to pick a particular eye

env.timeForSaccade = .02;
env.threshForSaccade = 30;