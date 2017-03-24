function res = sos(x ,dim, pnorm)
%
% function computes the square root of sum of squares along dimension dim.
% If dim is not specified, it computes it along the last dimension.
%

if nargin < 2
    dim = size(size(x),2);
end

if nargin < 3
    norm = 2;
end


res = (sum(abs(x.^norm),dim)).^(1/norm);
