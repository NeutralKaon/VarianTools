function [ h ] = fill_between_vertical( X, C, alpha, LARGE_VALUE )
%FILL_BETWEEN_VERTICAL Fill between x-coordinates.
%
%   [ h ] = fill_between_vertical( X, C, alpha )
%
%   X = 2-component vector containing endpoints
%   C = colour for filled polygon (default 'b')
%
%    If C is a single character string chosen from the list 'r','g','b',
%    'c','m','y','w','k', or an RGB row vector triple, [r g b], the
%    polygon is filled with the constant specified color.
%
%   alpha = transparency (default 0.5)
%
%   LARGE_VALUE = shade between these values (default 1e10).

if (nargin < 2)
    C = 'b';
end

if (nargin < 3)
    alpha = 0.5;
end

if (nargin < 4)
    LARGE_VALUE = 1e10;
end

Y = [LARGE_VALUE LARGE_VALUE];
h = fill( [X fliplr(X)],  [Y fliplr(-Y)], C );

set(h, 'FaceAlpha', alpha);
set(h, 'EdgeColor', 'None');

end

