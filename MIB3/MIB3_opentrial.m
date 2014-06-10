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

overlap = NaN;
curTargRwd = NaN; curTargOri = NaN;

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
probe = 0;%and(rand < p_probe,trialnum>0);
% initialize probe vars
dir1 = NaN; dir2 = NaN;  dir3 = NaN;

% iti times
iti = itimin + ((itimax - itimin) .* rand(1,1));

% fix hold times
fixHoldTime = fixHoldMin + ((fixHoldMax-fixHoldMin) .* rand(1,1));

% overlap times
overlap = overlapMin + ((overlapMax-overlapMin) .* rand);

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

% Display boxes in Eyelink
if EYEBALL
    
    Eyelink('command', 'clear_screen %d', 0);
    Eyelink('command', 'draw_cross %d %d 15', env.screenWidth/2, env.screenHeight/2);
    Eyelink('command', 'draw_box %d %d %d %d 15', round(fixRect(1)), round(fixRect(2)), round(fixRect(3)), round(fixRect(4)));
    
%     % Only show the target box of the forced targ if it's a forced trial
%     if ~forced
%         Eyelink('command', 'draw_box %d %d %d %d 15', round(gRect1(1)), round(gRect1(2)), round(gRect1(3)), round(gRect1(4)));
%         Eyelink('command', 'draw_box %d %d %d %d 15', round(gRect2(1)), round(gRect2(2)), round(gRect2(3)), round(gRect2(4)));
%     elseif strcmp(forcedLR, 'L')
%         Eyelink('command', 'draw_box %d %d %d %d 15', round(gRect1(1)), round(gRect1(2)), round(gRect1(3)), round(gRect1(4)));
%     else
%         Eyelink('command', 'draw_box %d %d %d %d 15', round(gRect2(1)), round(gRect2(2)), round(gRect2(3)), round(gRect2(4)));
%     end
    
end

disp(num2str(trialnum))

