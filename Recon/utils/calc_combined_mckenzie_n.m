function [ im_COMBINED, ccm, csm ] = calc_combined_mckenzie_n( im )
%CALC_COMBINED_MCKENZIE Does coil combination using McKenzie's method.
%   
%   uses code from ISMRM 2013 sunrise session on parallel imaging
%
% Usage:
%   [ im_COMBINED ] = calc_combined_mckenzie( im );
%
% Inputs:
%   im - [X,Y,Coil] or [X,Y,Coil,Z] or [X,Y,Coil,Z,...]
%
% Outputs:
%   im_COMBINED - [X,Y] or [X,Y,Z]

s = size(im);

if ndims(im) > 4
    im = reshape(im, [ s(1:3) prod(s(4:end)) ]);
else
    s(4) = 1;
end

if nargout > 1
    [im_COMBINED, ccm, csm] = calc_combined_mckenzie(im);
else
    [im_COMBINED] = calc_combined_mckenzie(im);
end

im_COMBINED = reshape( im_COMBINED, [ s(1:2) s(4:end) ] );

if nargout > 1
    ccm = reshape( ccm, s );
    csm = reshape( csm, s );
end

end

