% cat_images_helper
% takes 4d image [xres yres Nt num_slices]
% and puts it into a 2d matrix [num_slices x Nt] of images
%
% cat_orientation = 1 (default) if row=time,col=slice
%                 = 2 if row=slice,col=time
function im_cat = cat_images(im,do_normslice, cat_orientation)
    if(nargin<2)
        do_normslice=0;
    end
    if(nargin<3)
        cat_orientation=1;
    end

    switch cat_orientation
        case {1,'row'}
        case {2,'col'}
            im = permute(im,[1 2 4 3]);
    end

    N = size(im);
    num_dims = ndims(im);
    
    % build concatenated image based on input dimensions
    if (num_dims == 2)
        Nt = 1;
        num_slices = 1;
    elseif (num_dims == 3)
        Nt = N(3);
        num_slices = 1;
    else
        Nt = N(3);
        num_slices = N(4);
    end;
    
    xres = N(2);
    yres = N(1);
    %Nt = N(3);
    %num_slices = N(4);
        
        
        
    im_cat = zeros( yres*num_slices, xres*Nt );
    
    % do each slice separately
    for j=1:num_slices
        im_tmp = zeros(yres,xres*Nt);
        
        for k=1:Nt
            im_tmp(1:yres,(k-1)*xres+1:k*xres) = im(:,:,k,j);
        end;
        
        if(do_normslice)
            m = max(abs(im_tmp(:)));
            im_tmp = im_tmp/m;
        end
        
        im_cat( (j-1)*yres+1:j*yres, : ) = im_tmp;
    end;
