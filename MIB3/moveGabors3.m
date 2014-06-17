t_lastFrame = GetSecs - lasttime; % how long since last frame?

if t_lastFrame > flip_time % time to put up a new frame

    if t_lastFrame > flip_time*2
        flip = flip+1; frame = frame+1;
    end
    
    if flip > (360/phaseStep)
        flip = 1;
    end
    
    if tOn(1)
        textureIdx = t1Mov(flip);
        Screen('DrawTexture', w, textureIdx,[],t1Rect);
    end
    
    if tOn(2)
        textureIdx = t2Mov(flip);
        Screen('DrawTexture', w, textureIdx,[],t2Rect);
    end
    
    if tOn(3)
        textureIdx = t3Mov(flip);
        Screen('DrawTexture', w, textureIdx,[],t3Rect);
    end
    
    if fixStillOn
        Screen(w,'FillRect',fixcolor,fixRect); % to keep fix on screen
    end
    
    lasttime = Screen('Flip',w,[],1);
        
    % Increment flip & save presentation times
    allTimes = [allTimes; frame lasttime];
    frame = frame+1;
    flip = flip+1;

end