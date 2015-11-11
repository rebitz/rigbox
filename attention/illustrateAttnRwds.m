% load up the current variables
attention_params;

% rwdStd = pi/10
% minRwd = 0.1
% maxRwd = 0.9

rwdSeed = mean(orientationBounds);
theseOrientations = [orientationBounds(1):1:orientationBounds(2)];

% now the probability for choosing each target
radSeed = (rwdSeed/(range(orientationBounds)/2))*pi;
radOrientations = (theseOrientations/(range(orientationBounds)/2))*pi;
angDist = abs(mod((radSeed-radOrientations) + pi, pi*2) - pi);
theseRwds = (maxRwd-minRwd)*exp(-((angDist.^2)/(2*rwdStd.^2)))+minRwd;

figure(); 
plot(theseOrientations,theseRwds);
ylim([0 1])