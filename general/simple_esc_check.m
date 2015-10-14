% simple_esc_check.m
% only waits for juice and end tasking

if ~exist('stopkey')
    stopkey = KbName('ESCAPE');
end

if ~exist('juicekey')
    juicekey = KbName('f1');
end

[keyIsDown, secs, keyCode] = KbCheck;

if keyCode(stopkey)
    keep_waiting = 0;
    continue_running = 0;
    error_made = 1; errortype = NaN;
elseif keyCode(juicekey)
    giveJuice;
    disp('free juice');
    WaitSecs(.2); % don't rethrow
end