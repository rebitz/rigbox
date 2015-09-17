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
    % disp('moving') % to make this more vocal
    tmp = Shuffle([1:length(allTh)]);
    targTh = allTh(tmp(1));
end

tmp = Shuffle([1:length(tOffsets)]);
targR = tOffsets(tmp(1));

% setup the rect for this target
[t1x, t1y] = pol2cart(deg2rad(targTh),deg2px(targR, env));
targOrigin = [t1x,t1y]+origin;
targRect = [targOrigin targOrigin] + [-targSize -targSize targSize targSize];

% now the target identity (color)
whichTarg = randi(length(rwds));

targColor = targColors(whichTarg,:);

% Increment trialnum
trialnum = trialnum + 1;
disp(num2str(trialnum))

% Now a counter since the last change in rwd contingencies
if tnumInBlock < minBlockTrials
    tnumInBlock = tnumInBlock+1;
else
    disp('Reward contingencies are changing!!')
    
    % reset the counter
    tnumInBlock = 0;
    
    % flip the high and low, per Vince // who got it from Morrison & Saltzman
    tmpRwds = rwds;
    tmpRwds(1) = rwds(3); tmpRwds(3) = rwds(1);
    rwds = tmpRwds;
end

rwdP = rwds(whichTarg);

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
    
%     Eyelink('command', 'draw_box %d %d %d %d 15', round(actualBox(1)), round(actualBox(2)), round(actualBox(3)), round(actualBox(4)));
    
end