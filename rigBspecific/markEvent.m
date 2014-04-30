function timeStamp = markEvent(event,screenFlip,pulseWidth)
% markEvent sends the DIO command and gets the time stamp of the event
%   specified by input "event"
%
%   [event] can be a string ('targOn') or a integer (1:n ports)
%
% example useage:
%   [targOn] = markEvent('targOn') % open appropriate DIO and get time of target onset
%   [timeStamp] = markEvent(1) % open first 
%

global w

% we don't need a pulseWidth in if it's not specified
if nargin < 3
    pulseWidth = [];
end

if nargin < 2
    screenFlip = 0;
end

% unless we're juicing, then we need a minimum open time
if ~isempty(strfind(event,'juice'))
    pulseWidth = 0.03; % turns out 30ms works pretty well
end

% pull in the globals
global dio env

if isstr(event)
    channel = env.digOut.(event);    
else
    channel = event;
end

% make the appropriate 
tmp = zeros(1,env.nports);
[tmp(channel)] = deal(1);
tmp = tmp + env.allDIOclosed;

% open DIO
dio.outputSingleScan(tmp);

% get timestamp from flip command
if screenFlip
    timeStamp = Screen(w,'Flip');
else
    timeStamp = GetSecs;
end

% keep the DIO open if we need to, i.e. for juice delivery
% CAUTION - NOTHING ELSE CAN HAPPEN HERE!
if ~isempty(pulseWidth)
    while GetSecs() < timeStamp+pulseWidth
    end
end

% close DIO
dio.outputSingleScan(env.allDIOclosed);
