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
    trialstart = markEvent('trialStart');
    
    sampleEye;  % (does nothing if EYEBALL)
    
    % Fixation onset
    Screen(w,'FillRect',fixcolor,fixRect);
    fixon = Screen(w,'Flip');
    
    sampleEye;
    
    % Wait for fixation

    fixed = 0;
    while (GetSecs - fixon) < time2fix && ~fixed
        fixed = checkFix(origin, fix_err, space);
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
    
    if ~error_made % Display target, initial flash
        
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
        
        % then targ offset
        Screen(w,'FillRect',fixcolor,fixRect);
        targoff = Screen(w,'Flip');
        
    end
    
    if ~error_made % Continue with overlap period
        
        % Targ gap period
        while ((GetSecs - targoff) < targGap) && fixed
            
            fixed = checkFix(origin, fix_err, space);
            
            if ~fixed
                error_made = 1;
                errortype = 3; % broken fixation during gap
            end
            
        end
        
        % then GO CUE
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
            
            error_made = 1; % see if he's still fixing
            fixed = checkFix(origin, fix_err, space);
            
            if fixed
                errortype = 4;  % Didn't move eyes
            else
                errortype = 5;  % Didn't choose targ
            end
            
        end
        
    end
    
    if ~error_made % Hold fixation of chosen targ
        
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
        
        % Remove targs from the screen
        
    end
    
    % Some type of error in the trial
    if error_made
        
        Screen(w,'FillRect',errorColor,errorRect);
        errorFeedback = Screen(w,'Flip');
        
        while ((GetSecs - errorFeedback) < errorSecs)
            sampleEye;
            esc_check;
        end
        
        correct = 0;
        trialstop = GetSecs();

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
%         giveJuice;
        correct = 1;
        
    end
    
    trialstop = markEvent('trialStop');
    
catch
    
    %sca
    fprintf('ERROR')
    q = lasterror;
    
    rethrow(lasterror);
    
    correct = 0;
    
end