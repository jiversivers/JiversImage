function [registeredStack, transform] = alignByLineROI(fixed, moving, varargin)
%{
alignByLineROI is a manual image registration function that will transform
the moving image (arg 2) based on use selected fiducials from each image.
Two images (moving and fixed) are required as inputs. Additional name-value
pairs may be added to control allowed transformations. By default,
translation, scaling, and rotation are all utilized.

This function works by finding the line described by two points in each
image, then forcing those lines to match (as best as possible) given the
allowed transforms and returns the stack of both images. Moving is the only
image that will be transformed, but fixed may be padded. The registered
stack will contain moving in the first layer(s) and fixed last.

With the defualt settings, the lines are guranteed to register. If any
transformation option is turned off, the neccesary full transformation will
still be calculated, but only the allowed transforms will be applied. In
this case, the alignment cannot be guranteed. Furthermore, only the applied
transforms will be returned in the transformation structure. For this
reason, it is recommended to use the default settings and apply the
transforms desired manually using the transforms structure that is returned
as the second output argument.

To use this funciton, simply input the required and optional arguments. A
subplot of each image will display. You can zoom and pan as normal (being
careful to select the tool you want to use from the figure toobar). When
you have found a pair of matching points on the images (one on each),
select the point on the LEFT IMAGE FIRST, then select the CORRESPONDING
POINT ON THE RIGHT IMAGE. Repeat this process for the second point pair,
being careful to select on the LEFT IMAGE FIRST and the RIGHT IMAGE SECOND.
After selecting the second pair of points, the figure will close.

It is important to note, in the current version of this program, you CANNOT
UNDO OR MOVE POINTS AFTER SELECTING. (This will be updated in a future
version).

Dependencies: imageTransformer, impad
%}

p = inputParser;
isimg = @(x) size(x, 3)==1 || size(x, 3)==3;
addRequired(p, 'fixed', isimg)
addRequired(p, 'moving', isimg)
addParameter(p, 'translation', true, @islogical)
addParameter(p, 'scaling', true, @islogical)
addParameter(p, 'rotation', true, @islogical)
parse(p, fixed, moving, varargin{:})

%% Get ROIs
fig = figure('WindowState', 'maximized');
ax1 = subplot(1, 2, 1);
ax1.Title.String = 'Moving';
ax2 = subplot(1, 2, 2);
ax2.Title.String = 'Fixed';
imshow(moving, 'Parent', ax1)
imshow(fixed, 'Parent', ax2)
drawnow
roi = cell(2, 2);
% Rows correspond to the points (1 is first pt, 2 is second point)
% Columns correspond to images (1 is moving, 2 is fixed)
roi{1, 1} = drawpoint(ax1);
roi{1, 2} = drawpoint(ax2);
roi{2, 1} = drawpoint(ax1);
roi{2, 2} = drawpoint(ax2);

% Pts vectors are in (x, y) format
pts = cellfun(@(x) round(x.Position), roi, 'UniformOutput', false);

close(fig)
%% Calculate transforms
% Compare line length
dist = [0 0];
for ii = 1:2
    % 1: Moving
    % 2: Fixed
    dist(ii) = sqrt((pts{2,ii}(2)-pts{1,ii}(2))^2 + (pts{2,ii}(1)-pts{1,ii}(1))^2);
end
if p.Results.scaling
    transform.Scale = dist(2)/dist(1); % If scale>1, moving is too small
end

% Update points by scale
pts(:,1) = cellfun(@(x) x*transform.Scale, pts(:,1), 'UniformOutput', false);

% Compare line angle
thet = [0 0];
for ii = 1:2
    % 1: Moving
    % 2: Fixed
    thet(ii) = atan((pts{2,ii}(2)-pts{1,ii}(2))/(pts{2,ii}(1)-pts{1,ii}(1)));
end
dthet =  thet(1)-thet(2); % If dthet > 0, moving is off in CW direction
if p.Results.rotation
    transform.Rotation = rad2deg(dthet); % Tan fun calc in rad, but imrotate takes deg
end

% Then find where the rotation leaves the points
cent = (transform.Scale*size(moving, [1 2])+1)/2; % In (x, y) form. Not discreet...will round everything once at the end
[TH1, R1] = cart2pol(pts{1,1}(1)-cent(1), cent(2)-pts{1,1}(2)); 
[TH2, R2] = cart2pol(pts{2,1}(1)-cent(1), cent(2)-pts{2,1}(2));
[x1, y1] = pol2cart(TH1+dthet, R1);
[x2, y2] = pol2cart(TH2+dthet, R2);
pts{1,1}(1) = x1+cent(1);
pts{1,1}(2) = cent(2)-y1;
pts{2,1}(1) = x2+cent(1);
pts{2,1}(2) = cent(2)-y2;

% Calculate shift necessary to make both pt 1 and 2 match the fixed points,
% then take the average shift from these in both directions. The idea is to
% minimze rounding error by first finding both, and only ronding at the
% very end.
% Trans = fixedpoint - movingpoint = row-shift, column-shift
trans(1, :) = pts{1,2}-pts{1,1};
trans(2, :) = pts{2,2}-pts{2,1};
if p.Results.translation
    transform.Translation = flip(round(mean(trans))); % Gives average translation based on both points in rows(1) and columns(2) to accomodate any possible rounding errors caused by dtype limitatons then rounds
end
% Apply transforms to moving image (2) and pad fixed (1) to match size
moving = imageTransformer(moving, transform);
size2pad = max(cell2mat(cellfun(@size, {moving; fixed}, 'UniformOutput', false))); % Find largest dims overall
moving(end+1:size2pad(1), end+1:size2pad(2), :) = 0;
fixed(end+1:size2pad(1), end+1:size2pad(2), :) = 0;
registeredStack = cat(3, fixed, moving);
