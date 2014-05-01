function timeStamp = markEvent(event,screenFlip,pulseWidth)
% markEvent sends the DIO command and gets the time stamp of the event
%   specified by input "event" - RIG F VERSION!!!
%
%   [event] can be a string ('targOn') or a integer (1:n ports)
%
% example useage:
%   [targOn] = markEvent('targOn') % open appropriate DIO and get time of target onset
%   [timeStamp] = markEvent(1) % open first 
%

if nargin < 2
    screenFlip = 0; % default to no flippage
end
if nargin < 3
    pulseWidth = NaN;
end

global w

% get timestamp from flip command
if screenFlip
    timeStamp = Screen(w,'Flip');
else
    timeStamp = GetSecs;
end