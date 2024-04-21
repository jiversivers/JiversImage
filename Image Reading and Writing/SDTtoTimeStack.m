function TimeStack = SDTtoTimeStack(filename, varargin)

% Set defaults
defaultBinWidth = 1;
R = 1:4;
fd = 0;
off = false;

% Parse inputs
p = inputParser;
validNumber = @(x) isnumeric(x) && isscalar(x) && (x>=0);
validChannels = @(x) isnumeric(x) && ismatrix(x) && ~any(x<=0);
addRequired(p, 'filename', @isfile);
addParameter(p, 'binwidth', defaultBinWidth, validNumber);
addParameter(p, 'channel', R, validChannels);
addParameter(p, 'framedelay', fd, validNumber);
addParameter(p, 'triggerdelay', off, @islogical);
addParameter(p, 'peakatzero', off, @islogical);
parse(p, filename, varargin{:});

% Create BF image reader and set channel to read
r = bfGetReader(p.Results.filename);

% Load decay from reader
decay = uint16(zeros([r.getSizeX, r.getSizeY, numel(p.Results.channel), r.getSizeT])); % Assumes decay is always one layer <r.getSizeZ = 1>
for t = 1:r.getSizeT
    for c = 1:numel(p.Results.channel)
        ch = p.Results.channel(c);
        decay(:,:,c,t) = bfGetPlane(r, r.getIndex(0, ch-1, t-1)+1); % reader is 0-indexed, but bfGetPlane is 1-indexed...its silly
    end
end

% Skip number of frames from input
decay = decay(:,:,:,p.Results.framedelay+1:end);

% Skip leading frames that lack input
if p.Results.triggerdelay
    decay = decay(:, :, :, find(sum(decay, [1 2 3]), 1, 'first'):find(sum(decay, [1 2 3]), 1, 'last'));
end

if p.Results.peakatzero
    [~, shift] = max(decay, [], 4); % Find where the decay peaks
    tmpdecay = zeros(size(decay));
    for rr = 1:size(decay, 1)
        for cc = 1:size(decay, 2)
            tmpdecay(rr, cc, :, :) = cat(4, decay(rr, cc, :, shift(rr,cc, :):end), zeros(1, 1, size(decay, 3), shift(rr,cc, :)-1)); 
        end
    end
    decay = tmpdecay;
end

if p.Results.binwidth > 1
    TimeStack = uint16(zeros([size(decay, [1 2 3]), floor(size(decay, 4)/p.Results.binwidth)]));
    x = zeros(size(decay, [1 2 3]));
    bin = 1;
    t = 1;
    while bin*p.Results.binwidth < size(decay,4)
        x = x + double(decay(:,:,:,t));
        if mod(t, p.Results.binwidth) == 0
            TimeStack(:, :, :, bin) = uint16(x);
            bin = bin+1;
            x = zeros(size(decay, [1 2 3]));
        end
        t = t+1;
    end
else
    TimeStack = decay;
end