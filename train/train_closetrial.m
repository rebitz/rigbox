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
trials.radius = targR;
trials.targRect = targRect;

trials.correct = correct;
trials.jackpot = jackpotTrial;
trials.choiceTrial = choiceTrial;
trials.juiceTime = juiceTime;

% best choice in choice trials is jackpot == 1

trials.error = error_made;
trials.errortype = errortype;

trials.eyedata = samples;

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
