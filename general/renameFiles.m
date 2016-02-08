function renameFiles(folder,offendingString,newString)
%
% function renameFiles(folder,offendingString,newString)
%
% recursively renames all files in a specified directory which contain an
% offendingstring, replaces that string with the newString

home = pwd;
cd(folder);
top = pwd;

offending = offendingString;
new = newString;

% first, go through all the files in the current directory
renameAll(offending,new);

% then go into each directory and do all the files in there
tmp = dir;
dirs = {tmp([tmp.isdir]==1).name};
dirs = dirs(3:end);

for i = 1:length(dirs)
    cd(dirs{i})
    renameAll(offending,new);
    cd(top)
end
cd(home)

function renameAll(offending,new)
    tmp = dir;
    
    files = {tmp.name};
    files = files(3:end);

    % list of all the filenames that contain a match
    idx = find(~cellfun(@isempty,strfind(files,offending)));
    
    % go through these filenames and locate the strings
    fu = max(cellfun(@(x) length(x),files(idx))); % longest string len
    put = NaN(fu,length(files(idx)));% preallocate
    for k = 1:fu
        put(k,:) = cellfun(@(x) x(1)==k,strfind(files(idx),offending));
    end
    [~,id] = max(put); % find the first instance of the offending str
    
    for i = 1:length(idx)
        tmp = files{idx(i)};
        start = tmp(1:id(i)-1);
        finish = tmp(id(i)+length(offending):end);

        fname = strcat(start,new,finish);

        movefile(files{idx(i)},fname);
    end
