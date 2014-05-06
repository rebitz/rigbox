t_lastFrame = GetSecs - lasttime; % how long since last frame?

if t_lastFrame > flip_time % time to put up a new frame
    
%     if fixed
%         Screen('FillRect',w,fixcolor,fixRect)
%     end
    
    if t_lastFrame > flip_time*2
        flip = flip+1; frame = frame+1;
    end
    
    if flip > (360/phaseStep)
        flip = 1;
    end
    
    if ~probe
        textureIdx = curTargMov(flip);
        Screen('DrawTexture', w, textureIdx,[],curTargBox);
    else
        textureIdx = t1Mov(flip);
        Screen('DrawTexture', w, textureIdx,[],t1Rect);
        
        textureIdx = t2Mov(flip);
        Screen('DrawTexture', w, textureIdx,[],t2Rect);
    end
    
    Screen(w,'FillRect',fixcolor,fixRect); % to keep fix on screen
    lasttime = Screen('Flip',w,[],1);
    
    % Increment flip & save presentation times
    allTimes = [allTimes; frame lasttime];
    frame = frame+1;
    flip = flip+1;

end