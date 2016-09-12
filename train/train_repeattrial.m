% posner_opentrial
% Initializes a new trial

% Trial timing vars
ITIstart = NaN; % start of ITI
ITIend = NaN;   % end of ITI
fixon = NaN;    % fixation appearance
fixacq = NaN;   % fixation acquired
fixoff = NaN;   % fixation removal
targon = NaN;  % stimuli appearance
targoff = NaN; % stimuli off
goCue = NaN;
targAcq = NaN;  % target acquisition
trialstart = NaN;   % start of the trial
juiceTime = NaN;
tAcquired = NaN;

alltimes = [];

% Timing for this trial:
iti = itimin + ((itimax - itimin) .* rand(1,1));
fixHold = fixHoldMin + ((fixHoldMax - fixHoldMin) .* rand(1,1));
targOverlap = targOverlapMin + ((targOverlapMax - targOverlapMin) .* rand(1,1));
targGap = targGapMin + ((targGapMax - targGapMin) .* rand(1,1));

% Error vars
error_made = NaN;   % error flag
errortype = NaN;    % type of error made (1 = brokefix, 2 = nochoice (t), 3 = brokechoice)
brokeFixTime = NaN; % time of broken fixation
correct = NaN;  % flag for correct trial

% just comment out all target related shuffling

% % Target vars
% tmp = Shuffle([1:length(thetas)]);
% targTh = thetas(tmp(1));
% targIdx = tmp(1);
% 
% tmp = Shuffle([1:length(tOffsets)]);
% targR = tOffsets(tmp(1));

% [t1x, t1y] = pol2cart(deg2rad(targTh),deg2px(targR, env));
% targOrigin = [t1x,t1y]+origin;
% targRect = [targOrigin-targSize targOrigin+targSize];

% % jackpot trial?
% jackpotTrial = rand < pJackpot;
% if jackpotTrial && rotateForJackpot
%     rotTexture = rotateBy;
% else
%     rotTexture = 0;
% end
% 
% % choice trial? (superceeds last)
% choiceTrial = rand < pChoice;
% if choiceTrial
%     [t1x, t1y] = pol2cart(deg2rad(altTargTheta),deg2px(targR, env));
%     altTargOrigin = [t1x,t1y]+origin;
%     altTargRect = [altTargOrigin-targSize altTargOrigin+targSize];
%     rotTexture = rotateBy; % rotate the main target
% elseif ~choiceTrial && forceLoc
%     [t1x, t1y] = pol2cart(deg2rad(targTh),deg2px(targR, env));
%     targOrigin = [t1x,t1y]+origin;
%     targRect = [targOrigin-targSize targOrigin+targSize];
% end

% Increment trialnum
trialnum = trialnum + 1;
disp(num2str(trialnum))

% Initialize sample data
global samples
sample_size = 0;

if EYEBALL
    while ~sample_size
        sample_size = size(Eyelink('GetQueuedData'), 1);
    end
end

samples = NaN(sample_size,1);

% Display boxes in Eyelink
if EYEBALL
    
    Eyelink('command', 'clear_screen %d', 0);
    Eyelink('command', 'draw_cross %d %d 15', env.screenWidth/2, env.screenHeight/2);
    Eyelink('command', 'draw_box %d %d %d %d 15', round(fixRect(1)), round(fixRect(2)), round(fixRect(3)), round(fixRect(4)));    
    Eyelink('command', 'draw_box %d %d %d %d 15',...
        round(origin(1)-fix_err), round(origin(2)-fix_err), round(origin(1)+fix_err), round(origin(2)+fix_err));    

    Eyelink('command', 'draw_box %d %d %d %d 15',...
        round(targRect(1)), round(targRect(2)), round(targRect(3)), round(targRect(4)));
    Eyelink('command', 'draw_box %d %d %d %d 15',...
        round(targOrigin(1)-targ_err), round(targOrigin(2)-targ_err), round(targOrigin(1)+targ_err), round(targOrigin(2)+targ_err));    

    if choiceTrial
        Eyelink('command', 'draw_box %d %d %d %d 15',...
            round(altTargOrigin(1)-targ_err), round(altTargOrigin(2)-targ_err), round(altTargOrigin(1)+targ_err), round(altTargOrigin(2)+targ_err));    
    end
end