function img = fdf(varargin)
% m-file that can open Varian FDF imaging files in Matlab.
% Usage: img = fdf;
% Your image data will be loaded into img

warning off MATLAB:divideByZero;
if nargin~=1
[filename, pathname] = uigetfile('*.fdf','Please select a fdf file');
[fid] = fopen([pathname filename],'r');
else
[fid] = fopen(varargin{1},'r');
end
num = 0;
done = false;
machineformat = 'ieee-be'; % Old Unix-based  
line = fgetl(fid);
disp(line)
while (~isempty(line) && ~done)
    line = fgetl(fid)
    % disp(line)
    if ~isempty(strfind(line,'int  bigendian'))
        machineformat = 'ieee-le'; % New Linux-based    
    end
    machineformat = 'ieee-le';
    if ~isempty(strfind(line,'float  matrix[] ='))
        [token, rem] = strtok(line,'float  matrix[] = { , };');
        a=str2num(token);
        b=str2num(strtok(rem,', };'));
        M=zeros(2,length(a));
        M(1) = a;
        M(2) = b;
    end
    if ~isempty(strfind(line,'float  bits = '))
        [token, rem] = strtok(line,'float  bits = { , };');
        bits = str2num(token);
    end

    num = num + 1;
    
    if num > 50 %Originally 41
        done = true;
    end
end

skip = fseek(fid, -M(1)*M(2)*bits/8, 'eof');
img = fread(fid, [M(1), M(2)], 'float32', machineformat);

fclose(fid);
warning on MATLAB:divideByZero;
