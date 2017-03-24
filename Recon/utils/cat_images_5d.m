% cat_images_5d
% 5d: [xres yres Nt num_slices num_channel]
% put into 3d matrix [num_slices x Nt] of images x [num_channel] 
function im_cat = cat_images(im, do_normslice, cat_orientation)

    if(nargin<2)
        do_normslice=0;
    end
    if(nargin<3)
        cat_orientation=1;
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

    nc = size(im,5);

    % allocate:
    im_cat = zeros(yres * num_slices, xres*Nt, nc);
    for j=1:nc
        im_cat(:,:,j) = cat_images(im(:,:,:,:,j), do_normslice, cat_orientation);
    end
