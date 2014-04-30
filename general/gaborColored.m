function im3 = gaborColored(vhSize, colors, cyclesPer100Pix,orientation, phase, sigma , mean, amplitude)
% draw  gabor patch
% im = gabor(vhSize, cyclesPer100Pix, phase, sigma , mean, amplitude, orientation)
% vhSize: size of pattern, [vSize hSize]
% colors: [r, g, b], expressed in % of full color
% cyclesPer100Pix: cycles per 100 pixels
% phase: phase of grating in degree
% sigma: sigma of gaussian envelope
% mean: mean color value
% amplitude: amplitude of color value
% orientation: orientation of grating, 0 -> horizontal, 90 -> vertical
%
% (c) Yukiyasu Kamitani
%
% eg >>imshow(gabor([100 100], 8, 45, 0, 6 , 0.5, 0.5))

r = colors(1);
g = colors(2);
b = colors(3);

orientation = - orientation + 90;
X = ones(vhSize(1),1)*[-(vhSize(2)-1)/2:1:(vhSize(2)-1)/2];
Y =[-(vhSize(1)-1)/2:1:(vhSize(1)-1)/2]' * ones(1,vhSize(2));

CosIm =  cos(2.*pi.*(cyclesPer100Pix/100).* (cos(deg2rad(orientation)).*X ...
										  + sin(deg2rad(orientation)).*Y)  ...
						                  - deg2rad(phase)*ones(vhSize) );

CosIm = cat(3,CosIm*r,CosIm*g,CosIm*b);
             
% keyboard();

G = fspecial('gaussian', vhSize, sigma); 
G = G ./ (max(max(G))*(ones(vhSize))); 	% make the max 1
G = cat(3,G,G,G);
bit = mean*ones(vhSize);
middlebit = cat(3,bit,bit,bit);
im = amplitude *  G .* CosIm + middlebit;

% keyboard();
% im = (im-min(min(min(im))))./(max(max(max(im)))-min(min(min(im))));

im(find(abs(im-mean) < amplitude/64)) = mean;  % remove 1-grayscale error 64->
   
im3 = im;

function out = deg2rad(in)
    out = in * (pi/180);
end

end
