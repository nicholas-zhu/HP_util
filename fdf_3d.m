function [I,TE] = fdf_3d(inputFilename, inputDir)
% m-file that can open Varian FDF imaging files in Matlab.
%
% Shanrong Zhang
% Department of Radiology
% University of Washington
% 
% email: zhangs@u.washington.edu
% Date: 12/19/2004
% 
% Fix Issue so it is able to open both old Unix-based and new Linux-based FDF
% Date: 11/22/2007
%
% Dave Niles, 2/14/2011 - Added optional arguments and batch process.
%   I = fdf(inputFilename, inputDir)
%   I = fdf('all',...)
%   [I, TE] = fdf(...)
%
%   TE is in milliseconds
%
% Dave Niles, 9/20/2011 - Added code to support 3d volumes

warning off MATLAB:divideByZero;

is_3d = 0;  % 0 for 2D, 1 for 3D, DJN

if nargin < 2,  inputDir = pwd;     end
if nargin < 1,
    [inputFilename inputDir] = uigetfile('*.fdf','Please select a fdf file');
end;

if isequal(inputFilename, 'all'),
    cd(inputDir);
    files = dir('*.fdf');
    
    %JWG account for weird hidden fdf files
    ctr = 1;
    for jj = 1:length(files),
        if strcmp(files(jj).name(1),'.') ~= 1
            [I(:,:,ctr), TE(ctr)] = readFile(files(jj).name, inputDir);
            ctr = ctr + 1;
        end
    end
else,
    [I, TE] = readFile(inputFilename, inputDir);
end
    
function [img, echotime] = readFile(filename, pathname),
    [fid] = fopen(fullfile(pathname, filename),'r');

    num = 0;
    done = false;
    machineformat = 'ieee-be'; % Old Unix-based  
    line = fgetl(fid);
    % disp(line);
    while (~isempty(line) && ~done)
        line = fgetl(fid);
        % disp(line);
        if strmatch('float  te = ', line) % added by DJN
            echotime = strtok(line,'float  te = ');
            echotime = (str2num(echotime(1:end-1))).*1000; % milliseconds
        end
        if strmatch('int    bigendian', line)
            machineformat = 'ieee-le'; % New Linux-based    
        end
        
        if strmatch('float  matrix[] = ', line)
            [token, rem] = strtok(line,'float  matrix[] = { , };');
            M(1) = str2num(token);
            if is_3d == 1, % Added by DJN
                [temp,rem] = strtok(rem,', };');
                M(2) = str2num(temp);
                M(3) = str2num(strtok(rem,', };'));  
            else
                M(2) = str2num(strtok(rem,', };'));
                M(3) = 1;
            end
        end
        
        if strmatch(line, 'char  *spatial_rank = "3dfov";'), % Added by DJN
            is_3d = 1;
        end
        
        if strmatch('float  bits = ', line)
            [token, rem] = strtok(line,'float  bits = { , };');
            bits = str2num(token);
        end

        num = num + 1;

        if num > 41
            done = true;
        end
    end
    
    if is_3d == 1,  % Added by DJN
        skip = fseek(fid, -M(1)*M(2)*M(3)*bits/8, 'eof'); 
    else
        skip = fseek(fid, -M(1)*M(2)*bits/8, 'eof');
    end
    
    for ii = 1:M(3),  % Added by DJN
        temp_img = fread(fid,[M(1), M(2)], 'float32', machineformat);
        img(:,:,ii) = temp_img';                    
    end
        
    fclose(fid);
end
end

% end of m-code
