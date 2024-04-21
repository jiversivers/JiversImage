function [moving, shift] = manualRegister(moving, fixed)
% Shift lists the shift for registration with x and y translations,
% respectively. Right and up are positive.
shift = [0 0];
ch = [0 0];
f = figure;

% Choose channels to register
if ndims(moving) > 2 || ndims(fixed) > 2
    disp('Select channels to register. Press space/click to switch between images. Press enter to continue to registration.')
    imgI = 0;
    whichImg = {moving, fixed};
    while ~exist('b', 'var') || ~isempty(b)
        imshowpair(moving(:,:,ch(1)+1), fixed(:,:,ch(2)+1), "montage")
        [~, ~, b] = ginput(1);
        
        % Enter press
        if isempty(b)
            break
[]
        % Space press
        elseif b == 32 || b == 1 || b ==3        
            imgI = mod(imgI+1, 2);

        % Left arrow
        elseif (b == 28||b == 97)
            ch(imgI+1) = mod(ch(imgI+1)-1, (size(whichImg{imgI+1}, 3)));
    
        % Right arrow
        elseif (b == 29 ||b == 100)
            ch(imgI+1) = mod(ch(imgI+1)+1, (size(whichImg{imgI+1}, 3)));
    
        % Up arrow
        elseif (b == 30 ||b == 119)
            ch(imgI+1) = mod(ch(imgI+1)+1, (size(whichImg{imgI+1}, 3)));
    
        % Down arrow
        elseif (b == 31||b == 115)
            ch(imgI+1) = mod(ch(imgI+1)-1, (size(whichImg{imgI+1}, 3)));
        end
    end
end

% Display the images for registration
imshowpair(moving(:,:,ch(1)+1), fixed(:,:,ch(2)+1))

disp('Click to zoom/unzoom; use arrow keys/WASD to adjust registration. Press enter to finish.')
zoomed = false;
b=0;

while ~exist('b', 'var') || ~isempty(b)
    % Get input
    [x, y, b] = ginput(1);
        
    % Enter press
    if isempty(b)
        break

    % Click to zoom
    elseif (b == 1 || b == 3) && ~zoomed
        % Zoom in
        zoomX = round(x);
        zoomY = round(y);
        zoomed  = true;
        % Check if the zoom is near a boundary
        % Rows
        if zoomY-250 < 1
            yCoord = [1 500];
        elseif zoomY + 250 > size(moving,1)
            yCoord = [size(moving,1)-500 size(moving, 1)];
        else 
            yCoord = [zoomY-250 zoomY+250];
        end
        % Cols
        if zoomX-250 < 1
            xCoord = [1 500];
        elseif zoomX + 250 > size(moving,2)
            xCoord = [size(moving,2)-500 size(moving, 2)];
        else 
            xCoord = [zoomX-250 zoomX+250];
        end
        
        % Show zoomed
        imshowpair(moving(yCoord(1):yCoord(2), xCoord(1):xCoord(2), ch(1)+1), fixed(yCoord(1):yCoord(2), xCoord(1):xCoord(2), ch(2)+1))
   
    % Click to unzoom
    elseif (b == 1 || b == 3) && zoomed
        % Zoom out
        zoomed  = false;
        imshowpair(moving(:,:,ch(1)+1), fixed(:,:,ch(2)+1))

    % For zoomed display
    % Left arrow
    elseif (b == 28||b == 97) && zoomed
        shift(1) = shift(1) - 1;
        moving = [moving(:, 2:end, :) moving(:, 1, :)];
        % Display the images for registration
        imshowpair(moving(yCoord(1):yCoord(2), xCoord(1):xCoord(2), ch(1)+1), fixed(yCoord(1):yCoord(2), xCoord(1):xCoord(2), ch(2)+1))

    % Right arrow
    elseif (b == 29 ||b == 100) && zoomed
        shift(1) = shift(1) + 1;
        moving = [moving(:, end, :) moving(:, 1:end-1, :)];
        % Display the images for registration
        imshowpair(moving(yCoord(1):yCoord(2), xCoord(1):xCoord(2), ch(1)+1), fixed(yCoord(1):yCoord(2), xCoord(1):xCoord(2), ch(2)+1))

    % Up arrow
    elseif (b == 30 ||b == 119) && zoomed
        shift(2) = shift(2) + 1;
        moving = [moving(2:end, :, :); moving(1, :, :)];
        % Display the images for registration
        imshowpair(moving(yCoord(1):yCoord(2), xCoord(1):xCoord(2), ch(1)+1), fixed(yCoord(1):yCoord(2), xCoord(1):xCoord(2), ch(2)+1))

    % Down arrow
    elseif (b == 31||b == 115) && zoomed
        shift(2) = shift(2) - 1;
        moving = [moving(end, :, :); moving(1:end-1, :, :)];
        % Display the images for registration
        imshowpair(moving(yCoord(1):yCoord(2), xCoord(1):xCoord(2), ch(1)+1), fixed(yCoord(1):yCoord(2), xCoord(1):xCoord(2), ch(2)+1))
        
    % For unzoomed display
    % Left arrow
    elseif (b == 28||b == 97) && ~zoomed
        shift(1) = shift(1) - 1;
        moving = [moving(:, 2:end, :) moving(:, 1, :)];
        % Display the images for registration
        imshowpair(moving, fixed)

    % Right arrow
    elseif (b == 29||b == 100) && ~zoomed
        shift(1) = shift(1) + 1;
        moving = [moving(:,end, :) moving(:, 1:end-1, :)];
        % Display the images for registration
        imshowpair(moving, fixed)

    % Up arrow
    elseif (b == 30||b == 119) && ~zoomed
        shift(2) = shift(2)+ 1;
        moving = [moving(2:end, :, :); moving(1, :, :)];
        % Display the images for registration
        imshowpair(moving, fixed)

    % Down arrow
    elseif (b == 31 || b == 115) && ~zoomed
        shift(2) = shift(2) - 1;
        moving = [moving(end, :, :); moving(1:end-1, :, :)];
        % Display the images for registration
        imshowpair(moving, fixed)
    end
end

close(f)