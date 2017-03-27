function [ out ] = cellflat( C )
%cellflat Flattens a cell array.
%
%   C = { 1, {2,3}, {5,6} };
%   [ out ] = cellflat( C );
%
%   out = 
%       [1]    [2]    [3]    [5]    [6]

out = {};

for idx = 1:numel(C)
    if (~iscell(C{idx}))
        out = [out, C{idx}];
    else
        C_temp = cellflat( C{idx} );
        out = [out, C_temp{:}];
    end
end    

end

