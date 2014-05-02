% cvMIB.m
% The human version of the vMIB task. Display two gabor stimuli and the
% subject chooses one of them by saccading to the left or right.
%
%   Input:
%       filename - name of files to be saved as data output
%       mode - 'EYE' or 'TEST'

function [task_data, trial_data] = cBandit(filename, mode)

try,
    
    cBandit_params;    % Load the parameters
    openTask; % general function
    
    cBandit_opentask;  % Open the task
    
    % Run the task
    while trialnum < ntrials && continue_running
                
        cBandit_opentrial; % Initialize a new trial
        if ~probe
            cBandit_runtrial;  % Run the trial
        else % if 2 choice
            cBandit_probetrial;
        end
        cBandit_closetrial;    % Close the trial
        
    end
    
    closeTask; % general but rig specific function             
    
catch
    
    sca;
    commandwindow;
    rethrow(lasterror);
    q = lasterror
    ListenChar(0);
    
end