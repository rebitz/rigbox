global samples

if ~exist('fixChecking') || ~fixChecking
    esc_check;
elseif fixChecking
    simple_esc_check;
end

if EYEBALL
    
    try,
    [tempsamples, ~, ~] = Eyelink('GetQueuedData');
    
    if size(tempsamples, 1) == size(samples, 1)
        samples = [samples tempsamples];
    end
    catch
        waitsecs(0.02);
    end
    
end