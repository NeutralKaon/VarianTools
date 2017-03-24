function [raw, params, k]=readBrukerFid(dn)
% [raw, params, k]=readBrukerFid(dn)
% Raw: raw binary file; 
% Params: params struct from ACQpars file 
% k: reshaped k 
% dn: path to bruker directory (usually a number 1-5).
% Jack J. Miller, 2013
% University of Oxford
dn=fullfile(dn); 
params=readnmrpar(fullfile([dn '/acqp'])); 


%Sort out endianness
if params.BYTORDA == 0
  ByteOrdering = 'l';
else
  ByteOrdering = 'b';
end

% Read in 3D data 


fid = fopen(fullfile([dn '/fid']), 'r', ByteOrdering);
a = fread(fid, 'int32',ByteOrdering);
realFids=a(1:2:end); 
complexFids=a(2:2:end); 
raw=conj(complex(realFids,complexFids));
try
    k=reshape(raw, [params.ACQ_size(1)/2 params.ACQ_size(2:end)]); 
catch
    k=[]; 
    warning('Attempt at reshape failed!'); 
end
fclose(fid);






function P = readnmrpar(FileName)
% readBrukerFidPAR      Reads BRUKER parameter files to a struct
%
% SYNTAX        P = readnmrpar(FileName);
%
% IN            FileName:	Name of parameterfile, e.g., acqus
%
% OUT           Structure array with parameter/value-pairs
%

% Read file
A = textread(FileName,'%s','whitespace','\n');

% Det. the kind of entry
TypeOfRow = cell(length(A),2);
    
%Sorry, future self: 
R = {   ...
    '^##\$*(.+)=\ \(\d\.\.\d+\)(.+)', 'ParVecVal' ; ...
    '^##\$*(.+)=\ \(\d\.\.\d+\)$'   , 'ParVec'    ; ...
    '^##\$*(.+)=\ (.+)'             , 'ParVal'    ; ...
    '^([^\$#].*)'                   , 'Val'       ; ...
    '^\$\$(.*)'                     , 'Stamp'     ; ...
    '^##\$*(.+)='                   , 'EmptyPar'  ; ...
	'^(.+)'							, 'Anything'	...
    };

for i = 1:length(A)
    for j=1:size(R,1)
        [s,t]=regexp(A{i},R{j,1},'start','tokens');
        if (~isempty(s))
            TypeOfRow{i,1}=R{j,2};
            TypeOfRow{i,2}=t{1};
        break;
        end
    end
end

% Set up the struct
i=0;
while i < length(TypeOfRow)
    i=i+1;
    switch TypeOfRow{i,1}
        case 'ParVal'
            LastParameterName = TypeOfRow{i,2}{1};
            P.(LastParameterName)=TypeOfRow{i,2}{2};
        case {'ParVec','EmptyPar'}
            LastParameterName = TypeOfRow{i,2}{1};
            P.(LastParameterName)=[];
        case 'ParVecVal'
            LastParameterName = TypeOfRow{i,2}{1};
            P.(LastParameterName)=TypeOfRow{i,2}{2};
        case 'Stamp'
            if ~isfield(P,'Stamp') 
                P.Stamp=TypeOfRow{i,2}{1};
            else
                P.Stamp=[P.Stamp ' ## ' TypeOfRow{i,2}{1}];
            end
        case 'Val'
			if isempty(P.(LastParameterName))
				P.(LastParameterName) = TypeOfRow{i,2}{1};
			else
				P.(LastParameterName) = [P.(LastParameterName),' ',TypeOfRow{i,2}{1}];
			end
        case {'Empty','Anything'}
            % Do nothing
    end
end
    

% Convert strings to values
Fields = fieldnames(P);

for i=1:length(Fields);
    trystring = sprintf('P.%s = [%s];',Fields{i},P.(Fields{i}));
    try
        eval(trystring); %eval is evil
	catch 
        % Let the string P.(Fields{i}) be unaltered
    end
end