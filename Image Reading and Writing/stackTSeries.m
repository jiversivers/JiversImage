function [stack, metadata] = stackTSeries(tileDir)

baseName = strsplit(tileDir, filesep);
baseName = baseName{end};

xml = [tileDir filesep dir([tileDir filesep baseName '.xml']).name];
metadata = readPVxml(xml);

imgSize = metadata.ImageSize;
chnls = numel(metadata.Channels);
imgCount = metadata.ImageCount;

stack = zeros([imgSize chnls imgCount]);

for cyc = 1:imgCount
    for ch = 1:chnls
        imgName = [tileDir filesep metadata.FileNames{cyc, ch}];
        stack(:,:,ch,cyc) = double(imread(imgName));
    end
end