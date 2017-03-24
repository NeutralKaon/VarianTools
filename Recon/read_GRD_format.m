function [ data, params ] = read_GRD_format( filename,varargin )
% Read in varian GRD format file located at filename. 
% Output: data -- vector of points, scaled between [-32767, 32767] 
% Params: header struct, containing (depending on what generated the file):
%       NAME: filename 
%       POINTS: length(data) 
%       RESOLUTION: dt (seconds, typically 4 us) 
%       STRENGTH: what ±32767 corresponds to in G/cm 
%       header_length: length of header. 
% 
% Optionally, calling 'rescale' as an additional argument will rescale the
% output s.t. max(data) = strength. 
% 
% JJM 2016 and AZL 2015, University of Oxford
% 
% SEE ALSO: save_GRD_format
% 
params = read_GRD_format_header(filename);
data   = read_GRD_format_data(filename, params);

if nargin == 2 
    if strcmp(varargin{1},'rescale')
        dosomething(); 
    else
        error('Undefined call'); 
    end
elseif nargin >2 
    error('RTFM'); 
end

end

function data = read_GRD_format_data(filename, params)

data = zeros(params.POINTS,1);

fid = fopen(filename, 'r');
% skip header
for j=1:params.header_length
    fgetl(fid);
end

for j=1:params.POINTS
    LINE = fgetl(fid);
    data(j) = sscanf(LINE, '%d %*d');
end
fclose(fid);

end

function params = read_GRD_format_header(filename)
fid = fopen(filename, 'r');
is_header = true;
header_length = 0;

while (is_header)
    % Read header
    LINE = fgetl(fid);
    LINE_match_header     = regexp(LINE, '#');
    if (LINE_match_header)
        LINE_match_name       = regexp(LINE, 'NAME');
        LINE_match_points     = regexp(LINE, 'POINTS');
        LINE_match_resolution = regexp(LINE, 'RESOLUTION');
        LINE_match_strength   = regexp(LINE, 'STRENGTH');
        
        if (LINE_match_name)
            NAME = sscanf(LINE, '%*s %*s %s');
        end
        
        if (LINE_match_points)
            POINTS = sscanf(LINE, '%*s %*s %f');
        end

        if (LINE_match_resolution)
            RESOLUTION = sscanf(LINE, '%*s %*s %f');
        end        
        
        if (LINE_match_strength)
            STRENGTH = sscanf(LINE, '%*s %*s %f');
        end        
        
        header_length = header_length+1;
    else
        is_header = false;
    end
end

fclose(fid);

params.NAME          = NAME;
params.POINTS        = POINTS;
params.RESOLUTION    = RESOLUTION;
params.STRENGTH      = STRENGTH;
params.header_length = header_length;
end
