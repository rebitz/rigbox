function probs = convertProb(input,nVect)
% generates a vector of 1s & 0s where frequency of 1s corresponds to the input
%   probability, and the 1s are randomly interleaved into the vector
% defaults to a 100 element output vector, but takes optional input nVect to alter
%   the length of the output vector
%
% probs = convertProb(0.8) generates a 100 element vector that is 80% ones
% probs = convertProb(80, 200) generates a 200 element vector that is 80% ones

if  input > 100 || input < 0
    error('invalid input arguments')
end

if input > 1
    input = input / 100;
end

if nargin < 2
    nVect = 100;
end

flagged = 0;
if nVect == 1;
    flagged = 1;
    nVect = 100;
end

% make a vector that's the right size
probs = zeros(nVect,1);

% generate rand indices
list = [1:nVect]; list = Shuffle(list);
idx = list([1:round(nVect*input)]);

% set indicated elements to 1
probs(idx) = 1;
probs = logical(probs);

if flagged
    probs = probs(1);
end

end