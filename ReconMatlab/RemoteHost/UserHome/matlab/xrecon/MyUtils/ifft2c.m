function [ res ] = ifft2c( x )
% IFFTNC 2-dimensional Fourier transform with padding
%
% Usage: [ res ] = ifft2c(x)
%
% Inputs: 
%   x:      n-d array

res = ifftnc(x, [1 2]);

end

