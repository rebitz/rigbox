function out = photoTest
% set some control parameters
rate = 1000; % sampling rate
repeat = 5; % n repeats for struct
nCycles = 5; % cycles to include in each run
    % all timing is randomized

global w env
setupScreen;
global dio
setupDAQ(rate);

out = ([]);
for rep = 1:repeat
    result = photoTestCycle;
    if rep == 1
        out = result; 
    else
        out(rep) = result;
    end
end

% then clean up
daqreset; % legacy, but hasn't been replaced
clear('dio');
delete(lh); % clear the listener
Screen('CloseAll'); % Screen clear

%% SUBFUNCTION DEFINITIONS
function result = photoTestCycle

% setup output
result = ([]);
time = []; data = [];

lh = dio.addlistener('DataAvailable',@getData); 

%%

[on,off] = deal(NaN(1,nCycles));

dio.IsContinuous = true; % starts continuous data aquisition
acqT1 = GetSecs();
startBackground(dio)
acqT2 = GetSecs();
acqStart = mean([acqT1,acqT2]);

for i = 1:nCycles
    
WaitSecs( rand(1))
    
% Fixation onset
Screen(w,'FillRect',env.colorDepth/2) % clear the text
Screen(w,'FillRect',env.diodeColor,env.diodeRect)
on(i) = Screen(w,'Flip');

WaitSecs( rand(1))

% Fixation onset
Screen(w,'FillRect',env.colorDepth/2) % clear the text
Screen(w,'Flip')
off(i) = Screen(w,'Flip');

end

WaitSecs( rand(1))

acqStop = GetSecs();
stop(dio);

nsamples = (acqStop - acqStart);
nsamples = nsamples*rate;
fprintf('should have about %d samples',nsamples)

result.times = time';
result.voltage = data';

ons = on-acqStart;
offs = off-acqStart;
labels = zeros(1,length(time));
for q = 1:length(ons);
    idx = and(time > ons(q),time <= offs(q));
    [labels(idx)] = deal(1);
end

result.labels = labels;
% result.nSamplesExpected = nsamples;
% result.startTime = acqStart;
% result.secondTime = acqT2;
% result.stopTime = acqStop;
% result.ons = on;
% result.offs = off;

function getData(src,event)
    time = [time; event.TimeStamps];
    data = [data; event.Data];
end
end


function setupScreen
    % setup the screen environment
    defaultEnv;
    screenNumber = 1;

    Screen('CloseAll'); % Screen clear
    warning('off','MATLAB:dispatcher:InexactMatch');
    warning('off','MATLAB:dispatcher:InexactCaseMatch');
    Screen('Preference','VisualDebugLevel', 0);
    Screen('Preference', 'SuppressAllWarnings', 1);
    Screen('Preference', 'SkipSyncTests',1);

    % Create new window and record size
    [w, rect] = Screen('OpenWindow',screenNumber,env.colorDepth/2); % window Idx
    [env.screenWidth, env.screenHeight] = WindowSize(w);

    % Diode rect definition
    env.diodeRect = [(rect(3)-60) (rect(4)-60) rect(3) rect(4)];
    env.diodeColor = [255 255 255];

    Screen(w,'FillRect',env.colorDepth/2)
    Screen(w,'Flip')
    
end

function dio = setupDAQ(rate)
    %% setup the dio
    % then open the daq session, output dio object and flags
    devices = daq.getDevices;

    global dio;

    % DEV1 should be our PCI 6251
    if strcmp(devices(1).Model,'PCI-6251') || strcmp(devices(1).Model,'PCIe-6361')
        devStr = devices(1).ID;
        dio = daq.createSession('ni');  % specify # of lines on port 0
        dio.addAnalogInputChannel(devStr,0,'voltage');
    else
        fprintf('\n Error, wrong device ID entered \n')
        dio = [];
    end

    % set some properties
    dio.Rate = rate;
    dio.NotifyWhenDataAvailableExceeds = 100;
    
end

end