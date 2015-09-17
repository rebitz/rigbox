% AP for any computer I may use

[~,host] = system('hostname');
host = cellstr(host);

if strcmp(host{1}, 'Eddy-PC')
    % path to the github directory
    cd('C:\Users\Eddy\Documents\GitHub\rigbox')
    compName = 'rigF'; % name of the specific machine
elseif strcmp(host{1}, 'GB1LPM1')
    cd('C:\Users\User\Documents\rigbox')
    compName = 'rigB';
elseif strcmp(host{1}, 'buschma-7f6pr52')
    cd('C:\Users\labadmin\Documents\MATLAB\Becket\rigbox')
    compName = 'oz';
elseif strcmp(host{1}, 'buschma-73gqr52')
    cd('C:\Users\labadmin\Documents\MATLAB\Becket\rigbox')
    compName = 'space';
else % it's probably just on my laptop
    cd('/Users/becket/Documents/MATLAB/pbox');
    compName = 'laptop';
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

rmpath(folders{:})
rmpath(strcat(gitDir,splitChar,compName,'specific'))