%
% LOAD_VARIAN Read varian .fid/ directory.
%
% Usage: 
%   [k,params] = load_varian( directory, [FLAG_READ_PARAM] )
%
% Inputs:
%   directory:       data directory (e.g. DATA.fid/)
%   FLAG_READ_PARAM: read procpar (optional)
%
% Outputs:
%   k:       raw data (N_collapsed, N_views)
%   params:  parameter struct
% JM2013: Added parsing of the log file to compute actual experiment times,
% added to params struct as 'timeExperiment'. 

function [k,params] = load_varian( directory, FLAG_READ_PARAM )

if nargin < 2
    FLAG_READ_PARAM = false;
    params = [];
end

if (FLAG_READ_PARAM)
    params = readprocpar( directory );
    params.timeExperiment = read_log( directory );
    if isfield(params, 'timer')%Read actual timestamps 
        try
        if params.timer==1
            params.t=read_timer( directory );
        end
        catch
            params.t=0; 
            warning('Timer read failed!'); 
        end
    end
end
    
[RE,IM] = load_fid( fullfile(directory, 'fid') );
k=single(complex(RE, IM));

end
