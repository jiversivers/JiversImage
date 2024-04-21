function varargout = createColorORRMap(varargin)
% [coloredORR,cmap] = createColorORRMap(ORRMap,IntensityMap)
% returns a jet colormapped RGB composite (coloredORR) and colormap used (cmap) of the optical redox
% ratio map (ORRMap), with the brightness adjusted based on IntensityMap.
%
% ___ = createColorORRMap(___,Name,Value) 
% allows for more customization of the colored composite image. (See
% documentation for more info).
%
% Created by: Alan Woessner (aewoessn@gmail.com) 1/29/2022
%
% Maintained by: Kyle Quinn (kpquinn@uark.edu)
%                Quantitative Tissue Diagnostics Laboratory (Quinn Lab)
%                University of Arkansas   
%                Fayetteville, AR 72701

%--- Input Parser ---%

% Check that at least two inputs are present
if nargin < 2
    error('Error: Less than two inputs were used.');
end

% Required Inputs: ORRMap, IntensityMap
orr = varargin{1};
int = single(varargin{2});

% Create default values
opts.redoxMin = 0;
opts.redoxMax = 1;
opts.redoxInt = 0.005;
opts.intMinPercentile = 0.05;
opts.intMaxPercentile = 0.95;

% Parse inputs 
for i = 3:2:length(varargin)
    if isfield(opts,varargin{i})
        opts.(varargin{i}) = varargin{i+1};
    else
        warning([varargin{i},' is not a valid name/value pair. Please check the documentation for more info.']);
    end
end

% Generate nice looking colormap. The jet colormap used cuts off the ends
% of the jet colormap where the "value" (from h/s/v) is ~= 1. This is done
% by expanding a jet colormap at known values.
cmapLength = length((opts.redoxMin:opts.redoxInt:opts.redoxMax));
cmapJet = jet(100);
cmapJet = cmapJet(13:88,:);
for i = 1:3
    cmap(:,i) = interp1((1:length(cmapJet)),cmapJet(:,i),linspace(1,length(cmapJet),cmapLength));
end

% Use histcounts to bin each pixel based on the interval
[~,~,index] = histcounts(orr,(opts.redoxMin:opts.redoxInt:opts.redoxMax));
index(orr>opts.redoxMax) = length((opts.redoxMin:opts.redoxInt:opts.redoxMax))-1;
index(orr<opts.redoxMin) = 0;
index = index+1;

% Create jet colored image
coloredORR = ind2rgb(index,cmap);

% Prepare the intensity image
allVals = nonzeros(sort(reshape(int,1,[])));
bot = allVals(round(opts.intMinPercentile*length(allVals)));
top = allVals(round(opts.intMaxPercentile*length(allVals)));
int = (int-bot)./(top-bot);
int(int<0) = 0;
int(int>1) = 1;

% Adjust the intensity of the colored ORR map based on the intensity image
coloredORR = coloredORR.*int;

% Turn into a purely qualitative 8-bit image
varargout{1} = uint8(round(coloredORR.*255));

% Output the colormap (if desired)
varargout{2} = cmap;
end
