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
tAcquired = NaN;
altTargTheta = NaN;

alltimes = [];

% Timing for this trial:
iti = itimin + ((itimax - itimin) .* rand(1,1));
fixHold = fixHoldMin + ((fixHoldMax - fixHoldMin) .* rand(1,1));
targOverlap = targOverlapMin + ((targOverlapMax - targOverlapMin) .* rand(1,1));
targGap = targGapMin + ((targGapMax - targGapMin) .* rand(1,1));

% Error vars
error_made = NaN;   % error flag
errortype = NaN;    % type of error made (1 = brokefix, 2 = nochoice (t), 3 = brokechoice)
brokeFixTime = NaN; % time of broken fixation
correct = NaN;  % flag for correct trial

% Target vars
if fixationP > 0 && fixationP < 1;
    fixationMode = rand < fixationP;
end

try,
    weights = nanmean([correctionVector;[.1 .1]]);
    weights = weights/sum(weights)
    tmp = datasample(fliplr([1:length(thetas)]),1, 'Weights',weights);
catch
    tmp = Shuffle([1:length(thetas)]);
end

targTh = thetas(tmp(1));
targIdx = tmp(1);

tmp = Shuffle([1:length(tOffsets)]);
targR = tOffsets(tmp(1));

[t1x, t1y] = pol2cart(deg2rad(targTh),deg2px(targR, env));
targOrigin = [t1x,t1y]+origin;
targRect = [targOrigin-targSize targOrigin+targSize];

% jackpot trial?
jackpotTrial = rand < pJackpot;
if jackpotTrial && rotateForJackpot
    rotTexture = rotateBy;
else
    rotTexture = 0;
end

dropsForFixed = round((rand*(max(dropsForFixedSeed)-min(dropsForFixedSeed)))+min(dropsForFixedSeed));

% choice trial? (superceeds last)
pChoice
choiceTrial = rand < pChoice;
if choiceTrial
    if randomizeAlt
        altIdx = true(1,length(thetas)); altIdx(targIdx) = false;
        altTargTheta = targTh; fu = 0;
        while abs(mod((targTh-altTargTheta) + 180, 360) - 180) < 60 && fu < 25;
            fu = fu+1;
            tmpThetas = thetas(altIdx); tmpThetas = Shuffle(tmpThetas);
            altTargTheta = tmpThetas(1); altIdx = find(thetas==tmpThetas(1));
        end
        if fu == 25; altTargTheta = targTh+180; end
    else
        altTargTheta = targTh+180; %altIdx = find(thetas==tmpThetas(1));
    end
    [t1x, t1y] = pol2cart(deg2rad(altTargTheta),deg2px(targR, env));
    altTargOrigin = [t1x,t1y]+origin;
    altTargRect = [altTargOrigin-targSize altTargOrigin+targSize];
    rotTexture = rotateBy; % rotate the main target
elseif ~choiceTrial && forceLoc
    forceTargs = Shuffle(forceTargs);
    targTh = thetas(forceTargs(1));
    
    [t1x, t1y] = pol2cart(deg2rad(targTh),deg2px(targR, env));
    targOrigin = [t1x,t1y]+origin;
    targRect = [targOrigin-targSize targOrigin+targSize];
end

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
    Eyelink('command', 'draw_box %d %d %d %d 15',...
        round(origin(1)-fix_err), round(origin(2)-fix_err), round(origin(1)+fix_err), round(origin(2)+fix_err));    

    Eyelink('command', 'draw_box %d %d %d %d 15',...
        round(targRect(1)), round(targRect(2)), round(targRect(3)), round(targRect(4)));
    Eyelink('command', 'draw_box %d %d %d %d 15',...
        round(targOrigin(1)-targ_err), round(targOrigin(2)-targ_err), round(targOrigin(1)+targ_err), round(targOrigin(2)+targ_err));    

    if choiceTrial
        Eyelink('command', 'draw_box %d %d %d %d 15',...
            round(altTargOrigin(1)-targ_err), round(altTargOrigin(2)-targ_err), round(altTargOrigin(1)+targ_err), round(altTargOrigin(2)+targ_err));    
    end
end