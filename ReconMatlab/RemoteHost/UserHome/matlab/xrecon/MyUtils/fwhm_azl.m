function [width, centerindex] = fwhm_azl(x,y, varargin)

% function [width, centerindex] = fwhm_azl(x,y, options)
%
% Full-Width at Half-Maximum (FWHM) of the waveform y(x)
% and its polarity.
% The FWHM result in 'width' will be in units of 'x'
%
% centerindex gives the index for the maximum
%
% options: 
%   'verbose' - 1 or 0      [default (0)  ]
%   'level'   - from 0 to 1 [default (0.5)]
%
% Rev 1.2, April 2006 (Patrick Egan)
% 18.1.2013 AZL edited to return center index
%               edited to be verbose only if asked
%
% 27.03.2014 AZL changed name to fwhm_azl() to avoid conflict with
%           irt toolbox

options = processVarargin(varargin{:});

optionsDefaults = {...
    'verbose',  0; ...
    'level',    0.5 };

options = setDefaultStruct(options, optionsDefaults);

% Assign options
verbose = options.verbose;
lev50   = options.level;

y = y / max(y);
N = length(y);

width = 0;
centerindex = 0;

if y(1) < lev50                  % find index of center (max or min) of pulse
    [garbage,centerindex]=max(y);
    Pol = +1;
    if verbose
        disp('Pulse Polarity = Positive')
    end
else
    [garbage,centerindex]=min(y);
    Pol = -1;
    if verbose
        disp('Pulse Polarity = Negative')
    end
end
i = 2;
while sign(y(i)-lev50) == sign(y(i-1)-lev50)
    i = i+1;
end                                   %first crossing is between v(i-1) & v(i)
interp = (lev50-y(i-1)) / (y(i)-y(i-1));
tlead = x(i-1) + interp*(x(i)-x(i-1));
i = centerindex+1;                    %start search for next crossing at center
while ((sign(y(i)-lev50) == sign(y(i-1)-lev50)) & (i <= N-1))
    i = i+1;
end
if i ~= N
    Ptype = 1;  
    
    if verbose
        disp('Pulse is Impulse or Rectangular with 2 edges')
    end
    
    interp = (lev50-y(i-1)) / (y(i)-y(i-1));
    ttrail = x(i-1) + interp*(x(i)-x(i-1));
    width = ttrail - tlead;
else
    Ptype = 2; 
    
    if verbose
        disp('Step-Like Pulse, no second edge')
    end
    
    ttrail = NaN;
    width = NaN;
end
