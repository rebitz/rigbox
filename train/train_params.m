% train_params.m
% Initialize the parameters for training task

% Which display?
screenNumber = 1;

% Directory of where the data will be saved to
global gitDir
if IsOSX
    splitChar = '/';
else
    splitChar = '\';
end
dataDirectory = strcat(gitDir,splitChar,'train',splitChar,'data');

% Background color
bgcolor = [127 127 127];

% fixation color
fixcolor = [255 255 255];

% target color
targcolor = [255 255 255];

% baseline timing stuff
time2fix = 2;
time2choose = 1;

% Inter-trial interval bounds (s)
itimin = 1.25;
itimax = 1.75;