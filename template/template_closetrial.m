% posner_closetrial
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
trials.targ1OnTime = targSwitch-maskGap;
trials.targChange = targon2;
trials.targOff = targoff;
trials.releaseT = release;
trials.targAcq = targAcq;
trials.targGap = targGap;
trials.templateOn = templateOn;
trials.templateRect = tempRect;

trials.theta = thetas;
trials.radius = tOffsets;
trials.targRect = targRect;
trials.targOrigins = targOrigin;

% locations targets appear in
trials.targLocations = targLocs;
% - targOrigin(targLocs(1)) is location of first target

trials.validTrial = validTr;
trials.changeTarg = chTarg;
trials.targOrientations = targOrientations;
trials.changedTargOrientations = newtargOrientations;
trials.targSign = targSigns;
trials.targNoise = noise;
trials.changeNoise = chNoise;
trials.changeDir = sum(chNoise)>0; % positive = CW, neg = CCW (I believe)
trials.templateOrientation = orientationSeeds(template);
trials.templateID = template;
trials.templateOnT = templateont;
trials.templateOffT = templateofft;

trials.releasedLogical = ~isnan(release);
trials.switchTrial = switchTr;
trials.correct = correct;
trials.hit = hit;
trials.falseAlarm = falseAlarm;

trials.reportedDir = reportDir; % 1 = R, 0 = Left 
trials.reportedTarg = reportTarg; % actually in location space!!!

trials.juiceTime = juiceTime;

trials.error = error_made;
trials.errortype = errortype;

trials.eyedata = samples;

pcTime = NaN;

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
