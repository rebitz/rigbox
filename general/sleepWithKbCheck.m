function [wakeT,keys,rets]=sleepWithKbCheck(duration,keyActs,pollTime)
% SLEEPWITHKBCHECK  Wait a while but remain responsive to keypresses
% Usage:
%   [wakeT, keys, rets] = sleepWithKbCheck(duration, keyActs)
%     Sleeps for "duration" seconds while listening for keypresses, as
%     defined by the keyActs struct (see below). Returns wakeT, the actual
%     duration before the function returned, keys, a cell array of all keys
%     pressed before returning, and rets, a cell array of the values
%     returned by the keypress functions (see below).
%   ... = sleepWithKbCheck(..., pollTime)
%     Same as above, but sets the minimum keyboard polling interval, in
%     seconds. Default value is 0.01 s.
% 
% Note that SLEEPWITHKBCHECK does not provide accurate or precise timing.
% In general, MATLAB overhead will cause a total delay of slightly longer
% than "duration" when SLEEPWITHKBCHECK is called, and pollTime specifies
% only the *minimum* time between keypress checks; the actual time may
% increase, particularly when keys have been pressed. Therefore
% SLEEPWITHKBCHECK is inappropriate for use during timing-sensitive periods
% of a realtime script.
% 
% The keyActs struct array:
%  keyActs should be defined as a struct array with the following fields:
%    key: The key to trigger an action
%    wake: True/false, whether to stop sleeping when this key is pressed.
%          If set to [] (e.g., if setting keyActs(2).wake=true without ever
%          setting keyActs(1).wake), behaves as if false.
%    func: The function to call when the key is pressed. This field may be
%          either a function handle or a cell array in which the first
%          element is a function handle and subsequent elements are
%          arguments to the function. Examples:
%            keyActs(1).key = 'a';
%            keyActs(1).func = @myFunction;
%              Evaluates "myFunction" when A is pressed.
%            keyActs(2).key = 'b';
%            keyActs(2).func = {@disp, 'You pressed B!'};
%              Evaluates "disp('You pressed B!')" when B is pressed.
%          Calls no function if set to [].
%    capture: Number of output arguments to capture from the keypress
%             function. These outputs are stored in the "rets" return
%             argument as a cell array of cell arrays, such that rets{a}{b}
%             refers to the b'th output argument of the function called by
%             the a'th keypress. If set to [], behaves as if 0. Attempting
%             to capture more outputs than the keypress function will
%             supply will generate an error.
%   Extended example:
%     keyActs(1).key = 'a';
%     keyActs(2).key = 'b';
%     keyActs(2).wake = true;
%     keyActs(3).key = 'c';
%     keyActs(3).func = {@disp, 'You pressed C!'}
%     keyActs(4).key = 'd';
%     keyActs(4).func = @myFunction;
%     keyActs(4).capture = 3;
%     keyActs(4).wake = true;
%     [wakeT,keys,ret]=sleepWithKbCheck(5,keyActs);
%   The above code will cause MATLAB to sleep for 5 seconds or until B or D
%   are pressed on the keyboard. Pressing A will have no effect except to
%   record that A was pressed in keys. Pressing C will display "You pressed
%   C!" on the MATLAB console. Pressing D will call the function myFunction
%   and capture the first 3 output arguments into rets, before causing
%   SLEEPWITHKBCHECK to terminate.
%
% SLEEPWITHKBCHECK depends on PsychToolbox.

if nargin < 3 || isempty(pollTime)
    pollTime = .01;
end

startT = GetSecs;

[dummy, dummy, prevKeys] = KbCheck;
checkKeys = {keyActs.key};
keys = {};
rets = {};
anyWake = isfield(keyActs,'wake');
anyFunc = isfield(keyActs,'func');
anyCapt = isfield(keyActs,'capture');
if (isempty(duration) || duration==Inf) && ~anyWake
    error('sleepWithKbCheck:noExitStrategy', ...
        ['To prevent an infinite loop, you must provide a sleep ' ...
        'duration or a wake-up key. See HELP SLEEPWITHKBCHECK.']);
end
if ~isempty(duration)
    endT = startT + duration;
else
    endT = Inf;
end

while GetSecs < endT
    WaitSecs(pollTime);
    [dummy, dummy, curKeys] = KbCheck;
    newKeys = curKeys &~ prevKeys;
    prevKeys = curKeys;
    keyNames = KbName(newKeys);
    if ~isempty(keyNames)
        keyIndx = ismember(checkKeys, keyNames);
    else
        keyIndx = [];
    end
    for k = find(keyIndx)
        keys{end+1} = checkKeys{k};
        if anyFunc && ~isempty(keyActs(k).func)
            if anyCapt && ~isempty(keyActs(k).capture) ...
                    && keyActs(k).capture
                rets{end+1} = cell(keyActs(k).capture,1);
                if iscell(keyActs(k).func)
                    [rets{end}{:}] = feval(keyActs(k).func{:});
                else
                    [rets{end}{:}] = feval(keyActs(k).func);
                end
            else
                rets{end+1} = {};
                if iscell(keyActs(k).func)
                    feval(keyActs(k).func{:});
                else
                    feval(keyActs(k).func);
                end
            end
        else
            rets{end+1} = {};
        end
        if anyWake && ~isempty(keyActs(k).wake) && keyActs(k).wake
            wakeT = GetSecs - startT;
            return;
        end
    end
end
wakeT = GetSecs - startT;
