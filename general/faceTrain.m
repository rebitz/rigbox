function faceTrain(monk)
%
% put up a fixation cross and run some stim pulses
% -- plot the output by default to see the saccades generated
% -- returns mean endpoint location of stimulated saccades [th,rho]
% takes inputs filename, location of hole, depth (from brain 0)

% first parse inputs
filename = strcat(monk,'_',datestr(now,'ddmmyyyy_HHMM'));

% make a default environment!!!
global env juiceCount; defaultEnv;
KbName('UnifyKeyNames');

% set defaults
fixSize = 6;
useFaces = 1;
fixErr = 2;
fixColor = repmat(max(env.colorDepth)*1,1,3); % bright fix
bgColor = repmat(max(env.colorDepth)/3,1,3); % dark bg
EYEBALL = 0;

% initialize vars
tNum = 1;
continueRun = 1;
fixGo = 0;

% prepare the environment
setupDIOLocal;
disp('dio open');
prepareEnv; % open the screen, eyelink connectionk, etc
disp('environment initialized');

% image directory
imageDirectory = strcat(pwd,'/stimuli/');
imStr = '.JPG';

% get a list of image names
cd(imageDirectory)
files = dir;
idx = ~cellfun(@isempty,strfind({files.name},imStr));
imageList = {files(idx).name};
imageIdx = [1:length(imageList)];

trials = ([]);

while continueRun

    if ~continueRun; break; end
    
    % initialize trial stuff
    juiceCount = 0;
    
    % load the chosen stimulus, make the texture
    tmp = Shuffle(imageIdx);
    imName = imageList{tmp(1)};
    back = pwd;
    cd(imageDirectory)
    img = imread(imName);
    cd(back)
    imgIndx = Screen('MakeTexture', w, img);

    disp('ready for fixation, press "t" to display');
    waiting = 1; fixOnTrue = false;
    while waiting % main body of the code
        
        escStimCheck;
        
        if fixGo && ~fixOnTrue
            % Fixation onset
            if useFaces
                Screen(w,'DrawTexture',imgIndx,[],fixRect);
            else
                Screen(w,'FillRect',fixColor,fixRect)
            end
            flipT = Screen(w,'Flip');
            while (GetSecs - flipT) < 0.15
                escStimCheck;
            end
            fixOnTrue = true;
            fixGo = 0;
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
    if ~continueRun; break; end
    
    % clear the screen
    Screen(w,'FillRect',bgColor)
    screenClearT = Screen(w,'Flip');
    
    %% close out the trial
    
    WaitSecs(0.2);
    
    % save the filedata
    trials.juiceCount = juiceCount;
    
    % setup the next trial
    tNum = tNum+1;
 
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

    % Reseed random
    rng('shuffle');
    
    % initialize trials struct
    trials = ([]);
    
    % Setup stimuli and fixation rects
    fixSize = deg2px(fixSize, env)./2;
    fixRect = [origin origin] + [-fixSize -fixSize fixSize fixSize];
    fixErr = deg2px(fixErr, env)./2;

    % Now for images
    
    %%
    %%%%
    %%%%
    %%%% PAY ATTENTION!!!!
    env.dataDir = pwd;% 'C:\Users\User\Documents\GitHub\rigbox\stimTest\data';
    %%%%
    %%%%
    %%%%
    %%
    
    % setup keyboard
    if ~exist('stopkey') % set defaults in case not set above
        env.stopkey = KbName('escape');
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

function escStimCheck
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyCode(env.juicekey);
        count = 1;
        while count < 10
            try,
                giveJuice;
            catch
                disp('tried to juice')
            end
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

function closeTask

    % closeDio stuff
    
    % screen clear
    sca;
    commandwindow;
    
end

end