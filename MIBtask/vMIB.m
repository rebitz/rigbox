% vMIB.m
% The human version of the vMIB task. Display two gabor stimuli and the
% subject chooses one of them by saccading to the left or right.
%
%   Input:
%       filename - name of files to be saved as data output
%       mode - 'EYE' or 'TEST'

function [task_data, trial_data] = vMIB(filename, mode)

try
    
    vMIB_params;    % Load the parameters
    vMIB_opentask;  % Open the task
    
    % Run the task
    while trialnum < ntrials && continue_running
                
        vMIB_opentrial; % Initialize a new trial
        vMIB_runtrial;  % Run the trial
        vMIB_closetrial;    % Close the trial
        
    end
    
    vMIB_closetask;
    
catch
    
    sca;
    commandwindow;
    rethrow(lasterror);
    q = lasterror
    
end