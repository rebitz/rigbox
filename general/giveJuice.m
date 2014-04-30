function giveJuice

% giveJuice
global dio env

juiceChannel = 1;
juiceSecs = 0.5;
pulseWidth = 0.05;

tmp = zeros(1,env.nports);
[tmp(juiceChannel)] = deal(1);
on = tmp + env.allDIOclosed;
off = env.allDIOclosed;

dio.outputSingleScan(on);
% get timestamp
timeStamp = GetSecs();
    while GetSecs() < timeStamp+pulseWidth
    end
    
    % close DIO
dio.outputSingleScan(off);