% vMIB_closetrial
% Closes the trial and stores all the trial data

%data(trialnum).taskstart = taskstart;

% Trial-related timestamps
trial_data(trialnum).trial = trialnum;
trial_data(trialnum).trialstart = trialstart;
trial_data(trialnum).ITIstart = ITIstart;
trial_data(trialnum).ITIend = ITIend;

% Fixation-related timestamps
trial_data(trialnum).fixon = fixon;
trial_data(trialnum).fixacq = fixacq;
trial_data(trialnum).fixoff = fixoff;

% Target / choice / reward
trial_data(trialnum).targsOn = targsOn;
trial_data(trialnum).rwdL = t1Rwd;
trial_data(trialnum).rwdR = t2Rwd;
trial_data(trialnum).dirL = dirL;
trial_data(trialnum).dirR = dirR;
trial_data(trialnum).choice = choice;
trial_data(trialnum).correct = correct;
trial_data(trialnum).rewarded = rewarded;
trial_data(trialnum).forced = forced;

trial_data(trialnum).error = error_made;
trial_data(trialnum).errortype = errortype;

trial_data(trialnum).eyedata = samples;

cd(backhome)
save(filename,'trial_data');

% Cleanup screen
Screen(w,'FillRect', env.colorDepth/2);
Screen(w,'Flip');
