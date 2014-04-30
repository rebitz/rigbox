% cvMIB_closetask
% Closes the task and stores all the task data

% Close the targs
% Screen('Close',t1);
% Screen('Close',t2);
% Screen('Close',t3);

% Clear screen and save edf data
if EYEBALL
    
    Eyelink('command', 'clear_screen %d', 0);
    Eyelink('stoprecording');
    Eyelink('closefile');
    Eyelink('receivefile',edfname,edfname);
    Eyelink('shutdown');
    cmd = sprintf('edf2asc %s',edfname);
    %system(cmd);

end

% close the DIO
closeDIO;

% Clear and back to command line
sca;
commandwindow;
