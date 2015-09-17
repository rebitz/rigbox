function screenLuminanceTest
% screenLuminanceTest
%  just flash some colors so we can read it off the luminance meter

% make the default environment
global env; defaultEnv;

% set the background color
bgColor = [.1 .1 .1]*max(env.colorDepth);

% prepare the environment
prepareEnv; % open the screen, eyelink connectionk, etc
KbName('UnifyKeyNames');

colors = [.7 .7 .7;...
        .1 .1 .1;...
        .3 .3 .3]

colors = colors*max(env.colorDepth);

continueRun = 1;

fprintf('\n')
fprintf('\n Environment initialized, press space to advance screen.')

for i = 1:size(colors,1)
    if ~continueRun
        i = size(colors,1);
    else
        waiting = 1;
        
        Screen(w,'FillRect',colors(i,:));
        Screen(w,'Flip');
    
        colored = colors(i,:)./max(env.colorDepth);
        fprintf('\n')
        fprintf('\n Color #%d, [%.2f,%.2f,%.2f]',...
            i,colored(1),colored(2),colored(3))
        
        pause(0.25); % no double keys
        
        while waiting
            escStimCheck;
        end
        
    end
end

% close all, return to normal
sca;

function defaultEnv
    % Setup the environment struct - used by many task functions
    env.screenNumber = 1; % was 2
    env.resolution = Screen('Resolution',env.screenNumber);
    env.width = env.resolution.width;
    env.distance = 34; % in cm, monkey from screen
    env.physicalWidth = 40; % in cm, width of the visible screen
    env.colorDepth = 255;
    env.rigID = 'RigB'; %
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
    
    % setup keyboard
    if ~exist('stopkey') % set defaults in case not set above
        env.stopkey = KbName('escape');
    end

    if ~exist('nextkey')
        env.nextkey = KbName('space');
    end
end


function escStimCheck
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyCode(env.stopkey)
        waiting = 0;
        continueRun = 0;
    elseif keyCode(env.nextkey);
        waiting = 0;
    end
end

end