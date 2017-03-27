function [image, params] = reconVarianLite(dn, varargin)
% reconVarianLite 
% [image, params] = reconVarianLite(dn, varargin)
%
% Input: dn, the directory name of the sequence
% (i.e. /path/to/fid.fid)
%
% Output:
%   image -- the reconstructed image
%	dimensions: [nx,ny,slice,images]
%   params -- Acquisition parameters, from procpar
%
% JM, 2014.

[raw, params] = load_varian(fullfile(dn),1 );
seqfil = params.seqfil{:};

% Sequence list

sequences = containers.Map;
sequences('gems') = 'im2D';
sequences('sems') = 'im2D';
sequences('gems_fc') = 'im2D';
sequences('gems_fc_k') = 'im2D';

sequences('ge3d') = 'im3D';
sequences('se3d') = 'im3D';

sequences('cine_ge2d_work_old') = 'cine';

sequences('ge_2dseg_work_old') = 'im2Dseg';
sequences('ge3dseg_fc_bmru')  = 'im3Dseg';

sequences('spuls') = '1D';

sequences('AZL_mrad2d_k') = 'radial_selfgated';

if (isKey(sequences, seqfil))
    reconMode = sequences(seqfil);
else
    reconMode = [];
end

switch (reconMode)
    case 'im2D'
        nchannel = length(params.rcvrs{:}=='y');
        nread    = params.np/2;
        nphase   = params.nv;
        nslice   = params.ns;
        nimages  = params.arraydim;
        nechoes  = params.ne;

        k = reshape(raw, [nread nslice nphase nchannel nechoes nimages]);
        k = permute(k, [1 3 2 6 5 4]);
        
        image = ifft2c(k); 
        image = sos(image, 6);

    case 'im3D'
        nchannel = length(params.rcvrs{:}=='y');
    	nread   = params.np/2;
    	nphase  = params.nv;
	    nphase2 = params.nv2;
	    nimages = params.arraydim; 
        k = reshape(raw, [nread, nphase, nchannel, nphase2, nimages]);
	    k = permute(k, [1 2 4 5 3]);
        image = ifftnc(k, [1 2 3]);

        image = sos(image, 5);

    case 'cine'
    case 'im2Dseg'
        % JM June 2016 -- B0 map
        if length(params.te == 2) 
            try
            image=ReconB0Map(dn); 
            catch
            image=reconVarian(dn);
            end
        else
            image=reconVarian(dn);
        end
    case 'im3Dseg'
    case '1D'

    case 'radial_selfgated'

        %JM June 2016
        % output is [nx,ny,nt1,nt2]
        if (isfield(params, 'nphases_cardiac'))
            nphases_cardiac = params.nphases_cardiac;
        else
            nphases_cardiac = 16;
        end
        if (isfield(params, 'nphases_resp'))
            nphases_resp = params.nphases_resp;
        else
            nphases_resp = 1; 
        end 

        image = recon_mrad2d_selfgating(dn, nphases_cardiac, nphases_resp);
        image = permute(image, [1 2 5 3 4]);

    otherwise
      error('seqfil not supported');
end 

% Reshape images so that they are 4D:
image = image(:,:,:,:);
