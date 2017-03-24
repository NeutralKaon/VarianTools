function out = imshift_offcentre_modulate( kdata,kx,ky,kz,shift )
% imshift_offcentre_modulate
%
%   Phase-modulate 3d k-space data to produce a shift in image space.
%   This uses the k-space trajectory.
%
% Usage:
%   % Full 3D
%   kdata = imshift_offcentre_modulate( kdata,kx,ky,kz,shift )
%
%   % 2D
%   kdata = imshift_offcentre_modulate( kdata,real(k),imag(k),[],shift )
%
% Input:
%
%  kdata:    raw complex kspace data, dim: (Read,Lines, ...)
%  kx,ky,kz: components of a 3d kspace trajectory, dim: (Read, Lines)
%            Set inputs to [] if the trajectory is less than 3d.
%  shift:    real 3x1 vector containing pixel-shifts [dx,dy,dz]

if nargin < 5
    error('Not enough arguments');
end

s      = size(kdata);
s_traj = s(1:2);

if isempty(kx)
    kx = zeros(s_traj);
end

if isempty(ky)
    ky = zeros(s_traj);
end

if isempty(kz)
    kz = zeros(s_traj);
end

if numel(shift)<3
    shift(end+1:3) = 0;
end

shift_phase = kx * shift(1) + ky * shift(2) + kz * shift(3);

out = bsxfun(@times, kdata, exp(-i*pi*shift_phase));