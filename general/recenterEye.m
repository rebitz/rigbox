% recenterEye
scaleOffsetBy = 2;

 if Eyelink('newfloatsampleavailable')>0;
                        
    evt = Eyelink( 'newestfloatsample');
    if strcmp(env.eyeToTrack,'RIGHT')
        x = evt.gx(2); y = evt.gy(2);
    elseif strcmp(env.eyeToTrack,'LEFT')
        x = evt.gx(1); y = evt.gy(1);
    end
  
    xOffset = x-origin(1)/scaleOffsetBy;
    yOffset = y-origin(1)/scaleOffsetBy;
    
    targRect = targRect + [xOffset yOffset xOffset yOffset];
    targOrigin = targOrigin + [xOffset yOffset];
    try
    altTargRect = altTargRect + [xOffset yOffset xOffset yOffset];
    altTargOrigin = altTargOrigin + [xOffset yOffset];
    end
% origin  = nanmean([[x,y];repmat(origin,99,1)])
%     Eyelink('DriftCorrStart', x, y);
%     Eyelink('ApplyDriftCorr');
 end