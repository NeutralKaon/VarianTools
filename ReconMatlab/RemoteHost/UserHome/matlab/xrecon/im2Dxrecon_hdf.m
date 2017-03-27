function im2Dxrecon( data_directory )

im2d = reconVarian( fullfile(data_directory) ); 

%Binary blob here. 

% make sure this doesn't exist
output_name = [data_directory '/out.h5'];
imsize = size(im2d);

try
h5create(output_name, '/real', imsize);
h5create(output_name, '/imag', imsize);
end

h5write(output_name, '/real', real(im2d));
h5write(output_name, '/imag', imag(im2d));

end
