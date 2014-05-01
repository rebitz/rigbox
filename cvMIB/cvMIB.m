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

    cvMIB_params;    % Load the parameters
    openTask; % general rig specific
    cvMIB_opentask;  % specific open task func
    
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
    
    closeTask; % general rig specific function
    
    ListenChar(0);               
    
catch
    ListenChar(0);
    sca;
    commandwindow;
    rethrow(lasterror);
    q = lasterror;
    
end