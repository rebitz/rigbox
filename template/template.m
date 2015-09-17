% template.m
%
%   Input:
%       filename - name of files to be saved as data output
%       mode - 'EYE' or 'TEST'

% TO DO:
% 1. add catch trials -> change occurs in other stim on 20% of changes?
%   - goal is to show that they're using the template as an attn'l cue
%   - accuracy fall-off w/ distance between template and stim may also help

function template(filename,mode)

try
    ListenChar(2);
    
    template_params;    % Load the parameters
    openTask; % general rig specific
    template_opentask;  % Open the task
    
    % Run the task
    while trialnum < ntrials && continue_running
                
        template_opentrial; % Initialize a new trial
        
        template_runtrial;  % Run the trial
        
        template_closetrial;    % Close the trial
        
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