function B = padshift(A, shift)
% This function "shifts" and image, A, by adding zeros to the image such
% that it is offset from the orginal location by the amount of shift (in
% both horizontal and vertical dimensions).

% First, pad the image so we can shift it with no effect on actual values
% spatial relationships. This padding wil aslo take care of half of the
% magnitdue of the shift
saize = [size(A, [1 2]) + round(abs(shift)/2), size(A, 3)];
B = imPad(A, saize);

% Now shift it circularly, but it will just move all zeros that we just
% added
B = circshift(B, round(shift/2));