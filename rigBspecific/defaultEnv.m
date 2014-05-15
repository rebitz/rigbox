global env

% Setup the environment struct - used by many task functions
env.screenNumber = 2;
env.resolution = Screen('Resolution',env.screenNumber);
env.width = env.resolution.width;
env.distance = 34; % in cm, monkey from screen
env.physicalWidth = 40; % in cm, width of the visible screen
env.colorDepth = 255;
env.stimPort = 0; % port for microstim
env.stimCh = 1; % channel for microstimulation
env.juicePort = 0; % port for microstim
env.juiceCh = 0; % channel for microstimulation
env.rigID = 'RigB'; %

% open the DIO, make sure we can access everything
setupDIO;
env.allDIOclosed = flags;
env.nports = nports;
env.digOut = digOut;

KbName('UnifyKeyNames');