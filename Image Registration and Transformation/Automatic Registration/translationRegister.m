function translation = translationRegister(A, B)
% This function will register B with A. It return a vector SHIFT that
% encodes the neccessary shift in [rows, cols] to maximize the cross
% correlation of the two arrays. 

center=size(A, [1 2])/2;

% Cross-correlation of images
transMap=fftshift(ifft2(fft2(A).*fft2(rot90(B, 2))));

% Determine location of maximum correlation
[r, c]=find(transMap == max(transMap, [], 'all'));

% Caclulate neccesary shift from max correaltion coordinates
translation=round([r, c]-center);
