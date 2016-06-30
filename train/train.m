% train.m
% Let's train our guys how to do things!
%  -- this script does fixations, no-gap O2As, overlap O2As, initial MGS...
%
% Input:
%       subjname - name of subject, selects parameters and sets filename+date
%       mode - 'EYE' for running or 'TEST' for debugging

function train(subjname, mode)

try
    ListenChar(2);
    error_made = false; jackpotTrial = true;
    
    train_params; % general parameters
    eval(strcat(subjname,'_train_params')) % subject specific parameters
    openTask; % open the task more generally, rig specific
    train_opentask; % open the training-task-specific stuff
    
    % Run the task
    while trialnum < ntrials && continue_running
        
        if anyRepeat && ((~error_made && ~jackpotTrial && rand < pRepeat) || error_made)
            train_repeattrial;
            repeatTrial = true;
            disp('repeat called')
        else
            train_opentrial; % Initialize a new trial
            repeatTrial = false;
        end
        train_runtrial;  % Run the trial
        train_closetrial; % Close the trial
        
    end
    
    closeTask; % general rig specific function
    ListenChar(0);
    
catch
    
    sca;
    ListenChar(0);
    closeDIO;
    commandwindow;
    rethrow(lasterror);
    q = lasterror
    
end