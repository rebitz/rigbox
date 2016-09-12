function colors = pickColors(nColors)
% colors = pickColors(nColors)
%   grab some perceptually uniform and perceptually isoluminant colors

if nargin < 1
    nColors = 20; % to spit out
end

nColorSamples = 1000; % for creating the distribution
lum = 65; % range = 0 to 100
ecc = 35;

% samples around a circle: clunky legacy way of doing this
colorStep = (2*pi)/nColorSamples;
colorStart = rand * 2*pi;
[a,b,labAngles,labEccs] = deal(NaN(nColorSamples,1));
for i = 1:nColorSamples;
    [a(i),b(i)] = pol2cart(colorStart,ecc);
    labAngles(i) = colorStart;
    colorStart = colorStart+colorStep; % update angular distance
end

% apply some kind of matrix transform:
transformMx = eye(2,2);
% transformMx(1,2) = -.5; transformMx(2,1) = -.2; % sheer
% transformMx(1,1) = 1.1; transformMx(2,2) = 1.25; % stretch
shiftMx = [0,0];%[20,15];
tmp = [a,b]*transformMx + repmat(shiftMx,length(a),1);
a = tmp(:,1); b = tmp(:,2);
for i = 1:nColorSamples;
    [labAngles(i),labEccs(i)] = cart2pol(a(i),b(i));
end

L = repmat(lum,size(a));
[R,G,B] = Lab2RGB(L,a,b);
colors = NaN(nColorSamples,3);
for i = 1:nColorSamples
    colors(i,:) = [R(i),G(i),B(i)];
end

%PLOTZ:   
%figure('Position',[440   304   824   494]);
%subplot(1,3,1:2); axis square; hold on;
%
%for i = 1:nColorSamples;
%    plot(a(i),b(i),'.','Color',colors(i,:),'MarkerSize',100);
%end
%
%set(gca,'Color',[.5 .5 .5])
%xlim([-100 100]); ylim([-100 100]);

% check to see if this is perceptually uniform:
% subplot(1,3,3); hold on;
distances = NaN(nColorSamples-1,1);
for i = 1:nColorSamples-1
    distances(i) = cie00de([L(i),a(i),b(i)],[L(i+1),a(i+1),b(i+1)]);
%     plot(labAngles(i),1,'.','Color',colors(i,:),'MarkerSize',100);
end

distances(end+1) = cie00de([L(end),a(end),b(end)],[L(1),a(1),b(1)]);
% plot(labAngles(i+1),1,'.','Color',colors(i+1,:),'MarkerSize',100);
% plot(labAngles,distances); % should be a flat line
% plot(labAngles,cumsum(distances)/max(cumsum(distances)));
% xlim([min(labAngles) max(labAngles)]);

% express as a fraction fo distances
distances = (distances)./(sum(distances)); % as a frac of all distances

% now that we know how much of a perceptual jump exists for each angle, we
% can resample this distribution in a perceptually uniform way:
samplingDist = (cumsum(distances)-min(cumsum(distances)));
samplingDist = samplingDist ./ max(samplingDist);

nSamples = 50000;
sampledAngles = NaN(nSamples,1);
for i = 1:nSamples;
    sampledAngles(i) = find(rand < samplingDist,1,'first');
end

% edges = 1:10:nColorSamples;
% h = bar(labAngles(edges),hist(sampledAngles,edges)/800,'hist');
% set(h,'FaceColor',[.5 .5 .5])
% plot(labAngles(round(quantile(sampledAngles,[0:1/(20-1):1]))),ones(20,1),'.k');

% now find the colors that correspond to this resampling

% figure('Position',[440   304   524   494]);
% axis square; hold on;

edges = [0:((2*pi)/(nColors))/(2*pi):((2*pi)/(nColors))/(2*pi)*(nColors-1)];
seedIndx = round(quantile(sampledAngles,edges));
colorAngles = labAngles(seedIndx);
colorEccentricity = labEccs(seedIndx);

[a,b] = deal(NaN(length(colorAngles),1));
for i = 1:length(colorAngles);
    [a(i),b(i)] = pol2cart(colorAngles(i),colorEccentricity(i));
end
L = repmat(lum,size(a)); % same luminance for each

[R,G,B] = Lab2RGB(L,a,b);

colorStep = (2*pi)/nColors; colorStart = 0;

colors = NaN(nColors,3);
for i = 1:nColors
    colors(i,:) = [R(i),G(i),B(i)];
    
%     [x,y] = pol2cart(colorStart,ecc);
%     plot(x,y,'.','Color',colors(i,:),'MarkerSize',ecc*4);
%     colorStart = colorStart+colorStep;
end

% set(gca,'Color',[.5 .5 .5])
% xlim([-ecc-10 ecc+10]); ylim([-ecc-10 ecc+10]);

end

%% some requisite subfunctions:
function [R, G, B] = Lab2RGB(L, a, b)
%LAB2RGB Convert an image from CIELAB to RGB
%
% function [R, G, B] = Lab2RGB(L, a, b)
% function [R, G, B] = Lab2RGB(I)
% function I = Lab2RGB(...)
%
% Lab2RGB takes L, a, and b double matrices, or an M x N x 3 double
% image, and returns an image in the RGB color space.  Values for L are in
% the range [0,100] while a* and b* are roughly in the range [-110,110].
% If 3 outputs are specified, the values will be returned as doubles in the
% range [0,1], otherwise the values will be uint8s in the range [0,255].
%
% This transform is based on ITU-R Recommendation BT.709 using the D65
% white point reference. The error in transforming RGB -> Lab -> RGB is
% approximately 10^-5.  
%
% See also RGB2LAB. 

% By Mark Ruzon from C code by Yossi Rubner, 23 September 1997.
% Updated for MATLAB 5 28 January 1998.
% Fixed a bug in conversion back to uint8 9 September 1999.
% Updated for MATLAB 7 30 March 2009.

if nargin == 1
  b = L(:,:,3);
  a = L(:,:,2);
  L = L(:,:,1);
end

% Thresholds
T1 = 0.008856;
T2 = 0.206893;

[M, N] = size(L);
s = M * N;
L = reshape(L, 1, s);
a = reshape(a, 1, s);
b = reshape(b, 1, s);

% Compute Y
fY = ((L + 16) / 116) .^ 3;
YT = fY > T1;
fY = (~YT) .* (L / 903.3) + YT .* fY;
Y = fY;

% Alter fY slightly for further calculations
fY = YT .* (fY .^ (1/3)) + (~YT) .* (7.787 .* fY + 16/116);

% Compute X
fX = a / 500 + fY;
XT = fX > T2;
X = (XT .* (fX .^ 3) + (~XT) .* ((fX - 16/116) / 7.787));

% Compute Z
fZ = fY - b / 200;
ZT = fZ > T2;
Z = (ZT .* (fZ .^ 3) + (~ZT) .* ((fZ - 16/116) / 7.787));

% Normalize for D65 white point
X = X * 0.950456;
Z = Z * 1.088754;

% XYZ to RGB
MAT = [ 3.240479 -1.537150 -0.498535;
       -0.969256  1.875992  0.041556;
        0.055648 -0.204043  1.057311];

RGB = max(min(MAT * [X; Y; Z], 1), 0);

R = reshape(RGB(1,:), M, N);
G = reshape(RGB(2,:), M, N);
B = reshape(RGB(3,:), M, N); 

if nargout < 2
  R = uint8(round(cat(3,R,G,B) * 255));
end

end

function de00 = cie00de(Labstd,Labsample, KLCH)
%function de00 = deltaE2000(Labstd,Labsample, KLCH )
% Compute the CIEDE2000 color-difference between the sample between a reference
% with CIELab coordinates Labsample and a standard with CIELab coordinates 
% Labstd
% The function works on multiple standard and sample vectors too
% provided Labstd and Labsample are K x 3 matrices with samples and 
% standard specification in corresponding rows of Labstd and Labsample
% The optional argument KLCH is a 1x3 vector containing the
% the value of the parametric weighting factors kL, kC, and kH
% these default to 1 if KLCH is not specified.

% Based on the article:
% "The CIEDE2000 Color-Difference Formula: Implementation Notes, 
% Supplementary Test Data, and Mathematical Observations,", G. Sharma, 
% W. Wu, E. N. Dalal, submitted to Color Research and Application, 
% January 2004.
% available at http://www.ece.rochester.edu/~/gsharma/ciede2000/

de00 = [];

% Error checking to ensure that sample and Std vectors are of correct sizes
v=size(Labstd); w = size(Labsample);
if ( v(1) ~= w(1) | v(2) ~= w(2) )
  disp('deltaE00: Standard and Sample sizes do not match');
  return
end % if ( v(1) ~= w(1) | v(2) ~= w(2) )
if ( v(2) ~= 3) 
  disp('deltaE00: Standard and Sample Lab vectors should be Kx3  vectors'); 
  return
end 

% Parametric factors 
if (nargin <3 ) 
     % Values of Parametric factors not specified use defaults
     kl = 1; kc=1; kh =1;
else
     % Use specified Values of Parametric factors
     if ( (size(KLCH,1) ~=1) | (size(KLCH,2) ~=3))
       disp('deltaE00: KLCH must be a 1x3  vector');
       return;
    else
       kl =KLCH(1); kc=KLCH(2); kh =KLCH(3);
     end
end

Lstd = Labstd(:,1)';
astd = Labstd(:,2)';
bstd = Labstd(:,3)';
Cabstd = sqrt(astd.^2+bstd.^2);

Lsample = Labsample(:,1)';
asample = Labsample(:,2)';
bsample = Labsample(:,3)';
Cabsample = sqrt(asample.^2+bsample.^2);
 
Cabarithmean = (Cabstd + Cabsample)/2;

G = 0.5* ( 1 - sqrt( (Cabarithmean.^7)./(Cabarithmean.^7 + 25^7)));

apstd = (1+G).*astd; % aprime in paper
apsample = (1+G).*asample; % aprime in paper
Cpsample = sqrt(apsample.^2+bsample.^2);
Cpstd = sqrt(apstd.^2+bstd.^2);
% Compute product of chromas and locations at which it is zero for use later
Cpprod = (Cpsample.*Cpstd);
zcidx = find(Cpprod == 0);


% Ensure hue is between 0 and 2pi
% NOTE: MATLAB already defines atan2(0,0) as zero but explicitly set it
% just in case future definitions change
hpstd = atan2(bstd,apstd);
hpstd = hpstd+2*pi*(hpstd < 0);  % rollover ones that come -ve
hpstd(find( (abs(apstd)+abs(bstd))== 0) ) = 0;
hpsample = atan2(bsample,apsample);
hpsample = hpsample+2*pi*(hpsample < 0);
hpsample(find( (abs(apsample)+abs(bsample))==0) ) = 0;

dL = (Lsample-Lstd);
dC = (Cpsample-Cpstd);
% Computation of hue difference
dhp = (hpsample-hpstd);
dhp = dhp - 2*pi* (dhp > pi );
dhp = dhp + 2*pi* (dhp < (-pi) );
% set chroma difference to zero if the product of chromas is zero
dhp(zcidx ) = 0;

% Note that the defining equations actually need
% signed Hue and chroma differences which is different
% from prior color difference formulae

dH = 2*sqrt(Cpprod).*sin(dhp/2);
%dH2 = 4*Cpprod.*(sin(dhp/2)).^2;

% weighting functions
Lp = (Lsample+Lstd)/2;
Cp = (Cpstd+Cpsample)/2;
% Average Hue Computation
% This is equivalent to that in the paper but simpler programmatically.
% Note average hue is computed in radians and converted to degrees only 
% where needed
hp = (hpstd+hpsample)/2;
% Identify positions for which abs hue diff exceeds 180 degrees 
hp = hp - ( abs(hpstd-hpsample)  > pi ) *pi;
% rollover ones that come -ve
hp = hp+ (hp < 0) *2*pi;
% Check if one of the chroma values is zero, in which case set 
% mean hue to the sum which is equivalent to other value
hp(zcidx) = hpsample(zcidx)+hpstd(zcidx);

Lpm502 = (Lp-50).^2;
Sl = 1 + 0.015*Lpm502./sqrt(20+Lpm502);  
Sc = 1+0.045*Cp;
T = 1 - 0.17*cos(hp - pi/6 ) + 0.24*cos(2*hp) + 0.32*cos(3*hp+pi/30) ...
    -0.20*cos(4*hp-63*pi/180);
Sh = 1 + 0.015*Cp.*T;
delthetarad = (30*pi/180)*exp(- ( (180/pi*hp-275)/25).^2);
Rc =  2*sqrt((Cp.^7)./(Cp.^7 + 25^7));
RT =  - sin(2*delthetarad).*Rc;

klSl = kl*Sl;
kcSc = kc*Sc;
khSh = kh*Sh;

% The CIE 00 color difference
de00 = sqrt( (dL./klSl).^2 + (dC./kcSc).^2 + (dH./khSh).^2 + RT.*(dC./kcSc).*(dH./khSh) );

end
