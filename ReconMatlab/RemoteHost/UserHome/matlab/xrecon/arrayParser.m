function [out, group_id, param_list] = arrayParser(params); 
% arrayParser: parse procpar array string

DO_PARSE = true;

% warn if arrayParsed flag is sest
if isfield( params, 'arrayParsed' )
    if params.arrayParsed == 1
        disp('parsed already ...');
        DO_PARSE = false;
        out = params;
    end
end

if (DO_PARSE)

out     = params;

instr   = params.array{1}; 
groups  = regexp(instr,'\((.*?)\)|[^,]+','match'); 
ngroups = numel(groups);

ctr = 1;
group_id = [];
param_list = {};

for ix = 1:ngroups
    tmp = strsplit( groups{ix}, ',' );
    for ix2 = 1:numel(tmp)
        p = tmp{ix2};
        p(regexp(p, '[()]')) = [];
        group_id(ctr) = ix;
        param_list{ctr} = p;

        ctr = ctr+1;
    end
end

arraydim = params.arraydim;
% fill in dimensions for each group
group_dim = zeros(1, ngroups);
for ix = 1:ngroups
    p = param_list{ find(group_id == ix) };
    group_dim(ix) = numel( params.(p) );
end

if ngroups > 1
% for each arrayed parameter
for ix = 1:numel(param_list)
    p = param_list{ix};
    dim_target = group_dim;
    dim_target( group_id(ix) ) = 1;

    % parameter to [ 1, ... , N, 1, ... ]
    dim_source = ones(1, ngroups);
    dim_source( group_id(ix) ) = numel(params.(p));

    % reverse dimensions - vnmrj orders starting from largest id
    dim_target = dim_target(end:-1:1);
    dim_source = dim_source(end:-1:1);

    pp = reshape(params.(p), dim_source);
    pp = repmat( pp, dim_target );

    out.(p) = pp;
end
end

out.arrayParsed = 1;
out.group_id = group_id;
out.param_list = param_list;

end
