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
targacq = NaN;
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
if trialnum == 0 && exist('seedSeed')~=1
    rwdSeed = colorOrientations(randi(nColors));%colorOrientations(1) + range(colorOrientations).*rand;
    trSince = 0;
elseif trialnum == 0 &&  exist('seedSeed')==1
    rwdSeed = seedSeed;
    trSince = 0;
elseif (switchTrial && nanmean(rwdBuffer)>=rwdsRequired && ~isnan(rwdBuffer(end)) && nanmean(~isnan(rwdBuffer)) > .65 && trSince > trSinceMin)
    disp('SWITCH TRIAL!')
    disp('rewards are a-changing')
    
    if exist('nextSeed')==1
        rwdSeed = nextSeed;
        clear nextSeed;
    else        
        % make sure we take a big jump
        oldSeed = rwdSeed; angDist = 0;
        
        while angDist < minJump % require it to be above some minimum
            rwdSeed = colorOrientations(randi(nColors));%colorOrientations(1) + range(colorOrientations).*rand;
            angDist = abs(mod((rwdSeed-oldSeed) + 360/2, 360) - 360/2);
        end
    end
    
    trSince = 0;
else
    trSince = trSince + 1;
end

% Timing for this trial:
iti = itimin + ((itimax - itimin) .* rand(1,1));
fixHold = fixHoldMin + ((fixHoldMax - fixHoldMin) .* rand(1,1));
cueOn = cueOnMin + ((cueOnMax - cueOnMin) .* rand(1,1));
cueGap = cueGapMin + ((cueGapMax - cueGapMin) .* rand(1,1));

if cueing
    % choose number of cues on this trial:
    trialNCues = nCues(randi(length(nCues),1,1));
    
    % adjust fixation duration accordingly:
    fixHold = fixHold-(cueOn+cueGap)*trialNCues;
    
    cueIds = randi(size(cueOpts,1),trialNCues,1);
    cueColors = cueOpts(cueIds,:);
    
    cueOnTs = NaN(trialNCues,1);
    cueOffTs = NaN(trialNCues,1);
else
    cueOnTs = NaN;
    cueOffTs = NaN;
end
    
% Performance/Error vars
error_made = NaN;   % error flag
errortype = NaN;    % type of error made (1 = brokefix, 2 = nochoice (t), 3 = brokechoice)
brokeFixTime = NaN; % time of broken fixation
correct = NaN;  % flag for correct trial

% Target generation:

% set up forced choice trials
forced = rand < pForced;

if ~forced
    localNTargs = nTargs;
    
    % what colors will our targets have on this trial?
    % targIndx = randi(nColors,nTargs,1); % w/ replacement, but we want without:
    targIndx = Shuffle(1:nColors); targIndx = targIndx(1:nTargs);

    % where will these targets be placed in space?
    targSlots = convertProb(nTargs/nLocs,nLocs)';
else
    localNTargs = 1;
    
    if ~forceBest
        targIndx = Shuffle(1:nColors); targIndx = targIndx(1);
    else
        [~,targIndx] = min(abs(mod((rwdSeed-colorOrientations) + 360/2, 360) - 360/2));
    end
    targSlots = convertProb(1/nLocs,nLocs)'; % one location to check and display
end

theseColors = colorSeeds(targIndx,:);
theseOrientations = colorOrientations(targIndx);

% get the thetas of our selected targets
tmp = targSlots.*thetas;
theseThetas = tmp(tmp~=0);

% make the boxes for them to live in
[t1x, t1y] = pol2cart(theseThetas,repmat(tOffsets,1,nTargs));
targOrigin = [t1x',t1y']+repmat(origin,nTargs,1);

targRect = [targOrigin targOrigin] + repmat([-targSize -targSize targSize targSize],nTargs,1);

% now the probability for choosing each target
% radSeed = (rwdSeed/(range(orientationBounds)/2))*pi;
% radOrientations = (theseOrientations/(range(orientationBounds)/2))*pi;
angDist = abs(mod((rwdSeed-theseOrientations) + 360/2, 360) - 360/2);
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