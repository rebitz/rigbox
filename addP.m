% adds the first-order folders in its own directory to the path
here = pwd;
files = dir;
directories = {files([files.isdir]).name};
directories = directories(cellfun(@isempty,strfind(directories,'.')));
tmp = strcat(here,'/',directories); % full directory name
addpath(tmp{:},'-BEGIN') % add to beginning of path