function BTransformed = imageTransformer(B, transforms)

opts = fields(transforms);

% Work through all opts by priority of transform (scale>rotate>translate)
if any(contains(opts, 'Scale'))
    B = imresize(B, transforms.Scale);
end

if any(contains(opts, 'Rotation'))
    B = imrotate(B, transforms.Rotation, 'crop');
end

if any(contains(opts, 'Translation'))
    B = circshift(B, transforms.Translation);
end

if any(contains(opts, 'PadSize'))
    B = impad(B, transforms.PadSize, 'noCrop');
end

BTransformed = B;