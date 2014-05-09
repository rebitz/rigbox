function stimTest(filename,location,depth);
%
% put up a fixation cross and run some stim pulses
% -- plot the output by default to see the saccades generated
% -- returns mean endpoint location of stimulated saccades [th,rho]
% takes inputs filename, location of hole, depth (from brain 0)

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
filename = strcat(filename,'FIXSTIM',datestr(now,'mmddyy_HHMM'));

% make a default environment!!!
global env; defaultEnv;

% set defaults
fixSize = 0.5;
fixErr = 2;
fixColor = repmat(max(env.colorDepth),1,3); % bright fix
bgColor = repmat(max(env.colorDepth)/3,1,3); % dark bg
voltage = 50; % default, in muA
duration = 100; % default, in ms
fixOnTrue = 1; % default to on
postStimTime = 2; % how long to collect eye data after stimulation onset
EYEBALL = 1;

% for plotting:
colors = colormap('jet');
colorStep = 8;
preWindow = 0.1; %preWindow = preWindow*1000;
postWindow = 0.5; %postWindow = postWindow*1000;

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

while continueRun

    % plotting color for this trial
    if tNum*3 < length(colors)
        trialColor = colors(tNum*colorStep,:);
    else
        trialColor = colors(tNum*colorStep-length(colors),:);
    end
    
    % query the user for current stim information
    queryUser;
    if ~continueRun; break; end

    disp('ready for fixation, press "space" to display');
    waiting = 1;
    while waiting
        escStimCheck;
        sampleEye;
    end
    if ~continueRun; break; end
    
    if fixOnTrue
        % Fixation onset
        Screen(w,'FillRect',fixColor,fixRect)
        fixOnT = Screen(w,'Flip');
        
        fixed = 0; waiting = 1;
        while ~fixed && waiting
            fixed = checkFix(origin, fixErr);
            sampleEye;
            escStimCheck;
        end
        disp('fixation acquired; press "t" for stim')
    else
        fixOnT = GetSecs();
        fixed = 1;
    end
    
    % wait for user-inputted stimulation go time
    stimGo = 0;
    while ~stimGo && continueRun
        escStimCheck;
        sampleEye;
    end
    if ~continueRun; break; end
    
%     % get pre-stim eyetracker tstamp
%     if EYEBALL
%         r = Eyelink('RequestTime');
%         if r == 0
%             preEyeTime = Eyelink('ReadTime');
%         end
%     end
    
    % do stim
    stimPulse;
    disp('stim delivered, collecting eyedata');
    
%     % get post-stim timestamp from eyetracker
%     if EYEBALL
%         r = Eyelink('RequestTime');
%         if r == 0
%             postEyeTime = Eyelink('ReadTime');
%         end
%     end

    % clear the screen
    Screen(w,'FillRect',bgColor)
    screenClearT = Screen(w,'Flip');
    
    % wait a respectable period & collect eye data
    while (GetSecs() - stimOn) < postStimTime
        % escStimCheck; % no option to escape this - prime data collection!
        sampleEye;
    end
    
    %% close the trial, save all the deets
    trials(tNum).location = location;
    trials(tNum).depth = depth;
    
    trials(tNum).voltage = voltage;
    trials(tNum).duration = duration;
    trials(tNum).fixOnTrue = fixOnTrue;

    % timing, from matlab
    trials(tNum).fixOnTime = fixOnT;
    trials(tNum).stimOnTime = stimOn;
    trials(tNum).fixOffTime = screenClearT;

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
    
    % then plots
    preT = stimOn-preWindow;
    postT = stimOn+postWindow;
    % convert eyetracker stamps to matlab time
    tstamps = (samples(1,:)/1000)+trials(tNum).trackerOffset;
    idx = and(tstamps > preT, tstamps < postT);
    tstamps = tstamps(idx);
    xPos = samples(14,idx);
    yPos = samples(16,idx);
    pulse = zeros(1,length(tstamps)); % make a cartoon pulse of when stim was on
    idx = and(tstamps >= stimOn, tstamps <= stimOn+(duration./1000));
    pulse(idx) = deal(voltage);
    tFromStim = tstamps - min(tstamps);
    
    % then plotting
    figure(99);
    subplot(6,1,1); hold on; % pulse
    plot(tFromStim,pulse,'Color',trialColor);
    ylabel('stim pulse (cartoon)');
    
    subplot(6,1,2); hold on; % x pos
    plot(tFromStim,xPos-nanmean(xPos(1:preWindow*1000)),'Color',trialColor);
    ylabel('x position (px)');
    
    subplot(6,1,3); hold on; % y pos
    plot(tFromStim,yPos-nanmean(yPos(1:preWindow*1000)),'Color',trialColor);
    ylabel('y position (px)');
    
    subplot(6,1,4:6); hold on;
    plot(xPos-nanmean(xPos(1:preWindow*1000)),...
        yPos-nanmean(yPos(1:preWindow*1000)),'Color',trialColor);
    xlabel('xpos (px)'); ylabel('ypos (px)');
    xlim([-env.screenWidth/2 env.screenWidth/2]);
    ylim([-env.screenHeight/2 env.screenHeight/2]);
    
    % append plot info to trial struct
%    trials(tNum).preEyeTime = preEyeTime;
%    trials(tNum).postEyeTime = postEyeTime;
    trials(tNum).x = xPos;
    trials(tNum).y = yPos;
    trials(tNum).tstamps = tstamps;
    trials(tNum).pulse = pulse;
    
    
    % setup the next trial
    tNum = tNum+1;
    samples = NaN(size(samples,1),1);
 
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
    if strcmp(devices(1).Model,'PCI-6251') || strcmp(devices(1).Model,'PCIe-6361')
        dio = daq.createSession('ni');  % specify # of lines on port 0
        
        devStr = devices(1).ID;
        
        % juice port
        portStr = strcat('port',num2str(env.juicePort),'/line',num2str(env.juiceCh));
        dio.addDigitalChannel(devStr,portStr,'OutputOnly') %0:3 is #1-4
        
        % microstim port
        portStr = strcat('port',num2str(env.stimPort),'/line',num2str(env.stimCh));
        dio.addDigitalChannel(devStr,portStr,'OutputOnly') %0:3 is #1-4
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

function giveJuice % send a pulse to open the stim
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
    set(gcf, 'Position', [50 49 409 841]);
    
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
    
    % Setup stimuli and fixation rects
    fixSize = deg2px(fixSize, env)./2;
    fixRect = [origin origin] + [-fixSize -fixSize fixSize fixSize];
    fixErr = deg2px(fixErr, env)./2;

    env.dataDir = 'C:\Users\User\Documents\GitHub\rigbox\stimTest\data';
    
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
    promt = {'voltage:','duration','fixation displayed?'};
    nLines = 1;
    def = {num2str(voltage),num2str(duration),'y'};
    tmp = inputdlg(promt,'test',nLines,def);
    
    if isempty(tmp) % cancel was pressed
        continueRun = 0;
    else
        curIn = str2num(tmp{1});
        if isempty(curIn);
            fprintf('\n no voltage given, recording %0g mV \n',voltage);
            voltage = voltage; % assume no change if no info provided
        else
            voltage = curIn;
        end
        
        durIn = str2num(tmp{2});
        if isempty(durIn);
            fprintf('\n no duration given, recording %0g ms \n',duration);
            duration = duration; % assume no change if no info provided
        else
            duration = durIn;
        end
        
        fixIn = tmp{3};
        if isempty(fixIn);
            fprintf('\n no answer given, default to showing fixation \n');
            fixOnTrue = 1; % default to fix on
        elseif ~isempty(strfind(fixIn,'y'));
            fixOnTrue = 1; % on
        else
            fixOnTrue = 0; % off
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

function defaultEnv
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
end

end