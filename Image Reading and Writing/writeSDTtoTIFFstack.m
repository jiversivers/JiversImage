function writeSDTtoTIFFstack(filename, savename, varargin)

% Parse inputs
assert(isfile(filename), ['Invalid filename: ' filename])

img = SDTtoTimeStack(filename, varargin{:});
SamplesPerPixel = size(img, 3);
nameParse = strsplit(savename, '.tif');
sn = nameParse{1};

if exist([sn '.tiff'], 'file')
    opt = questdlg('What would you like to do?', ['Warning: ' savename ' already exists!'], 'Overwrite', 'Append', 'Keep Both', 'Keep Both');
    switch opt
        case 'Overwrite'
            delete([sn '.tiff']);
        case 'Keep Both'
            extN = 1;
            while exist([sn '.tiff'], 'file')
                extN = extN + 1;
                sn = [nameParse{1} '_' num2str(extN)];
            end
    end
end

savename = [sn '.tiff'];
TiffSingleWrite(img, savename, 3);

end