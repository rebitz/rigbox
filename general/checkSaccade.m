% checkSaccade.m
% Checks if fixation is broken based on threshold crossing

function fixed = checkSaccade(threshold,checkTime)

global TESTING EYEBALL env

fixed = 1;

if ~TESTING && EYEBALL
        
    simple_esc_check;
        
    checked = 0;
       
    while ~checked && fixed

        [x,y] = deal(NaN(2,1));

        if Eyelink('newfloatsampleavailable')>0;
                        
            evt = Eyelink( 'newestfloatsample');
            if strcmp(env.eyeToTrack,'RIGHT')
                x(1) = evt.gx(2); y(1) = evt.gy(2);
            elseif strcmp(env.eyeToTrack,'LEFT')
                x(1) = evt.gx(1); y(1) = evt.gy(1);
            end

        end

        WaitSecs(checkTime);

        if Eyelink('newfloatsampleavailable')>0;

            evt = Eyelink( 'newestfloatsample');
            if strcmp(env.eyeToTrack,'RIGHT')
                x(2) = evt.gx(2); y(2) = evt.gy(2);
            elseif strcmp(env.eyeToTrack,'LEFT')
                x(2) = evt.gx(1); y(2) = evt.gy(1);
            end
    
        end

        eyeChange = sqrt(diff(x).^2+diff(y).^2);

        if eyeChange > threshold
            fixed = 0;
        end

        if ~isnan(eyeChange)
            checked = 1;
        end
    end
end