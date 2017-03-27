function [ res ] = ifftnc( x, dim )
% IFFTNC N-dimensional I-Fourier transform with padding
%
% Usage: [ res ] = ifftnc(x, [dim])
%
% Inputs: 
%   x:      n-d array
%   dim:    vector containing dimensions to fft
%           default: 1 (column), 2 (row)

if nargin < 2
    if (iscolumn(x))
        dim = 1;
    else
        dim = 2;
    end
end

res = x;
for idx = 1:numel(dim)
    res = ifftc(res,dim(idx));
end

end

