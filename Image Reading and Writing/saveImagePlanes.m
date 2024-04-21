function saveImagePlanes(imageStack, savename, varargin)
if ~exist(savename, 'dir')
    mkdir(savename)
end

baseName = strsplit(savename, filesep);
baseName = baseName{end};

% Future update to add options to support saving RGBs and for saving each
% channel seperately. As it is, one option is commented out.
p = inputParser;

dims = ndims(imageStack);
idx = cell(1, dims-1);
idx(:) = {':'};

% This saves RGB if multichannel or grayscales if only one channel.
for N = 1:size(imageStack, dims)
    imName = [savename filesep baseName '_Cycle' num2str(N, '%05.f') '.tiff'];
    TiffSingleWrite(imageStack(idx{:}, N), imName, varargin{:})
end

% This saves each channel seperately (both options work identically if
% image only has one channel, assuming they are still of the dimensions
% YXCN, if a grayscale image is squeezed, each plane will be saved multiple
% times (as many as times as there are seperate planes) in the current
% code. Adding an unsqeeze for the third dimension solves this.
% for ch = 1:size(imageStack, 3)
%     for N = 1:size(imageStack, dims)
%         imName = [savename filesep baseName '_Cycle' num2str(N, '%05.f') '_Ch' num2str(ch) '.tiff'];
%         TiffSingleWrite(imageStack(:,:,ch,N), imName)
%     end
% end