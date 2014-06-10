function [T1,T2,T3,transitions] = generateBlockForBandit3(hazard,ntrials,values,minTrials)
% output 3 value vectors that match our requirements
% 1. transitions w/ a hazard rate == hazard
% 2. except = stays the same for at least minTrials

disp('making reward vectors');

if nargin < 2
    ntrials = 1000;
end

if nargin < 3
    % set the bounds on the walk/seed/etc
    values = [20 50 90];
end

if nargin < 4
    minTrials = 10;
end

% try,
    [T1,T2,T3,transitions] = tryWalk(values,minTrials);

% catch
%     keyboard();
% end

%%
function [T1vals,T2vals,T3vals,transitions] = tryWalk(values,minTrials)

% easier to operate on integer steps
bounds = values / 10;

% seed randomly
whichSeed = Shuffle([1,2,3]); %keyboard();
T1seed = bounds(whichSeed(1));
T2seed = bounds(whichSeed(2));
T3seed = bounds(whichSeed(3));

[T1vals,T2vals,T3vals] = deal(NaN(1,ntrials));

% make a bunch of transition time points, dependant on hazard
transitions = binornd(ones(1,ntrials),hazard);
transitions(1) = 1; % set it to keep the first moment as a transition

ind = strfind(transitions,[1 1]); % repeats
if ~isempty(ind);
    for k = 1:length(ind)
        transitions(ind(k):ind(k)+1) = [1 0];
    end
end

cleanUp = 1;
while cleanUp
    clean = 1;
    for i = 1:minTrials
        fu = [1 zeros(1,i) 1];
        ind = strfind(transitions,fu);
        if ~isempty(ind)
            fu(end) = 0;
            for k = 1:length(ind)
                transitions(ind(k):ind(k)+i+1) = fu;
            end
            clean = 0;
        end
    end
    if clean; cleanUp = 0; break; end
end

% the dreaded for loop
for i = 1:ntrials
    if transitions(i) == 1
        seeds = Shuffle([T1seed T2seed T3seed]);
        T1seed = seeds(1);
        T2seed = seeds(2);
        T3seed = seeds(3);
    end
    T1vals(i) = T1seed;
    T2vals(i) = T2seed;
    T3vals(i) = T3seed;
end

T1vals = T1vals*10; T2vals = T2vals*10; T3vals = T3vals*10;

end

end