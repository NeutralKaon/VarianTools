function [out] = ReconB0Map(dn) 
% Recon & mask out multiecho segmented GE2D or GE data 
% Input: /path/to/directory.fid/ 
% Output: masked out 3D map (multi-slice) 
% Errors would be given if numel(te) ~= 2. 
% JM '16 


        [raw, params] = load_varian(dn,1 );
        thresh=0.01; %Threshold for mask -- this seems to work quite well.


        if strcmp(params.seqfil,'gems')
        %%
            nchannel = length(params.rcvrs{:}=='y');
            % Parameters
            nread    = params.np/2;
            nphase   = params.nv;
            nslice  = params.ns;
            nechoes = length(params.te);

            if ((nechoes ~= 2 ) || (nchannel ~= 1))
                warning('Multiecho or multicoil not yet implemented');
            end

            %% Reshape

            temp=zeros(nread,nphase.*nechoes);
            k=zeros(nread,nphase,nslice,nechoes);

            for i=1:nslice
                temp(:,:)=raw(:,i:nslice:end);
                for j=1:nechoes
                    k(:,:,i,j)=temp(:,((j-1)*(end/nechoes)+1):j*(end/nechoes));
                end
            end

            im=fft2c(conj(k));
        else
            [im]=reconVarian(dn);
            if ndims(im) == 3
                im=permute(im,[1 2 4 3]); 
            end
        end
        % Construct map 
        p1=angle(im(:,:,:,1)./im(:,:,:,2));
        s=im.*conj(im); %Magnitude image

        m1=abs(s)>thresh*max(abs(s(:)));
        m2=m1(:,:,:,1) | m1(:,:,:,2);
        DeltaTE=params.te(2)-params.te(1);
        map=squeeze((m2.*p1)/(2*pi*DeltaTE)); 

        fprintf(1,'--------------- B0 Map results ---------------\n');
        fprintf(1,'Mean Delta-B: %.2f (Hz)\n     Std-Dev: %.2f (Hz)\n    Kurtosis: %.2f\n',mean(map(:)), ...
                        std(map(:)), kurtosis(map(:)));
        fprintf(1,'----------------------------------------------\n');
        out=map;
end
