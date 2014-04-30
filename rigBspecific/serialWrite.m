function serialWrite(output)

% try,
    port = serial('COM1'); % plugged into plx usb
    set(port,'BaudRate',115200);
    fopen(port);

    
% plexon computer is expecting a vector 
sendPut = NaN(1,length(output)*2); here = 1;
for i = 1:length(output)
    sendPut(here) = mod(output(i),256); here = here+1;
    sendPut(here) = floor(output(i)/256); here = here+1;
end

sendPut = sendPut(~isnan(sendPut));

fwrite(port,sendPut);
fclose(port);
delete(port);
clear port;
% catch
%     disp('Unknown Error, nothing written!')
% end