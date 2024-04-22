function img = loadStitchStack(stackPath, channel)

if ~exist('channel', 'var')
    channel = 1:numel(dir([stackPath filesep 'img_t1_z1_c*']));
end

% Prepare empty array to add image data into
imname =  arrayfun(@(x) dir([stackPath filesep 'img_t1_z1_c' num2str(x) '*']).name, channel, 'UniformOutput', false);
iminfo = imfinfo([stackPath filesep imname{1}]);
img = zeros(iminfo.Height, iminfo.Width, numel(channel));

for c = 1:numel(channel)
    img(:,:,channel(c)) = imread([stackPath filesep imname{c}]);
end