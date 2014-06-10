global env

% Setup the environment struct - used by many task functions
env.screenNumber = 0;
env.resolution = Screen('Resolution',env.screenNumber);
env.width = env.resolution.width;
env.distance = 70; % in cm, monkey from screen
env.physicalWidth = 61; % in cm, width of the visible screen
env.colorDepth = 255;
env.stimPort = 0; % port for microstim
env.stimCh = 1; % channel for microstimulation
env.juicePort = 0; % port for microstim
env.juiceCh = 0; % channel for microstimulation
env.rigID = 'RigF'; %