% to include in a general directory:
% - deg2rad
% - deg2px
% - environment struct
% - esc_check
%
% to do:
% - in gabor -> cycles per 100 px to cycles per degree

%% params

EYEBALL = 0;

screenNumber = 1; % 1 is my other display

% stimuli stuff
maxFrames = 200; % stops when it gets here right now
orientation = 45;
gSize = [200 200];
phaseStep = 5;
showTime = 2;

fixcolor = 255;

% target locations
%
%       270
%   180     0
%       90
%
theta = [260 290]; % degrees - 270 is vertical
tOffset = 8; % degrees

% setup the environment for converting btw degrees and pixels
env = Screen('Resolution',screenNumber);
env.screenNumber = screenNumber;
env.distance = 70; % in cm, monkey from screen
env.physicalWidth = 61; % in cm, width of the visible screen
env.colorDepth = 255;

%% backend params, conversions to useful formats for later

% make movement always tangent to the circle
% orientation should be between 0 and 90 to make sure we know direction
%   NEED RIGHT GABOR.M to make this work -> orientation = orientation+90;
orientations = theta;
orientations(orientations >= 180) = orientations(orientations >= 180)-180
t1orientation = orientations(1);
t2orientation = orientations(2);

% convert stimulus features to appropriate units
theta = deg2rad(theta);
tOffset = deg2px(tOffset,env);

%% open task stuff

Screen('Preference', 'SkipSyncTests', 2 );
[w, rect] = Screen('OpenWindow',env.screenNumber,env.colorDepth/2); % window Idx

origin = [(rect(3)-rect(1))/2 (rect(4)-rect(2))/2];
fixRect = [origin origin]+[-2 -2 2 2];

[t1x,t1y] = pol2cart(theta(1),tOffset);
[t2x,t2y] = pol2cart(theta(2),tOffset);

t1origin = [t1x,t1y]+origin;
t2origin = [t2x,t2y]+origin;

gRect1 = [t1origin-gSize/2 t1origin+gSize/2];
gRect2 = [t2origin-gSize/2 t2origin+gSize/2];

%% open trial stuff

[t1,t2] = deal(NaN(ceil(360/phaseStep),1));

% gabor mx for target 1
phase = 0;

for i = 1:(360/phaseStep);
    phase = phase + phaseStep;
    frame = gabor(gSize, 2, t1orientation, phase, 20, 0.5, 0.5);
    frame = frame .* env.colorDepth;
    t1(i) = Screen('MakeTexture',w,frame);
end

% target 2
phase = 0;
for i = 1:(360/phaseStep);
    phase = phase + phaseStep;
    frame = gabor(gSize, 2, t2orientation, phase, 20, 0.5, 0.5);
    frame = frame .* env.colorDepth;
    t2(i) = Screen('MakeTexture',w,frame);
end


%% run trial



startTime = GetSecs;
lasttime = startTime;
flip = 1; frame = 0;
flip_time = .001; % s per frame (actual min is about 0.1667, but this does it at that minima)
out = [];

keepGoing = 1;

while (GetSecs - startTime) < showTime % moves the gabors endlessly/for showTime
    
    thetime = GetSecs - lasttime; % how long since last frame?
    
    if thetime > flip_time % time to put up a new frame
        
        Screen('FillRect',w,fixcolor,fixRect)
        
        textureIdx = t1(flip);
        Screen('DrawTexture', w, textureIdx,[],gRect1);
        
        textureIdx = t2(flip);
        Screen('DrawTexture', w, textureIdx,[],gRect2);

        lasttime = Screen('Flip',w,[],1);
        
        if flip < (360/phaseStep)
            flip = flip+1;
        else
            flip = 1;
        end
        
        out = [out; frame lasttime];
        frame = frame+1;
    end
    
    % If fixation broken, mark time (to stop movies, remove unselected
    % targ). Checkfix will determine this.
    
    if KbCheck
        break % exit loop upon key press
    end 
end 

Screen('Close',t1);
Screen('Close',t2);
Screen('Close',w); 