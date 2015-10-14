function manualJuice

global env
defaultEnv;
localEnv;
setupDIO;

ListenChar(2);
KbName('UnifyKeyNames');

continueRun = 1

while continueRun
    continueRun = escStimCheck(env);
end

closeDIO;
ListenChar(0);

end

function continueRun = escStimCheck(env)
    continueRun = 1;
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyCode(env.stopkey)
        waiting = 0;
        continueRun = 0;
    elseif keyCode(env.juicekey);
        giveJuice;
        WaitSecs(0.1); % refractory
    end
end

function localEnv
    global env

    % setup keyboard
    if ~exist('stopkey') % set defaults in case not set above
        env.stopkey = KbName('space');
    end

    if ~exist('juicekey')
        env.juicekey = KbName('j');
    end
end
