function stimTargTest(filename,location,depth,targLoc)
%
% put up a target stimulus and run some stim pulses right before the targ
% -- idea is to see if target PLR is modulated by FEF stim
% takes inputs filename, location of hole, depth (from brain 0)
%   also targLoc - which should be [theta, ecc], in deg;
%
% there is no ITI here - you have to press space to make the initial
% fixation appear - after that it should progress automatically

% first parse inputs
if nargin < 3 % if nothing provided
    disp('No depth provided')
    depth = NaN;
end

if nargin < 2 % if nothing provided
    disp('No recording site provided')
    location = NaN;
end

if nargin < 1
    disp('No filename provided, using test.mat')
    filename = 'test';
end
filename = strcat(filename,'TARGSTIM',datestr(now,'mmddyy_HHMM'));

% make the default environment
global env; defaultEnv;

% set parameters
changingStimParams = 0; % 0 = use info provided at start of run
nTrials = 100;
pStimTrial = 0.7;

fixSize = 0.5;
fixErr = 3;
fixColor = repmat(max(env.colorDepth),1,3); % bright fix
minFixed = .4; % min time to hold fix
maxFixed = .6; % max time to hold fix
time2choose = 1; % time to saccade to target

targSize = 3;
targErr = 10;
targColor = repmat(max(env.colorDepth),1,3);
targInLoc = targLoc;
targOutLoc = [targLoc(1)+180 targLoc(2)]; % opposing side
bgColor = repmat(max(env.colorDepth)/4,1,3); % dark bg for pupil size

current = 50; % default, in muA
duration = 100; % default, in ms
% fixOnTrue = 1; % default to on
postStimTime = 2; % how long to collect eye data after stimulation onset
EYEBALL = 1;

% timestamps that may not be accessed = NaNs
[fixOnT,fixAcq,stimOn,screenClearT,targOnT,juiceT] = deal(NaN);

% initialize vars
tNum = 1;
continueRun = 1;

% prepare the environment
prepareEnv; % open the screen, eyelink connectionk, etc
disp('environment initialized');
setupStimDio; % open the dio
disp('dio open');

global samples;
samples = NaN(31,1);

% start by asking the user what to do;
if ~changingStimParams
    queryUser;
end

while continueRun

    % initialize some trial by trial parameters
    % pick which target to show
    targIn = Shuffle([0 1]);
    if targIn(1) == 1
        targIn = 1;
        targRect = t1Rect;
        targOrigin = t1origin;
    elseif targIn(1) == 0
        targIn = 0;
        targRect = t0Rect;
        targOrigin = t0origin;
    end
    
    % stim or no stim trial?
    stimTrial = convertProb(pStimTrial); stimTrial = stimTrial(1);
    
    % pick hold time for this trial
    holdTime = rand*(maxFixed-minFixed)+minFixed;
    
    % query the user for current stim information if it's changing
    if changingStimParams
        queryUser;
        if ~continueRun; break; end
    end

    disp('ready for fixation, press "space" to display');
    waiting = 1;
    while waiting
        escStimCheck;
        sampleEye;
    end
    if ~continueRun; break; end
    
    % Fixation onset
    Screen(w,'FillRect',fixColor,fixRect)
    fixOnT = Screen(w,'Flip');

    fixed = 0; errorMade = 0; waiting = 1;
    while ~fixed && waiting
        fixed = checkFix(origin, fixErr);
        sampleEye;
        escStimCheck;
    end
    disp('fixation acquired; waiting for stim and targ')
    
    % wait for fixation hold time for stimulation go time
    fixAcq = GetSecs;
    while (GetSecs - fixAcq) < holdTime && fixed && continueRun
        fixed = checkFix(origin, fixErr);
        escStimCheck;
        sampleEye;
    end % can shortcircuit this with stim key
    if ~continueRun; break; end
    if ~fixed; errorMade = 1; end
    
    if ~errorMade;        
        % and it's a stim trial, do stim
        if stimTrial
            stimPulse;
            disp('stim delivered, collecting eyedata');
        end

        % do target onset
        Screen(w,'FillRect',targColor,targRect)
        targOnT = Screen(w,'Flip');

        % check for eye position within the target
        targAcq = 0;
        while (GetSecs - targOnT) < time2choose && ~targAcq
            targAcq = checkFix(targOrigin, targErr);
        end
        if ~targAcq; errorMade = 1; end
    end
    
    if ~errorMade
        juiceT = giveJuice();
        
    end
    
    % clear the screen
    Screen(w,'FillRect',bgColor)
    screenClearT = Screen(w,'Flip');

    % wait a respectable period & collect eye data
    while (GetSecs() - stimOn) < postStimTime
        escStimCheck; % mostly to check for juicing
        sampleEye;
    end
    
    %% close the trial, save all the deets
    trials(tNum).location = location;
    trials(tNum).depth = depth;
    
    % stimulation parameters
    trials(tNum).stimTrial = stimTrial; % logical
    trials(tNum).current = current;
    trials(tNum).duration = duration;

    % timing, from matlab
    trials(tNum).fixOn = fixOnT;
    trials(tNum).fixAcq = fixAcq;
    trials(tNum).fixHoldTime = holdTime;
    trials(tNum).stimOnTime = stimOn;
    trials(tNum).fixOffTime = screenClearT;

    % target information
    trials(tNum).targOn = targOnT;
    trials(tNum).targInLoc = targInLoc;
    trials(tNum).targOutLoc = targOutLoc;
    trials(tNum).targInLogical = targIn;
    
    % outcome information
    trials(tNum).error = errorMade;
    trials(tnum).juiceT = juiceT;
    
    % eye data
    trials(tNum).eyedata = samples;

    % trackerTimeOffset
    r = Eyelink('RequestTime');
    if r == 0
        WaitSecs(0.1); %superstition
        beforeTime = GetSecs();
        trackerTime = Eyelink('ReadTime'); % in ms
        afterTime = GetSecs();

        pcTime = mean([beforeTime,afterTime]); % in s
        trials(tNum).pcTime = pcTime;
        trials(tNum).trackerTime = trackerTime;
        trials(tNum).trackerOffset = pcTime - (trackerTime./1000);
        % would make legit time = (eyeTimestamp/1000)+offset
    end
    
    % setup the next trial
    tNum = tNum+1;
    if tNum > nTrials; continueRun = 0; end % or don't
    
    % vars that may not be accessed = NaNs
    samples = NaN(size(samples,1),1);
    [fixOnT,fixAcq,stimOn,screenClearT,targOnT,juiceT] = deal(NaN);
 
end

% post-process? extract actual saccades?

closeDio;
closeTask;

%% Begin subfunctions:

function setupStimDio % subfunction to open the stimulator

    % open the daq session
    devices = daq.getDevices;

    global dio;

    % DEV1 should be our PCI 6251
    if strcmp(devices(1).Model,'PCI-6251')
        dio = daq.createSession('ni');  % specify # of lines on port 0
        
        % juice port
        portStr = strcat('port',num2str(env.juicePort),'/line',num2str(env.juiceCh));
        dio.addDigitalChannel('Dev1',portStr,'OutputOnly') %0:3 is #1-4
        
        % microstim port
        portStr = strcat('port',num2str(env.stimPort),'/line',num2str(env.stimCh));
        dio.addDigitalChannel('Dev1',portStr,'OutputOnly') %0:3 is #1-4
    else
        fprintf('\n Error, wrong device ID entered \n')
        dio = [];
    end
end

function closeDio
    global dio
    daqreset; % legacy, but hasn't been replaced
    clear('dio');
end

function stimPulse % send a pulse to open the stim
    global dio
    dio.outputSingleScan([0 1]);
    stimOn = GetSecs();
    dio.outputSingleScan([0 0]);
end

function timeStamp = giveJuice % send a pulse to open the stim
    global dio
    dio.outputSingleScan([1 0]);
    % get timestamp
    timeStamp = GetSecs();
    while GetSecs() < timeStamp+0.05
    end
    dio.outputSingleScan([0 0]);
end

function prepareEnv
    % setup plotting window for us
    h = figure(99); clf; hold on;
    set(gcf, 'Position', [360 49 609 841]);
    
    Screen('CloseAll'); % Screen clear
    warning('off','MATLAB:dispatcher:InexactMatch');
    warning('off','MATLAB:dispatcher:InexactCaseMatch');
    Screen('Preference','VisualDebugLevel', 0);
    Screen('Preference', 'SuppressAllWarnings', 1);
    Screen('Preference', 'SkipSyncTests',1);
    
    [w, rect] = Screen('OpenWindow',env.screenNumber,bgColor); % window Idx
    [env.screenWidth, env.screenHeight] = WindowSize(w);
    
    Screen(w,'FillRect',bgColor);
    Screen(w,'Flip');
    
    disp('screens prepared...');

    % Define origin of screen
    origin = [(rect(3) - rect(1))/2 (rect(4) - rect(2))/2];

    % Reseed random
    rng('shuffle');
    
    % initialize trials struct
    trials = ([]);
    
    disp('connecting eyelink...');
    
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
                Eyelink('Command', 'screen_pixel_coords = %d %d %d %d', ...
                    rect(1), rect(2), rect(3), rect(4) );
                Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA,PUPIL');

                % Calibrate tracker
                Eyelink('StartSetup');
                Eyelink('DriftCorrStart', origin(1), origin(2));
                Eyelink('ApplyDriftCorr');
                
            elseif r ~= 0
                % If Eyelink can't initialize: report error and quit
                disp('Eyelink failed to initialize, check connections');
                continueRun = 0;
            end

            Eyelink('StartRecording');
        catch
            % If Eyelink can't initialize: report error and quit
            disp('Eyelink failed to initialize, check connections');
            continueRun = 0;
        end
    end
    
    % Setup fixation rects
    fixSize = deg2px(fixSize, env)./2;
    fixRect = [origin origin] + [-fixSize -fixSize fixSize fixSize];
    fixErr = deg2px(fixErr, env)./2;
    
    % Setup target rects
    [t1x, t1y] = pol2cart(deg2rad(targInLoc(1)),deg2px(targInLoc(2), env));
    [t0x, t0y] = pol2cart(deg2rad(targOutLoc(1)),deg2px(targOutLoc(2), env));
    targSize = deg2px(targSize, env)./2;
    t1origin = [t1x,t1y]+origin;
    t1Rect = [t1origin t1origin] + [-targSize -targSize targSize targSize];
    t0origin = [t0x,t0y]+origin;
    t0Rect = [t0origin t0origin] + [-targSize -targSize targSize targSize];
    targErr = deg2px(targErr, env)./2;

    global gitDir
    if IsOSX
        splitChar = '/';
    else
        splitChar = '\';
    end
    dataDirectory = strcat(gitDir,splitChar,'stimTest',splitChar,'data');
    env.dataDir = dataDirectory;
    
    % setup keyboard
    if ~exist('stopkey') % set defaults in case not set above
        env.stopkey = KbName('esc');
    end

    if ~exist('waitkey')
        env.waitkey = KbName('space');
    end
    
    if ~exist('stimkey')
        env.stimkey = KbName('t');
    end
    
    if ~exist('juicekey')
        env.juicekey = KbName('j');
    end
end

function queryUser
    promt = {'current:','duration'};
    nLines = 1;
    def = {num2str(current),num2str(duration)};
    tmp = inputdlg(promt,'test',nLines,def);
    
    if isempty(tmp) % cancel was pressed
        continueRun = 0;
    else
        curIn = str2num(tmp{1});
        if isempty(curIn);
            fprintf('\n no current given, recording %0g mA \n',current);
            current = current; % assume no change if no info provided
        else
            current = curIn;
        end
        
        durIn = str2num(tmp{2});
        if isempty(durIn);
            fprintf('\n no duration given, recording %0g ms \n',duration);
            duration = duration; % assume no change if no info provided
        else
            duration = durIn;
        end
    end
end

function escStimCheck
    ListenChar(2);
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyCode(env.stopkey)
        waiting = 0;
        continueRun = 0;
    elseif keyCode(env.waitkey);
        waiting = 0;
    elseif keyCode(env.juicekey);
        giveJuice;
        WaitSecs(0.1); % refractory
    elseif keyCode(env.stimkey);
        % put up the stim cross
        stimGo = 1;
    end
    ListenChar(0);
end

function sampleEye
    if EYEBALL
        [tempsamples, ~, ~] = Eyelink('GetQueuedData');
        if size(tempsamples, 1) == size(samples, 1)
            samples = [samples tempsamples];
        end
    end
end

function closeTask
    % save data
    home = pwd;
    cd(env.dataDir);
    save(filename,'trials','env');
    
    % closeDio stuff
    
    % screen clear
    sca;
    commandwindow;
    
    % eyelink clear
    if EYEBALL
        Eyelink('command', 'clear_screen %d', 0);
        Eyelink('stoprecording');
        Eyelink('shutdown');
    end
    
end

function fixed = checkFix(object, err)
    fixed = 0;
    if ~EYEBALL
        WaitSecs(0.5)
        fixed = 1;
    else
        escStimCheck;
        checked = 0;
       
        while ~checked
            if Eyelink('newfloatsampleavailable')>0;

                evt = Eyelink( 'newestfloatsample');
                x = evt.gx(1);
                y = evt.gy(1);

                if (evt.pa(1) > 0) && (abs(x-object(1)) > err || abs(y-object(2)) > err)
                    fixed = 0;
                else
                    fixed = 1;
                end
                checked = 1;
            end
        end
    end
end

end