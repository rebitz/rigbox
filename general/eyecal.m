function eyecal(nCalPts)

% Default to 5-point calibration:
if nargin<1
    nCalPts = 5;
end

setupDIO;
defaultEnv;
global env const
env.allDIOclosed = flags;
env.nports = nports;
env.digOut = digOut;

% Define some basic constants:
const.monkeyScreen = env.screenNumber;
const.interTrial = 1; % In seconds
stimOnTime = 60000; % very long is the point
const.bgColor = [127 127 127];
const.targColor = [255 255 255];

Screen('CloseAll'); % Screen clear
Screen('Preference','VisualDebugLevel', 0);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'SkipSyncTests',1);

% Connect to Eyelink
if ~Eyelink('IsConnected')
    Eyelink('Initialize');
end

% Set up the canvas:
[w, screenRect] = Screen('OpenWindow', ...
    const.monkeyScreen, const.bgColor, [], 32);
const.w = w;
const.screenRect = screenRect;
HideCursor;
blankScreen = Screen('OpenOffscreenWindow', ...
    const.monkeyScreen, const.bgColor, [], 32);
const.blankScreen = blankScreen;
const.screenCenter = ...
    round([mean(screenRect([1 3])) mean(screenRect([2 4]))]);

startEyelinkCal(screenRect, nCalPts);

% Set up keys and functions to handle keypresses during the calibration
% task:
KbName('UnifyKeyNames');
% fixCode = KbName('space');
% toggleCode = KbName('downarrow');
% endCode = KbName('escape');
keyHandlers(1).key = 'ESCAPE'; % Terminate the task
keyHandlers(1).func = @escapeHandler;
keyHandlers(1).wake = true;
keyHandlers(2).key = 'j'; % Immediate juice reward
keyHandlers(2).func = @giveJuice; %{@juicej, .05};
keyHandlers(3).key = 'space';
keyHandlers(3).func = @acceptFixation;
keyHandlers(3).wake = true;
keyHandlers(4).key = 't'; % for flicker calibration; use your
keyHandlers(4).func = @toggleStim; % own stimulus display function

% Define fixation spot parameters:
fixShape  = [-6 -8; ...
             6  8];
fixShape2 = [-5 -7; ...
             5  7];
targShape = [-8 -8; ...
             8  8];
fixRect = shiftPoints(fixShape, const.screenCenter)';
fixRect = fixRect(:)';
fixRect2 = shiftPoints(fixShape2, const.screenCenter)';
fixRect2 = fixRect2(:)';

% %Initalize juice delivery system

% Sync with the screen(?)
Screen('CopyWindow',blankScreen,w,screenRect,screenRect);
Screen('Flip',w);

sharedWorkspace EYECAL -clear
sharedWorkspace('EYECAL', 'keepGoing', true);
sharedWorkspace('EYECAL', 'stimOn', false);
trialNum = 0;

% give a second with the screen up before the first target
sleepWithKbCheck(const.interTrial,keyHandlers);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%  BEGIN SESSION  %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%while continueRunning
while sharedWorkspace('EYECAL','keepGoing')
    % Clear the screen:
    Screen('CopyWindow', blankScreen, w, screenRect, screenRect);
    Screen('Flip', w);
    
    trialNum = trialNum+1;
    % Determine where Eyelink expects the target to appear:
    [result, targX, targY] = Eyelink('TargetCheck');
    targRect = shiftPoints(targShape, [targX targY])';
    targRect = targRect(:)'; const.targRect = targRect;
   
    % draw target spot:
    Screen('FillRect', w, const.targColor, targRect);
    Screen('Flip', w);
    sharedWorkspace('EYECAL', 'stimOn', true);
    fprintf(strcat('\n targ',num2str(trialNum),'on'))

    % check to see if we've completed the task
    if ~sharedWorkspace('EYECAL','keepGoing');
        break;
    else
        sleepWithKbCheck(stimOnTime,keyHandlers);
    end
       
    % Clear the screen:
    Screen('CopyWindow', blankScreen, w, screenRect, screenRect);
    Screen('Flip', w);
    % Wait the intertrial interval:
    sleepWithKbCheck(const.interTrial,keyHandlers);
    if ~sharedWorkspace('EYECAL','keepGoing');
        break;
    end
    
%     doneMessage = Eyelink('Command','cal_done_beep')
%     m = Eyelink('Command','eyelink_cal_message')
%     [r, messageString] = Eyelink('CalMessage')

end
% Clean up
Screen('Closeall');
Eyelink('Shutdown');
closeDIO;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% HELPER FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function startEyelinkCal(winSize, nCalPts)
% Start calibration on Eyelink. winSize is the size of the stimulus window
% being used (ie, the screenRect output from Screen('OpenWindow',...));
% nCalPoints is the number of calibration points to use (should be 3, 5, or
% 9).
Eyelink( 'Command','screen_pixel_coords = %d %d %d %d', winSize(1), winSize(2), winSize(3), winSize(4) );
calType = ['HV' num2str(nCalPts)];
Eyelink('Command', ['calibration_type = ' calType]);
Eyelink('Command','enable_automatic_calibration','NO');
Eyelink('StartSetup');
cont = true;
% Wait until Eyelink actually enters Setup mode (otherwise the
% SendKeyButton command below can happen too quickly and won't actually put
% us in calibration mode):
while cont && Eyelink('CurrentMode')~=2
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('ESCAPE'))
        disp('Aborted while waiting for Eyelink!');
        cont = false;
    end
end
% Magic words: Send the keypress 'c' to select "Calibrate"
Eyelink('SendKeyButton',double('c'),0,10);

function newPoints = shiftPoints(points, shift)
% Points should be N-by-2 for N points, shift should be 1-by-2
%newPoints = bsxfun(@plus,points,shift);
shift = repmat(shift, size(points,1), 1);
newPoints = points + shift;

function escapeHandler
sharedWorkspace('EYECAL','keepGoing',false);

function acceptFixation
% accept trigger code
Eyelink('AcceptTrigger');
% Beep:
sound(sin(1:.4:400));
giveJuice;
% exit the while
runit = 0;

function toggleStim
global const
if sharedWorkspace('EYECAL', 'stimOn');
    Screen('CopyWindow', const.blankScreen, const.w, const.screenRect, const.screenRect);
    Screen('Flip', const.w);
    sharedWorkspace('EYECAL', 'stimOn',false)
    %pause(0.1); % to avoid weird flicker
    fprintf('\n toggle off! \n')
elseif ~sharedWorkspace('EYECAL', 'stimOn');
    Screen('FillRect', const.w, const.targColor, const.targRect);
    Screen('Flip', const.w);
    sharedWorkspace('EYECAL', 'stimOn',true)
    %pause(0.1); % to avoid weird flicker
    fprintf('\n toggle on! \n')
end