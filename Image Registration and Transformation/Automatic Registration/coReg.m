function [BTransformed, transformations, R] = coReg(A, B, varargin)

validFlags = {'-sca', '-rot', '-tra', '-skew'};
transformations = struct();

switch nargin
    case 2
        opts = validFlags;
    otherwise
        opts = varargin(:);
end

% Work through all opts by priority of transform (scale>rotate>translate)
if any(contains(opts, '-sca'))
    BScale = scaleRegister(A, B);
    B = imresize(B, 1/BScale);
    transformations.Scale = BScale;
end

if any(contains(opts, '-rot'))
    BRotate = rotationRegister(A, B);
    B = imrotate(B, BRotate, 'crop');
    transformations.Rotation = BRotate;
end

if any(contains(opts, '-tra'))
    size2pad = max(cell2mat(cellfun(@size, {A; B}, 'UniformOutput', false)));
    transformations.PadSize = size2pad;
    A = impad(A, size2pad, 'noCrop');
    B = impad(B, size2pad, 'noCrop');
    BShift = translationRegister(A, B);
    B = circshift(B, BShift);
    transformations.Translation = BShift;
end

if any(contains(opts, '-skew'))
    warning('Skew transform not available. It will be released in coming update.')
end

isInvalid = cellfun(@(x) ~contains(x, validFlags), opts);
if any(isInvalid)
    warning(['Unrecognized options: ', opts{isInvalid}])
end

BTransformed = B;

% Score transformation
R = corr2(A, B);
end