function trials = barTrain(monk)
%
% first parse inputs
filename = strcat(monk,'_','barTrain','_',datestr(now,'ddmmyyyy_HHMM'));

% make a default environment!!!
global env juiceCount ioObj allRects; defaultEnv;
KbName('UnifyKeyNames');

% set defaults
% stimuli/display?
fullScreen = 0; % full screen color?
    % else:
    fixSize = 4;
    fixShift = 8;
cueGoTime = 1; % else, put up the cue after release
goColor = [1 1 1]; % white
noGoColor = [1 .5 .5]; % gray
bgColor = [0 0 0];
maxTR = 25;

% timings?
tToGo = 2;
tToHoldSeeds = [.6 1.2];
tWaitInGo = 2.15;
itiSeeds = [1.15 2.25];
penaltyWait = .05;

% others?
nJuices = 5;
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
    
    waiting = 1;
    while waiting % main body of the code
        
        % initialize trial stuff
        juiceCount = 0; goOnTrue = false; barDown = false; released = false;
        responseT = NaN; initializeT = NaN; flipT2 = NaN;
        iti = sampleFrom(itiSeeds); tToHold = sampleFrom(tToHoldSeeds);
        if exist('nextRect');
            fixRect = nextRect; % only update location at tr start
        end
        
        % put up the first cue
        Screen(w,'FillRect',bgColor)
        Screen(w,'FillRect',noGoColor,fixRect)
        flipT1 = Screen(w,'Flip');
        
        % wait for bar to be down
        while (GetSecs() - flipT1) < tToGo && ~barDown
            escStimCheck;
            barCheck;
        end
        
        if barDown % if sucessful!
            initializeT = GetSecs();
            goOnTrue = true; % allow manual juicing
        end

        while (GetSecs() - initializeT) < tToHold && barDown
            escStimCheck;
            barCheck;
        end
        
        if cueGoTime && barDown % if we're telling him when to go
            Screen(w,'FillRect',bgColor)
            Screen(w,'FillRect',goColor,fixRect)
            flipT2 = Screen(w,'Flip');
        elseif barDown
            flipT2 = GetSecs();
        end
        
        % wait for the period in which he can respond
        while barDown && (GetSecs() - flipT2) < tWaitInGo
            escStimCheck;
            barCheck;
        end
        
        if ~barDown && ~isnan(flipT2)
            responseT = GetSecs();
            if rand(1) < pJackpot; timesBy = jackpotTimes;
            else timesBy = 1; end
            giveJuice(nJuices*timesBy);
            released = true;
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
        trials(tNum).releasedLogical = released;
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
    if keyCode(env.juicekey) && goOnTrue
        count = 1; nJuices
        while count < nJuices
%             try,
                giveJuice;
%             catch
%                 disp('tried to juice')
%             end
            count = count+1
        end
        juiceCount = juiceCount+1;
    elseif keyCode(env.stimkey);
        % put up the stim cross
        fixGo = 1;
    elseif keyCode(env.stopkey)
        waiting = 0;
        continueRun = 0;
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

end