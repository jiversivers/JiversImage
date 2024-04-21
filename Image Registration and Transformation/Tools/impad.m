function paddedImage = impad(img, saize, croption)

if nargin == 2
    croption = 'noCrop';
end

p = inputParser;
validSize = @(x) isnumeric(x) && ismatrix(x) && (numel(x) == ndims(img) || (numel(x)-1 == ndims(img) && x(end)==1) || (numel(x) < ndims(img)));
validCroption = @(x) strcmpi(x, 'noCrop') || strcmpi(x, 'crop');
addRequired(p, 'image')
addRequired(p, 'size', validSize)
addRequired(p, 'cropOption', validCroption);
parse(p, img, saize, croption);

% Add trivial padding dims to size until it is the apprpriate number of
% dims
while ndims(img) > numel(saize) == 1
    saize = [saize size(img, ndims(img))];
end

% Remove singleton dims
while saize(end) == 1
    saize = saize(1:end-1);
end

% Use max dimsenion (no cropping, only pad)
d = max([size(img); saize]);

% Create array to add final image to
paddedImage = zeros(d, class(img));

switch lower(p.Results.cropOption)
    case 'nocrop'
        fd = [0 0 0];
    case 'crop'
        fd = round((size(paddedImage) - saize)/2);
end

if ndims(img) == numel(saize)

    % Determine ofset from each edge
    ofs = floor((d - size(img))/2);
    if ndims(img) == 3
        paddedImage(1+ofs(1):size(img,1)+ofs(1), 1+ofs(2):size(img,2)+ofs(2), 1+ofs(3):size(img,3)+ofs(3)) = img;
        % Handle croption
        paddedImage = paddedImage(fd(1)+1:end-fd(1), fd(2)+1:end-fd(2), fd(3)+1:end-fd(3));
    elseif ismatrix(img)
        paddedImage(1+ofs(1):size(img,1)+ofs(1), 1+ofs(2):size(img,2)+ofs(2)) = img;
        % Handle croption
        paddedImage = paddedImage(fd(1)+1:end-fd(1), fd(2)+1:end-fd(2));
    end

else
    error('Image dimensions and size do not match.')
end