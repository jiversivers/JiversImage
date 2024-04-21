%% Image Getter
% This function is a very simple function to clean up code from needing
% multiple directory changes or long image path calls. It simply moves into
% a directory to get the specified image and reads it in as a double, then
% returns to the start directory. The syntax for calling this function is
% as follows: image = imget(folder,channel) where folder is the folder holding all thhe
% images and channel is the number or numbers of the channels you want. 1-4
% corresponding to RGB and UV respectively. If no channel is specified, all
% available will be returned.

function imout = imget(imin, channel, typeFlag)

if ~exist('channel', 'var') || isempty(channel)
    channel = 1:numel(dir([imin, filesep, '*Ch*']));
end

if ~exist('typeFlag', 'var')
    typeFlag = '-fov';
end

% Prepare empty array to add image data into
imname = arrayfun(@(x) dir([imin, filesep, '*Ch', num2str(x),'*']).name, channel, 'UniformOutput', false);
iminfo = imfinfo([imin filesep imname{1}]);
imout = zeros(iminfo.Height, iminfo.Width, numel(channel));

if strcmp(typeFlag, '-fov')
    for ii = 1:numel(channel)
        imout(:,:,ii) = imread([imin filesep imname{ii}]);
    end

elseif strcmp(typeFlag, '-atlas')
    % Find out how many images there are
    imgCount = numel(dir([imin, filesep, '*Ch1*']));

    % List all their base names
    files = cell(imgCount, numel(channel));
    for n = 1:imgCount
        for ii = 1:numel(channel)
            ch = channel(ii);
            names = {dir([imin, filesep, '*Ch', num2str(ch), '*']).name};
            files{n,ch} = names{n};
        end
    end

    % Preallocate array size based on image size
    imout = zeros([size(imread([imin, filesep, files{1}])), numel(channel), imgCount]);

    % Load each channel of each image (M*N*C*imgCount)
    for n = 1:imgCount
        for ii = 1:numel(channel)
            ch = channel(ii);
            imout(:,:,ch,n) = imread([imin, filesep, files{n, ch}]);
        end
    end
else
    error(['Unrecognized type flag: ', typeFlag])
end