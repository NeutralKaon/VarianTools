function [ out ] = flipxy( in )
%FLIPXY Flips x and y dimensions.

out = flipdim( flipdim( in, 1) ,2);


end

