function normalized_image = fluorescein_normalization_master(varargin) %#codegen
% normalized_image = FLUORESCEIN_NORMALIZATION_MASTER(I,options)
% normalized_image = FLUORESCEIN_NORMALIZATION_MASTER(I,PMT,Attenuation,PowerFlag,RefAtten,RefPow,dateTaken,laserFlag,PMTChannel)
% 
% For use by QuinnLab and AIMRC
% University of Arkansas
% Created by Jake Jones
% V.2.0
% Last updated 2/7/2023 AW
%
% Update notes: 
%  -Complete overhaul of function -> new input handling, added support for
%  third MPM, removed need for laser power
%
% Function purpose:
%  Normalizes intensity images based on gain and power to a concentration
%  of fluorescein measured from a calibration solution.
%
%%%%%%%%%%%%%%%%%%%%%%%% Description of Variables %%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:
%
%     I = intensity image (uint16)
%
%     Options = structure variable with following fields:
%
%     PMT = value assciated with PMT sensitivity (voltage) when image "I" was taken.
%
%     Attenuation = Amount applied to attenuate the laser when image "I" was taken.
%                   - For MaiTai: pockel attenuation in volts (NOT % ATTENUATION)
%                   - For Insight: % Power, as listed on ATM software
%
%     RefAtten = Reference attenuation values taken day of imaging. These
%                values should be within the linear region of the curve
%                that relate Power to Attenuation (either Pockels value (NOT % ATTENUATION)
%                or %Power).
%                **Note: At least three values should be taken.**
%
%     RefPow = Objective power reference values taken day of imaging and
%               correspond to RefAtten values
%
%     dateTaken = The date that image "I" was taken. Should be in the form:
%                 dateTaken = [YYYY,MM,DD] 
%                 Example: dateTaken = [2017,6,1];
%                 Example: dateTaken = datetime(xmlData.PVScan.Attributes.date,'InputFormat','MM/dd/uuuu hh:mm:ss aa');
%
%     laserFlag = Input that allows for specification of which
%                 laser transfer function to use. Current options are:
%                   1) Upright1
%                   2) Inverted1
%                   3) Upright2
%                 **Note: Between 2018 and 2020, the MaiTai and Insight
%                 were both on the Upright1 microscope. The laser transfer
%                 functions for this time period are setup such that the
%                 MaiTai is under Inverted1 and the Insight is under
%                 Upright1.**
%
%     PMTChannel = Value (1-4) indicating which options.PMT the image was collected
%     on. This is for baked in background subtraction.
%
% Outputs:
%
%   conc = Normalized intensity image based on uM of fluorescein.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Step 1: Determine if legacy input, if yes, then parse
I = single(varargin{1});

if ~isstruct(varargin{2})
    options = parseLegacyInput(varargin{2:end});
else
    options = varargin{2};
end
options.offsetSub = false;

% Step 2: Use least square regression to find the relationship between power
% attenuation and objective power readings.
x = options.RefAtten;
y = options.RefPow;

[r,c] = size(options.RefPow);
if r < c
    x = x';
    y = y';
end
X = [ones(length(x),1) x];
b = X\y; % Y-intercept of the regression line

ObjPow = b(1) + b(2).*options.Attenuation;

% Step 3: Convert the date that the image was taken and lookup corresponding
% transfer function to calculate gain. The formulas for gain can be found
% in the fluorescein normalization excel workbooks with the names and dates
% listed below. 

date = datetime(options.dateTaken);

    if (date<datetime(2017,6,1))
        % PreMay2017
        % JJ

        switch(options.laserFlag)
            case('Upright1')
                % Upright1 Transfer Function
                g = (1E-22).*options.PMT.^7.8731;
                
                % PMT Offset values
                offset = [0 0 0 0];

            case('Inverted1')
                % Inverted1 Transfer Function
                error('Inverted1 not supported for given date.');

            case('Upright2')
                % Upright2 Transfer Function
                error('Upright2 not supported for given date.');
        end
    elseif (date<datetime(2017,11,8)) && (date>datetime(2017,6,1))
        % PreNovember2017
        % JJ

        switch(options.laserFlag)
            case('Upright1')
                % Upright1 Transfer Function
                g = (8E-23).*options.PMT.^8.077;
                
                % PMT Offset values
                offset = [0 0 0 0];

            case('Inverted1')
                % Inverted1 Transfer Function
                error('Inverted1 not supported for given date.');

            case('Upright2')
                % Upright2 Transfer Function
                error('Upright2 not supported for given date.');
        end
        
    elseif (date<datetime(2018,7,2)) && (date>datetime(2017,11,8))
        % PreJune2018
        % JJ,HR (11/8/2017)
        
        switch(options.laserFlag)
            case('Upright1')
                % Upright1 Transfer Function
                g = (7E-23).*options.PMT.^7.9121;
                
                % PMT Offset values
                offset = [0 0 0 0];

            case('Inverted1')
                % Inverted1 Transfer Function
                error('Inverted1 not supported for given date.');

            case('Upright2')
                % Upright2 Transfer Function
                error('Upright2 not supported for given date.');
        end

    elseif (date<datetime(2018,8,27)) && (date>datetime(2018,7,2))
        % PreJuly_2_2018
        % HR,OK (6/6/2018)

        switch(options.laserFlag)
            case('Upright1')
                % Upright1 Transfer Function
                g = (2E-24).*options.PMT.^8.3908;
                
                % PMT Offset values
                offset = [0 0 0 0];

            case('Inverted1')
                % Inverted1 Transfer Function
                error('Inverted1 not supported for given date.');

            case('Upright2')
                % Upright2 Transfer Function
                error('Upright2 not supported for given date.');
        end

    elseif (date<datetime(2018,10,5)) && (date>datetime(2018,8,27))
        % Aug_27_2018THRUSep_10_2018
        % OK (9/4/2018)

        switch(options.laserFlag)
            case('Upright1')
                % Upright1 Transfer Function
                g = (2E-24).*options.PMT.^8.3908;
                
                % PMT Offset values
                offset = [0 0 0 0];

            case('Inverted1')
                % Inverted1 Transfer Function
                error('Inverted1 not supported for given date.');

            case('Upright2')
                % Upright2 Transfer Function
                error('Upright2 not supported for given date.');
        end
   
    elseif (date<datetime(2018,11,19)) && (date>datetime(2018,10,5))
        % AfterOctober_5_2018
        % ?? 10/5/18

        switch(options.laserFlag)
            case('Upright1')
                % Upright1 Transfer Function
                g = (2.3763E-23).*options.PMT.^7.6537;
                
                % PMT Offset values
                offset = [0 0 0 0];

            case('Inverted1')
                % Inverted1 Transfer Function
                error('Inverted1 not supported for given date.');

            case('Upright2')
                % Upright2 Transfer Function
                error('Upright2 not supported for given date.');
        end

    elseif (date<datetime(2019,12,13)) && (date>datetime(2018,11,19))
        % AW (11/19/2018)
        switch(options.laserFlag)
            case('Upright1')
                % Upright1 Transfer Function
                g = (4.8794E-24).*options.PMT.^8.1718;
                
                % PMT Offset values
                offset = [0 0 0 0];
            case('Inverted1')
                % Inverted1 Transfer Function
                g = (8.4881E-23).*options.PMT.^7.4941;
                
                % options.PMT Offset values
                offset = [0 0 0 0];

            case('Upright2')
                % Upright2 Transfer Function
                error('Upright2 not supported for given date.');
        end

    elseif date<datetime(2020,1,22) && date>datetime(2019,12,13)
        % MB,CS,AW (12/13/2019)

        switch(options.laserFlag)
            case('Upright1')
                % Upright1 Transfer Function
                g = (1.3526E-23).*options.PMT.^7.9677;
                
                % PMT Offset values
                offset = [0 0 0 0];
            case('Inverted1')
                % Inverted1 Transfer Function
                g = (2.4229E-24).*options.PMT.^8.0743;
                
                % options.PMT Offset values
                offset = [0 0 0 0];

            case('Upright2')
                % Upright2 Transfer Function
                error('Upright2 not supported for given date.');
        end
        
     elseif date<datetime(2020,7,17) && date>datetime(2020,1,22)
        % OK,CS (1/22/2020)
        % 1/17/2020 - date MaiTai purge filter was replaced

        switch(options.laserFlag)
            case('Upright1')
                % Upright1 Transfer Function
                g = (1.9009E-21).*options.PMT.^7.1885;
                
                % PMT Offset values
                offset = [0 0 0 0];
            case('Inverted1')
                % Inverted1 Transfer Function
                g = 8.5089E-22.*options.PMT.^7.1636;
                
                % options.PMT Offset values
                offset = [0 0 0 0];

            case('Upright2')
                % Upright2 Transfer Function
                error('Upright2 not supported for given date.');
        end
        
      elseif date<datetime(2021,6,10) && date>datetime(2020,7,17)
        % OK,CS (7/17/2020)
        % *Note: As of this date, the MaiTai is exclusive to the inverted
        % MPM while the insight is attached to the original MPM.
        % 1/17/2020 - date MaiTai was not calibrated

        switch(options.laserFlag)
            case('Upright1')
                % Upright1 Transfer Function
                g = (1.8897E-20).*options.PMT.^6.8312;
                
                % PMT Offset values
                offset = [0 0 0 0];
            case('Inverted1')
                % Inverted1 Transfer Function
                g = 8.5089E-22.*options.PMT.^7.1636;
                
                % options.PMT Offset values
                offset = [0 0 0 0];

            case('Upright2')
                % Upright2 Transfer Function
                error('Upright2 not supported for given date.');
        end
        
    elseif date<datetime(2022,12,1) && date>datetime(2021,6,10) 
        % CS (6/10/2021)

        switch(options.laserFlag)
            case('Upright1')
                % Upright1 Transfer Function
                g = (1.2505E-23).*options.PMT.^7.9265;
                
                % PMT Offset values
                offset = [377 473 393 77];
            case('Inverted1')
                % Inverted1 Transfer Function
                g = (6E-36).*options.PMT.^12.232;
                
                % options.PMT Offset values
                offset = [0 0 0 0];

            case('Upright2')
                % Upright2 Transfer Function
                error('Upright2 not supported for given date.');
        end

    elseif date>datetime(2022,12,1)
        % Current
        % AEW (Dec 2022 - Jan 2023)

        switch(options.laserFlag)
            case('Upright1')
                % Upright1 Transfer Function
                g = (6.55107E-24).*options.PMT.^8.029222607;
                
                % PMT Offset values
                offset = [379.7346952, 446.6135238, 379.3671238, 71.04764762];

            case('Inverted1')
                % Inverted1 Transfer Function
                g = (4.15075E-25).*options.PMT.^8.341763251;
                
                % options.PMT Offset values
                offset = [0 0 0 0]; % These are basically 0

            case('Upright2')
                % Upright2 Transfer Function
                g = (5.51228E-24).*options.PMT.^7.956680523;
                
                % options.PMT Offset values
                offset = [0 0 0 0]; % These are basically 0
        end   
    else
        error('Error: Could not get correct date. Please refer to the documentation.')
    end

% Get the intensity offset for the particular channel that was used
if options.offsetSub
    intOffset = 0;
else
    intOffset = offset(options.PMTChannel);
end

% Calculate concentration fluorescein (uM)
conc=((I-intOffset)./(ObjPow.^2))./g;
% conc(conc<0) = 0;
% conc(isnan(conc)) = 0;
% conc(isinf(conc)) = 0;

normalized_image = conc;
end

function options = parseLegacyInput(varargin)
    options.PMT = varargin{1};
    options.Attenuation = varargin{2};

    if strcmp(varargin{3},'-las')
        count = 1;
    elseif strcmp(varargin{3},'-obj')
        count = 0;
    end

    options.RefAtten = varargin{4};
    options.RefPow = varargin{5+count};
    options.dateTaken = varargin{6+count};
    if strcmp(varargin{7+count},'-m')
        options.laserFlag = 'Inverted1';
    elseif strcmp(varargin{7+count},'-i')
        options.laserFlag = 'Upright1';
    end
    options.PMTChannel = varargin{8+count};
end