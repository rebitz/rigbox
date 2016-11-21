% train_closetrial
% Closes the trial and stores all the trial data

trials = ([]);

% Trial-related timestamps
trials.trialNumber = trialnum;
trials.trialStart = trialstart;
trials.trialStop = trialstop;
trials.ITIstart = ITIstart;
trials.ITIend = ITIend;

% Fixation-related timestamps
trials.fixOn = fixon;
trials.fixAcq = fixacq;
trials.fixOff = fixoff;
trials.fixHold = fixHold;

% Target / choice
trials.targOn = targon;
trials.targOff = targoff;
trials.goCue = goCue;
trials.targAcq = targAcq;
if exist('tAcquired') ==1
    trials.whichTarg = tAcquired;
else
    trials.whichTarg = NaN;
end
trials.targOverlap = targOverlap;
trials.targGap = targGap;

trials.theta = targTh;
trials.altTargTheta = altTargTheta;
%trials.altTargOrientation = gOrientation + rotateBy;
trials.radius = targR;
trials.targRect = targRect;
trials.targColor = targcolor;
trials.altTargColor = altTargColor;

trials.correct = correct;
trials.jackpot = jackpotTrial;
trials.choiceTrial = choiceTrial;
trials.juiceTime = juiceTime;

trials.repeatTrial = repeatTrial;

% best choice in choice trials is jackpot == 1

trials.error = error_made;
trials.errortype = errortype;

trials.eyedata = samples;

% thetas
if exist('correctionVector') ~=1
    correctionVector = ones(size(thetas));
end

if correct && jackpotTrial
    correctionVector(thetas==altTargTheta) = correctionVector(thetas==altTargTheta) - 0.05;
elseif correct % missed the jackpot, make that loc more likely
    correctionVector(thetas==altTargTheta) = correctionVector(thetas==altTargTheta) + 0.05;
end

% wrap
correctionVector = min([correctionVector; ones(size(correctionVector))]);
correctionVector = max([correctionVector; zeros(size(correctionVector))]);

correctionVector;
if sum(correctionVector) < 1.5 && pChoice < 1;
    pChoice = pChoice+0.05;
    disp('increased choice prob')
end

if EYEBALL
    r = Eyelink('RequestTime');
    if r == 0
        WaitSecs(0.1); %superstition
        beforeTime = GetSecs();
        trackerTime = Eyelink('ReadTime'); % in ms
        afterTime = GetSecs();
        
        pcTime = mean([beforeTime,afterTime]); % in s
        trials.pcTime = pcTime;
        trials.trackerTime = trackerTime;
        trials.trackerOffset = pcTime - (trackerTime./1000);
        % would make legit time = (eyeTimestamp/1000)+offset
    end
end

zpad = '_';
if trialnum < 10
    zpad = '_000';
elseif trialnum < 100
    zpad =  '_00';
elseif trialnum < 1000
    zpad = '_0';
end

cd(backhome)
save(strcat(filename, zpad, num2str(trialnum)), 'trials');

% Cleanup screen
Screen(w,'FillRect', bgcolor);
Screen(w,'Flip');
