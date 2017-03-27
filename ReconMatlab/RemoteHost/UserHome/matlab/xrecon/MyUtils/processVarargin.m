% Allow varargin to hold either a struct or a list of field / value pairs.
%
% If parameters are specified more than once, the final value is used.
%
% [options] = processVarargin(varargin)
%
% Example 1:
%
% To use this in a function, add code as follows:
%
% function [ ... ] = myfunction(param1, param2, ... , varargin)
% ...
% % Read options from varargin
% options = processVarargin(varargin{:});
%
%
% Example 2:
%
% inputStruct = struct('abc',1);
% inputStruct.def = {23};
% options = processVarargin(inputStruct);
% options2 = processVarargin('abc',1,'def',{23});
%
% After running this code, inputStruct, options and options2 will all be
% the same.


function [options] = processVarargin(varargin)

if numel(varargin)==0
    options = struct();
elseif mod(numel(varargin),2)==1
    if numel(varargin)==1 && isstruct(varargin{1})
            options = varargin{1};
    else
        error('Input must either be a single structure or a list of field / value pairs')
    end
else
    % Wrap any cell arrays before passing in to struct()
    for idx=2:2:numel(varargin)
        if iscell(varargin{idx})
            varargin{idx} = {varargin{idx}};
        end
    end
    
    try
        options = struct(varargin{:});
    catch ME
        if strcmp(ME.identifier,'MATLAB:DuplicateFieldName')
            fn = varargin(1:2:end);
            val = varargin(2:2:end);
            
            [fn, fnDx] = myUnique(fn);
            val = val(fnDx);
            
            tmp = reshape([fn; val],1,[]);
            options = struct(tmp{:});
        else
            ME.throwAsCaller();
        end
    end
end
end

function [out,dx] = myUnique(in)
% unique is changing in R2012a so roll our own

[tmpSort, tmpSortDx] = sort(in);
mask = true(size(tmpSort));
for idx=numel(tmpSort)-1:-1:1
    if isequal(tmpSort(idx+1),tmpSort(idx))
        mask(idx) = false;
    end
end

out = tmpSort(mask);
dx = tmpSortDx(mask);

end
