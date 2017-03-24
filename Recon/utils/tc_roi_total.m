% TC_ROI_TOTAL Time course function
%
% Usage: [tc,tcstd] = tc_roi(im,roi)
%
% Takes 4d image [xres yres Nt num_slices]
% and region of interest [xres yres 1 num_slices]
% and calculates time course for each slice

function [tc,tcstd,roi_size] = tc_roi_total(im, roi)
    N = size(im);
    
    Nt = N(3);
    
    if size(N)<4
        num_slices = 1;
    else
        num_slices = N(4);
    end

    tc = zeros(Nt,1);
    tcstd = zeros(Nt,1);

    roi_tmp = roi(:,:,1,:);
    for k=1:Nt
        im_tmp = im(:,:,k,:);

        tc(k) = mean(im_tmp(roi_tmp));
        tcstd(k) = std(im_tmp(roi_tmp));
    end

    roi_size = length(find(roi));
