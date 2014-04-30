% generalized task closing for all tasks

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

% Clear and back to command line
sca;
commandwindow;