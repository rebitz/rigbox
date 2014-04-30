% vMIB_closetask
% Closes the task and stores all the task data

% Close the targs
Screen('Close',t1);
Screen('Close',t2);

% Clear screen and save edf data
if EYEBALL
    
    Eyelink('command', 'clear_screen %d', 0);
    Eyelink('stoprecording');
    Eyelink('closefile');
    Eyelink('receivefile',edfname,edfname);
    %EYELINK('shutdown');
    cmd = sprintf('edf2asc %s',edfname);
    %system(cmd);

end

% Clear and back to command line
sca;
commandwindow;

accuracy = nanmean([trial_data.correct]);

task_data.ntrials = ntrials;
task_data.eyeball = EYEBALL;
task_data.testing = TESTING;
task_data.dataDir = dataDirectory;

task_data.time2fix = time2fix;
task_data.fixHoldTime = fixHoldTime;
task_data.fixcolor = fixcolor;
task_data.fixSize = fixSize;
task_data.fix_err = fix_err;

task_data.itimin = itimin;
task_data.itimax = itimax;

task_data.theta = theta;
task_data.tOffset = tOffset;
task_data.maxFrames = maxFrames;
task_data.gSize = gSize;
task_data.phaseStep = phaseStep;

task_data.showTime = showTime;
task_data.targHoldTime = targHoldTime;
task_data.targ_err = targ_err;

task_data.lowRwd = lowRwd;
task_data.highRwd = highRwd;
task_data.stepSize = stepSize;
task_data.stStep = stStep;
task_data.p_forced = p_forced;

task_data.screenNumber = screenNumber;
task_data.env = env;

task_data.accuracy = accuracy;

