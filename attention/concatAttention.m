
home = pwd;

files = dir;
matfiles = ~cellfun(@isempty,strfind({files.name},'.mat'));
matfiles = {files(matfiles).name};

idx = [files.isdir] == 1;
files = {files(idx).name};
files = files(3:end);

list = unique(files);

tok = strtok(matfiles,'.');
for i = 1:length(tok)
    idx = strcmp(list,tok{i});
    list = list(~idx); 
end

out = ([]);
for block = 1:length(list)
    cd(list{block});
    
    % grab the trials
    files = dir;
    matfiles = ~cellfun(@isempty,strfind({files.name},'.mat'));
    matfiles = {files(matfiles).name};
    tmpfiles = matfiles(cellfun(@isempty,strfind(matfiles,'taskVariables')));
    
    for i = 1:length(tmpfiles)
        load(tmpfiles{i})
        [trials.block] = block;
        if ~isfield(trials,'releasedLogical'); [trials.releasedLogical] = NaN; end
        out = [out trials];
    end
    
    % grab the task variables
    if block == 1
        tmpfiles = matfiles(~cellfun(@isempty,strfind(matfiles,'taskVariables')));
        load(tmpfiles{:});
        block = 1;
    end
    
    cd ..
end

% append response time
tmp = num2cell([out.targAcq] - [out.targOn]);
[out.rt] = deal(tmp{:});

% append info about what reward block we're in
rwdBlock = 1; out(1).rwdBlock = 1;
for tr = 1:length(out)-1
    if out(tr).block ~= out(tr+1).block || out(tr+1).trialSince == 0
        rwdBlock = rwdBlock+1;
    end
    out(tr+1).rwdBlock = rwdBlock;
end

% now whether they made the best of all possible choices
[~,maxRwd] = max(vertcat(out.targRwds),[],2);
tmp = num2cell(maxRwd == [out.chosenTarg]');
[out.bestChoice] = deal(tmp{:});

length(out)

    
%% first, we just make sure there's some evidence of learning
%% align everything to the first trial after a change, attempt learning curves

behOI = 'rewarded';
behOI = 'bestChoice';

smoothBy = 1;
nSince = 30;
nBefore = 20;

% trying to calculate chance = p(stim)*p(rwd|stim)
if strcmp(behOI,'rewarded')
    % random seed -> since we've discretized orientations, the chance value
    % depends on the precise value of the seed relative to orientation opts
    rwdSeed = orientationBounds(1) + rand*range(orientationBounds);

    % now the probability for choosing each target
    radSeed = (rwdSeed/90)*pi;
    radOrientations = (orientationSeeds/90)*pi;
    angDist = abs(mod((radSeed-radOrientations) + pi, pi*2) - pi);
    if exist(rwdScale)
        theseRwds = rwdScale*exp(-((angDist.^2)/(2*rwdStd.^2)));
    else
        theseRwds = (maxRwd-minRwd)*exp(-((angDist.^2)/(2*rwdStd.^2)))+minRwd;
    end

    % figure(); plot(orientationSeeds,theseRwds)
    chance = nanmean(theseRwds);
else
    chance = 1/length(nanunique([out.chosenTarg]));
end

firsts = find([out.trialSince]==0);
runs = NaN(length(firsts),nSince+nBefore+1);

for tr = 1:length(firsts)

    idx = [firsts(tr)-nBefore:firsts(tr)+nSince];
    validTrNums = find(and(idx>0,idx<length(out))); % first, select valid trial numbers
    idx = idx(validTrNums); % translate back into trial numbers
    selex = or([out(idx).rwdBlock] == out(firsts(tr)).rwdBlock,...
        [out(idx).rwdBlock] == out(firsts(tr)).rwdBlock-1);
    idx = idx(selex); keeps = validTrNums(selex);
    
    tmp = out(idx);
    runs(tr,keeps) = [tmp.(behOI)];

end

figure(); hold on;
m = gsmooth(nanmean(runs),smoothBy);
e = gsmooth(nanste(runs),smoothBy);
xpos = [1-nBefore:1+nSince];
plot(xpos,m)
plot(xpos,m+e,'--')
plot(xpos,m-e,'--')

h = line([min(xpos) max(xpos)],[chance chance]);
h(2) = line([0 0],[0 .9]);
set(h,'Color','k')

%% whole session plot:

behOI = 'rewarded';
behOI = 'bestChoice';

smoothBy = 5;

figure(); hold on;
plot(gsmooth([out.(behOI)],smoothBy))
plot([out.trialSince]==0,'.k')


h = line([0 length(out)],[chance chance]);
set(h,'Color','k')
