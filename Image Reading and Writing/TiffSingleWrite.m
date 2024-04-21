function TiffSingleWrite(A, savename, overwriteOpt)

% overwriteOpt is 0 for skip, 1 for overwrite, 2 for keep a copy

A = single(A);
nameParse = strsplit(savename, '.tif');
sn = nameParse{1};

% Get overwrite opt through dialog if user didn't input one.
if exist([sn '.tiff'], 'file') && ~exist("overwriteOpt", "var")
    opt = questdlg('What would you like to do?', ['Warning: ' savename ' already exists!'], 'Overwrite', 'Keep Both', 'Append', 'Keep Both');
    switch opt
        case 'Skip'
            return
        case 'Overwrite'
            delete([sn '.tiff']);
        case 'Keep Both'
            extN = 1;
            while exist([sn '.tiff'], 'file')
                extN = extN + 1;
                sn = [nameParse{1} '_' num2str(extN)];
            end
        case 'Append'
    end

% If user already input an override opt at call
elseif exist([sn '.tiff'], 'file') && exist("overwriteOpt", "var")
    switch lower(overwriteOpt)
        case {0, 'skip'}
            return
        case {1, 'overwrite'}
            delete([sn '.tiff']);
        case {2, 'keep both'}
            extN = 1;
            while exist([sn '.tiff'], 'file')
                extN = extN + 1;
                sn = [nameParse{1} '_' num2str(extN)];
            end
        case {3, 'append'}
    end
end

t = Tiff([sn '.tiff'], 'a');

tagStruct.Photometric = Tiff.Photometric.MinIsBlack;
tagStruct.Compression = Tiff.Compression.None;
tagStruct.BitsPerSample = 32;
tagStruct.SampleFormat = Tiff.SampleFormat.IEEEFP;

tagStruct.ImageWidth = size(A, 2);
tagStruct.ImageLength = size(A, 1);
tagStruct.XResolution = 1;
tagStruct.YResolution = 1;

tagStruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagStruct.ResolutionUnit = Tiff.ResolutionUnit.None;

tagStruct.SamplesPerPixel = 1;
tagStruct.ExtraSamples = Tiff.ExtraSamples.Unspecified;

for ii = 1:size(A,3)
    t.setTag(tagStruct)
    t.write(A(:,:,ii))
    t.writeDirectory()
end

close(t);
