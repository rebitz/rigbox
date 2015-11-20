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
        WaitSecs(0.01); % refractory
    end
end

function localEnv
    global env

    % setup keyboard
    if ~exist('stopkey') % set defaults in case not set above
        try
        env.stopkey = KbName('ESCAPE');
        catch
            env.stopkey = KbName('esc');
        end
    end

    if ~exist('juicekey')
        env.juicekey = KbName('SPACE');
    end
end
