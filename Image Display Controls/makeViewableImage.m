function vim = makeViewableImage(imarray, channels)
if exist('channels', 'var')
    temparray = zeros([size(imarray, [1 2]), numel(channels)]);
    for ii = 1:numel(channels)
        if channels(ii)~=0
            temparray(:,:,ii) = imarray(:,:,channels(ii));
        end
    end
    imarray = temparray;
    clear temparray
end

% Create a nice viewable image (mean intensity at 75% bitdepth)
if ~(isa(imarray, 'double') || isa(imarray, 'single'))
    vim = double(imarray/mean(imarray, 'all', 'omitnan'))/(0.75*log2(double(intmax(class(imarray)))));
else
    vim = (imarray/(mean(imarray, 'all', 'omitnan')))/6;
end