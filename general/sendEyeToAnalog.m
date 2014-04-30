
%% first connect to eyelink

if Eyelink('IsConnected') ~= 1
    disp('Trying to connect to Eyelink, attempt #1(/2):');
    r = Eyelink('Initialize');
    if r ~= 0
        WaitSecs(.5) % wait half a sec and try again
        disp('Trying to connect to Eyelink, attempt #2(/2):');
        r = Eyelink('Initialize');
    end
elseif Eyelink('IsConnected') == 1
    r = 0; % means OK initialization
end

Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA,PUPIL');
% Eyelink('StartSetup');
% Eyelink('DriftCorrStart', origin(1), origin(2));
% Eyelink('ApplyDriftCorr');
Eyelink('StartRecording');


%% then start the DAQ session

devices = daq.getDevices;
dio = daq.createSession('ni');

xCH = dio.addAnalogOutputChannel('Dev1', 0, 'Voltage');
yCH = dio.addAnalogOutputChannel('Dev1', 1, 'Voltage');


%% finally, output the eyeball position to the analog card

space = KbName('space');
esc = KbName('esc');

runit = 1;

while runit
    
    [keyIsDown,secs,keyCode]=KbCheck;
    if keyIsDown==1 && keyCode(space) || keyCode(esc)
        runit = 0;
    end 
    
    if Eyelink('newfloatsampleavailable')>0;

        evt = Eyelink( 'newestfloatsample');
        x = evt.gx(1)
        y = evt.gy(1)

        %dio.outputSingleScan([x/1000 y/1000]);

    end
end