% MIB3_params.m
% Initialize the parameters for vMIB task

MIB_generalParams; % shared with MIBreplay

% Number of trials
ntrials = 200;

p_probe = 0.8; % p(forced choice trial

% Directory of where the data will be saved to
global gitDir
if IsOSX
    splitChar = '/';
else
    splitChar = '\';
end
dataDirectory = strcat(gitDir,splitChar,'MIB3',splitChar,'data');

% % Target colors
% color1 = [2/3 4/9 0];
% color2 = [1/9 5/9 7/9];
% color3 = [7/9 1/3 8/9];
% colors = [color1; color2; color3];

% Reward parameters
walkRewards = 1; % else just deliver at lower and upper bounds
rwdLB = 10; % lower bound, if ~walkRewards, just assigns to these
rwdUB = 90; % % upper bound
hazard = 0.10; % p(step), size fixed at 10%
if ~walkRewards
    hazard = 0.02; % works well for the block style
end
nToGen = 2000; % length of vector to generate
minContinuousValues = 100; % n trials w/ no switches in block version

% Lower and upper bounds on reward contingencies
rwd1 = 20;
rwd2 = 50;
rwd3 = 80;
rwds = [rwd1 rwd2 rwd3];

% Probability of target moving location
p_move = .2;