function [pc,rox] = epi_pc_1d_nav_get(nav)
% EPI_PC_1D_NAV_GET 1d EPI nyquist phase correction using navigators
%
% Usage: 
%   [pc,rox] = epi_pc_1d_nav_get(nav)
%   s(:,2:2:end,:) = bsxfun(@times, s(:,2:2:end,:), exp(i*polyval(pc, rox)));
%
% Inputs:
%   nav:    input navigator kspace data
%           dimensions: [ro, nnav, nviews]
%           
%           nviews represents the number of different navigator views, this
%           can be different slices, or different coils, etc.
%
% Outputs:
%   pc:     phase corr (pc(1) = slope, pc(2) = intercept)
%   rox:    readout axis
%           
%   Multiply exp(i*polyval(pc, rox)) onto each even phase encoded line.
% AZL & JJM, 2014
        s = size(nav);
        if(ndims(s)<3) 
            s(3) = 1;
        end
        ro = s(1);
        ns = s(3);

        % Apply 1D fft in readout
        nav = fftshift(fft(fftshift(nav,1),size(nav,1),1),1);
        navP = mean(nav(:,1:2:end,:),2);
        navN = mean(nav(:,2:2:end,:),2);
        navRatio = squeeze(navP .* conj(navN));
        phi = angle(navRatio);
        w   = abs(navRatio);
        % relative weight for each slice
        ws = sum(w, 1);
        
        % least squares fit
        % weights are abs(navRatio)
        rox = (1:ro).'; % axis for readout
        A = [ rox  ones(ro,1) ];
        pc = zeros(2,ns);
        for idx = 1:ns
            pc(:,idx) = lscov( A, phi(:,idx), w(:,idx) );
        end
        % Average results with weights  
        
        pc = sum( bsxfun(@times,pc,ws),2 )/sum(ws);
        
        % Average the slopes
        pca(1) = sum(pc(1,:).*ws)/sum(ws);
        % Circular average on the constant term
        pca(2) = angle(sum(exp(i*pc(2,:)).*ws) / sum(ws));

        pc = pca;
end
