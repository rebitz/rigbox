% esc_check.m

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

elseif keyCode(juicekey)
    %mark_event('free_juice')
    %DIO=juice2(0.1,DIO);
end