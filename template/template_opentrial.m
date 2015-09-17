% posner_opentrial
% Initializes a new trial

% switch trial?
rand(1,1)<pSwitch;

% Trial timing vars
ITIstart = NaN; % start of ITI
ITIend = NaN;   % end of ITI
fixon = NaN;    % fixation appearance
fixacq = NaN;   % fixation acquired
fixoff = NaN;   % fixation removal
targon = NaN;  % stimuli appearance
targon2 = NaN; % stim change time
targoff = NaN; % stimuli off
release = NaN; % time bar is released
goCue = NaN;
targAcq = NaN;  % target acquisition
trialstart = NaN;   % start of the trial
juiceTime = NaN;
templateont = NaN;
templateofft = NaN;
switchTr = NaN;
reportDir = NaN; reportTarg = NaN;

alltimes = [];

% Timing for this trial:
iti = itimin + ((itimax - itimin) .* rand(1,1));
fixHold = fixHoldMin + ((fixHoldMax - fixHoldMin) .* rand(1,1));
templateOn = templateOnMin + ((templateOnMax - templateOnMin) .* rand(1,1));
targGap = targGapMin + ((targGapMax - targGapMin) .* rand(1,1));
maskGap = maskGapMin + ((maskGapMax - maskGapMin) .* rand(1,1));
targSwitch = targSwitchMin + ((targSwitchMax - targSwitchMin) .* rand(1,1));

% Performance/Error vars
error_made = NaN;   % error flag
errortype = NaN;    % type of error made (1 = brokefix, 2 = nochoice (t), 3 = brokechoice)
brokeFixTime = NaN; % time of broken fixation
correct = NaN;  % flag for correct trial
hit = NaN;
falseAlarm = NaN; % flag for fa

% Target generation - uniform noise
if ~fixedOffsetsFromTemplate
    noise = (rand(1,nTargs).*orientationSigma)-(orientationSigma./2);
else % fixed offset, but random sign
    targSigns = double(rand(1,nTargs)>0.5);
    [targSigns(targSigns==0)] = deal(-1);
    noise = repmat(fixedOffset,1,nTargs).*targSigns;
end
targOrientations = orientationSeeds+noise;

gbIndx = NaN(1,nTargs);
for i = 1:nTargs
    gb(:,:,i) = gabor(vhSize, gCycles, targOrientations(i), gPhase, gSigma, gMean, gAmp).*env.colorDepth;
    gbIndx(i) = Screen('MakeTexture', w, gb(:,:,i));
end

[t1x, t1y] = pol2cart(thetas,repmat(tOffsets,1,nTargs));
targOrigin = [t1x',t1y']+repmat(origin,nTargs,1);

targW = size(gb,1)/2;
targH = size(gb,2)/2;

targRect = [targOrigin targOrigin] + repmat([-targW -targH targW targH],nTargs,1);

% randomly assign targets to locations
targLocs = Shuffle([1:nTargs]);

% template generation
template = Shuffle([1:nTargs]); template = template(1);
gbTemplate = gabor(vhSize, gCycles, orientationSeeds(template), gPhase, gSigma, gMean, gAmp);
gbTemplate = gbTemplate.*env.colorDepth;
tempIndx = Screen('MakeTexture', w, gbTemplate);

templateOrigin = origin;

tempW = size(gbTemplate,1)/2;
tempH = size(gbTemplate,1)/2;

tempRect = [templateOrigin templateOrigin] + [-tempW -tempH tempW tempH];

% target change generation
validTr = rand(1,1)<pValid;
if validTr; chTarg = template;
else
    tgs = [1:nTargs]; tgs = Shuffle(tgs(tgs~=template));
    chTarg = tgs(1);
end

chNoise = zeros(1,nTargs);
chNoise(chTarg) = (rand(1,1).*noiseSigma)-(noiseSigma./2);
newtargOrientations = targOrientations+chNoise;

gbNewIndx = NaN(1,nTargs);
for i = 1:nTargs
    gbNew(:,:,i) = gabor(vhSize, gCycles, newtargOrientations(i), gPhase, gSigma, gMean, gAmp).*env.colorDepth;
    gbNewIndx(i) = Screen('MakeTexture', w, gbNew(:,:,i));
end

% mask generation is done in open task

% and is this a switch trial?
switchTr = rand(1,1)<pSwitch;

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
    
%     Eyelink('command', 'draw_box %d %d %d %d 15', round(actualBox(1)), round(actualBox(2)), round(actualBox(3)), round(actualBox(4)));
    
end