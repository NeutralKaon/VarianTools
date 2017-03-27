function [ n ] = extract_noise_mean( im, mask )
%EXTRACT_NOISE_MEAN Extract noise mean from stack of images.
%   [ n ] = extract_noise_mean( im, mask )
%
%   im is [X,Y, ...]
%   mask is [X,Y]
%
%   n is the mean of the magnitude image taken across all images in stack

n = bsxfun(@times, im, mask);
n(n==0) = nan;
n = nanmean(n(:));

end

