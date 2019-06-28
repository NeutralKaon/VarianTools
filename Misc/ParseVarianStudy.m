function out = ParseVarianStudy(xmlPath,options)
% Parse a VnmrJ study.xml file
%
% Extract a list of links to studies and names given either a path to a
% VnmrJ study directory, or alternatively the study.xml file directly
%
% Options is an optional struct contianing:
%
% -- 'loadProcpar', a logical flag that, if set, will result in the procpar
%     being included (defualt off)
% -- 'loadComment', as above but for the comment flag (default on)
% -- 'loadData', try to reconstruct imaging and spectroscopy data
%
% Jack J. Miller, University of Oxford, 2019
%

defaultOptions = {...
    'loadProcpar', 0; ...
    'loadComment', 1; ...
    'loadData', 0; ...
    };

if nargin == 1
    opts = setDefaultStruct(struct(),defaultOptions);
elseif nargin == 2
    opts = setDefaultStruct(options,defaultOptions);
else
    help jjmParseVarianStudy;
    error('Check usage');
end

if opts.loadData
    opts.loadProcpar = true; 
end


if isfolder(xmlPath)
    fn = fullfile(xmlPath,'study.xml');
elseif isfile(xmlPath)
    fn = xmlPath;
else
    error('Check input');
end

[filepath,~,ext] = fileparts(fn);
if ~strcmp(ext,'.xml')
    error('Check study.xml file exists');
end

xmlS = xml2struct(fn);

out.nScans = 0;

totalToParse = (length(xmlS.template{2}.action));

f = waitbar(0,'Loading data...');

for ix = 1:totalToParse
    if strcmp(xmlS.template{2}.action{ix}.Attributes.status,'Completed')
        %Scan actually ran...
        out.nScans = out.nScans + 1;
        out.scan(out.nScans).dataLoc = fullfile(filepath, [xmlS.template{2}.action{ix}.Attributes.data '.fid']);
        out.scan(out.nScans).title = xmlS.template{2}.action{ix}.Attributes.title;
        
        if opts.loadProcpar
            try
                out.scan(out.nScans).procpar = readprocpar(out.scan(out.nScans).dataLoc);
                out.scan(out.nScans).comment = out.scan(out.nScans).procpar.comment{1};
            catch
                warning('Data missing for file %s, number %d\n',out.scan(out.nScans).dataLoc,ix);
                out.scan(out.nScans).procpar = 'DATA  MISSING!';
                out.scan(out.nScans).comment = 'DATA  MISSING!';
            end
        elseif opts.loadComment
            try
                
                out.scan(out.nScans).comment = queryPP(out.scan(out.nScans).dataLoc,'comment');
                
            catch
                warning('Data missing for file %s, number %d\n',out.scan(out.nScans).dataLoc,ix);
                out.scan(out.nScans).comment = 'DATA  MISSING!';
            end
        end
        
        if opts.loadData 
           try
              warning('Not yet implemented...'); 
           catch
               warning('Data recon for file %s, number %d failed!\n',out.scan(out.nScans).dataLoc,ix);
           end
        end
        
    end
    waitbar(ix / totalToParse ,f,'Loading data...');
end
close(f)
end


function V = queryPP(name,parameter);

%name='c:/img/e1720/data/gems_01.img'
%parameter='name'
%----------------------------------------
%function queryPP
%finds a parameter value in procpar
%----------------------------------------
%Usage V = queryPP(name,par);
%
%Input:
%name = name of FID directory without the .fid extension
%pars  = name of parameters in cell array e.g {'name','te','tr'}
%
%Output:
%V    = value of parameter - possibly a vector or matrix (strings)
%
%Examples:
%V = queryPP('sems_ms','gro');
%
%
%----------------------------------------
% Maj Hedehus, Varian, Inc., Oct 2001.
%----------------------------------------


if exist('name') == 0
    name = input('DIR name : ','s');
end

if exist('parameter') == 0
    parameter = input('Which parameter: ','s');
end


fullname = sprintf('%s%cprocpar',name,'/'); %something funky with the backslash going on...

fid = fopen(fullname,'r');
if fid == -1
    str = sprintf('Can not open file %s',fullname);
    error(str);
end

par  = fscanf(fid,'%s',1);

while (~strcmp(par,parameter)) & ~feof(fid)
    type  = fscanf(fid,'%d',1);
    fgetl(fid); %skip rest of line
    nvals = fscanf(fid,'%d',1);
    fgetl(fid); %skip rest of line
    if type == 2 %string, the remaining values are on seperate lines
        for n = 1:nvals-1
            fgetl(fid);
        end
    end
    fgetl(fid);  %skip "line 3"
    
    par = fscanf(fid,'%s',1);
end

if feof(fid)
    V = 'parameter not found';
    return
end


type  = fscanf(fid,'%d',1);
fgetl(fid); %skip rest of line
nvals = fscanf(fid,'%d',1);

switch type
    case 1  % float
        V = fscanf(fid,'%f',nvals);
    case 2  % string
        L = fgetl(fid);
        if (strcmp(parameter,'name') || strcmp(parameter,'comment'))
            sm=L(2:end);
        else
            sm = sscanf(L,'%s',1); %for some odd reason, fscanf(fid,..) doesn't work here
        end
        for n = 1:nvals-1
            L = fgetl(fid);
            sm = sscanf(L,'%s',1);
            sm = str2mat(sm); %,s);
            V{n} = sm(2:length(sm)-1); %skip " " quotes
        end
        if (nvals==1)
            V=sm(2:length(sm)-1);
        end
        
    case 3  % delay
        V = fscanf(fid,'%f',nvals);
    case 4  % flag
        L = fgetl(fid);
        sm = sscanf(L,'%s',1); %for some odd reason, fscanf(fid,..) doesn't work here
        for n = 1:nvals-1
            L = fgetl(fid);
            sm = sscanf(L,'%s',1);
            sm = str2mat(sm)
        end
        V = sm;
    case 5  % frequency
        V = fscanf(fid,'%f',nvals);
    case 6  % pulse
        V = fscanf(fid,'%f',nvals)*1e6;
    case 7  % integer
        V = fscanf(fid,'%d',nvals);
    otherwise
        V = 'not defined';
end

fclose(fid);

end
