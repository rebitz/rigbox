% attention_opentask;

% Set the ITI for the first trial.
iti = itimin + (itimin - itimax) .* rand(1,1);

%% Ensure output

% Name datafile in case it was forgotten
if ~exist('filename')
    disp('Subject name not provided, using unnamed as name')
    subject = sprintf('unnamed');
else
    subject = filename;
end;

% Create directory where data will be stored
filestart = filename;
filename = strcat(filename,'_001');

cd(dataDirectory)

files = dir;
files = {files([files.isdir]==1).name};

if sum(strcmp(files,filestart))<1 % but if we're wrong
    mkdir(filestart)
end

dataDirectory = strcat(dataDirectory,splitChar,filestart);
cd(dataDirectory)

zpad = '_00';

if ~isdir(filename)
    mkdir(filename)
else
    i = 1;
    filename = strcat(filestart,zpad,num2str(i));
    while isdir(filename)
        i = i+1;
        if i >= 10
            zpad = '_0';
        end
        filename = strcat(filestart,zpad,num2str(i));
    end
    mkdir(filename);
end

cd(filename)
backhome = pwd;

%% Setup stimuli

% Convert cue and targ features to appropriate units
diodeRect = [(rect(3)-60) (rect(4)-60) rect(3) rect(4)];
diodeColor = [255 255 255];

% Setup stimuli and fixation rects
fixSize = deg2px(fixSize, env)./2;
fixRect = [origin origin] + [-fixSize -fixSize fixSize fixSize];
fix_err = deg2px(fix_err, env)./2;

targSize = deg2px(targSize, env)./2;
targ_err = deg2px(targ_err, env)./2;

% target stuff
tOffsetDG = tOffsets; % save for later
tOffsets = deg2px(tOffsets, env); % <- happens just in time
thetas = thetas*(pi./180); % convert thetas to radians

% error feedback
errorSize = deg2px(errorSize, env)./2;
errorRect = [origin origin] + [-errorSize -errorSize errorSize errorSize];

% reward distribution happens just in time in opentrial

% temporary key assignment, going clockwise like target ids
targKey = [right,down,left,up];

%% Make Eyelink start recording

if EYEBALL
    Eyelink('startrecording');
end

%% Save all the task data

cd(backhome)

% if ~isempty(which('v2struct'))
%     task = v2struct;
% end % probably doesn't actually work - gotta do some messing
% saves all the variables we've generated so far:
save(strcat(filename,'_taskVariables'));

