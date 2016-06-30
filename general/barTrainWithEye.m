function trials = barTrain(monk)
%
% first parse inputs
filename = strcat(monk,'_','barTrain','_',datestr(now,'ddmmyyyy_HHMM'));

% make a default environment!!!
global env juiceCount ioObj allRects; defaultEnv;
KbName('UnifyKeyNames');

% set defaults
maxTR = 22;

% stimuli/display?
fullScreen = 0; % full screen color?
    % else:
    fixSize = 2.5;
    fixShift = 8;
onAtBar = 0; % else on before bar, at start of trial
cueGoTime = 1; % use the cue to signal go time? else, put up the cue after release
goColor = [1 .7 .7]; % white
jackpotColor = [.75 .85 .85]; % another color
noGoColor = [1 .5 .5]; % gray
bgColor = [0 0 0];

EYEBALL = 1;
fixErr = 5;

% timings?
tToGo = 60; % time to wait for first lever press
tToHoldSeeds = [.48 .88]; % min max hold time before go
tWaitInGo = 2; % time to wait for for lever release, s
itiSeeds = [1.1 1.4];
penaltyWait = .05;

pJuiceAtHold = .85;
pJuiceAtGo = 0;

% others?
nJuices = 4;
pJackpot = 0.15;
jackpotTimes = 3;

% initialize vars
tNum = 1;
continueRun = 1;
fixGo = 0;
whichFix = 1;
buffer = NaN(1,10);

% prepare the environment
setupDIOLocal;
disp('dio open');
prepareEnv; % open the screen, eyelink connectionk, etc
disp('environment initialized');

% define a utility for making jitter
sampleFrom = @(x) rand*range(x)+min(x);

while continueRun

    if ~continueRun; break; end

    if EYEBALL;
        Eyelink('command', 'draw_box %d %d %d %d 15', round(fixRect(1)), round(fixRect(2)), round(fixRect(3)), round(fixRect(4)));    
    end
    
    waiting = 1;
    while waiting % main body of the code
        
        % initialize trial stuff
        juiceCount = 0; goOnTrue = false; barDown = false; released = false;
        responseT = NaN; initializeT = NaN; flipT2 = NaN;
        iti = sampleFrom(itiSeeds); tToHold = sampleFrom(tToHoldSeeds);
        jackpotTrial = rand(1) < pJackpot;
        if exist('nextRect');
            fixRect = nextRect; % only update location at tr start
        end
        
        if ~onAtBar
            % put up the first cue
            Screen(w,'FillRect',bgColor)
            Screen(w,'FillRect',noGoColor,fixRect+[-10 -10 10 10])
            flipT1 = Screen(w,'Flip');
        else
            flipT1 = GetSecs();
        end
        
        % wait for bar to be down
        while (GetSecs() - flipT1) < tToGo && ~barDown
            escStimCheck;
            barCheck;
            fixed = checkFix(origin, fixErr);
            if fixed; giveJuice(1); fixed = false; end
        end
        
        if barDown % if sucessful!
            initializeT = GetSecs();
            goOnTrue = true; % allow manual juicing

            if rand < pJuiceAtHold; giveJuice(1); end
            Screen(w,'FillRect',bgColor)
            Screen(w,'FillRect',noGoColor,fixRect)
            flipT1 = Screen(w,'Flip');
        end

        while (GetSecs() - initializeT) < tToHold && barDown
            escStimCheck;
            barCheck;
            fixed = checkFix(origin, fixErr);
            if fixed; giveJuice(1); fixed = false; end
        end
        
        if cueGoTime && barDown % if we're telling him when to go
            if rand < pJuiceAtGo; giveJuice(1); end
            Screen(w,'FillRect',bgColor)
            if ~jackpotTrial
                Screen(w,'FillRect',goColor,fixRect)
            else
                Screen(w,'FillRect',jackpotColor,fixRect)
            end
            flipT2 = Screen(w,'Flip');
        elseif barDown
            flipT2 = GetSecs();
        end
        
        % wait for the period in which he can respond
        while barDown && (GetSecs() - flipT2) < tWaitInGo
            escStimCheck;
            barCheck;
            fixed = checkFix(origin, fixErr);
            if fixed; giveJuice(1); fixed = false; end
        end
        
        if ~barDown && ~isnan(flipT2)
            responseT = GetSecs();
            if jackpotTrial; timesBy = jackpotTimes;
            else timesBy = 1; end
            giveJuice(nJuices*timesBy);
            released = true;
        elseif ~barDown % if it was an early release, get the t anyway
            responseT = GetSecs;
        end
    
        % clear the screen
        Screen(w,'FillRect',bgColor)
        screenClearT = Screen(w,'Flip');
        goOnTrue = false;

        %% close out the trial
        % save the filedata
        trials(tNum).juiceCount = juiceCount;
        trials(tNum).trialStartT = flipT1;
        trials(tNum).goCueT = flipT2;
        trials(tNum).t2initialize = initializeT;
        trials(tNum).releasedLogical = released; % this is actually more of a correct
        trials(tNum).responseT = responseT;
        trials(tNum).trialEnd = screenClearT;

        % setup the next trial
        tNum = tNum+1
        
        % ITI 
        itiStart = GetSecs;
        if ~released; iti = iti+penaltyWait; end
        while (GetSecs - itiStart) < iti
            escStimCheck;
        end
        
        if tNum>maxTR; waiting = 0; continueRun = 0; end
    end
    
    if ~continueRun; break; end
end

% close out the task
closeDIO;
closeTask;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Begin subfunctions:  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function setupDIOLocal
    %global ioObj

    try,
        ioObj = io32;
        status = io32(ioObj);
        if status ~= 0,
            error('Couldn''t initialize port.');
        else
            disp('Juice delivery system initialized.')
        end
    catch
        disp('Couldn''t initialize port, running anyway.');
    end
end

function prepareEnv
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
%                 Eyelink('DriftCorrStart', origin(1), origin(2));
%                 Eyelink('ApplyDriftCorr');
                
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

    % sounds, if necessary
    makeAudioFeedback;

    % Reseed random
    rng('shuffle');
    
    % parallel port for reading the bar press?
    env.leverBit = 7; % from redgreen
    env.leverBitMask = uint16(bitset(0, env.leverBit, 1));
    
    % initialize trials struct
    trials = ([]);
    
    % Setup stimuli and fixation rects
    fixSize = deg2px(fixSize, env)./2;
    if ~fullScreen
        fixRect = [origin origin] + [-fixSize -fixSize fixSize fixSize];
    else
        fixRect = rect;
    end

    goColor = max(env.colorDepth)*goColor; % bright fix
    noGoColor = max(env.colorDepth)*noGoColor; % bright fix
    bgColor = max(env.colorDepth)*bgColor; % dark bg
    jackpotColor = max(env.colorDepth)*jackpotColor;

    fixShift = deg2px(fixShift, env);
    
    allRects = [fixRect;...
        fixRect + [fixShift 0 fixShift 0];...
        fixRect - [fixShift 0 fixShift 0];...
        fixRect + [0 fixShift 0 fixShift];...
        fixRect - [0 fixShift 0 fixShift]];

    % set a home directory somewhere
    env.home = pwd;
    cd(env.home);

    % data directory
    if IsOSX
        env.splitChar = '/';
    else
        env.splitChar = '\';
    end
    env.dataDir = strcat(env.home,env.splitChar,'train',env.splitChar,'data');
    
    % setup keyboard
    if ~exist('stopkey') % set defaults in case not set above
        env.stopkey = KbName('ESCAPE');
    end

    if ~exist('waitkey')
        env.waitkey = KbName('Return');
    end
    
    if ~exist('jackpotkey')
        env.jackpotkey = KbName('j');
    end
    
    if ~exist('stimkey')
        env.stimkey = KbName('t');
    end
    
    if ~exist('juicekey')
        env.juicekey = KbName('space');
    end
    
    if ~exist('nextkey')
        env.nextkey = KbName('RightArrow');
    end
    
    % now fill out and save our taskdata stuff, now we've got it all
    taskdata = env;
    vars = who; 
    for i = 1:length(vars)
        if exist(vars{i},'var') && ~isempty(vars{i}) && ...
                ~strcmp(vars{i},'ans') && ~strcmp(vars{i},'env')
            taskdata.(vars{i}) = eval(vars{i});
        end
    end
    cd(env.dataDir);
    save(strcat(filename,'_taskdata'),'taskdata');
    cd(env.home);
end

function escStimCheck
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyCode(env.juicekey) %&& goOnTrue
        count = 1; nJuices
        %while count < nJuices
%             try,
                giveJuice;
%             catch
%                 disp('tried to juice')
%             end
         %   count = count+1
        %end
        %juiceCount = juiceCount+1;
    elseif keyCode(env.stimkey);
        % put up the stim cross
        fixGo = 1;
    elseif keyCode(env.stopkey)
        waiting = 0;
        continueRun = 0;
    elseif keyCode(env.jackpotkey);
        jackpotTrial = true;
    elseif keyCode(env.waitkey);
        waiting = 0;
    elseif keyCode(env.nextkey);
        if whichFix < size(allRects,1)
            nextRect = allRects(whichFix+1,:);
            whichFix = whichFix+1;
        else
            nextRect = allRects(1,:);
            whichFix = 1;
        end
    end
end

function barCheck
    buffer = [buffer(2:end) ~bitand(env.leverBitMask, io32(ioObj, env.juicePort+1))];
    barDown = nanmean(buffer) > .9;
end

function makeAudioFeedback
    for sounds = 1:2
        switch sounds
            case 1
                cf = [440 523.25 698.46];   % rising 3 notes
            case 2
                cf = [440 220 220]; % falling 2 notes;
        end

        sf = 22050;                 % sample frequency (Hz)
        d = .1;                     % duration - each tone (s)
        n = sf * d;                 % number of samples
        stmp = (1:n) / sf;             % sound data preparation

        s = [];
        for i = 1:length(cf)
            s = [s sin(2 * pi * cf(i) * stmp)];   % sinusoidal modulation
        end

    %   sound(s, sf);               % sound presentation

        switch sounds
            case 1
                env.rwdSound = s;   % rising 3 notes
            case 2
                env.norwdSound = s;   % falling 2 notes
        end
    end
    env.soundSF = sf;
end

function closeTask

    % save trials
    cd(env.dataDir);
    save(filename,'trials');
    cd(env.home);
    
    % screen clear
    sca;
    commandwindow;
    
    cd(env.home)
    
end

function fixed = checkFix(object, err)
    fixed = 0;
    if EYEBALL
        checked = 0;
        
        while ~checked
            Eyelink('newfloatsampleavailable');
            
            if Eyelink('newfloatsampleavailable')>0;

                evt = Eyelink( 'newestfloatsample');
                % for tracking the RIGHT eye
                xR = evt.gx(2); yR = evt.gy(2); paR = evt.pa(2);
                
                % for tracking the LEFT eye
                xL = evt.gx(1); yL = evt.gy(1); paL = evt.pa(1);
                
                % now combine so we don't have to think about this again
                x = [xL, xR]; x(x==-32768) = NaN; x = nanmean(x);
                y = [yL, yR]; y(y==-32768) = NaN; y = nanmean(y);
                pa = [paL, paR]; pa(pa==-32768) = NaN; pa = nanmean(pa);

                if (pa > 0) && (abs(x-object(1)) > err || abs(y-object(2)) > err)
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