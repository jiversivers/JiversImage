function [t,count,SP] = readsdt(filename)
% Reads *.sdt file saved by SPCM (Becker & Hickl GmbH). 
% https://www.becker-hickl.com/products/spcm/
% Example:
% [t,count,SP]=readsdt('ph3.sdt');
% Yuanfei Jiang, 2022.01.06
% Institute of Atomic and Molecular Physics, Jilin University, P.R.China.
% Read data files (.sdt) saved by Single Photon Counter Module(SPCM)
% Example:
% [t,count,sp]=readsdt(filename)
%     t  time
% count  photon count value
%    sp  parameters saved in the data file
if exist(filename, 'file')
    [~, ~, ext] = fileparts(filename);
    if strcmpi(ext,'.sdt')
        f = fopen(filename);
        textscan(f, '%s %s %s ', 1,'headerlines',1);
        N1=textscan(f, '%s %s %s', 1,'headerlines',1);
        SP.Title=char(N1{3});
        textscan(f, '%s %s', 1,'headerlines',2);
        D1=textscan(f, '%s %s %s', 1,'headerlines',1);
        SP.Date=char(D1{3});
        T1=textscan(f, '%s %s %s', 1,'headerlines',1);
        SP.Time=char(T1{3});
        textscan(f, '%s %s %s', 1,'headerlines',7);
        for i=15:174
            a=textscan(f, '%s %s',1);
            b=char(a{2});
            c=strsplit(b(2:end-1),',');
            if ismember(i,[19 26 55 72])
                eval(['SP.',char(c{1}),'=''',char(c{3}),''';']);
            else
                eval(['SP.',char(c{1}),'=',char(c{3}),';']);
            end
        end
        t=((1:SP.SP_ADC_RE)*SP.SP_TAC_TC)';
        textscan(f, '%s', 1,'headerlines',46);
        fread(f,17750,'uint8');
        count=fread(f,4096,'uint16');
        fclose(f);
        disp([pwd,'\',filename,'    --- Experiment Date: ',SP.Date,' ',SP.Time,'.  Exported successfully.']);
    else
        warning('FileError:NoFile', 'File format %s does not support\n', ext);
    return
    end
else
    warning('FileError:NoFile', 'File %s does not exist\n', filename);
    return
end