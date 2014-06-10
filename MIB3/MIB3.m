% cvMIB.m
% The human version of the vMIB task. Display two gabor stimuli and the
% subject chooses one of them by saccading to the left or right.
%
%   Input:
%       filename - name of files to be saved as data output
%       mode - 'EYE' or 'TEST'

function [task_data, trial_data] = MIB3(filename, mode)

try
    
    ListenChar(2);

    MIB3_params;    % Load the parameters
    openTask; % general rig specific
    MIB3_opentask;  % specific open task func
    
    % Run the task
    while trialnum < ntrials && continue_running
                
        MIB3_opentrial; % Initialize a new trial
        MIB3_runtrial;  % Run the trial
        
        MIB3_closetrial;    % Close the trial
        
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