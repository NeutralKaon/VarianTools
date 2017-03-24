function [ im_COMBINED, ccm, csm ] = calc_combined_mckenzie( im, cal_shape )
%CALC_COMBINED_MCKENZIE Does coil combination using McKenzie's method.
%
%   Uses code from ISMRM 2013 sunrise session on parallel imaging
%
% Usage:
%   [ im_COMBINED ] = calc_combined_mckenzie( im );
%   [ im_COMBINED, ccm, csm ] = calc_combined_mckenzie( im );
%
% Inputs:
%   im - [X,Y,Coil] or [X,Y,Coil,Z] or [X,Y,Coil,Z,...]
%
% Outputs:
%   im_COMBINED - [X,Y] or [X,Y,Z]

s = size(im);
n_RO = s(1);
n_PE = s(2);

if ndims(im) > 2
    n_CH = s(3);
else
    n_CH = 1;
    s(3) = n_CH;
end

if ndims(im) > 3
    n_SL = prod(s(4:end));
else
    n_SL = 1;
    s(4) = n_SL;
end

s_final = s;
s_final(3) = 1;

im = reshape(im, [n_RO n_PE n_CH n_SL]);
imsize = [n_RO n_PE];

if nargin < 2
    cal_shape = [n_RO n_PE];
end

cal_data = ismrm_transform_image_to_kspace(im, [1 2], cal_shape);

f = hamming(cal_shape(1)) * hamming(cal_shape(2))';
fmask = repmat(f, [1 1 n_CH n_SL]);
filtered_cal_data = cal_data .* fmask;

clear cal_data fmask f

cal_im = ismrm_transform_kspace_to_image(filtered_cal_data, [1 2], imsize);

csm = zeros(n_RO, n_PE, n_CH, n_SL);
ccm = zeros(n_RO, n_PE, n_CH, n_SL);

for idx = 1:n_SL
    csm(:,:,:,idx) = ismrm_estimate_csm_mckenzie(cal_im(:,:,:,idx));
    csm(:,:,:,idx) = ismrm_normalize_shading_to_sos( csm(:,:,:,idx) );
    ccm(:,:,:,idx) = ismrm_compute_ccm( csm(:,:,:,idx) );
end

% ---------------------------------------------------------
% calculate the combined map
% alau@cardiov 27.02.2014 return complex.
%   this may break some code.
% im_COMBINED = abs(sum(im .* ccm, 3));
im_COMBINED = (sum(im .* ccm, 3));

im_COMBINED = reshape(im_COMBINED, s_final);
ccm = reshape(ccm, s);
csm = reshape(csm, s);


end

