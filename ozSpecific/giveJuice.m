function giveJuice(nJuice)

% giveJuice
global ioObj env

if nargin < 1
    nJuice = env.defaultRwdDrops;
end

for juice = 1:nJuice
    data_in = io32(ioObj, env.juicePort);
    base_data_out = bitset(data_in, env.rwdBit, 0);
    rew_data_out = bitset(data_in, env.rwdBit, 1);
    io32(ioObj, env.juicePort, rew_data_out);
    WaitSecs(env.rwdDuration/1000);
    io32(ioObj, env.juicePort, base_data_out);
    WaitSecs(env.rwdDelay/1000);
end

