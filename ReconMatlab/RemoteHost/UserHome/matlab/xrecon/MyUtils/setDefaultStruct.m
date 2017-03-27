function x = setDefaultStruct(x, defaults)
% setDefaultStruct Sets default fields in struct
%
% x = setDefaultStruct(x, defaults)
%
% defaults is a cell array (N x 2) containing pairs of default fields
% x is a struct that may or may not contain these fields
%
% This function sets the fields in defaults in x, if they do not exist.
%
% example:
%
% optionsDefaults = {...
%    'debug', 0; ...
%    'xdir', 'rev'; ...
%    'xlabel', '\delta / ppm'; ...
%    'LineWidth', 2; ...
%    'prior', struct(); ...
%    'addSpectra', 'sum' };
%
% options = setDefaultStruct(options, optionsDefaults);

    assert(isstruct(x));

    for idx = 1:size(defaults, 1)
        if ~isfield(x,defaults{idx,1})
            x.(defaults{idx,1}) = defaults{idx,2};
        end
    end
end