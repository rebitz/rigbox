% cvMIB_closetrial
% Closes the trial and stores all the trial data

trial_data = ([]);

% Trial-related timestamps
trial_data.trial = trialnum;
trial_data.trialstart = trialstart;
trial_data.ITIstart = ITIstart;
trial_data.ITIend = ITIend;

% Fixation-related timestamps
trial_data.fixOn = fixon;
trial_data.fixAcq = fixacq;
trial_data.fixOff = fixoff;
trial_data.fixHoldTime = fixHoldTime;
trial_data.overlap = overlap;

% Target / choice / reward
trial_data.targOn = targOn;
trial_data.targAllTimestamps = allTimes; % frame flipTime
trial_data.targAcq = targAcq;
trial_data.juiceTime = juiceTime;

% training trials
trial_data.rwd = curTargRwd;
trial_data.dir = dir;
trial_data.choice = choice;
trial_data.correct = correct;
trial_data.rewarded = rewarded;
trial_data.rwdDice = rwdDice;
trial_data.condition = curTargOri; % actually target position

try
    trial_data.theta = theta(choice);
catch
    trial_data.theta = NaN;
end

% probe trials
trial_data.probe = probe;
trial_data.forced = ~probe;
trial_data.choice = choice;

trial_data.t1Rwd = t1Rwd; % t1
trial_data.dir1 = dir1;
trial_data.targ1origin = t1origin;

trial_data.t2Rwd = t2Rwd; % t1
trial_data.dir2 = dir2;
trial_data.targ2origin = t2origin;

trial_data.t3Rwd = t3Rwd; % t1
trial_data.dir3 = dir3;
trial_data.targ3origin = t3origin;

if probe
    fprintf('\n T1 = %d, T2 = %d, chose %d, rwd = %d \n',...
        t1Rwd,t2Rwd,choice,rewarded);
end

trial_data.error = error_made;
trial_data.errortype = errortype;

trial_data.eyedata = samples;
 
if EYEBALL 
    r = Eyelink('RequestTime');
    if r == 0
        WaitSecs(0.1); %superstition
        beforeTime = GetSecs();
        trackerTime = Eyelink('ReadTime'); % in ms
        afterTime = GetSecs();
        
        pcTime = mean([beforeTime,afterTime]); % in s
        trial_data.pcTime = pcTime;
        trial_data.trackerTime = trackerTime;
        trial_data.trackerOffset = pcTime - (trackerTime./1000);
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
save(strcat(filename, zpad, num2str(trialnum)), 'trial_data');

% save the current trial counter
if correct == 1
    rwds.counter = rwds.counter+1;
    cd .. % go up a step
    save(rwdvar,'rwds');
end

% Cleanup screen
Screen(w,'FillRect', env.colorDepth/2);
Screen(w,'Flip');
