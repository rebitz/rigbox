% MGS_closetask
% Closes the task and stores all the task data

% Clear screen and save edf data
if EYEBALL
    
    Eyelink('command', 'clear_screen %d', 0);
    Eyelink('stoprecording');
    Eyelink('closefile');
    Eyelink('receivefile',edfname,edfname);
    Eyelink('shutdown');
    
    % convert the edf file to an ascii file
    % cmd = sprintf('edf2asc %s',edfname);
    % system(cmd);

end

% close the DIO
closeDIO;

% close the serial port
fclose(port);
delete(port);
delete(instrfindall);

% Clear and back to command line
sca;
commandwindow;

accuracy = nanmean([trial_data.correct]);


