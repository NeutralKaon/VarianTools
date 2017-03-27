function [ C ] = mat2cell_squeeze( M )
%MAT2CELL_SQUEEZE Converts n-dimensional matrix to cell.
%
%   [C] = mat2cell_squeeze(M) converts a n-dimensional matrix M of size 
%   (S,N) to cell C containing N arrays of size S.

if (isnumeric(M))
  
    nd = ndims(M);
    S = size(M);
    C = cell(1,S(nd));
    
    Mr = permute(M, [nd 1:nd-1]);
    
    for j=1:S(nd)
        C{j} = reshape( squeeze(Mr(j, :)), S(1:nd-1) );
    end
else
    C = M;
end

end

