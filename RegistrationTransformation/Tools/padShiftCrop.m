function [Ac, Bc] = padShiftCrop(A, B, shift)
% This function performs the specified SHIFT on B, then pads A
% approprialetly to align the images, and finally crops out the parts of
% the pair that are not in overlapping space. SHIFT is a vector specifying
% the numer of rows and columns (respectively) to move B.

cSize = ceil(size(B, [1 2]) - abs(shift));
BcCenter = ceil((size(B, [1 2]) - shift)/2);
AcCenter = ceil((size(A, [1 2]) + shift)/2);
Bc = B(floor(1+BcCenter(1)-cSize(1)/2):floor(BcCenter(1)+cSize(1)/2), floor(1+BcCenter(2)-cSize(2)/2):floor(BcCenter(2)+cSize(2)/2), :);
Ac = A(floor(1+AcCenter(1)-cSize(1)/2):floor(AcCenter(1)+cSize(1)/2), floor(1+AcCenter(2)-cSize(2)/2):floor(AcCenter(2)+cSize(2)/2), :);

