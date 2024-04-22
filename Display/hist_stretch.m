function [B] = hist_stretch(A, dark, sat, bitDepth)

% This function will automatically enhance the contrast of a grayscale or 
% single-channel image, A, such that approximately 'dark' percent of pixels
% are at 0 and 'sat' percent of pixels are saturated.

% Determine dynamic range from input or default value (16-bit)
if ~exist('bitDepth', 'var')
    bitDepth = 16;
end

dynamicRange = (2^bitDepth) - 1;

% Normalize image and scale by 255.
A=(A/max(max(A)))*dynamicRange;

% Determining upper and lower bounds of contrast-enhanced image range
% Finding intensity that 'sat'% of pixels are above for upper limit

hi=max(A,[],'all');                                 % Begins checking pixel counts at max intensity value of the image.
p_hi=0;
while p_hi<(sat/100)*(size(A,1)*size(A,2))          % Loops until the number of pixels above intensity value is sat% of pixel total
    p_hi=size(find(A>=hi),1);
    hi=hi-1;
end

% Finiding intensity that 'dark'% of pixels are below for lower limit
lo=min(A,[],'all');                                 % Begins checking pixel count at min intensity value of the image
p_lo=0;
while p_lo<(dark/100)*(size(A,1)*size(A,2))         % Loops until the number of pixels above intensity value is dark% of pixel total
    p_lo=size(find(A<=lo),1);
    lo=lo+1;
end


% Using limits to strech histogram 
B=(A-lo).*(dynamicRange/(hi-lo));

% Bringing saturated pixels to max of the dynamic range and dark pixels to 0.
B=(B>=0).*B+(B<0).*0;
B=(B<=dynamicRange).*B+(B>dynamicRange).*dynamicRange;

end