% posner_opentrial
% Initializes a new trial

% Trial timing vars
ITIstart = NaN; % start of ITI
ITIend = NaN;   % end of ITI
fixon = NaN;    % fixation appearance
fixacq = NaN;   % fixation acquired
fixoff = NaN;   % fixation removal
targon = NaN;  % stimuli appearance
targoff = NaN; % stimuli off
goCue = NaN;
targAcq = NaN;  % target acquisition
trialstart = NaN;   % start of the trial
juiceTime = NaN;

alltimes = [];

% Timing for this trial:
iti = itimin + ((itimax - itimin) .* rand(1,1));
fixHold = fixHoldMin + ((fixHoldMax - fixHoldMin) .* rand(1,1));
targGap = targGapMin + ((targGapMax - targGapMin) .* rand(1,1));

% Error vars
error_made = NaN;   % error flag
errortype = NaN;    % type of error made (1 = brokefix, 2 = nochoice (t), 3 = brokechoice)
brokeFixTime = NaN; % time of broken fixation
correct = NaN;  % flag for correct trial

% Target vars
if exist('targTh','var')
    allTh = thetas(thetas ~= targTh);
else
    allTh = thetas;
    targTh = thetas(1); % will always start on the same side
end

if rand <= pMove % move target if necessary
    disp('moving')
    tmp = Shuffle([1:length(allTh)]);
    targTh = allTh(tmp(1));
end

tmp = Shuffle([1:length(tOffsets)]);
targR = tOffsets(tmp(1));

% load the chosen stimulus, make the texture
tmp = Shuffle(imageIdx);
imName = imageList{tmp(1)};
back = pwd;
cd(imageDirectory)
img = imread(imName);
cd(back)
imgIndx = Screen('MakeTexture', w, img);

[t1x, t1y] = pol2cart(deg2rad(targTh),deg2px(targR, env));
targOrigin = [t1x,t1y]+origin;

targW = targSize;
targH = size(img,1) .* (targW/size(img,2));

targRect = [targOrigin targOrigin] + [-targW -targH targW targH];

% Increment trialnum
trialnum = trialnum + 1;
disp(num2str(trialnum))

% Initialize sample data
global samples
sample_size = 0;

if EYEBALL
    while ~sample_size
        sample_size = size(Eyelink('GetQueuedData'), 1);
    end
end

samples = NaN(sample_size,1);

% Display boxes in Eyelink
if EYEBALL
    
    Eyelink('command', 'clear_screen %d', 0);
    Eyelink('command', 'draw_cross %d %d 15', env.screenWidth/2, env.screenHeight/2);
    Eyelink('command', 'draw_box %d %d %d %d 15', round(fixRect(1)), round(fixRect(2)), round(fixRect(3)), round(fixRect(4)));
    
    Eyelink('command', 'draw_box %d %d %d %d 15', round(actualBox(1)), round(actualBox(2)), round(actualBox(3)), round(actualBox(4)));
    
end