strToCat = '01042016'
monk = 'beak';
task = 'barTrain';

cd(strcat(gitDir,splitChar,'train',splitChar,'data'));
files = dir;
idx = and(~cellfun(@isempty,strfind({files.name},strToCat)),...
    cellfun(@isempty,strfind({files.name},'taskdata')));
idx = and(idx,and(~cellfun(@isempty,strfind({files.name},monk)),...
    ~cellfun(@isempty,strfind({files.name},task))));
files = {files(idx).name};



data = [];
for i = 1:length(files);
    load(files{i});
    try
        data = [data trials];
    end
end

correctIdx = or(~isnan([data.responseT]),[data.releasedLogical]==1);

disp('number of trials: ')
nTotal = length(data)

disp('number of correct trials: ')
nCorrect = sum(correctIdx)

disp('percent correct: ')
nCorrect/nTotal

disp('percent correct after target change: ')
sum(correctIdx(~isnan([data.goCueT])))/sum(~isnan([data.goCueT]))

% now keep response times
tmp = num2cell([data.responseT] - [data.goCueT]);
[data.rt] = deal(tmp{:});

disp('mean response time: ')
nanmean([data.rt])

disp('std response time: ')
nanstd([data.rt])

xpos = [0:.1:3];
figure();
bar(xpos,hist([data.rt],xpos))
title('from go cue')

% now align to another event - the time the bar goes down
tmp = num2cell([data.responseT] - [data.t2initialize]);
[data.rt] = deal(tmp{:});

disp('std of bar-down aligned response time: ')
nanstd([data.rt])

xpos = [0:.1:3];
figure();
bar(xpos,hist([data.rt],xpos))
title('from bar down')

cd(gitDir);