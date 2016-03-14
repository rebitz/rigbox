% checkFix.m
% Checks if fixation is acquired through either a spacebar press (TESTING)
% or eye position moving inside fix rect (EYEBALL)

function fixed = checkFix(object, err, key)

fixChecking = 1;

global TESTING EYEBALL

fixed = 0;

if TESTING || EYEBALL
    
    [keyIsDown,~,keyCode] = KbCheck;
            
    % Key pressed -> fixation acquired
    if keyIsDown && keyCode(key);
        fixed = 1;
    else
        fixed = 0;
    end
    
end

if ~TESTING && EYEBALL
        
    simple_esc_check;
        
    sampleEye;
        
    checked = 0;
       
    while ~checked
        
        if Eyelink('newfloatsampleavailable')>0;
                        
            evt = Eyelink( 'newestfloatsample');
            x = evt.gx(1);
            y = evt.gy(1);
            
            if (evt.pa(1) > 0) && (abs(x-object(1)) > err || abs(y-object(2)) > err)
                fixed = 0;
            else
                fixed = 1;
            end
            
            checked = 1;
            
        end
        
    end
    
end

fixChecking = 0;

end