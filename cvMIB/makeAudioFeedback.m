%% series of pure tones

for sounds = 1:2
    switch sounds
        case 1
            cf = [440 523.25 698.46];   % rising 3 notes
        case 2
            cf = [440 220 220]; % falling 2 notes;
    end
    
    sf = 22050;                 % sample frequency (Hz)
    d = .1;                     % duration - each tone (s)
    n = sf * d;                 % number of samples
    stmp = (1:n) / sf;             % sound data preparation

    s = [];
    for i = 1:length(cf)
        s = [s sin(2 * pi * cf(i) * stmp)];   % sinusoidal modulation
    end

%   sound(s, sf);               % sound presentation

    switch sounds
        case 1
            rwdSound = s;   % rising 3 notes
        case 2
            norwdSound = s;   % falling 2 notes
    end
end
