% set the correct modes, based on user input

if nargin<2
    mode = 'EYE';
end

global EYEBALL
if strcmp(mode, 'EYE')
    EYEBALL = 1;
end

% Is this a test run?
global TESTING
if strcmp(mode, 'TEST')
    TESTING = 1;
else
    TESTING = 0;
end

ListenChar(2);

%% setup and begin to fill the global environmental variables
% does the dio in defaultEnv 

global env w
defaultEnv;

%% Initialize screen and keyboard fns

Screen('CloseAll'); % Screen clear
warning('off','MATLAB:dispatcher:InexactMatch');
warning('off','MATLAB:dispatcher:InexactCaseMatch');
Screen('Preference','VisualDebugLevel', 0);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'SkipSyncTests',1);

% Create new window and record size
[w, rect] = Screen('OpenWindow',env.screenNumber,env.colorDepth/2); % window Idx
[env.screenWidth, env.screenHeight] = WindowSize(w);

% Reseed random
RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
rng('shuffle');

% Switch KbName into unified mode: It will use the names of the OS-X
% platform on all platforms in order to make this script portable:
KbName('UnifyKeyNames');
space = KbName('SPACE');
esc = KbName('ESCAPE');
right = KbName('RightArrow');
left = KbName('LeftArrow');
up = KbName('UpArrow');
down = KbName('DownArrow');
shift = KbName('RightShift');
stopkey = KbName('ESCAPE');
juicekey = KbName('j');

% Define origin of screen
origin = [(rect(3) - rect(1))/2 (rect(4) - rect(2))/2];

%% initialize eye
% Connection with Eyelink if not in testing mode
if EYEBALL
    try       
        if Eyelink('IsConnected') ~= 1
            disp('Trying to connect to Eyelink, attempt #1(/2):');
            r = Eyelink('Initialize');
            if r ~= 0
                WaitSecs(.5) % wait half a sec and try again
                disp('Trying to connect to Eyelink, attempt #2(/2):');
                r = Eyelink('Initialize');
            end
        elseif Eyelink('IsConnected') == 1
            r = 0; % means OK initialization
        end

        if r == 0;
            disp('Eyelink successfully initialized!')
            % Get origin
            eyeparams.origin = origin;

            Eyelink('Command', 'screen_pixel_coords = %d %d %d %d', ...
                rect(1), rect(2), rect(3), rect(4) );
            Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA,PUPIL');
            edfname = 'ef.edf';
            Eyelink('openfile',edfname);

            % Calibrate tracker
            Eyelink('StartSetup');
            Eyelink('DriftCorrStart', origin(1), origin(2));
            Eyelink('ApplyDriftCorr');

            % Start of the task
            taskstart = GetSecs;
        elseif r ~= 0
            % If Eyelink can't initialize: report error and quit
            disp('Eyelink failed to initialize, check connections');
            continue_running = 0;
        end

    catch
        % If Eyelink can't initialize: report error and quit
        disp('Eyelink failed to initialize, check connections');
        continue_running = 0;
    end
end

%% feedback stuff:

errorSize = 8;
errorColor = [0 128 0];
errorSecs = 0.5;

makeAudioFeedback;
env.rwdSound = rwdSound;
env.norwdSound = norwdSound;
env.soundSF = sf;

%% from task-specific open task

% Initialize trial number
trialnum = 0;

% Flag to keep running task
continue_running = 1;

% set a default wait time if waiting for text needs to happen
waitForText = 1.5;


%% get full pathdef of data directory since we'll be moving around a lot

dataDirectory
cd(dataDirectory);
dataDirectory = pwd;