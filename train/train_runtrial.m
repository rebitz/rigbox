% train_runtrial.m
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
    trialstart = markEvent('trialStart');
    
    sampleEye;  % (does nothing if EYEBALL)
    
    % Fixation onset block
    if ~error_made && fixationMode
        Screen(w,'FillRect',bgcolor)
        Screen(w,'FillRect',fixcolor,fixRect);
        fixon = Screen(w,'Flip');
        fOn = true;

        sampleEye;

        % Wait for fixation
        fixed = 0; colors = [targcolor; altTargColor];
        big = 10; count = 1; iter = 1;
        while (GetSecs - fixon) < time2fix && ~fixed && ~error_made
            fixed = checkFix(origin, fix_err, space);
            esc_check;
            if toggle && (GetSecs - fixon) > 1;
                if count > 5
                    big = big + 3;
                    count = 1;
                end
                if fOn == true;
                    Screen(w,'FillRect',bgcolor)
                    Screen(w,'FillRect',fixcolor,fixRect);
                    Screen(w,'Flip');
                    fOn = false;
                else
                    if rand < 0.05; iter = 3; end
                    switch iter
                        case 1
                            iter = 2;
                            color = colors(2,:)*255;
                        case 2
                            iter = 1;
                            color = colors(1,:)*255;
                        case 3
                            color = rand(1,3)*255;
                            iter = 1;
                    end

                    Screen(w,'FillRect',bgcolor)
                    Screen(w,'FillRect',color,fixRect+[-big -big big big]);
                    Screen(w,'FillRect',fixcolor,fixRect);
                    %Screen(w,'FillRect',fixcolor,fixRect+[-big -big big big]);
                    Screen(w,'Flip');
                    fOn = true;
                end
                WaitSecs(0.13); count = count+1;
            end
        end

        % If fixation acquired, record time of acquisition
        if fixed && ~error_made
            fixacq = GetSecs;
            Screen(w,'FillRect',bgcolor)
            Screen(w,'FillRect',fixcolor,shrinkFixRect);
            Screen(w,'Flip');
            if juiceForAcq; giveJuice(1); end
            %recenterEye;
        elseif ~error_made
            fixacq = 0;
            error_made = 1;
            errortype = 1;  % no fixation
        end

        % Hold fixation
        while ((GetSecs - fixacq) < fixHold) && fixed && ~error_made
            fixed = checkFix(origin, fix_err, space);        
            if ~fixed
                error_made = 1;
                errortype = 2;  % broken fixation
            end
        end

        sampleEye;
    end
    
    % Display target, initial flash if wer're doing a complicated task
    if ~error_made && targetMode && (overlapMode || memoryMode) && fixationMode
                
        % Cue onset (keep fix point there)
        Screen(w,'FillRect',fixcolor,shrinkFixRect);
        if gaborTarg
            Screen('DrawTexture',w,preGbIndx,[],targRect,rotTexture);
        elseif jackpotTrial
            Screen(w,'FillRect',targcolor,targRect);
        else
            Screen(w,'FillRect',altTargColor,targRect);
        end
        if gaborTarg && choiceTrial
            Screen('DrawTexture',w,preGbIndx,[],altTargRect,0);
        elseif ~gaborTarg && choiceTrial
            Screen(w,'FillRect',targcolor,targRect);
            Screen(w,'FillRect',altTargColor,altTargRect);
        end
        targon = Screen(w,'Flip');
        tOnLogical = true;
        
        sampleEye;
        
        % Targ viewing period
        while ((GetSecs - targon) < targOverlap) && fixed
            
            if tOnLogical && (GetSecs - targon) > preTargTime;
                Screen(w,'FillRect',fixcolor,shrinkFixRect);
                Screen(w,'Flip');
                tOnLogical = false;
            end
                
            fixed = checkFix(origin, fix_err, space);
            
            if ~fixed
                error_made = 1;
                errortype = 3; % broken fixation during overlap
            end
            
        end
        
    end
    
    if ~error_made && targetMode && memoryMode && fixationMode % Continue with memory period
        
        % Remove the target from the screen if it's a memory      
        Screen(w,'FillRect',fixcolor,fixRect);
        targoff = Screen(w,'Flip');
            
        % and hold fix for the memory period
        while ((GetSecs - targoff) < targGap) && fixed
            
            fixed = checkFix(origin, fix_err, space);
            
            if ~fixed
                error_made = 1;
                errortype = 3; % broken fixation during gap
            end
            
        end
    end
    
    if ~error_made && targetMode % time to look for fix on ecc targ
        
        count = 0;
        while juiceForFixed && checkFix(origin, fix_err, space) && count < dropsForFixed
            giveJuice(1)
            count = count+1;
        end
        
        % then GO CUE
        Screen(w,'FillRect',fixcolor,shrinkFixRect);
        if targOnAfterGo || (~memoryMode && ~overlapMode)
            if gaborTarg
                Screen('DrawTexture',w,gbIndx,[],targRect,rotTexture);
            elseif jackpotTrial
                Screen(w,'FillRect',targcolor,targRect);
            else
                Screen(w,'FillRect',altTargColor,targRect);
            end
        end
        if gaborTarg && choiceTrial
            Screen('DrawTexture',w,gbIndx,[],altTargRect,0);
        elseif ~gaborTarg && choiceTrial
            Screen(w,'FillRect',targcolor,targRect);
            Screen(w,'FillRect',altTargColor,altTargRect);
        end
        
        % then remove fix
        Screen(w,'FillRect',bgcolor,fixRect)
        goCue = Screen(w,'Flip');
        
        % let us know when the go cue occurred
        Eyelink('command', 'draw_box %d %d %d %d 15', round(shrinkFixRect(1)), round(shrinkFixRect(2)), round(shrinkFixRect(3)), round(shrinkFixRect(4)));    

        if  saccadeMode && checkFix(origin, fix_err, space)
        % check for target acquisition
            acquired = 0; fixed = 1; specialBonus = 0;
            while ((GetSecs - goCue) < time2choose) && ~acquired
                if fixed
                    fixed = checkSaccade(env.threshForSaccade,env.timeForSaccade);
                    sampleEye;
                    esc_check;
                elseif checkFix(targOrigin, targ_err, space) %&& ~checkFix(origin, fix_err, space)
                    targAcq = GetSecs();
                    if choiceTrial % if it's a choice, reward for picking the best
                        jackpotTrial = 1;
                        % now if this was one of our forced also,
                        if sum(targIdx==forceTargs) > 0
                            specialBonus = 1;
                        end
                    end
                    acquired = 1;
                    tAcquired = 'high';
                elseif choiceTrial && checkFix(altTargOrigin, targ_err, space) %&& ~checkFix(origin, fix_err, space)
                    targAcq = GetSecs;
                    targOrigin = altTargOrigin; % set selected for holding
                    jackpotTrial = 0;
                    %if he goes to an forced alternate to a non-forced targ,
                    %bonus!
                    if rwdBonusForcedTargs && sum(altIdx==forceTargs) > 0 && sum(targIdx==forceTargs) == 0
                        specialBonus = 1;
                    end
                    acquired = 1;
                    tAcquired = 'low';
                else
                    sampleEye;
                    esc_check;
                end
            end

            if ~acquired

                fixed = checkFix(origin, fix_err, space);

                if fixed && ~error_made
                    error_made = 1; % see if he's still fixing
                    errortype = 4;  % Didn't move eyes
                elseif ~error_made
                    error_made = 1; % see if he's still fixing
                    errortype = 5;  % Didn't choose targ
                end

            end
        elseif saccadeMode
           error_made = 1; 
           errortype = 3; % broke fix before go cue
        end
%     elseif ~error_made && ~saccadeMode
%         giveJuice(dropsForFixed);
    end
    
    if ~error_made && targetMode && saccadeMode % Hold fixation of chosen targ
        
        % remove everything but the chosen targ from the screen
        if choiceTrial
            Screen(w,'FillRect',bgcolor)
            
            if jackpotTrial 
                if gaborTarg
                    Screen('DrawTexture',w,gbIndx,[],targRect,rotTexture);
                else
                    Screen(w,'FillRect',targcolor,targRect);
                end
            elseif  ~jackpotTrial
                if gaborTarg
                    Screen('DrawTexture',w,gbIndx,[],altTargRect,0);
                else
                    Screen(w,'FillRect',altTargColor,altTargRect);
                end
            end
            Screen(w,'Flip');
        end
        
        % Hold fixation of target
        held = 1;
        while ((GetSecs - targAcq) < targHoldTime) && held
            
            held = checkFix(targOrigin, targ_err, space);
            
            if ~held
                error_made = 1;
                errortype = 6;  % broke targ fixation
            else
                sampleEye;
                esc_check;
            end
            
        end
        
    end
    
    if rmTargB4Rwd
        % Remove everything from the screen
        Screen(w,'FillRect',bgcolor)
        Screen(w,'Flip');
    end
        
    %% OUTCOMES!
    if (targAcq - goCue) < penalizeShortRTTime
        error_made = 1;
        errortype = 3;
    end
    
    % Some type of error in the trial
    if error_made
        
        errortype
        if ~isnan(errortype) && errortype > 2 %%((errortype > 3 && noErrForFixed) || ~noErrForFixed)
            Screen(w,'FillRect',errorColor,errorRect);
            errorFeedback = Screen(w,'Flip');

            while ((GetSecs - errorFeedback) < errorSecs)
                sampleEye;
                esc_check;
            end
        end

        correct = 0;

        if errortype == 1 % No fixation
            
            % CODE FOR NO FIX
            
        elseif errortype == 2 % Broken fixation, pre targ
            
            % CODE FOR BROKEN FIX, OVERLAP
            
        elseif errortype == 3 % Broken fixation, post targ
            
            % CODE FOR BROKEN FIX, GAP
        
        elseif errortype == 4 % Didn't move eyes from fixation
            
            % CODE FOR NO EYE MOVE TO TARG
            
        elseif errortype == 5 % No target selected
            
            % CODE FOR NO TARG CHOSEN
            
        elseif errortype == 6 % Broke target fixation
            
            % CODE FOR BROKE TARG FIX
            
        end
        
    else % No errors, correct trial
        
        juiceTime = markEvent('juice');
        correct = 1;
                
        if juiceForLow; giveJuice(nDropsJuice); end
        
        if jackpotTrial
            for drop = 1:jackpotMultiple
                giveJuice(nDropsJuice);
            end
        else
            WaitSecs(((env.rwdDuration*nDropsJuice*jackpotMultiple)+(env.rwdDelay*nDropsJuice*jackpotMultiple))./1000);
        end
        
        if rwdBonusForcedTargs %% specialBonus &&
            giveJuice(rwdBonusNJuices);
        end
        
    end
    
    % Remove everything from the screen
    Screen(w,'FillRect',bgcolor)
    Screen(w,'Flip');
    
    trialstop = markEvent('trialStop');
    
catch
    
    %sca
    fprintf('ERROR')
    q = lasterror;
    
    rethrow(lasterror);
    
    correct = 0;
    
end