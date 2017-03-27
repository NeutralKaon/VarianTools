function im2Dxrecon( data_directory, output_directory )

[im, k, raw, params, dn] = reconVarianLite( fullfile(data_directory) ); 

ns = params.ns;
ne = params.ne;
na = params.arraydim;

IMMODE = @abs;
% IMMODE = @real;

im = IMMODE(im);

% expand parameters which are arrayed
params = arrayParser(params);

for ix_s = 1:ns
for ix_a = 1:na
for ix_e = 1:ne
  slice = ix_s;
  image = ix_a;
  echo = ix_e;

  in_params = params;
  list = {'te','tr','ti','psi','phi','theta'};
  for ix = 1:numel(list)
    in_params.(list{ix}) = select(in_params.(list{ix}), ix_a);
  end

  disp(sprintf('writing slice = %d/%d, image = %d/%d, echo = %d/%d', slice, ns, image, na, echo, ne));
  fname = sprintf([output_directory '/slice%03dimage%03decho%03d.fdf'], slice, image, echo);
  fdfwrite(fname, im(:,:,ix_s,ix_a,ix_e).', in_params, slice, image, echo);
end
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
