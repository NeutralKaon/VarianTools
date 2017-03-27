function [pathname, im] =B0mapArrayed(varargin)
% Plot a B0 map from a Varaian GEMS scan acquired at two echo times.
% Optional inputs (1): directory, a path/to/the/fid.fid directory;
%                 (2): Thresh, a different value for the threshold-based
%                 segmentation used to calculate statistics (default 5%).
% JM '14


if nargin==0
    [pathname]=uigetdir('','Select a Gems FID with arrayed Te');
    thresh=0.01;
    
elseif nargin == 1
    pathname=fullfile(varargin{1});
    thresh=0.01;
elseif nargin == 2
    pathname=fullfile(varargin{1});
    thresh = varargin{2};
end

%% Load fid
if pathname ~= 0
    [raw, params] = load_varian(pathname,1 );
else
    error('Cancel clicked');
end

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
    [im]=reconVarian(pathname);
    if ndims(im) == 3
        im=permute(im,[1 2 4 3]); 
    end
    
end
p1=angle(im(:,:,:,1)./im(:,:,:,2));
s=im.*conj(im); %Magnitude image

m1=abs(s)>thresh*max(abs(s(:)));
m2=m1(:,:,:,1) | m1(:,:,:,2);



DeltaTE=params.te(2)-params.te(1);
map=squeeze((m2.*p1)/(2*pi*DeltaTE)); 

fprintf('--------------- B0 Map results ---------------\n');
fprintf('Mean Delta-B: %.2f (Hz)\n     Std-Dev: %.2f (Hz)\n    Kurtosis: %.2f\n',mean(map(:)), ...
    std(map(:)), kurtosis(map(:)));
fprintf('----------------------------------------------\n');


viewimage(map,'colormap','hsv','Title','B0 Map (Hz)','zoom','4');
[n, x]=hist(map(map~=0),150);
figure; stairs(x,n);
title('Approximate spectrum');
xlabel('Freq. (Hz)');
ylabel('Intensity (a.u)');
viewimage(im,'colormap','gray','Title','Anatomy','zoom','4');
