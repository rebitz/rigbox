function faceTrain(monk)
%
% first parse inputs
filename = strcat(monk,'_',datestr(now,'ddmmyyyy_HHMM'));

% make a default environment!!!
global env juiceCount; defaultEnv;
KbName('UnifyKeyNames');

% set defaults
fixSize = 6;
useFaces = 1; % at all?
pNotFace = 0.1;
nJuices = 5;
fixColor = repmat(max(env.colorDepth)*1,1,3); % bright fix
bgColor = [0,0,0];%repmat(max(env.colorDepth)/3,1,3); % dark bg

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
    juiceCount = 0; nFlips = 0; firstFixOnT = NaN;
    
    % load the chosen stimulus, make the texture
    tmp = Shuffle(imageIdx);
    imName = imageList{tmp(1)};
    back = pwd;
    cd(env.imageDirectory)
    img = imread(imName);
    cd(back)
    imgIndx = Screen('MakeTexture', w, img);

    disp('ready for fixation, press "t" to display');
    waiting = 1; fixOnTrue = false;
    while waiting % main body of the trial code
        
        escStimCheck;
        
        if fixGo && ~fixOnTrue
            % Fixation onset
            if ~useFaces || rand < pNotFace
                Screen(w,'FillRect',fixColor,fixRect)
            else
                Screen(w,'DrawTexture',imgIndx,[],fixRect);
            end
            flipT = Screen(w,'Flip');
            while (GetSecs - flipT) < 0.15
                %escStimCheck;
            end
            fixOnTrue = true;
            fixGo = 0;
            if ~isnan(firstFixOnT); firstFixOnT = flipT; end
            nFlips = nFlips+1;
        elseif fixGo && fixOnTrue
            Screen(w,'FillRect',bgColor)
            flipT = Screen(w,'Flip');
            while (GetSecs - flipT) < 0.2
                escStimCheck;
            end
            fixGo = 0;
            fixOnTrue = false;
        end
    end
    
    % clear the screen
    Screen(w,'FillRect',bgColor)
    screenClearT = Screen(w,'Flip');

    %% close out the trial

    WaitSecs(0.2);

    % save the filedata
    trials(tNum).juiceCount = juiceCount;
    trials(tNum).nFlips = nFlips;
    trials(tNum).imageName = imName;
    trials(tNum).firstFixOnT = firstFixOnT;
    trials(tNum).trialEnd = screenClearT;

    % setup the next trial
    tNum = tNum+1;

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
    
    % initialize trials struct
    trials = ([]);
    
    % Setup stimuli and fixation rects
    fixSize = deg2px(fixSize, env)./2;
    fixRect = [origin origin] + [-fixSize -fixSize fixSize fixSize];

    % set a home directory somewhere
    env.home = pwd;
    cd(env.home);

    % image directory
    if IsOSX
        env.splitChar = '/';
    else
        env.splitChar = '\';
    end
    env.imageDirectory = strcat(env.home,env.splitChar,'stimuli');
    env.imStr = '.png';

    % get a list of image names
    cd(env.imageDirectory)
    files = dir;
    idx = ~cellfun(@isempty,strfind({files.name},env.imStr));
    idx = and(idx,cellfun(@isempty,strfind({files.name},'._')));
    imageList = {files(idx).name};
    imageIdx = [1:length(imageList)];

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
    if keyCode(env.juicekey) && fixOnTrue
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