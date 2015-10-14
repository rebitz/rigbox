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
        Screen(w,'FillRect',fixcolor,fixRect);
        fixon = Screen(w,'Flip');

        sampleEye;

        % Wait for fixation
        fixed = 0;
        while (GetSecs - fixon) < time2fix && ~fixed && ~error_made
            fixed = checkFix(origin, fix_err, space);
            esc_check;
        end

        % If fixation acquired, record time of acquisition
        if fixed && ~error_made
            fixacq = GetSecs;
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
        Screen(w,'FillRect',fixcolor,fixRect);
        Screen(w,'FillRect',targcolor,targRect);
        targon = Screen(w,'Flip');
        
        sampleEye;
        
        % Targ viewing period
        while ((GetSecs - targon) < targOverlap) && fixed
            
            fixed = checkFix(origin, fix_err, space);
            
            if ~fixed
                error_made = 1;
                errortype = 2; % broken fixation during overlap
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
        
        % then GO CUE
        if targOnAfterGo || (~memoryMode && ~overlapMode)
            Screen(w,'FillRect',targcolor,targRect);
        end
        Screen(w,'FillRect',bgcolor,fixRect)
        goCue = Screen(w,'Flip');
        
        % check for target acquisition
        acquired = 0;
        while ((GetSecs - goCue) < time2choose) && ~acquired
            if checkFix(targOrigin, targ_err, space);
                targAcq = GetSecs();
                acquired = 1;
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
        
    end
    
    if ~error_made && targetMode % Hold fixation of chosen targ
        
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
    
    % Remove everything from the screen
    Screen(w,'FillRect',bgcolor)
    Screen(w,'Flip');
        
    %% OUTCOMES!
    
    % Some type of error in the trial
    if error_made
        
        errortype
        if ~isnan(errortype)
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
            
        elseif errortype == 2 % Broken fixation, overlap
            
            % CODE FOR BROKEN FIX, OVERLAP
            
        elseif errortype == 3 % Broken fixation, gap
            
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
        giveJuice;
        correct = 1;
        
        if rand < pJackpot
            for drop = 1:nJackpotDrops
                giveJuice;
            end
        end
        
    end
    
    trialstop = markEvent('trialStop');
    
catch
    
    %sca
    fprintf('ERROR')
    q = lasterror;
    
    rethrow(lasterror);
    
    correct = 0;
    
end