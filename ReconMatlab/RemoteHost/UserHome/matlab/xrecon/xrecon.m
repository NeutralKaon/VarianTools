function xrecon( data_directory, output_directory )

% reconVarianLite returns a 4D array of images: [nread, nphase, nslice, nimages]
[im, params] = reconVarianLite( fullfile(data_directory) ); 

IMMODE = @abs;
% IMMODE = @real;
% IMMODE = @angle;
im = IMMODE(im);

%mask = abs(im(:,:,1));
%mask = mask / max(abs(mask(:)));
%mask = mask > 0.1;
%im = angle( im(:,:,1) .* conj(im(:,:,3)) );
%im = im.*mask;

fdfwrite_directory( output_directory, im, params );

end


