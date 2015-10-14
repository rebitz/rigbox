% attention.m
%
%   runs the all things for all people task
%
%   Input:
%       filename - name of files to be saved as data output
%       mode - 'EYE' or 'TEST'

function attention(filename,mode)

try
    ListenChar(2);
    
    attention_params;    % Load the parameters
    openTask; % general rig specific    
    attention_opentask;  % Open the task
    
    % Run the task
    while trialnum < ntrials && continue_running
                
        attention_opentrial; % Initialize a new trial
        
        attention_runtrial;  % Run the trial
        
        attention_closetrial;    % Close the trial
        
    end
    
    closeTask; % general rig specific function
    ListenChar(0);               
    
catch
    
    sca;
    ListenChar(0);
    ShowCursor();
    closeDIO;
    commandwindow;
    rethrow(lasterror);
    q = lasterror
    
end