function [image, k, raw, params, dn, varargout] =reconVarian(dn, varargin)
% Recon Varian gradient or spin echo sequences, 1, 2 or 3D.
% [image, k, raw, params, dn, varargout] =reconVarian(dn, varargin)
%
% Input: dn, the directory name of the sequence in question
% (i.e. /path/to/fid.fid)
%
% Output:
%   image -- the reconstructed image
%   k -- its reconstructed N-dimensinal Fourier transform
%   raw -- the unreshaped, raw data
%   params -- Acquisition parameters, from procpar
%   dn -- the input directory name
%   Varargout -- if a multi-coil acquisition has been performed,
%   varargout{1} will contain an attempt at a reconstruction from each
%   element, according to the McKenzie method. Note that, due to the lack
%   of noise samples, this might not be artefact free.
%
% JM, 2014.


% Parse directory name
if strcmp(dn(end),'/')
    dn=dn(1:end-1);
end
if strcmp(dn(end-4:end),'/fid')
    dn=dn(1:end-4);
end;

if dn ~= 0
    [raw, params] = load_varian(fullfile(dn),1 );
else
    error('No filename supplied.');
end

sequence=params.seqfil{:};
fileName=params.file{:};

CartesianTwoD={'gems','sems','gems_fc','gems_fc_k','ge2d_t2w_bmru_jjm'};
CartesianThreeD={'ge3d','se3d'};
Cine={'cine_ge2d_work_old'};
OneD={'spuls'};
SegmentedTwoDee={'ge_2dseg_work_old'};
SegmentedThreeDee={'ge3dseg_fc_bmru'};
Flow={'gems_fc_k_jjm'};
varargout{1}=[];

if any(strcmp(sequence,CartesianTwoD))
    nc=params.rcvrs{:};
    nchannel = sum(nc(:)=='y');
    nread    = params.np/2;
    nphase   = params.nv;
    nslice  = params.ns;
    if length(params.pss) >1 
        if length(params.pss) ~= params.ns
            nslice=length(params.pss);
        end
        
        if params.sliceorder == 1 
            [~,sliceorder]=sort(params.pss); 
        end
    end
            
    %nechoes = length(params.array)/nchannel; %super dodgy, seems to work...
    nechoes=params.arraydim/nchannel;
    %if nchannel>1
    if any(strcmp(sequence,{'sems'}))
        nechoes=params.arraydim/(nphase*nchannel);
        x = reshape(raw, [nread,  nslice, nechoes, nchannel, nphase]);
        k = permute(x, [1 5 2 4 3]);  %Read phase slice coils echoes 
        
    else
        temp=zeros(nread,nphase.*nechoes.*nchannel);
        k=zeros(nread,nphase,nslice,nchannel,nechoes);
        try
            for i=1:nslice
                temp(:,:)=raw(:,i:nslice:end);
                k=reshape(temp,[nread,nphase,nslice,nchannel,nechoes]);
            end
        catch
            for i=1:nslice
                temp(:,:)=raw(:,i:nslice:end);
                k(:,:,i,:,:)=reshape(temp,[nread,nphase,1,nchannel,nechoes]);
            end
        end
    end
    %else
    
    %     temp=zeros(nread,nphase.*nechoes);
    %     k=zeros(nread,nphase,nslice,nchannel,nechoes);
    %     for i=1:nslice
    %         temp(:,:)=raw(:,i:nslice:end);
    %         for j=1:nechoes
    %             k(:,:,i,:,j)=temp(:,((j-1)*(end/nechoes)+1):j*(end/nechoes));
    %         end
    %     end
    %    end
    if (params.sliceorder==1 && nslice > 1 )
        k=k(:,:,sliceorder,:,:);
    end
    k=conj(k); %This is always the case with Varian data
    image=fft2c(k);
    
    
    
elseif any(strcmp(sequence,Cine))
    nc=params.rcvrs{:};
    nchannel = sum(nc(:)=='y');
    
    if nchannel > 1
        error('Multi-coil CINE recon not yet implemented');
    end
    nread    = params.np/2;
    nphase   = params.nv;
    nslices=length(params.pss);
    nframes = size(raw,2)/nslices/nphase;
    %Might not work with multislice
    
    k=zeros(nread,nphase,nframes,nslices);
    temp=zeros(nread,nphase.*nslices);
    
    for i=1:nframes
        temp(:,:)=raw(:,i:nframes:end);
        for j=1:nslices
            k(:,:,i,j)=temp(:,((j-1)*(end/nslices)+1):j*(end/nslices));
        end
    end
    k=conj(k);
    image=fft2c(k);
    
elseif any(strcmp(sequence,CartesianThreeD))
    nread=params.np/2;
    nphase=params.nv;
    nphase2=params.nv2;
    narrays = length(params.array{:});
    nc=params.rcvrs{:};
    nchannels = sum(nc(:)=='y');
    
    if (narrays==0) && (nchannels==1)
        k=squeeze(reshape(raw,nread, nphase, nphase2,nchannels));
        image=fftnc(k,[1 2 3]);
    elseif (nchannels>1) && (narrays==0)
        k=zeros(nread,nphase,nphase2,nchannels); 
        for i=1:nphase
            a=raw(:,i:nphase:end); 
            k(:,i,:,:)=permute(reshape(a,[nread nchannels nphase2]),[1 3 2]);
        end
        image=fftnc(k,[1 2 3]); 
    elseif narrays > 0
        warning('Arrayed multicoil 3D scan recon is not yet impelemented.')
    end
    
elseif any(strcmp(sequence,OneD))
    image=fftc(raw);
    k=raw;
elseif any(strcmp(sequence,SegmentedTwoDee))
%Below kindly from AZL
    np = params.np/2;
    nv = params.nv;
    %Jack 
    % ns = numel(params.pss) + numel(params.te) -1 ;
    ns = length(params.pss); 
    ne = length(params.te); 
    
    raw = reshape(raw, [np nv ns ne]);
    
    rawa = 0*raw;
    rawa(:, params.pelist + nv/2 + 1, :,:) = raw;
    raw = rawa;
    
    % zeropad in readout for echopos
    echopos = params.echopos;
    s_echopos = size(raw);
    s_echopos(1) = round(2 * (0.5 - echopos) * np);
    echopad = zeros( s_echopos );
    raw = cat(1, echopad, raw);
    
    try
        raw = crop(raw, [np nv ns ne]);
    catch
        raw = crop(raw, [np nv]);
    end
    
    % Deal with partial fourier if appropriate 
    
    kf = raw;
    if (params.echopos ~= 0.5)
        for ix = 1:ns
            try
                 [~, kf(:,:,ix)] = pocs(raw(:,:,ix));
            end
        end
    end
    im = ifft2c(kf);
%    im = flipdim(im, 2);
%    im = flipdim(im, 3);
    k=kf;
    image = im;
    
    
%     nread=params.np/2;
%     nphase=params.nv;
%     nslices=length(params.pss); %JM may 16
%     %nslices=params.ns;
%     
%     if nslices > 1
%      %   error('Multislice recon not yet impelemnted');
%     end
%     
%     narrays=params.arraydim;
%     
%     temp=zeros(nread,nphase);
%     k=zeros(nread,nphase,narrays);
%     for i =1:narrays
%         temp=raw(:,(i-1)*nphase+1:i*nphase);
%         temp=temp(:,nphase/2+1+params.pelist); %Reshape trajectory;
%         
%         k(:,1:2:end,i)=temp(:,1:nphase/2);
%         k(:,2:2:end,i)=temp(:,nphase/2+1:end);
%     end
%     
%     %Correct for phase ramps;
%     N=nphase;
%     k=bsxfun(@times,exp(-1i*2*pi*([0:N-1]*(2*params.etl)/N)),k);
%     image=fft2c(k);
    
elseif any(strcmp(sequence,SegmentedThreeDee))
    nread=params.np/2;
    nphase=params.nv;
    nphase2=params.nv2;
    nechoes=params.arraydim;
    
    temp=zeros(size(raw,1), size(raw,2)/nechoes, nechoes);
    temp2=zeros(nread,nphase,nphase2,nechoes);
    
    for j=1:nechoes
        temp(:,:,j)=raw(:,(j-1)*end/nechoes+1:j*end/nechoes);
    end
    
    for j=1:nechoes
        for i=1:nphase2;
            temp2(:,:,i,j)=temp(:,(i-1)*nphase+1:i*nphase,j);
            temp2(:,:,i,j)=temp2(:,nphase/2+params.pelist,i,j);
        end
    end
    
    k=temp2;
    image=fftnc(k,[1 2 3]);
    
    %     for i=1:nechoes
    %         temp=raw(:,(i-1)*nphase+1:i*nphase);
    %         temp=temp(:,nphase/2+params.pelist); %Reshape trajectory;
    %
    %         k(:,1:2:end,i)=temp(:,1:nphase/2);
    %         k(:,2:2:end,i)=temp(:,nphase/2+1:end);
    %     end
    
elseif any(strcmp(sequence,Flow))
    nread=params.np/2;
    nphase=params.nv;
    nslices=params.ns;
    narrays=params.arraydim; 
    k=reshape(raw,[nread, nphase, nslices, narrays]); 
    image=fft2c(k);    
else
    error('Recon not yet implemented for sequence file %s',sequence);
end

