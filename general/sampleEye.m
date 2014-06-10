global samples

esc_check;

if EYEBALL
        
    [tempsamples, ~, ~] = Eyelink('GetQueuedData');
    
    if size(tempsamples, 1) == size(samples, 1)
        samples = [samples tempsamples];
    end
    
end