% closeDIO

% delete and clear the session object
daqreset; % legacy, but hasn't been replaced
clear('dio');

clear('eventNames','nports','eventNames','digOut','flags','devices')

