% EVERYTHING SO FAR:
% folder = {'bun010816','bun010916','bun011016',...
%     'bun011116','bun011216','bun011316','bun011416',...
%     'bun011516','bun011916','bun012016','bun012116',...
%     'bun012216'}

% CUMULATIVE SINCE FIRST CHOICES
% folder = {'bun011116','bun011216','bun011316','bun011416',...
%     'bun011516','bun011916','bun012016','bun012116',...
%     'bun012216','bun012616','bun012716','bun012816',...
%     'bun012916','bun020116','bun020216','bun020316',...
%     'bun020416','bun020516','bun020816','bun021116',...
%     'bun021216','bun021516','bun021616','bun021716',...
%     'bun021816','bun021916','bun022216','bun022416',...
%     'bun030316','bun030416','bun030716','bun030816',...
%     'bun030916','bun031016','bun031116','bun031416',...
%     'bun031516','bun031616','bun031716','bun031816',...
%     'bun032116','bun032216','bun032316'};

% folder = {'bun030316','bun030416','bun030716','bun030816',...
%     'bun030916','bun031016','bun031116','bun031416',...
%     'bun031516','bun031616','bun031716','bun031816',...
%     'bun032116','bun032216','bun032316'}
% 
% % since the bug in the overlap triggering a choice was fixed:
% folder = {'bun031516','bun031616','bun031716','bun031816',...
%     'bun032116','bun032216','bun032316','bun032416',...
%     'bun032516','bun033016','bun033116','bun040116',...
%     'bun040216','bun041916','bun042016','bun042116',...
%     'bun042216','bun042316','bun042516','bun042616',...
%     'bun042816','bun042916','bun050116','bun050216',...
%     'bun050316','bun050416','bun050516','bun050616'}
% saveNew = false;
%saveNew = true;

% from 5/09 to 5/12, started messing w/ task
%       running him on an overlap task
%       got corrects properly coded towards the end of 5/11

% folder = {'bun063016','bun070116','bun070516','bun070616','bun070716',...
%     'bun070816','bun070916','bun071116','bun071216','bun071316',...
%     'bun071416','bun071816','bun071916','bun072016','bun082416',...
%     'bun082516','bun082616','bun082916','bun083016','bun083116'}
% 
% folder = {'bun082416','bun082516','bun082616','bun082916',...
%     'bun083016','bun083116','bun090216','bun090716','bun090816'};

% switched to color in: 'bun070916'
%'beak091416','beak091516','beak091616','beak091916','beak092016',...
%'beak092116','beak092216','beak092816','beak092916','beak100316',...
%'beak100416','beak100516','beak100616'
%
% choices forward (ish):
folder = {'beak101216','beak101316','beak101416','beak102116','beak102716',...
    'beak102816','beak102916','beak103116','beak110116','beak110216',...
    'beak110316','beak110416','beak110716','beak110816','beak110916',...
    'beak111016','beak111116','beak120916','beak121216','beak121316',...
    'beak121416','beak121516'};
%saveNew = false;
%folder = {'beak101216','beak101316','beak101416','beak102116','beak102716'}
saveNew = true;


% JUST TODAY
folder = {'beak121516'}

cd(strcat(gitDir,splitChar,'train',splitChar,'data'));

out = ([]);

for q = 1:length(folder)

cd(folder{q});
folders = dir; % get the names of all the folders

processed = false;
if length(folder) > 1 % check to see if we've saved processed data 
    idx = [folders.isdir] == 0;
    files = {folders(idx).name};
    if ~isempty(strcmp(files,strcat(folder{q},'.mat')));
        processed = true
        load(strcat(folder{q},'.mat'))
    end
end

if ~processed
    % otherwise, process the data
    idx = [folders.isdir] == 1;
    folders = {folders(idx).name};
    folders = folders(3:end);
    list = unique(folders);
    
    data = ([]);

    for block = 1:length(list)
        cd(list{block});

        folders = dir;
        matfiles = ~cellfun(@isempty,strfind({folders.name},'.mat'));
        matfiles = {folders(matfiles).name};

        % grab the task variables
        tmpfiles = matfiles(~cellfun(@isempty,strfind(matfiles,'taskVariables')));
        load(tmpfiles{:});

    % WHAT MODE ARE WE IN?
    % fixationMode = 1;
    % targetMode = 1; % targ on at all?
    %     % this guy supercedes all that come below it
    % overlapMode = 0; % targ on before fix off?
    % targOnAfterGo = 1; % have the target on after fix off go cue?
    %     % combining these two is a simple overlap task
    % memoryMode = 0; % turn targ off at any point before fix off?
    %     % if this is set to 1, then there is an overlap by default

        % grab the trials and load em in
        tmpfiles = matfiles(cellfun(@isempty,strfind(matfiles,'taskVariables')));

        for i = 1:length(tmpfiles)
            load(tmpfiles{i})
            [trials.block] = block;
            [trials.saccadeMode] = targetMode;
            [trials.overlapMode] = overlapMode;
            try,
                if gaborTarg && rotateForJackpot
                    [trials.jackpotOrientation] = gOrientation+rotateBy;
                    [trials.otherOrientation] = gOrientation;
                else
                    [trials.jackpotOrientation] = NaN;
                    [trials.otherOrientation] = gOrientation;
                end
            catch
                [trials.jackpotOrientation] = NaN;
                [trials.otherOrientation] = gOrientation;
            end

            if ~isfield(trials,'releasedLogical'); [trials.releasedLogical] = NaN; end
            if ~isfield(trials,'jackpot'); [trials.jackpot] = NaN; end
            if ~isfield(trials,'choiceTrial'); [trials.choiceTrial] = NaN; end
            if ~isfield(trials,'whichTarg'); [trials.whichTarg] = NaN; end
            if ~isfield(trials,'gaborOrientation'); [trials.gaborOrientation] = NaN; end
            if ~isfield(trials,'jackpotOrientation'); [trials.jackpotOrientation] = NaN; end
            if ~isfield(trials,'otherOrientation'); [trials.otherOrientation] = NaN; end
            if ~isfield(trials,'repeatTrial'); [trials.repeatTrial] = deal(false); end
            if ~isfield(trials,'targColor'); [trials.targColor] = deal(NaN); end
            if ~isfield(trials,'altTargColor'); [trials.altTargColor] = deal(NaN); end

            if ~isfield(trials,'altTargTheta');
                tmp = num2cell([trials.theta]+180);
                [trials.altTargTheta] = deal(tmp{:});
            end
            
            data = [data trials];
        end

        keep out folder list block gitDir splitChar q data saveNew

        cd ..
    end
    
    % if we're doing some summary stuff, go ahead and assume the day is
    % over - save to facilitate later processing
    data = rmfield(data,'eyedata');
    
    if length(folder) > 1 && saveNew
        save(strcat(folder{q}),'data')
    end
end

[data.session] = deal(q);
if ~isfield(data,'whichTarg'); [data.whichTarg] = deal(NaN); end
if ~isfield(data,'altTargTheta');
    tmp = num2cell([data.theta]+180);
    [data.altTargTheta] = deal(tmp{:});
end
if ~isfield(data,'jackpotOrientation'); [data.jackpotOrientation] = deal(NaN); end
if ~isfield(data,'otherOrientation'); [data.otherOrientation] = deal(NaN); end
if ~isfield(data,'repeatTrial'); [data.repeatTrial] = deal(false); end
if ~isfield(data,'targColor'); [data.targColor] = deal(NaN); end
if ~isfield(data,'altTargColor'); [data.altTargColor] = deal(NaN); end

out = [out data];

cd ..

end

% append response time
[out.rt] = deal(NaN); % preseed
idx = [out.saccadeMode]==1; % for the simple saccade trials
tmp = num2cell([out(idx).targAcq] - [out(idx).goCue]);
[out(idx).rt] = deal(tmp{:});%% now some basic analyses:

%%
out = out([out.saccadeMode]==1);

try
    fprintf('\n \n \nFILENAME: %s \n',folder)
end
fprintf('number of trials: %d \n',length(out))
fprintf('   number correct: %d \n',sum([out.correct]));
fprintf('percent correct: %2.1f \n',nanmean([out.correct])*100)
fprintf('   excluding noFix: %2.1f \n',(1-nanmean([out.errortype]>1))*100)
fprintf('   excluding preTarg: %2.1f \n',(1-nanmean([out.errortype]>2))*100)

avgRT = sprintf(' %3.0f ms ',nanmean([out.rt])*1000);
stdRT = sprintf(' %3.0f',nanstd([out.rt])*1000);
 
% initialize our plotting window
figure('Position', [680   341   891  637]);
    
% plot error types
subplot(2,2,1:2);
nErrorTypes = 6;
[m] = deal(NaN(1,nErrorTypes));
for i = 1:nErrorTypes
    m(i) = nanmean([out.errortype] == i);
end
bar([1:nErrorTypes],m)
ylabel('fraction of trials with this errortype')
set(gca,'XTickLabel',...
    {'noFix','brokeFixPre','brokeFixPost',...
    'noSaccade','errantSaccade','brokeTarg'})
title(strcat(folder{:}))
ylim([0 1]) 

% plot broken fix error likelihood against fix time
nbins = 8;
subplot(2,2,3); hold on;
for i = 1%:3
    switch i
        case 1; x = [out.fixHold]; c = 'r';
        case 2; x = [out.goCue]-[out.fixOn]; c = 'k';
        case 3; x = ([out.goCue]-[out.fixOn])-[out.fixHold]; c = 'b';
    end
 %x = [out.rt]; c = 'r';

        y = or([out.errortype]==2,[out.errortype]==3);
        %y = [out.errortype]==3;
         
        xpos = [min(x):range(x)/nbins:max(x)];
        %xpos = [0:.1:1.5];
        
        [~,idx] = histc(x,xpos);
        [m,e] = deal(NaN(1,nbins));
        for i = 1:nbins
            m(i) = nanmean(y(idx==i));
            e(i) = nanstd(y(idx==i))/sqrt(sum(~isnan(y(idx==i)))-1);
        end
        h = errorbar(xpos(1:end-1)+mean(diff(xpos))/2,m,e);
        set(h,'Color',c);
end
ylabel('p(broken fix error)');
xlabel('time');

% rt histogram:
subplot(2,2,4);
xpos = [0:.02:.5];
bar(xpos,hist([out.rt],xpos));
xlim([min(xpos) max(xpos)]);
ylabel('count');
xlabel(strcat('rt: ',avgRT,...
    ' +/-',stdRT));

if length(unique([out.session])) > 1
    figure('Position',[313 558 1201 420]); hold on;
    [nCorrect,nAttempted] = deal(NaN(size(unique([out.session]))));
    for i = 1:length(unique([out.session]))
        folder{i};
        nansum([out.session]==i);
        nAttempted(i) = nansum([out.session]==i);
        nCorrect(i) = nansum([out([out.session]==i).correct]);
    end
    bar(nAttempted,'FaceColor','w'); bar(nCorrect);
    set(gca,'XTick',[1:length(unique([out.session]))],'XTickLabel',folder);
    ylabel('number of correct trials')
    xLim = xlim; line([xLim(1) xLim(2)],[nanmean(nCorrect) nanmean(nCorrect)]);
end

jckRT = nanmean([out([out.jackpot]==1).rt]);
nonRT = nanmean([out([out.jackpot]==0).rt]);
fprintf('avg rt, no jackpot: %2.3f \n',nonRT)
fprintf('        jackpot: %2.3f \n',jckRT)

[h,p] = ttest2([out([out.jackpot]==0).rt],[out([out.jackpot]==1).rt]);
if h; fprintf('        sig diff: p = %2.3f \n',p);
else; fprintf('        n. sig diff: p = %2.3f \n',p); end
% now probability of post target errors
jckErr = nanmean([out([out.jackpot]==1).errortype]>2);
nonErr = nanmean([out([out.jackpot]==0).errortype]>2);
fprintf('avg errors, no jackpot: %2.3f \n',nonErr)
fprintf('        jackpot: %2.3f \n',jckErr)

% if we have more than one session, do a summary of beh across sessions
if length(unique([out.session])) > 1
    beh = 'rt';
    %beh = 'error';
    
    figure(); hold on;
    [m,e] = deal(NaN(2,length(unique([out.session]))));
    for i = 1:length(unique([out.session]))
        idx = [out.session]==i;
        m(1,i) = nanmean([out(and(idx,[out.jackpot] == 0)).(beh)]);
        e(1,i) = nanstd([out(and(idx,[out.jackpot] == 0)).(beh)]);
        m(2,i) = nanmean([out(and(idx,[out.jackpot] == 1)).(beh)]);
        e(2,i) = nanstd([out(and(idx,[out.jackpot] == 1)).(beh)]);
    end
      
    these = {folder{~isnan(m(1,:))}};
    plot(m(:,~isnan(m(1,:))))
    legend(these,'Location','NorthWest')
    
    set(gca,'XTick',[1,2],'XTickLabel',{'low','high'});
    xlabel('reward value');
    xlim([0.5 2.5]);
end

% now for choice trials, if we've got them
if sum([out.choiceTrial]==1)>2
    selex = ([out.choiceTrial]==1);
    pcntCorrectChoice = nanmean([out(selex).correct]);
    fprintf('choice trials, pcnt correct: %2.1f \n',pcntCorrectChoice*100)
    selex = or([out.choiceTrial]~=1,[out.errortype]==1);
    pcntCorrectChoice = nanmean([out(~selex).correct]);
    fprintf('        excluding no fix: %2.1f \n',pcntCorrectChoice*100)
    selex = and([out.correct]==1,[out.choiceTrial]==1);
    pcntCorrectChoice = nanmean([out(selex).jackpot]);
    fprintf('        pcnt chose best: %2.1f \n',pcntCorrectChoice*100)
    fprintf('        n/n choices: %2.0f / %2.0f \n',sum([out(selex).jackpot]),sum(selex))
end

% choice trial accuracy and counts
if length(unique([out.session])) > 1
    figure('Position',[313 558 1201 420]); hold on;
    [nCorrectTrial,nCorrectChoice,nAttempted] = deal(NaN(size(unique([out.session]))));
    for i = 1:length(unique([out.session]))
        folder{i};
        idx = and([out.session]==i,[out.choiceTrial]==1);
        nAttempted(i) = nansum(idx);
        nCorrectTrial(i) = nansum([out(idx).correct]);
        idx = and(idx,[out.correct]==1);
        nCorrectChoice(i) = nansum([out(idx).jackpot]);  
    end
    bar(nAttempted,'FaceColor','w');
    bar(nCorrectTrial); bar(nCorrectChoice,'FaceColor','k');
    set(gca,'XTick',[1:length(unique([out.session]))],'XTickLabel',folder);
    ylabel('number of trials')
    legend('total','correct','best choice','Location','NorthWest')
end

% repeats = nanmean([out(and([out.repeatTrial]==1,[out.correct]==1)).jackpot]);
% norepeats = nanmean([out(and([out.repeatTrial]==0,[out.correct]==1)).jackpot]);
% 
% fprintf('pcnt best choice, not a repeat: %2.1f \n',norepeats*100)
% fprintf('        repeat trials: %2.1f \n',repeats*100)

%% sliding accuracy plot

tmper = 10;

% get chance levels (ish)
% nBoot = 1000; ref = NaN(2,nBoot);
% for i = 1:nBoot
%     tmp = tsmovavg(convertProb(.5,tmper*2)','s',tmper);
%     ref(1,i) = nanmax(tmp);
%     ref(2,i) = nanmin(tmp);
% end
% ci = [quantile(ref(1,:),[.975]), quantile(ref(2,:),[.025])];
% ci = [quantile(ref(1,:),[.95]), quantile(ref(2,:),[.05])];

nBoot = 1000; ref = [];
for i = 1:nBoot
    tmp = tsmovavg(convertProb(.5,tmper*10)','e',tmper);
    ref = [ref tmp(~isnan(tmp))];
end
ci = [quantile(ref,[0.025,.975])];
%ci = [quantile(ref,[0.05,.95])];

idx = find(and([out.correct]==1,[out.choiceTrial]==1));
mTrace = tsmovavg([out(idx).jackpot],'s',tmper);

figure('Position',[313 558 1201 420]); hold all
plot(idx,mTrace);
plot(idx,[out(idx).gaborOrientation]/180);

ylim([0 1]);
xLim = xlim; yLim = ylim;
line([xLim(1) xLim(2)],[.5 .5])
h = line([xLim(1) xLim(2)],[ci(1) ci(1)]);
h(2) = line([xLim(1) xLim(2)],[ci(2) ci(2)]);
set(h,'LineStyle','--');

% find changes in orientation or color
switches = find(abs(diff([out.jackpotOrientation]))>1);
switches = [switches find(abs(diff([out.otherOrientation]))>1)];
tmp = vertcat(out.targColor);
switches = [switches find(abs(diff(tmp(:,1)))>1)];
tmp = vertcat(out.altTargColor);
switches = [switches; find(abs(diff(tmp(:,1)))>1)];
switches = unique(switches);
try, clear h;
for i = 1:length(switches)
    h(i) = line([switches(i) switches(i)],[yLim(1) yLim(2)]);
end
set(h,'Color','r')
end

 %% check out the spatial distribution of jackpots (correct choices), RTs, and all choices

figure('Position',[480 611 1334 367]);
for plotWhat = 1:3
    subplot(1,4,plotWhat);
    
    switch plotWhat
        case 1
            behOI = 'jackpot';
        case 2
            behOI = 'rt';
        case 3
            behOI = 'error';
    end

    % correct for wrapping errors
    tmp = [out.altTargTheta];
    tmp(tmp>360) = tmp(tmp>360)-360;
    tmp = num2cell(tmp);
    [out.altTargTheta] = deal(tmp{:});

    if plotWhat < 3
        idxOG = and([out.correct]==1,[out.choiceTrial]==1);
    else
        idxOG = [out.choiceTrial]==1;
    end
    
    tmp = unique([out.altTargTheta]); tmp = tmp(~isnan(tmp));
    m = NaN(length(tmp),1);
    for i = 1:length(tmp);
        idx = and(idxOG,[out.altTargTheta]==tmp(i));
        m(i) = nanmean([out(idx).(behOI)]);
    end

    % wrap em around
    tmp = [tmp tmp(1)];  m = [m; m(1)];

    h = polar(tmp/(180/pi),m');
    set(h,'LineWidth',2);
    title(behOI)
end

% same for where he chooses to look
subplot(1,4,4)

% correct for wrapping errors
tmp = [out.altTargTheta];
tmp(tmp>360) = tmp(tmp>360)-360;
tmp = num2cell(tmp);
[out.altTargTheta] = deal(tmp{:});

idxOG = and([out.correct]==1,[out.choiceTrial]==1);

tmp = unique([out.altTargTheta]); tmp = tmp(~isnan(tmp));
m = NaN(length(tmp),2);
for i = 1:length(tmp);
    idx = and(idxOG,[out.altTargTheta]==tmp(i));
    m(i,1) = nansum([out(idx).jackpot]);
    m(i,2) = sum(idx);
    
    idx = and(idxOG,[out.theta]==tmp(i));
    m(i,1) = m(i,1) + nansum([out(idx).jackpot]);
    m(i,2) = m(i,2) + sum(idx);
end

m = m(:,1) ./ m(:,2);

% wrap em around
tmp = [tmp tmp(1)];  m = [m; m(1)];

h = polar(tmp/(180/pi),m');
set(h,'LineWidth',2);
title('choice')

%% now the orientation of the jackpot relative plot

figure();
for plotWhat = 1:2
    subplot(1,2,plotWhat);
    
    switch plotWhat
        case 1
            strOI = 'jackpot';
        case 2
            strOI = 'other';
    end

    behOI = strcat(strOI,'Orientation');
    
    % correct for wrapping errors
    tmp = [out.(behOI)];
    tmp(tmp>=180) = tmp(tmp>=180)-180;
    tmp(tmp<0) = tmp(tmp<0)+180;
    tmp = num2cell(tmp);
    [out.(behOI)] = deal(tmp{:});

    idxOG = and([out.correct]==1,[out.choiceTrial]==1);

    tmp = unique([out.(behOI)]); tmp = tmp(~isnan(tmp))
    m = NaN(length(tmp),1);
    for i = 1:length(tmp);
        idx = and(idxOG,[out.(behOI)]==tmp(i));
        m(i) = nanmean([out(idx).jackpot]);
    end

    % wrap em around
    %tmp = [tmp tmp(1)];  m = [m; m(1)];

    %if plotWhat == 2; m = 1-m; end
    
    h = plot(tmp,m','.-');
    set(h,'LineWidth',2,'MarkerSize',30);
    title(behOI)
    h = line([0 180],[.5 .5]);
    set(h,'Color','k','LineStyle','--')
    xlim([0 180]); ylim([.1 .9])
end

%% over time, relative to switches in what is jackpotted
% CURRENTLY CONFLATED W/TIME W/IN SESSION/BLOCK!!!
if length(unique([out.jackpotOrientation])) > 1
    beh = 'error';
    %beh = 'rt';
    %beh = 'choice'
    pre = 10; post = 50; binWidth = 3;
    figure();
    %switches = find(abs(diff([[out(1).jackpotOrientation],[out.jackpotOrientation]]))>1);
    %switches = find([or(diff([out.jackpotOrientation])~=0,diff([out.otherOrientation])~=0)]);
    
    switches = find(abs(diff([out.jackpotOrientation]))>1);
switches = [switches find(abs(diff([out.otherOrientation]))>1)];
tmp = vertcat(out.targColor);
switches = [switches find(abs(diff(tmp(:,1)))>1)];
tmp = vertcat(out.altTargColor);
switches = [switches find(abs(diff(tmp(:,1)))>1)];
switches = unique(switches);

    [m,e,p] = deal(NaN(2,pre+post));
    for i = 1:pre+post
        if i == 1;
            selex = [];
            for j = 1:length(switches)
                selex = [selex [switches(j)-(pre*binWidth+1):switches(j)-((pre-1)*binWidth+1)]];
            end
        else
            selex = selex + binWidth;
        end
        if strcmp(beh,'choice')
            idx = intersect(selex,find(and([out.correct]==1,[out.choiceTrial]==1)));
            m(1,i) = nanmean([out(idx).jackpot]);
            e(1,i) = sqrt((m(1,i)*(1-m(1,i)))/length(idx));
        else
            idx1 = intersect(selex,find([out.jackpot]==1));
            m(1,i) = nanmean([out(idx1).(beh)]);
            e(1,i) = nanstd([out(idx1).(beh)])./sqrt(length(idx1)-1);

            idx2 = intersect(selex,find([out.jackpot]==0));
            m(2,i) = nanmean([out(idx2).(beh)]);
            e(2,i) = nanstd([out(idx2).(beh)])./sqrt(length(idx2)-1);

            [p(1,i),p(2,i)] = ttest2([out(idx1).(beh)],[out(idx2).(beh)]);
        end
    end
    xpos = [binWidth*-pre:binWidth:binWidth*post];
    xpos = xpos(1:end-1) + diff(xpos)/2;
    errorbar([xpos;xpos]',m',e')
    if ~strcmp(beh,'choice')
        legend('jackpot','not jackpot')
        ylabel(beh);
    else
        ylabel('percent choosing jackpot')
    end
    xlabel('trials relative to rwd switch')
end

