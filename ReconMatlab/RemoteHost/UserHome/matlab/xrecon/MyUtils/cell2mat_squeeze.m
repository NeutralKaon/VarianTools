function [ M ] = cell2mat_squeeze( C )
%CELL2MAT_SQUEEZE Converts cell of arrays to matrix.
%
%   [M] = cell2mat_squeeze(C) converts a cell C containing N arrays of size
%   S to a matrix M of size (S,N).

if (iscell(C))
    nd = ndims(C{1});
    C = reshape( C, [ ones(1,nd) numel(C) ] ); 
    M = cell2mat(C);
else
    M = C;
end

end

