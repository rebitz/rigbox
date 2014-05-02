function [T1,T2] = generateWalkForBandit(hazard,ntrials,bounds)
% output 2 value vectors that match our requirements
% 1. bounded at bounds [LB UB], eg [10 90];
% 2. evens out every 500 trials, E(t1) =ish E(t2)
% 3. no more than 50 trials in each chunk where t1 < 30% && t2 < 30%

disp('making reward vectors');

if nargin < 2
    ntrials = 1000;
end

if nargin < 3
    % set the bounds on the walk/seed/etc
    low = 10;
    high = 90;
else
    low = min(bounds); high = max(bounds);
end

chunk = 750; % trials to even out over
err = 10; % allow x% variance btw means

motivationThresh = 20;
motivationTrials = 50;

% try,
runIt = 1; attempts = 0;
while runIt
    attempts = attempts+1;
    
    [T1,T2] = tryWalk(high,low);
    
    %%
    check = 1;
    for i = 1:chunk:ntrials
        if i+chunk > ntrials
            there = ntrials;
        else
            there = i+chunk;
        end
        
        m1 = mean(T1(i:there));
        m2 = mean(T2(i:there));
        if m1 > m2+err || m1 < m2-err
            check = 0; % failed the check
            break;
        end
        
        fu = sum(and(T1(i:there)<=motivationThresh, T2(i:there)<=motivationThresh));
        if fu > motivationTrials
            check = 0; % failed the check
            break;
        end
    end
    
    if check == 1
        runIt = 0;
        break;
    end
    
    if attempts == 50 || attempts == 100 || attempts == 150
        disp('still working...')
    end
    %%
end

fprintf('took %d attemps, but here it is \n',attempts);
% catch
%     keyboard();
% end

%%
function [T1vals,T2vals] = tryWalk(high,low)

% easier to operate on integer steps
low = low / 10; high = high / 10;

% % variance in random process
% stStep = stepSize * 2/3;

% seed randomly
% seedIn = [high-low]
T1seed = low + randperm([high-low],1);
T2seed = low + randperm([high-low],1);

[T1vals,T2vals] = deal(NaN(1,ntrials));

% make a bunch of transition time points, dependant on hazard
T1transitions = binornd(ones(1,ntrials),hazard);
T2transitions = binornd(ones(1,ntrials),hazard);

% make some of them negative
T1signs = binornd(ones(1,ntrials),.5); T1transitions(and(T1transitions,T1signs)) = -1;
T2signs = binornd(ones(1,ntrials),.5); T2transitions(and(T2transitions,T2signs)) = -1;

% the dreaded for loop
for i = 1:ntrials
    if T1seed+T1transitions(i) >= low && T1seed+T1transitions(i) <= high
        T1seed = T1seed+T1transitions(i);
    end
    if T2seed+T2transitions(i) >= low && T2seed+T2transitions(i) <= high
        T2seed = T2seed+T2transitions(i);
    end
    T1vals(i) = T1seed;
    T2vals(i) = T2seed;
end

T1vals = T1vals*10; T2vals = T2vals*10;

end

end