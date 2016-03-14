% generalized task closing for all tasks

% Clear screen and save edf data
if EYEBALL
    
    Eyelink('command', 'clear_screen %d', 0);
    Eyelink('stoprecording');
    %Eyelink('closefile');
    %Eyelink('receivefile',edfname,edfname);
    Eyelink('shutdown');
    %cmd = sprintf('edf2asc %s',edfname);
    %system(cmd);

end

% keyboard on
ListenChar(0);
ShowCursor();

% close the DIO
closeDIO;

% Clear and back to command line
sca;
commandwindow;

% % clearIPaddress
% ipConfig = 'netsh int ip set address \"Local Area Connection\" dhcp';
% result = system(ipConfig);
% 
% if result == 0
%     disp('ip address sucessfully returned to normal')
% else
%     disp('ERROR: problem with IP address configuration')
% end