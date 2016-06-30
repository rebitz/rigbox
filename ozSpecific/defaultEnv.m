disp('hi rig Oz!')

global env

% Setup the environment struct - used by many task functions
env.screenNumber = 2;
env.resolution = Screen('Resolution',env.screenNumber);
env.width = env.resolution.width;
env.distance = 70; % in cm, monkey from screen
env.physicalWidth = 61; % in cm, width of the visible screen
env.colorDepth = 255;
env.rigID = 'Oz'; %

% juicer stuff
env.juicePort = hex2dec('DFF8');
env.rwdBit = 1;
env.rwdDuration = 60;%75; % in ms
env.rwdDelay = 50; % in ms
env.defaultRwdDrops = 1;

% eyelink stuff
env.eyeToTrack = 'RIGHT'; % if no t binocular
env.binocularEye = 'NO'; % 'NO' to pick a particular eye