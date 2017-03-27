function [ xn ] = normalize_to_maximum( x )
%NORMALIZE_TO_MAXIMUM Normalizes an array to the absolute maximum.
% Usage:
%   [xn] = normalize_to_maximum(x);

xn = x / max(abs(x(:)));

end

