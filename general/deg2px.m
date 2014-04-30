function pixels = deg2px(degrees,env)

rads = deg2rad(degrees);

stimCm = tan(rads)*env.distance;
convF = env.width./env.physicalWidth;
pixels = stimCm * convF;


