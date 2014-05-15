function [T1,T2,transitions] = generateBlockForBandit(hazard,ntrials,bounds,minTrials)
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

if nargin < 4
    minTrials = 10;
end

% try,
    [T1,T2,transitions] = tryWalk(high,low,minTrials);

% catch
%     keyboard();
% end

%%
function [T1vals,T2vals,transitions] = tryWalk(high,low,minTrials)

% easier to operate on integer steps
low = low / 10; high = high / 10;

% seed randomly
% seedIn = [high-low]
bounds = [high,low];
whichSeed = Shuffle([1,2]); %keyboard();
T1seed = bounds(whichSeed(1));
T2seed = bounds(whichSeed(2));

[T1vals,T2vals] = deal(NaN(1,ntrials));

% make a bunch of transition time points, dependant on hazard
transitions = binornd(ones(1,ntrials),hazard);
transitions(1) = 1; % set it to keep the first moment as a transition

ind = strfind(transitions,[1 1]); % repeats
if ~isempty(ind);
    for k = 1:length(ind)
        transitions(ind(k):ind(k)+1) = [1 0];
    end
end

for i = 1:minTrials
    fu = [1 zeros(1,i) 1];
    ind = strfind(transitions,fu);
    if ~isempty(ind)
        fu(end) = 0;
        for k = 1:length(ind)
            transitions(ind(k):ind(k)+i+1) = fu;
        end
    end
end


% the dreaded for loop
for i = 1:ntrials
    if transitions(i) == 1
        seeds = [T1seed T2seed];
        T1seed = seeds(2);
        T2seed = seeds(1);
    end
    T1vals(i) = T1seed;
    T2vals(i) = T2seed;
end

T1vals = T1vals*10; T2vals = T2vals*10;

end

end