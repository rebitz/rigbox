% replay concat blocks:

files = dir;
idx = [files.isdir] == 1;
files = {files(idx).name};
files = files(3:end);

trials = ([]);

subjhome = pwd;

% for each block
for j = 1:length(files);
    
    cd(subjhome);
    localtrials = ([]);

    % go to that block's directory
    cd(files{j});

    % then find all the files
    dat = dir;
    
    % now the trial data
    matfiles = ~cellfun(@isempty,strfind({dat.name},'.mat'));
    matfiles = find(and(matfiles,cellfun(@isempty,strfind({dat.name},'task_data'))));

    for q = 1:length(matfiles)
        load(dat(matfiles(q)).name)
        localtrials = [localtrials trial_data];
    end
    
    trials = [trials localtrials];
    
end

choices = [trials.choice];
choices = choices(~isnan(choices));

% make choices the right length for what we're looking for
while length(choices) < ntrials
    choices = [choices choices];
end

keepIdx = zeros(1,length(choices));
i = randi(length(choices)-ntrials);
keepIdx(i:i+ntrials) = 1;

choices = choices(keepIdx==1);