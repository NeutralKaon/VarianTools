function fdfwrite_directory( output_directory, im, params )
% fdfwrite_directory
%   Write 4D image array as .fdf files.
%
%   Inputs:
%   output_directory: path for data
%   im: [read, phase, slice, images]
%   params: procpar array
%

ns = size(im,3);
ni = size(im,4);

in_params = params;
list = {'te','tr','ti','psi','phi','theta'};
% Fix the arrayed parameter for fdf.
for ix = 1:numel(list)
    in_params.(list{ix}) = select(in_params.(list{ix}), 1);
end

for ix_s = 1:ns
for ix_i = 1:ni
	slice = ix_s;
	image = ix_i;
	echo  = 1;
	
	disp(sprintf('writing slice = %d/%d, image = %d/%d, echo = %d/%d', slice, ns, image, ni, echo, 1));
    fname = sprintf([output_directory '/slice%03dimage%03decho%03d.fdf'], slice, image, echo);
    fdfwrite(fname, im(:,:,ix_s,ix_i).', in_params, slice, image, echo);
end
end

end

function y = select(v, ix)
   if numel(v) > 1
	y = v(ix);
   else
	y = v;
   end
end
