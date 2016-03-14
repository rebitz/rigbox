% attention_closetrial
% Closes the trial and stores all the trial data

trials = ([]);

% Trial-related timestamps
trials.trialNumber = trialnum;
trials.trialSince = trSince; % tr since switch
trials.trialStart = trialstart;
trials.trialStop = trialstop;
trials.ITIstart = ITIstart;
trials.ITIend = ITIend;

% Fixation-related timestamps
trials.fixOn = fixon;
trials.fixAcq = fixacq;
trials.fixOff = fixoff;
trials.fixHold = fixHold;

% cue stuff
trials.cueOnT = cueonT;
trials.cueOffT = cueoffT;
trials.whichCued = whichCued;

% Target timings
trials.targGap = targGap; % time after cue
trials.targOn = targon;
trials.targOff = targoff;
trials.targAcq = targacq;

% target information
trials.theta = theseThetas;
trials.radius = tOffsets;
trials.targRect = targRect;
trials.targOrigins = targOrigin;
trials.targOrientations = theseOrientations;
trials.targContrasts = theseContrasts;
trials.targSlots = targSlots;

% reward information
trials.targRadDistance = angDist; % in radians
trials.targRwds = theseRwds;
trials.switchTrial = switchTrial;
trials.rwdSeed = rwdSeed;

% performance information
trials.correct = correct; % chose a target?
trials.chosenTarg = choice; % which target?

trials.rewarded = rewarded; % given juice?
trials.rwdBuffer = rwdBuffer;
trials.juiceTime = juiceTime;
trials.error = error_made;
trials.errortype = errortype;

% eyedata
trials.eyedata = samples;

pcTime = NaN;

if EYEBALL
    beforeTime = GetSecs();
    r = Eyelink('RequestTime');
    afterTime = GetSecs();
    if r == 0
        WaitSecs(0.1); %superstition
        trackerTime = Eyelink('ReadTime'); % in ms
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

% % sent a trial summary to the command line?
% if trials.releasedLogical
%     if switchTr
%         fprintf('\n Switch trial, released? %d \n',[trials.releasedLogical])
%     end
%     
%     fprintf('\n Reported direction: %d \n',[trials.reportedDir])
%     fprintf('\n Actual direction: %d \n',[trials.changeDir])
% end

% Cleanup screen
Screen(w,'FillRect', env.colorDepth/2);
Screen(w,'Flip');
