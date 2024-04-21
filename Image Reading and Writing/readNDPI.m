function varargout = readNDPI(filename, varargin)

% Default inputs
res = 1;
w = false;
nameParse = strsplit(filename, '.ndpi');
savename = [nameParse{1} '.tiff'];

%Parse input
p = inputParser;
isValidFile = @(x) isfile(x);
isValidRes = @(x) (isnumeric(x) && all(x)>0) || strcmp('all', x);
isValidMode = @(x) islogical(x);
addRequired(p, 'filename', isValidFile)
addOptional(p, 'savename', savename)
addOptional(p, 'resolutionlevel', res, isValidRes)
addOptional(p, 'write', w, isValidMode)
parse(p, filename, varargin{:});

nameParse = strsplit(p.Results.savename, '.tiff');

% Create reader for file
reader = bfGetReader(p.Results.filename);

% Parse resolution option
if strcmp('all', p.Results.resolutionlevel)
    res = 1:1:reader.getSeriesCount-1;
else
    res = p.Results.resolutionlevel;
end

imgs = cell(numel(res), 1);
metadata = cell(numel(res), 1);

for r = res
    
    % Set reader to current series
    try
        reader.setSeries(r);
    catch ME
        if strcmp(ME.identifier, 'MATLAB:Java:GenericException')
            error(['Invalid resolution level selected. This image contains resolution levels between 1 and ' num2str(reader.getSeriesCount-1)])
        else
            error(['Unidentified error at resolution set time...' getReport(ME)])
        end
    end

    % Get image plane & metadata
    i = zeros([reader.getSizeY reader.getSizeX reader.getSizeC]);
    for ch = 1:reader.getSizeC
        i(:,:, ch) = bfGetPlane(reader, ch);
    end
    md = reader.getMetadataStore();
    
    % Handle final outs
    if p.Results.write
        savename = [nameParse{1} '_ResolutionLevel' num2str(r) '.ome.tiff'];
        java.lang.System.gc(); % Clear up heap space for bfsave
        bfsave(i, savename);
    else
        imgs{r} = i;
        metadata{r} = md;
        varargout{1} = imgs;
        varargout{2} = metadata;
    end
end

