function isAValidVarianFid = isVarian(dn)
% Returns true if the directory dn is a valid VnmrJ directory, and false
% otherwise.
%
% JJM 2013

isAValidVarianFid = false;
hasFid = false;
hasProcpar = false;


fNameInfo = dir(fullfile(dn));
for ix = 1:length(fNameInfo)
    if (strcmpi(fNameInfo(ix).name, 'fid') && ~fNameInfo(ix).isdir)
        hasFid = true;
    end
    if strcmpi(fNameInfo(ix).name,'procpar')
        hasProcpar = true;
    end
end

if isempty(ix)
    warning('Directory %s does not exist', dn);
end

if (hasFid && hasProcpar)
    isAValidVarianFid = true;
end

