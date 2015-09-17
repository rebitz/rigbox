% posner.m
% The human version of the posner cueing task - display a line that cues
% the location of the target with 80% reliability, followed by the
% presentation of the target at either the cued location or at any of 2
% non-cued positions
%
%   Input:
%       filename - name of files to be saved as data output
%       mode - 'EYE' or 'TEST'

function expressRwd(filename)

try
    ListenChar(2);
    
    expressRwd_params;    % Load the parameters
    openTask; % general rig specific
    expressRwd_opentask;  % Open the task
    
    % Run the task
    while trialnum < ntrials && continue_running
                
        expressRwd_opentrial; % Initialize a new trial
        expressRwd_runtrial;  % Run the trial
        expressRwd_closetrial;    % Close the trial
        
    end
    
    closeTask; % general rig specific function
    expressRwd_closetask; % saves the trial numbers for the next block
    
    ListenChar(0);               
    
catch
    
    sca;
    ListenChar(0);
    closeDIO;
    commandwindow;
    rethrow(lasterror);
    q = lasterror
    
end