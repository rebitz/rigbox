function status = drawFixWindow(target, errWin, winColor)
% DRAWFIXWINDOW  Draw a rectangle representing a fixation window on the
% Eyelink fixation monitor
%
% Usage:
%   status = drawFixWindow(target, errWin, winColor)
%
%   target is a two-element vector representing the [x y] screen
%     coordinates of the fixation spot. The [x y] coordinates are in
%     Eyelink screen coordinates, not necessarily display screen
%     coordinates.
%   errWin is the "radius" of the fixation window (ie, the distance from
%     the center to the sides of the square)
%   winColor is the color index to use for the rectangle.  It should be an
%     integer from 0-15. Note that the background is also one of these
%     colors (determined by the parameter to the 'clear_screen' Eyelink
%     command), so if your fixation window doesn't appear, try using a
%     different color.
%
% Suggested application:
% 
% When you are ready to start checking eye position to determine when the
% subject has acquired to the target (ie, before the start of the while
% loop), call the following:
%     Eyelink('Command', 'clear_screen 0');
% (Use a number other than 0 to make the background a different color).
% Then call drawFixWindow for each possible target.
% Once the target has been acquired (ie, after the end of the while loop),
% you may want to call the clear_screen command again, just to tidy up.
%
% GKA March 2009

% Color codes:
% 0: Black
% 1: Dark blue
% 2: Dark green
% 3: Teal
% 4: Dark red
% 5: Magenta
% 6: Dark yellow
% 7: Neutral grey
% 8: Dark grey
% 9: Periwinkle
% 10: Spring green
% 11: Cyan-grey
% 12: Salmon
% 13: Light purple
% 14: Light yellow
% 15: Light grey

boxLeft = target(1)-errWin;
boxRight = target(1)+errWin;
boxTop = target(2)-errWin;
boxBottom = target(2)+errWin;

status = Eyelink('Command', 'draw_filled_box %d %d %d %d %d', ...
    boxLeft, boxTop, boxRight, boxBottom, winColor);
