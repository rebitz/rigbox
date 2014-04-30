% esc_check.m

if ~exist('stopkey')
    stopkey = KbName('ESCAPE');
end

if ~exist('juicekey')
    juicekey = KbName('j');
end

[keyIsDown, secs, keyCode] = KbCheck;

if keyCode(stopkey)
    keep_waiting = 0;
    continue_running = 0; 

elseif keyCode(juicekey)
    giveJuice
    disp('juiced')
end