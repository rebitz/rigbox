% AP for my laptop or rigF

[~,host] = system('hostname');
host = cellstr(host);

if strcmp(host{1},'dn2lk5n84.stanford.edu') || strcmp(host{1},'Beckets-MacBook-Pro.local')
    % enter the path to the git hub directory
    cd('/Users/becket/Documents/MATLAB/pbox');
    compName = 'laptop';
elseif strcmp(host{1}, 'Eddy-PC')
    cd('C:\Users\Eddy\Documents\GitHub\rigbox')
    compName = 'rigF';
elseif strcmp(host{1}, 'GB1LPM1')
    cd('C:\Users\User\Documents\rigbox')
    compName = 'rigB';
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