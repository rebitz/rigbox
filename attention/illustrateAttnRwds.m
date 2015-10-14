% load up the current variables
attention_params;

% rwdStd = pi/20


rwdSeed = mean(orientationBounds);
theseOrientations = [orientationBounds(1):1:orientationBounds(2)];

radSeed = (rwdSeed/180)*pi;
radOrientations = (theseOrientations/180)*pi;
angDist = abs(mod((radSeed-radOrientations) + pi, pi*2) - pi);
theseRwds = rwdScale*exp(-((angDist.^2)/(2*rwdStd.^2)));

figure(); 
plot(theseOrientations,theseRwds);