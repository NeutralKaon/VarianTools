function [ res ] = fftnc( x, dim )
% FFTNC N-dimensional Fourier transform with padding
%
% Usage: [ res ] = fftnc(x, [dim])
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
    res = fftc(res,dim(idx));
end

end