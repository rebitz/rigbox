% cvMIB_opentrial
% Initializes a new trial

% Trial timing vars
ITIstart = NaN; % start of ITI
ITIend = NaN;   % end of ITI
fixon = NaN;    % fixation appearance
fixacq = NaN;   % fixation acquired
fixoff = NaN;   % fixation removal
targOn = NaN;  % MIB stimuli appearance
targAcq = NaN;
trialstart = NaN;   % start of the trial
juiceTime = NaN;
rwdDice = NaN;

overlap = NaN; cueon = NaN;
curTargRwd = NaN; curTargOri = NaN;

cueLoc = NaN;

% Error vars
error_made = NaN;   % error flag
errortype = NaN;    % type of error made (1 = brokefix, 2 = nochoice (t), 3 = brokechoice)
brokeFixTime = NaN; % time of broken fixation

% Target vars
correct = NaN;  % flag for correct trial
choice = NaN;   % the target chose (1, 2, or 3)
rewarded = NaN;
dir = 'CW';      % direction of gabor (CW: clockwise, CCW: counter clock wise)

% determine if this is a probe trial
probe = and(rand < p_probe,trialnum>0);

% here, probe means only 1 t on screen
% else, we put up distractors also
if probe
    tOn = zeros(1,3);
else
    tOn = ones(1,3);
end

% iti times
iti = itimin + ((itimax - itimin) .* rand(1,1));

% fix hold times
fixHoldTime = fixHoldMin + ((fixHoldMax-fixHoldMin) .* rand(1,1));

% cue latency times
cueLatency = cueLatencyMin + ((cueLatencyMax-cueLatencyMin) .* rand(1,1));

% overlap times
% overlap = overlapMin + ((overlapMax-overlapMin) .* rand);

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

% Increment rewards
if rwds.counter == 0; rwds.counter = 1; end
t1Rwd = rwds.t1Rwd(rwds.counter); 
t2Rwd = rwds.t2Rwd(rwds.counter);
t3Rwd = rwds.t3Rwd(rwds.counter);

% assign dir of movement
if rand < .5;
    dir1 = 'CCW';
    t1Mov = flipud(t1Mov);
else
    dir1 = 'CW';
end

if rand < .5;
    dir2 = 'CCW';
    t2Mov = flipud(t2Mov);
else
    dir2 = 'CW';
end

if rand < .5;
    dir3 = 'CCW';
    t3Mov = flipud(t3Mov);
else
    dir3 = 'CW';
end

% assign cue locations
if rwds.choices(rwds.counter) == 1
    cueLoc = cueBox1;
elseif rwds.choices(rwds.counter) == 2
    cueLoc = cueBox2;
elseif rwds.choices(rwds.counter) == 3
    cueLoc = cueBox3;
end       

% do the probe thing:
if probe
    tOn(rwds.choices(rwds.counter)) = 1;
end

% Display boxes in Eyelink
if EYEBALL
    
    Eyelink('command', 'clear_screen %d', 0);
    Eyelink('command', 'draw_cross %d %d 15', env.screenWidth/2, env.screenHeight/2);
    Eyelink('command', 'draw_box %d %d %d %d 15', round(fixRect(1)), round(fixRect(2)), round(fixRect(3)), round(fixRect(4)));
    
    Eyelink('command', 'draw_box %d %d %d %d 15',...
        round(t1Rect(1)), round(t1Rect(2)), round(t1Rect(3)), round(t1Rect(4)));
    Eyelink('command', 'draw_box %d %d %d %d 15',...
        round(t2Rect(1)), round(t2Rect(2)), round(t2Rect(3)), round(t2Rect(4)));
    Eyelink('command', 'draw_box %d %d %d %d 15',...
        round(t3Rect(1)), round(t3Rect(2)), round(t3Rect(3)), round(t3Rect(4)));

end

disp(num2str(trialnum))

