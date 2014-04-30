% cvMIB.m
% The human version of the vMIB task. Display two gabor stimuli and the
% subject chooses one of them by saccading to the left or right.
%
%   Input:
%       filename - name of files to be saved as data output
%       mode - 'EYE' or 'TEST'

function [task_data, trial_data] = cvMIB(filename, mode)

try
    
    ListenChar(2);

    openTask; % general function
    cvMIB2_params;    % Load the parameters
    cvMIB2_opentask;  % Open the task
    
    % Run the task
    while trialnum < ntrials && continue_running
                
        cvMIB_opentrial; % Initialize a new trial
        if ~probe
            cvMIB_runtrial;  % Run the trial
        else
            cvMIB_probetrial;
        end
        cvMIB_closetrial;    % Close the trial
        
    end
    
    closeTask; % general but rig specific function
    
    ListenChar(0);               
    
catch
    
    sca;
    commandwindow;
    rethrow(lasterror);
    q = lasterror
    ListenChar(0);
    
end