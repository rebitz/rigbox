% vMIB_opentrial
% Initializes a new trial

% Trial timing vars
ITIstart = NaN; % start of ITI
ITIend = NaN;   % end of ITI
fixon = NaN;    % fixation appearance
fixacq = NaN;   % fixation acquired
fixoff = NaN;   % fixation removal
targsOn = NaN;  % MIB stimuli appearance
trialstart = NaN;   % start of the trial

% Error vars
error_made = NaN;   % error flag
errortype = NaN;    % type of error made (1 = brokefix, 2 = nochoice (t), 3 = brokechoice)
brokeFixTime = NaN; % time of broken fixation

% Target vars
correct = NaN;  % flag for correct trial
choice = NaN;   % the target chose (L or R)
rewarded = NaN;
dirL = 'U'; % direction of L and R targs (initialized to up)
dirR = 'U';

% Forced vars (if a forced task)
forced = 0;
forcedLR = NaN;
forcedMov = NaN;
forcedDir = NaN;
forcedRwd = NaN;
forcedLoc = NaN;
forcedBox = NaN;
forcedKey = NaN;

% Initialize sample data
global samples
sample_size = 0;

if EYEBALL
    while ~sample_size
        sample_size = size(Eyelink('GetQueuedData'), 1);
    end
end

samples = NaN(sample_size,1);

% Increment trialnum
trialnum = trialnum + 1;

% Determine direction of gabors (.5 chance of up or down)
if rand < .5;
    t1 = flipud(t1);
    if strcmp(dirL, 'U')
        dirL = 'D';
    else
        dirL = 'U';
    end
end
if rand < .5;
    t2 = flipud(t2);
    if strcmp(dirR, 'U')
        dirR = 'D';
    else
        dirR = 'U';
    end
end

% Assign reward contingencies (change only after correct trial)
if trialnum == 1
    
    t1Rwd = T1vals(1);
    t2Rwd = T2vals(1);
    
else
    
    t1Rwd = T1vals(sum([trial_data(:).correct]) + 1);
    t2Rwd = T2vals(sum([trial_data(:).correct]) + 1);
    
end

% Determine if a forced choice trial
if rand < p_forced
    
    forced = 1;
    
    % Randomly assign L or R to be forced
    if rand < .5
        forcedLR = 'L';
        forcedMov = t1;
        forcedDir = dirL;
        forcedRwd = t1Rwd;
        forcedLoc = t1origin;
        forcedBox = gRect1;
        forcedKey = left;
    else
        forcedLR = 'R';
        forcedMov = t2;
        forcedDir = dirR;
        forcedRwd = t2Rwd;
        forcedLoc = t2origin;
        forcedBox = gRect2;
        forcedKey = right;
    end
    
end

% Display boxes in Eyelink
if EYEBALL
    
    Eyelink('command', 'clear_screen %d', 0);
    Eyelink('command', 'draw_cross %d %d 15', env.screenWidth/2, env.screenHeight/2);
    Eyelink('command', 'draw_box %d %d %d %d 15', round(fixRect(1)), round(fixRect(2)), round(fixRect(3)), round(fixRect(4)));
    
    % Only show the target box of the forced targ if it's a forced trial
    if ~forced
        Eyelink('command', 'draw_box %d %d %d %d 15', round(gRect1(1)), round(gRect1(2)), round(gRect1(3)), round(gRect1(4)));
        Eyelink('command', 'draw_box %d %d %d %d 15', round(gRect2(1)), round(gRect2(2)), round(gRect2(3)), round(gRect2(4)));
    elseif strcmp(forcedLR, 'L')
        Eyelink('command', 'draw_box %d %d %d %d 15', round(gRect1(1)), round(gRect1(2)), round(gRect1(3)), round(gRect1(4)));
    else
        Eyelink('command', 'draw_box %d %d %d %d 15', round(gRect2(1)), round(gRect2(2)), round(gRect2(3)), round(gRect2(4)));
    end
    
end 
    