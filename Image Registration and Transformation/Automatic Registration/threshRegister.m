function varargout = threshRegister(varargin)

% This function registers two images based on a binary threshhold of a
% grayscale for each image. The threshold level is set as the mean of all
% non-zero pixels. A median filter is applied afterward to filter out S&P
% noise from background low SNR regions. The thresholded images are then
% registered using COREG, which is based on image cross-correlation.
% Available transformation types can be included as option flags or, by
% default, all available will be used.
%
% The output will be a single image stack cotaining the registered images
% (the fixed image will stay in the first index(indicies), but now will be
% stacked as a single array (as images will now be padded to match size).
% Additionally, the second out argument is the transformation structure
% applied to form the registered stack.

% Parse input and prep output
assert(nargin>=3, 'Invalid number of arguments. Must input 2 image arrays and registration transform type(s).')
assert(all(cellfun(@ndims, varargin(1:2)) > 1), 'Invalid input. First two arguments should be fixed and moving image, respectively.')
tempims = varargin(1:2);
opts = varargin(3:end);
varargout = cell(1, 3);

%%%%%%%%%%%%%%
% Preprocess %
%%%%%%%%%%%%%%
% Grayscale, threshhold, and medfilt
tempims = cellfun(@imPrep, tempims, 'UniformOutput', false);

% Make images the same size
size2pad = max(cell2mat(cellfun(@size, tempims', 'UniformOutput', false)));
tempims = cellfun(@(x) impad(x, size2pad, 'noCrop'), tempims, 'UniformOutput', false);

%%%%%%%%%%%%%%%%
% Registration %
%%%%%%%%%%%%%%%%
% Calculate optimal transformations
[~, varargout{2:3}] = coReg(tempims{:}, opts{:});
B = imageTransformer(varargin{2}, varargout{2});

% Recalculate size in case it changed
size2pad = max(cell2mat(cellfun(@size, tempims', 'UniformOutput', false)));
varargout{2}.PadSize = size2pad; % overwrite

% Apply transforms to moving image (2) and pad fixed (1) to match size
varargout{1} = cat(3, impad(varargin{1}, varargout{2}.PadSize, 'noCrop'), B);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pre-process function %%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function preppedIm = imPrep(im)
% Grayscale
preppedIm = mean(im, 3);

% Normalize
preppedIm = preppedIm/(max(preppedIm, [], 'all'));

% Threshold above non-0 background.
preppedIm = preppedIm>mean(preppedIm(preppedIm>0));

% Filter out S&P noise
preppedIm = double(medfilt2(preppedIm, [15 15]));
end