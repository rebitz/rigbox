% esc_check.m

if ~exist('stopkey')
    stopkey = KbName('ESCAPE');
end

if ~exist('juicekey')
    juicekey = KbName('f1');
end

if ~exist('pausekey')
    pausekey = KbName('p');
end

[keyIsDown, secs, keyCode] = KbCheck;

if keyCode(stopkey)
    keep_waiting = 0;
    continue_running = 0;
elseif keyCode(pausekey)
    paused = 1; disp('PAUSED! Press the space bar to continue.');
    error_made = 1; errortype = NaN;
    while paused
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyCode(space)
            paused = 0;
        elseif keyCode(stopkey)
            keep_waiting = 0;
            continue_running = 0;
            paused = 0;
        elseif keyCode(juicekey)
            giveJuice;
            disp('free juice');
            WaitSecs(.2); % don't rethrow
        end
    end
elseif keyCode(juicekey)
    giveJuice;
    disp('free juice');
    WaitSecs(.2); % don't rethrow
end