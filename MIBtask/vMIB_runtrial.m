% vMIB_runtrial.m
% Runs an MIB trial based on the parameters specified

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
    Screen(w,'FillRect',fixcolor,fixRect)
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
    while ((GetSecs - fixacq) < fixHoldTime) && ~error_made
        
        fixed = checkFix(origin, fix_err, space);
        
        if ~fixed
            error_made = 1;
            errortype = 2;  % broken fixation
        end
        
    end
    
    sampleEye;
    
    if ~error_made % Display MIB targs
        
        targsOn = GetSecs;  % time of onset of targets
        
        lasttime = targsOn; % time of pervious frame for targets
        flip = 1;   % initialize flip (index of frame for phase)
        frame = 0;  % initialize frame
        flip_time = .001; % s per frame (actual min is about 0.1667, but this does it at that minima)
        out = []; % targ output params (to save)
        
        % Move the gabors until choice is made
        choiceMade = 0;
        while ((GetSecs - targsOn) < showTime) && ~choiceMade
            
            if fixed
                fixed = checkFix(origin, fix_err, space);
                if ~fixed
                    % Fixation offset
                    Screen(w,'FillRect',env.colorDepth/2,fixRect)
                    fixoff = Screen(w,'Flip');
                end
            end
            
            if ~forced
                
                % Check for fixation on left and right targs
                if checkFix(t1origin, targ_err, left);
                    choice = 'L';
                    chosenObj = t1origin;
                    chosenKey = left;
                    choiceMade = 1;
                elseif checkFix(t2origin, targ_err, right);
                    choice = 'R';
                    chosenObj = t2origin;
                    chosenKey = right;
                    choiceMade = 1;
                end
                
            else
                
                if checkFix(forcedLoc, targ_err, forcedKey);
                    choice = forcedLR;
                    chosenObj = forcedLoc;
                    chosenKey = forcedKey;
                    choiceMade = 1;
                end
                
            end
            
            % No choice made, keep moving gabors
            if ~choiceMade
                moveGabors;
                sampleEye;
                esc_check;
            end
            
        end
        
        if ~choiceMade
            
            error_made = 1;
            
            if fixed
                errortype = 3;  % Didn't move eyes
            else
                errortype = 4;  % Didn't choose targ
            end
            
        end
        
    end
    
    if ~error_made % Hold fixation of chosen targ
        
        targacq = GetSecs;
        
        % Hold fixation of target
        held = 1;
        while ((GetSecs - targacq) < targHoldTime) && held
            
            held = checkFix(chosenObj, targ_err, chosenKey);
            
            if ~held
                error_made = 1;
                errortype = 5;  % broke targ fixation
            else
                moveGabors;
                sampleEye;
                esc_check;
            end
            
        end
        
        % Remove targs from the screen
        
    end
    
    % Some type of error in the trial
    if error_made
        
        correct = 0;

        if errortype == 1 % No fixation
            
            % CODE FOR NO FIX
            
        elseif errortype == 2 % Broken fixation
            
            % CODE FOR BROKEN FIX
            
        elseif errortype == 3 % Didn't move eyes from fixation
            
            % CODE FOR NO EYE MOVE TO TARG
            
        elseif errortype == 4 % No target selected
            
            % CODE FOR NO TARG CHOSEN
            
        elseif errortype == 5 % Broke target fixation
            
            % CODE FOR BROKE TARG FIX
            
        end
        
    else % No errors, correct trial
        
        correct = 1;
        
        % Give reward based on rwd contingency
        rewarded = 0;
        if strcmp(choice, 'L') && (rand < (t1Rwd/100))
            
            % juice
            rewarded = 1;
            
        elseif strcmp(choice, 'R') && (rand < (t2Rwd/100))
            
            % juice
            rewarded = 1;
            
        end
        
    end
    
catch
    
    %sca
    fprintf('ERROR')
    q = lasterror;
    
    rethrow(lasterror);
    
    correct = 0;
    
end