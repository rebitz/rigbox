% attention_runtrial.m

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
    
    if ~error_made && cueing % put up the cue stuff
        
        % draw cue??
        
        % Fixation on top
        Screen(w,'FillRect',fixcolor,fixRect)
        cueonT = Screen(w,'Flip');
        
        sampleEye;
        
        % Cue viewing period
        while ((GetSecs - cueonT) < cueOn) && fixed
            
            fixed = checkFix(origin, fix_err, space);
            
            if ~fixed
                error_made = 1;
                errortype = 2; % broken fixation during cue
            end
            
        end
        
        % then turn off the cue
        Screen(w,'FillRect',fixcolor,fixRect)
        cueoffT = Screen(w,'Flip');
    end
    
    if ~error_made && cueing % gap/memory period
        while ((GetSecs - cueoffT) < targGap) && fixed
            fixed = checkFix(origin, fix_err, space);
            
            if ~fixed
                error_made = 1;
                errortype = 3; % broken fixation during overlap
            end
        end
        
    end
    
    if ~error_made % then it's time to put the targets on
        
        % first onto eyelink
        if EYEBALL
            for i = 1:nTargs
                Eyelink('command', 'draw_box %d %d %d %d 15', ...
                    round(targRect(i,1)), round(targRect(i,2)), round(targRect(i,3)), round(targRect(i,4)));
            end
        end
        
        % then pbox
        for i = 1:nTargs
            Screen('DrawTexture',w,gbIndx(i),[],targRect(i,:));
        end
        Screen(w,'FillRect',fixcolor,fixRect)
        targon = Screen(w,'Flip');

    end
    
    if ~error_made % time to search for a target selection!
        
        % Fixation offset == go cue
        for i = 1:nTargs
            Screen('DrawTexture',w,gbIndx(i),[],targRect(i,:));
        end
        Screen(w,'FillRect',env.colorDepth/2,fixRect)
        fixoff = Screen(w,'Flip');
        fixStillOn = 0;

        locsToCheck = find(targSlots);
        
        choiceMade = 0;
        while ((GetSecs - fixoff) < time2choose) && choiceMade == 0
            for i = 1:length(locsToCheck)
                if checkFix(targOrigin(i,:), targ_err, targKey(i))
                    choice = i;
                    curTargKey = targKey(i);
                    curTargOri = targOrigin(i,:);
                    targacq = GetSecs;
                    choiceMade = 1;
                end
            end
        end
        
        if ~choiceMade
            error_made = 1;
            if fixed
                errortype = 4;  % Didn't move eyes
            else
                errortype = 5;  % Didn't choose a valid targ
            end
        end
    end
    
    if ~error_made % Hold fixation of chosen targ
        
        targacq = GetSecs;
        
        % Hold fixation of target
        held = 1;
        while ((GetSecs - targacq) < targHoldTime) && held
            
            held = checkFix(curTargOri, targ_err, curTargKey);
            
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
    
    % Remove everything (but the chosen targ?) from the screen
    Screen(w,'FillRect',bgcolor)
    if keepOn && ~error_made
        Screen('DrawTexture',w,gbIndx(choice),[],targRect(choice,:));
    end
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
        
        % Give reward based on rwd contingency and dice roll
        rwdDice = rand;

        if theseRwds(choice) > rwdDice
            rewarded = 1
        else rewarded = 0
        end
        
        if rewarded
            juiceTime = markEvent('juice');
            giveJuice;
        else
            juiceTime = GetSecs();
            sound(env.norwdSound, env.soundSF);
        end
        
    end
    
    while (GetSecs - targoff) < postRewardTime
        sampleEye;
    end
    
    trialstop = GetSecs();
    
catch
    
    %sca
    fprintf('ERROR')
    q = lasterror;
    rethrow(lasterror);
    correct = 0;
    
end