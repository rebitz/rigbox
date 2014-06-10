% AP for my laptop or rigF

[~,host] = system('hostname');
host = cellstr(host);

if strcmp(host{1},'dn2lk5n84.stanford.edu')
    cd('/Users/becket/Documents/MATLAB/pbox');
    compName = 'laptop';
else
    cd('')
    compName = 'rigF';
end

    
files = dir;
folders = {files([files.isdir]).name};
folders = folders(cellfun(@isempty,strfind(folders,'.')));
folders = folders(cellfun(@isempty,strfind(folders,'specific')));

global gitDir
gitDir = pwd;

if IsOSX
    splitChar = '/';
else
    splitChar = '\';
end

for i = 1:length(folders)
    folders(i) = strcat(gitDir,splitChar,folders(i));
end

addpath(folders{:})

addpath(strcat(gitDir,splitChar,compName,'specific'))

defaultEnv;
