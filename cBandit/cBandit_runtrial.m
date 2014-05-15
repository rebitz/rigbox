% cvMIB_runtrial.m
% Runs an MIB trial based on the parameters specified

try
    
    esc_check;
    
    allTimes = [];
    error_made = 0;
    
    % Trial starts
    trialstart = markEvent('trialStart');
    
    % ITI period starts
    ITIstart = GetSecs;
    
    % ITI (while gathering pupil data / checking for esc)
    while (GetSecs - ITIstart) < iti
        sampleEye;
    end
    
    % ITI period ends
    ITIend = GetSecs;
    
    sampleEye;  % (does nothing if EYEBALL)
    
    % Fixation onset
    Screen(w,'FillRect',fixcolor,fixRect)
    fixon = markEvent('fixOn',1); % 1 for the flip do
    
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
    
    if ~error_made % Display MIB targ
        
        targOn = GetSecs;
        
        lasttime = targOn; % time of pervious frame for targets
        flip = 1;   % initialize flip (index of frame for phase)
        frame = 0;  % initialize frame
        flip_time = .005; % s per frame (actual min is about 0.1667, but this does it at that minima)
        out = []; % targ output params (to save)
        
        % Move the gabors until choice is made
        choiceMade = 0;
        while ((GetSecs - targOn) < showTime) && ~choiceMade
            
            if fixed % keep fixation on the screen until time
                moveGaborsBandit;
                sampleEye;
                esc_check;
                fixed = checkFix(origin, fix_err, space);
                if ~fixed
                    % Fixation offset
                    Screen(w,'FillRect',env.colorDepth/2,fixRect)
                    fixoff = Screen(w,'Flip');
                end
            elseif checkFix(curTargOri, targ_err, curTargKey);  % Check for fixation on targ
                targAcq = GetSecs;
                choiceMade = 1;
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
            
            held = checkFix(curTargOri, targ_err, curTargKey);
            
            if ~held
                error_made = 1;
                errortype = 5;  % broke targ fixation
            else
                %moveGaborsBandit;
                sampleEye;
                esc_check;
            end
            
        end
        
        % Remove targs from the screen
        
    end
    
    % Some type of error in the trial
    if error_made
        errortype
        
        Screen(w,'FillRect',errorColor,errorRect);
        errorFeedback = Screen(w,'Flip');
        
        while ((GetSecs - errorFeedback) < errorSecs)
            sampleEye;
            esc_check;
        end
        
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
        rwdDice = rand;

        if rwdDice < (curTargRwd/100)
            rewarded = 1;       
        end

        if strcmp(env.rigID,'RigB')
            if rewarded
                juiceTime = markEvent('juice');
                sound(env.rwdSound,env.soundSF);
            else
                sound(env.norwdSound,env.soundSF);
            end
        elseif strcmp(env.rigID,'RigF')
            % feedback on block
            if rewarded
                rewardText = strcat('Win! \n \n',...
                    '+1 points \n \n');
                sound(env.rwdSound,env.soundSF);
                points = 1;
            else
                rewardText = strcat('no win \n \n',...
                    'no points \n \n');
                sound(env.norwdSound,env.soundSF);
                points = 0;
            end

            rewards = rewards+points;
            rewardText1 = strcat(rewardText,'\n');

            Screen('TextFont',w, 'Arial');
            Screen('TextSize',w, 20);

            DrawFormattedText(w,rewardText1 ,'center', 'center')
            Screen('Flip',w);

            startWait = GetSecs();
            while (GetSecs() - startWait) < waitForText;
                sampleEye;
            end

            rewardText2 = strcat(rewardText,num2str(rewards),' total points');

            Screen('TextFont',w, 'Arial');
            Screen('TextSize',w, 20);

            Screen(w,'FillRect',env.colorDepth/2) % clear the target rect
            DrawFormattedText(w,rewardText2 ,'center', 'center')
            Screen('Flip',w);

            startWait = GetSecs();
            while (GetSecs() - startWait) < waitForText;
                sampleEye;
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