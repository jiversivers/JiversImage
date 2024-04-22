function ch = chooseChannelView(img)
ch = 0;
disp('Select channels to register. Use the arrow keys to scroll through channels. Press enter to select and continue.')
while ~exist('b', 'var') || ~isempty(b)
    imagesc(img(:,:,ch+1))
    [~, ~, b] = ginput(1);
    
    % Enter press
    if isempty(b)
        break

    % Left arrow
    elseif (b == 28||b == 97)
        ch = mod(ch-1, (size(img, 3)));

    % Right arrow
    elseif (b == 29 ||b == 100)
        ch = mod(ch+1, (size(img, 3)));

    % Up arrow
    elseif (b == 30 ||b == 119)
        ch = mod(ch+1, (size(img, 3)));

    % Down arrow
    elseif (b == 31||b == 115)
        ch = mod(ch-1, (size(img, 3)));
    end
end
ch = ch+1;
close(gcf)
end