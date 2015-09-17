% posner_runtrial.m
% Runs a posner cued target trial based on the parameters specified

try
 
    esc_check;
    
    error_made = 0;
    
    % ITI period starts
    ITIstart = GetSecs;
    
    % ITI (while gathering pupil data / checking for esc)
    while (GetSecs - ITIstart) < iti
        sampleEye;
    end
    
    % ITI period ends
    ITIend = GetSecs;
    
    % Trial starts
    trialstart = GetSecs;
    
    sampleEye;  % (does nothing if EYEBALL)
    
    % Fixation onset
    Screen(w,'FillRect',fixcolor,fixRect);
    
    fixon = Screen(w,'Flip');
    
    sampleEye;
    
    % Wait for fixation
    fixed = 0;
    while (GetSecs - fixon) < time2fix && ~fixed
        fixed = checkFix(origin, fix_err, space);
        esc_check;
    end
    
    % If fixation acquired, record time of acquisition
    if fixed
        fixacq = GetSecs;
    else
        fixacq = 0;
        error_made = 1;
        errortype = 1;  % no fixation
    end
    
    % Hold fixation
    while ((GetSecs - fixacq) < fixHold) && fixed
        fixed = checkFix(origin, fix_err, space);        
        if ~fixed
            error_made = 1;
            errortype = 2;  % broken fixation
        end
    end
    
    sampleEye;
    
    if ~error_made % put up the template
        
        % draw template
        Screen('DrawTexture',w,tempIndx,[],tempRect);
        
        % Fixation on top
        Screen(w,'FillRect',fixcolor,fixRect)
        templateont = Screen(w,'Flip');
        
        sampleEye;
        
        % Targ viewing period
        while ((GetSecs - templateont) < templateOn) && fixed
            
            fixed = checkFix(origin, fix_err, space);
            
            if ~fixed
                error_made = 1;
                errortype = 2; % broken fixation during overlap
            end
            
        end
        
        % then turn off the template
        Screen(w,'FillRect',fixcolor,fixRect)
        templateofft = Screen(w,'Flip');
    end
    
    if ~error_made % gap/memory period
        while ((GetSecs - templateofft) < targGap) && fixed
            fixed = checkFix(origin, fix_err, space);
            
            if ~fixed
                error_made = 1;
                errortype = 3; % broken fixation during overlap
            end
        end
        
    end
    
    
    if ~error_made % then it's time to put the targets on
        
        for i = 1:nTargs
            Screen('DrawTexture',w,gbIndx(i),[],targRect(targLocs(i),:));
        end
        Screen(w,'FillRect',fixcolor,fixRect)
        targon = Screen(w,'Flip');

        masked = 0;
        % time for target to switch
        while ((GetSecs - targon) < targSwitch) && fixed
            fixed = checkFix(origin, fix_err, space);
            if ~fixed
                error_made = 1;
                errortype = 4; % broken fixation during targ on
            end
            
            if ((GetSecs - targon) > maskGap) && masking && ~masked % put up the mask if it's time
                for i = 1:nTargs
                    Screen('DrawTexture',w,mskIndx,[],targRect(targLocs(i),:));
                end
                Screen(w,'FillRect',fixcolor,fixRect)
                maskon = Screen(w,'Flip');
                masked = 1;
            end
        end

    end
    
    if ~error_made % target switch time!
        
        if switchTr
            for i = 1:nTargs
                Screen('DrawTexture',w,gbNewIndx(i),[],targRect(targLocs(i),:));
            end
        else
            for i = 1:nTargs
                Screen('DrawTexture',w,gbIndx(i),[],targRect(targLocs(i),:));
            end
        end
        
        Screen(w,'FillRect',fixcolor,fixRect)
        targon2 = Screen(w,'Flip');
        
        % time for target to switch
        % also, now we check for bar release
        masked = 0;
        while ((GetSecs - targon2) < time2choose) && fixed
            fixed = checkFix(origin, fix_err, space);
            if ~fixed
                release = GetSecs;
            end
            
            if ((GetSecs - targon2) > maskGap) && masking && ~masked % put up the mask if it's time
                for i = 1:nTargs
                    Screen('DrawTexture',w,mskIndx,[],targRect(targLocs(i),:));
                end
                Screen(w,'FillRect',fixcolor,fixRect)
                maskon = Screen(w,'Flip');
                masked = 1;
            end
            
        end
    end
    
    % Remove everything from the screen    
    Screen(w,'FillRect',bgcolor)
    targoff = Screen(w,'Flip');
        
    % if some type of error in the trial
    if error_made

        if errortype == 1 % No fixation
            
            % CODE FOR NO FIX
            
        elseif errortype == 2 % Broken fixation, overlap
            
            % CODE FOR BROKEN FIX, OVERLAP
            
        elseif errortype == 3 % Broken fixation, gap
            
            % CODE FOR BROKEN FIX, GAP
        
        elseif errortype == 4 % Didn't move eyes from fixation
            
            % CODE FOR BROKEN FIX, TARG #1 ON
            
        elseif errortype == 5 % No target selected
            
            % CODE FOR NO TARG CHOSEN
            
        elseif errortype == 6 % Broke target fixation
            
            % CODE FOR BROKE TARG FIX
            
        end
        errortype
        
    else % No errors, correct trial
        
        if ~isnan(release) && switchTr
            % release w/ switch, correct hit
            correct = 1;
            hit = 1;
        elseif ~isnan(release) && ~switchTr
            % release, no switch, false alarm
            correct = 0;
            falseAlarm = 1;
        elseif isnan(release) && switchTr
            % no release, but was a switch
            correct = 0;
            hit = 0;
        elseif isnan(release) && ~switchTr
            % correct rejection 
            correct = 1;
            falseAlarm = 0;
        end
        
        if correct
            juiceTime = markEvent('juice');
            giveJuice;
        else
            sound(env.norwdSound, env.soundSF);
        end
        
        if ~isnan(release) && (queryLoc == 1 || queryDir == 1) % report which target and its direction

            Screen('TextFont',w, 'Arial'); 
            Screen('TextSize',w, 30);

            if queryDir
                instructions = strcat('\n Left or Right? \n');
                pause(0.2); % avoid doubletap

                DrawFormattedText(w,instructions ,'center', 'center');
                Screen('Flip',w);

                waiting = 1;
                while waiting
                    [keyIsDown,secs,keyCode]=KbCheck;
                    if keyIsDown==1 && (keyCode(right) || keyCode(left))
                        if keyCode(right); reportDir = 1;
                        else reportDir = 0; end
                        waiting = 0;
                    end

                end
            end
            
            if queryLoc
%                 instructions = strcat('\n Which target? \n');
%                 DrawFormattedText(w,instructions ,'center', 'center');
%                 Screen('Flip',w);
                pause(0.2); % avoid doubletap

                for i = 1:nTargs % in targ loc space!!! (not target ID!)
                    DrawFormattedText(w,strcat(num2str(i),'?'),targOrigin(i,1), targOrigin(i,2));
                end
                Screen('Flip',w);

                waiting = 1;
                while waiting
                    [keyIsDown,secs,keyCode]=KbCheck;
                    if keyIsDown==1 && (keyCode(onekey) || keyCode(twokey) || keyCode(threekey))
                        if keyCode(onekey); reportTarg = 1;
                        elseif keyCode(twokey); reportTarg = 2;
                        else reportTarg = 3; end
                        waiting = 0;
                    end

                end
            end
            
        end
        
    end
    
    trialstop = GetSecs();
    
catch
    
    %sca
    fprintf('ERROR')
    q = lasterror;
    
    rethrow(lasterror);
    
    correct = 0;
    
end