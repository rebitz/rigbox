function barTrain(monk)
%
% first parse inputs
filename = strcat(monk,'_','barTrain','_',datestr(now,'ddmmyyyy_HHMM'));

% make a default environment!!!
global env juiceCount; defaultEnv;
KbName('UnifyKeyNames');

% set defaults
% stimuli/display?
fullScreen = 1; % full screen color?
    % else:
    fixSize = 10;
cueGoTime = 1; % else, put up the cue after release
goColor = [1 1 1]; % white
noGoColor = [.5 .5 .5]; % gray
bgColor = [0 0 0];

% timings?
tToGo = 2;
tToHold = 1;
tWaitInGo = 2;

% others?
nJuices = 5;

% initialize vars
tNum = 1;
continueRun = 1;
fixGo = 0;

% prepare the environment
setupDIOLocal;
disp('dio open');
prepareEnv; % open the screen, eyelink connectionk, etc
disp('environment initialized');

while continueRun

    if ~continueRun; break; end
    
    % initialize trial stuff
    juiceCount = 0; goOnTrue = false; barDown = false; released = false;

    disp('new trial!');
    
    waiting = 1;
    while waiting % main body of the code
        
        Screen(w,'FillRect',bgColor)
        Screen(w,'FillRect',noGoColor,fixRect)
        flipT1 = Screen(w,'Flip');
        
        while (GetSecs() - flipT1) < tToGo && ~barDown
            escStimCheck;
            barDown = bitand(env.leverBitMask, io32(ioObj, env.juicePort+1));
            if barDown
                initializeT = GetSecs();
                goOnTrue = true; % allow manual juicing
            end
        end
        
        while (GetSecs() - flipT1) < tToHold && barDown
            escStimCheck;
            barDown = bitand(env.leverBitMask, io32(ioObj, env.juicePort+1));
        end
        
        if cueGoTime && barDown % if we're telling him when to go
            Screen(w,'FillRect',bgColor)
            Screen(w,'FillRect',goColor,fixRect)
            flipT2 = Screen(w,'Flip');
        end
        
        while (GetSecs() - flipT2) < tWaitInGo && ~released && barDown
            escStimCheck;
            released = ~bitand(env.leverBitMask, io32(ioObj, env.juicePort+1));
            if released
                responseT = GetSecs();
            end
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
        tNum = tNum+1;
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
    global ioObj

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
        count = 1;
        while count < nJuices
%             try,
                giveJuice;
%             catch
%                 disp('tried to juice')
%             end
            count = count+1;
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
    end
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