flags = NaN;
nports = 0;
digOut = NaN;

global ioObj

ioObj = io32;
status = io32(ioObj);
if status ~= 0,
    error('Couldn''t initialize port.');
else
    disp('Juice delivery system initialized.')
end