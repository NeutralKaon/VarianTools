function [ im_shift ] = shiftFOV( im, varargin )
%SHIFTFOV Circularly shifts the FOV for each slice position
%
% Usage: 
%
% idx_centre = 1;
% [ im_shift ] = shiftFOV( im, 'order','ascending', 'centre', idx_centre);
%
% Inputs:
%   im:     dimensions [X,Y,Channel,Slice, ...]
%
% Options:
%   order:  [ascending], descending
%   centre: index for isocentre (after MB phase correction)
%   debug:  [false], true


options = processVarargin(varargin{:});
% Scan through options setting essential fields
optionsDefaults = {...
    'debug', false; ...
    'centre', 1; ...
    'order', 'ascending'; ...
    'multibandFactor', 0 };
options = setDefaultStruct(options, optionsDefaults);

s = size(im);
nPE    = s(2);
nSlice = s(4);

if options.multibandFactor == 0
    nMB = nSlice;
else
    nMB = options.multibandFactor;
end

switch options.order
    case 'ascending'
        order_sign = -1;
    case 'descending'
        order_sign = 1;
    otherwise
        fprintf('invalid order, setting to ascending...\n');
        order_sign = -1;
end

if (options.centre > nSlice || options.centre < 1)
    fprintf('centre = %d invalid and not in [1, %d], setting to 1\n', ...
        options.centre, nSlice);
    options.centre = 1;
end

if (options.debug)
    fprintf('Shifting FOV ...\n');
    fprintf('order:        %s\n', options.order);
    fprintf('centre index: %d\n', options.centre);
    fprintf('phase encodes: %d\n', nPE);
    fprintf('number of slices: %d\n', nSlice);
    fprintf('multiband factor: %d\n', nMB);
end
    

% allocate
im_shift = 0*im;

for idx = 1:nSlice
    pctFOV = idx - options.centre;
    im_shift(:,:,:,idx,:) = circshift(im(:,:,:,idx,:), [0 order_sign * floor(nPE * pctFOV / nMB) 0] );
    
    if (options.debug)
        fprintf('shifting by:  %d\n',  floor(nPE * pctFOV / nMB));
    end
end
