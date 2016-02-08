% EVERYTHING SO FAR:
% folder = {'bun010816','bun010916','bun011016',...
%     'bun011116','bun011216','bun011316','bun011416',...
%     'bun011516','bun011916','bun012016','bun012116',...
%     'bun012216'}

% JUST THE LAST 2 WEEKS
folder = {'bun011116','bun011216','bun011316','bun011416',...
    'bun011516','bun011916','bun012016','bun012116',...
    'bun012216','bun012616','bun012716','bun012816',...
    'bun012916','bun020116','bun020216','bun020316',...
    'bun020416','bun020516'}

% JUST TODAY
%folder = {'bun020516'}

cd(strcat(gitDir,splitChar,'train',splitChar,'data'));

out = ([]);

for q = 1:length(folder)

cd(folder{q});
folders = dir; % get the names of all the folders

processed = false;
% if length(folder) > 1 % check to see if we've saved processed data 
%     idx = [folders.isdir] == 0;
%     files = {folders(idx).name};
%     if ~isempty(strcmp(files,strcat(folder{q},'.mat')));
%         processed = true
%         load(strcat(folder{q},'.mat'))
%     end
% end

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
                    [trials.gaborOrientation] = gOrientation;
                else
                    [trials.gaborOrientation] = NaN;
                end
            catch
                [trials.gaborOrientation] = NaN;
            end

            if ~isfield(trials,'releasedLogical'); [trials.releasedLogical] = NaN; end
            if ~isfield(trials,'jackpot'); [trials.jackpot] = NaN; end
            if ~isfield(trials,'choiceTrial'); [trials.choiceTrial] = NaN; end
            if ~isfield(trials,'whichTarg'); [trials.whichTarg] = NaN; end
            data = [data trials];
        end

        keep out folder list block gitDir splitChar q data

        cd ..
    end
    
    % if we're doing some summary stuff, go ahead and assume the day is
    % over - save to facilitate later processing
    data = rmfield(data,'eyedata');
    
    if length(folder) > 1;
        save(strcat(folder{q}),'data')
    end
end

[data.session] = deal(q);
if ~isfield(data,'whichTarg'); [data.whichTarg] = deal(NaN); end
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
    {'noFix','brokeFixLap','brokeFixGap',...
    'noSaccade','errantSaccade','brokeTarg'})
 title(strcat(folder{:}))

% plot broken fix error likelihood against fix time
nbins = 8;
subplot(2,2,3)
x = [out.fixHold]; y = or([out.errortype]==2,[out.errortype]==3);
xpos = [min(x):range(x)/nbins:max(x)];
[~,idx] = histc(x,xpos);
[m,e] = deal(NaN(1,nbins));
for i = 1:nbins
    m(i) = nanmean(y(idx==i));
    e(i) = nanstd(y(idx==i))/sqrt(sum(~isnan(y(idx==i)))-1);
end
errorbar(xpos(1:end-1)+mean(diff(xpos))/2,m,e);
ylabel('p(broken fix error)');
xlabel('fix hold time');

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

%%
% checkout the behavioral response on jackpot trials
% over time, relative to switches in what is jackpotted
% CURRENTLY CONFLATED W/TIME W/IN SESSION!!!
if length(unique([out.gaborOrientation])) > 1
    %beh = 'error';
    %beh = 'rt';
    beh = 'choice'
    pre = 3; post = 5; binWidth = 30;
    figure();
    switches = find(abs(diff([[out(1).gaborOrientation],[out.gaborOrientation]]))>1);
    
    [m,e,p] = deal(NaN(2,pre+post));
    for i = 1%:pre+post
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
    legend('jackpot','not jackpot')
    ylabel(beh); xlabel('trials relative to rwd switch')
end