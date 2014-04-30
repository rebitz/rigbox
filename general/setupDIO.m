% first set up a struct specifying the event names and such
eventNames = {'juice','trialStart','fixOn','fixAcq','targOn',... % 5
    'targChange','targAcq','trialStop'}; % these will appear in order
nports = length(eventNames);

% then append these to a struct
for i = 1:nports
    digOut.(eventNames{i}) = i;
end

% then open the daq session, output dio object and flags
devices = daq.getDevices;

global dio;

% DEV1 should be our PCI 6251
if strcmp(devices(1).Model,'PCI-6251') || strcmp(devices(1).Model,'PCIe-6361')
    if nports <= 8
        portStr = strcat('port0/line0:',num2str(nports-1));
        devStr = devices(1).ID;
        % start a sessiont
        dio = daq.createSession('ni');  % specify # of lines on port 0
        dio.addDigitalChannel(devStr,portStr,'OutputOnly') %0:3 is #1-4
    else
        fprintf('\n Too many events! Reconfigure ports! \n')
        dio = [];
    end
else
    fprintf('\n Error, wrong device ID entered \n')
    dio = [];
end

flags = zeros(1,nports);

clear('portStr','devices');