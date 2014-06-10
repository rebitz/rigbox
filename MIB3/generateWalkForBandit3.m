function [T1,T2,T3] = generateWalkForBandit3(hazard,ntrials,bounds,stepSize)
% output 3 value vectors that match our requirements
% 1. bounded at bounds [LB UB], eg [10 90];
% 2. evens out every 750 [chunk] trials, E(t1) =ish mean(E(t2),E(t3))
% 3. no more than 50 trials in each chunk where all ts < 20

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

if nargin < 4
    stepSize = 1;
elseif stepSize > 1
    stepSize = stepSize/10;
end

% hopefully it will never come to this
if stepSize > (range(bounds)/10)
    stepSize = range(bounds)/10;
end

chunk = 750; % trials to even out over
err = 15; % allow x% variance btw means

motivationThresh = 20;
motivationTrials = 50;

% try,
runIt = 1; attempts = 0;
while runIt
    attempts = attempts+1;
    
    [T1,T2,T3] = tryWalk(high,low);
    
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
        m3 = mean(T3(i:there));
        if m1 > m2+err || m1 < m2-err || m1 > m3+err || m1 < m3-err || m2 > m3+err || m2 < m3-err
            check = 0; % failed the check
            break;
        end
        
        fu = sum(and(and(T1(i:there)<=motivationThresh,...
                     T2(i:there)<=motivationThresh),...
                     T3(i:there)<=motivationThresh));
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
function [T1vals,T2vals,T3vals] = tryWalk(high,low)

% easier to operate on integer steps
low = low / 10; high = high / 10;

% seed randomly
% seedIn = [high-low]
T1seed = low + randperm([high-low],1);
T2seed = low + randperm([high-low],1);
T3seed = low + randperm([high-low],1);

[T1vals,T2vals,T3vals] = deal(NaN(1,ntrials));

% make a bunch of transition time points, dependant on hazard
T1transitions = binornd(ones(1,ntrials),hazard);
T2transitions = binornd(ones(1,ntrials),hazard);
T3transitions = binornd(ones(1,ntrials),hazard);

% make some of them negative
T1signs = binornd(ones(1,ntrials),.5);
T1transitions(and(T1transitions,T1signs)) = -1;
T2signs = binornd(ones(1,ntrials),.5);
T2transitions(and(T2transitions,T2signs)) = -1;
T3signs = binornd(ones(1,ntrials),.5);
T3transitions(and(T3transitions,T3signs)) = -1;

T1transitions = T1transitions*stepSize;
T2transitions = T2transitions*stepSize;
T3transitions = T3transitions*stepSize;

% the dreaded for loop
for i = 1:ntrials
    if T1seed+T1transitions(i) >= low && T1seed+T1transitions(i) <= high
        T1seed = T1seed+T1transitions(i);
    end
    if T2seed+T2transitions(i) >= low && T2seed+T2transitions(i) <= high
        T2seed = T2seed+T2transitions(i);
    end
    if T3seed+T3transitions(i) >= low && T3seed+T3transitions(i) <= high
        T3seed = T3seed+T3transitions(i);
    end
    T1vals(i) = T1seed;
    T2vals(i) = T2seed;
    T3vals(i) = T3seed;
end

T1vals = T1vals*10; T2vals = T2vals*10; T3vals = T3vals*10;


end

end