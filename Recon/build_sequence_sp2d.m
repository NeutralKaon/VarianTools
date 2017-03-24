%
% BUILD_SEQUENCE_SP2D Build 2d spiral sequence using readout gradients
%
% Usage: 
%   [ g,k ] = build_sequence_sp2d( directory );
%
% Inputs:
%   directory:     data directory
%          
% Outputs:
%   g:  gradient waveform
%   k:  k-space
% AZL & JJM 2016

function [ gr,kr,kr_max,params ] = build_sequence_sp2d( directory )

params = readprocpar( directory );

points_before_read  = params.nBeforeRead;
try
    nSample             = params.nSamples;
catch
     nSample             = params.np/2;
end

nshots              = params.nshots;
radialAngleRange    = params.radialAngleRange;

[g_ro, p_ro] = read_GRD_format([directory '/ro1.GRD']);
[g_pe, p_pe] = read_GRD_format([directory '/pe1.GRD']);

g_ro = (g_ro/32768) * p_ro.STRENGTH;
g_pe = (g_pe/32768) * p_pe.STRENGTH;

gr = g_ro + 1i*g_pe;

gr = gr(points_before_read+1:points_before_read+nSample);
kr = cumtrapz(gr);

angles = [0:nshots-1]/nshots*radialAngleRange*pi/180;
angles = -angles;

kr = bsxfun(@times, kr, exp(i*angles));

kr_max = max(abs(kr(:)));

kr = kr/kr_max*0.5;

end
