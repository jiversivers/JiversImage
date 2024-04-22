function rotation = rotationRegister(A, B)
%% Transform images and compute magnitude of transform for each
A2=abs(fftshift(fft2(A)));
B2=abs(fftshift(fft2(B)));

%% Prepare coordinate planes for orientation analysis
% Create coordinate grid of image size
[Axs, Ays] = meshgrid(1:size(A,2),1:size(A,1));
[Bxs, Bys] = meshgrid(1:size(B,2),1:size(B,1));

% Shift grid to center on (0,0)
Axs = Axs-(size(A,2)/2);
Ays = Ays-(size(A,1)/2);
Bxs = Bxs-(size(B,2)/2);
Bys = Bys-(size(B,1)/2);

% Create polar coordinate grid
[ATH, AR] = cart2pol(Axs,Ays);
[BTH, BR] = cart2pol(Bxs,Bys);
ATH = rad2deg(ATH);
BTH = rad2deg(BTH);

% Mask out the 
A_Rwind = (25<=AR)&(AR<=0.5*min(size(A, [1 2])));
B_Rwind = (25<=BR)&(BR<=0.5*min(size(B, [1 2])));

% Loop over 1-degree increments of each image to determine orientation
% off-set (ignoring center of FFT)
A_ori = zeros([1 180]);
B_ori = zeros([1 180]);
for d=1:180
    % Image A
    % Create observation wedge
    obsTH=d-1;
    wedge=(obsTH<-ATH)&(-ATH<=d);
    % Make observation window
    window=wedge.*A_Rwind;
    % Determine window size
    pixelcount=sum(sum(window));
    % Detemine intensity of FFt within window
    wind=A2.*window;
    % Calculate intensity percent
    A_ori(d)=sum(sum(wind))/pixelcount;

    % Repeat for Image B
    wedge=(obsTH<-BTH)&(-BTH<=d);
    window=wedge.*B_Rwind;
    pixelcount=sum(sum(window));
    wind=B2.*window;
    B_ori(d)=sum(sum(wind))/pixelcount;
end

% Cross-corellating orientation array to determine rotation for maximum
% correlation
Rot_map=fftshift(ifft(fft(A_ori).*fft(rot90(B_ori,2))));
[~, rotation]=max(Rot_map);
rotation = (rotation-90)/2;

end