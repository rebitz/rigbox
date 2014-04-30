t_lastFrame = GetSecs - lasttime; % how long since last frame?

if t_lastFrame > flip_time % time to put up a new frame
    
    if fixed 
        Screen('FillRect',w,fixcolor,fixRect)
    end
    
    if ~forced
        textureIdx = t1(flip);
        Screen('DrawTexture', w, textureIdx,[],gRect1);
        
        textureIdx = t2(flip);
        Screen('DrawTexture', w, textureIdx,[],gRect2);
    else
        textureIdx = forcedMov(flip);
        Screen('DrawTexture', w, textureIdx,[],forcedBox);
    end
    
    lasttime = Screen('Flip',w,[],1);
    
    % Increment flip
    if flip < (360/phaseStep)
        flip = flip+1;
    else
        flip = 1;
    end
    
    out = [out; frame lasttime];
    frame = frame+1;
    
end