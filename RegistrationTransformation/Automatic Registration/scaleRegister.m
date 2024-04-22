function scale = scaleRegister(A, B)

% Use bounding box positions to get a starting point for scale
Abp = regionprops(A, 'BoundingBox').BoundingBox;
Bbp = regionprops(B, 'BoundingBox').BoundingBox;
Bbscale(1) = Abp(3)/Bbp(3); % Ratio by length
Bbscale(2) = Abp(4)/Bbp(4); % Rato by width
Bbscale(3) = sqrt(prod(Bbscale)); % Ratio by area

% focus on bounding box area
A = imcrop(A, Abp);
B = imcrop(B, Bbp);

% Resize and test to determine best ratio to use
R = zeros(1,3);
for ii = 1:3
    % Always scale down to avoid having to upsample and introduce artifacts
    if Bbscale(ii) > 1
        Ar = imresize(A, 1/Bbscale(ii), 'bicubic');
        Br = B;
    else
        Ar = A;
        Br = imresize(B, Bbscale(ii), 'bicubic');
    end

    % Test (but only consider the region within the Bounding Box)
    size2pad = max([size(Ar); size(Br)]);
    Ar = impad(Ar, size2pad, 'noCrop');
    Br = impad(Br, size2pad, 'noCrop');
    R(ii) = corr2(Ar, Br);
end

% Select best result
scale = Bbscale(R == max(R));