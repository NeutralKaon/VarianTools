function [ res ] = fft2c( x )
% FFTNC 2-dimensional Fourier transform with padding
%
% Usage: [ res ] = fft2c(x)
%
% Inputs: 
%   x:      n-d array

res = fftnc(x, [1 2]);

end

