% attention_opentrial
% Initializes a new trial

% switch trial?
switchTrial = rand(1,1) < hazard;

% Trial timing vars
trialstart = NaN;   % start of the trial
ITIstart = NaN; % start of ITI
ITIend = NaN;   % end of ITI
fixon = NaN;    % fixation appearance
fixacq = NaN;   % fixation acquired
fixoff = NaN;   % fixation removal
cueonT = NaN;   % cue on time
cueoffT = NaN;   % cue off time
targon = NaN;
targonT = NaN;  % stimuli appearance
goCue = NaN;
targAcq = NaN;  % target acquisition
juiceTime = NaN;
choice = NaN;

% implement the reward tracking buffer
if trialnum == 0
    rwdBuffer = NaN(1,trialsRequired);
else
    rwdBuffer = [rwdBuffer rewarded];
    rwdBuffer = rwdBuffer(2:end);
end

rewarded = NaN;

% PAY ATTN! - this isn't implemented
whichCued = NaN;

% now reseed the probability of reward if necessary
if trialnum == 0
    rwdSeed = orientationBounds(1) + range(orientationBounds).*rand;
    trSince = 0;
elseif (switchTrial && nanmean(rwdBuffer)>=rwdsRequired && trSince > trSinceMin)
    disp('SWITCH TRIAL!')
    disp('rewards are a-changing')
    
    % make sure we take a big jump
    oldSeed = rwdSeed; angDist = 0;
        
    while angDist < minJump % require it to be above some minimum
        rwdSeed = orientationBounds(1) + range(orientationBounds).*rand;
        angDist = abs(mod((rwdSeed-oldSeed) + range(orientationBounds)/2, range(orientationBounds)) - range(orientationBounds)/2);
    end
    rwdSeed
    trSince = 0;
else
    trSince = trSince + 1;
end


% Timing for this trial:
iti = itimin + ((itimax - itimin) .* rand(1,1));
fixHold = fixHoldMin + ((fixHoldMax - fixHoldMin) .* rand(1,1));
cueOn = cueOnMin + ((cueOnMax - cueOnMin) .* rand(1,1));
targGap = targGapMin + ((targGapMax - targGapMin) .* rand(1,1));

% Performance/Error vars
error_made = NaN;   % error flag
errortype = NaN;    % type of error made (1 = brokefix, 2 = nochoice (t), 3 = brokechoice)
brokeFixTime = NaN; % time of broken fixation
correct = NaN;  % flag for correct trial

% Target generation:
% what orientations will our targets have today?
theseOrientations = orientationSeeds(randi(orientationBins,nTargs,1));

% where will these targets be placed in space?
targSlots = convertProb(nTargs/nLocs,nLocs)';

% get the thetas of our selected targets
tmp = targSlots.*thetas;
theseThetas = tmp(tmp~=0);

% now the contrast levels
theseContrasts = trasts(randi(length(trasts),1,nTargs));

% make the targets images
gbIndx = NaN(1,nTargs);
for i = 1:nTargs
    gb(:,:,i) = gabor(vhSize, gCycles, theseOrientations(i), gPhase, gSigma, gMean, theseContrasts(i));
    gb(:,:,i) = gb(:,:,i) .*env.colorDepth;
    gbIndx(i) = Screen('MakeTexture', w, gb(:,:,i));
end

% make the boxes for them to live in
[t1x, t1y] = pol2cart(theseThetas,repmat(tOffsets,1,nTargs));
targOrigin = [t1x',t1y']+repmat(origin,nTargs,1);

targW = size(gb,1)/2;
targH = size(gb,2)/2;

targRect = [targOrigin targOrigin] + repmat([-targW -targH targW targH],nTargs,1);

% now the probability for choosing each target
radSeed = (rwdSeed/(range(orientationBounds)/2))*pi;
radOrientations = (theseOrientations/(range(orientationBounds)/2))*pi;
angDist = abs(mod((radSeed-radOrientations) + pi, pi*2) - pi);
theseRwds = (maxRwd-minRwd)*exp(-((angDist.^2)/(2*rwdStd.^2)))+minRwd;

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
    
end