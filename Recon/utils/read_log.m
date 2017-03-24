function timeExperiment = read_log( procdir ) 
% Parse a varian log file structure to extract the total times of
% experiments. Returns the total time in seconds. Input: Fid directory
% (i.e. /path/to/study.fid/), with or without trailing slash.
%
% Incremental block updates are, at present ignored (though it would be
% trivial to record them).
%
% Jack Miller, 2013.



if (nargin ==0) || (nargin >=2)
    help readlog;
end
if (nargin >= 1)
  if (procdir(length(procdir)) ~= '/')
    procdir(length(procdir)+1) = '/';
  end
end

% open the file
% flog = fopen([procdir 'procpar'],'r');
flog = fopen(fullfile(procdir, 'log'),'r');

if (flog == -1)
  error('(readlog) ERROR: Could not open %s',[procdir 'procpar']);
end

%Get line
line = fgets(flog);

%Date/time regex
pattern='(Mon|Tue|Wed|Thu|Fri|Sat|Sun) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Nov|Dec) (| |0[0-9]|1[0-9]|2[0-9]|3[0-1]) ([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]:[0-9][0-9] [0-9][0-9][0-9][0-9]:';
formatIn='ddd mmm dd HH:MM:SS yyyy';

while ischar(line) 
  % Match dates
  [startIndx,endIndx]=regexpi(line,pattern);
  dateString=line(startIndx:(endIndx-1)); 
  %Chop out the text after them
  expressionString=line(endIndx:end);
  dateEnded=0;
  dateStarted=0;
  
  if ~isempty(strfind(expressionString,'Experiment started'))
      dateStarted=datenum(dateString,formatIn);
  elseif ~isempty(strfind(expressionString, 'Acquisition complete'))
      dateEnded=datenum(dateString,formatIn);
  end  
  line=fgets(flog);
end

timeExperiment=round((dateEnded-dateStarted)*60*60*24); 
%Matlab returns a date number, which is the number of days since a chosen epoch -- 1900 by default. 
%Here we multiply by one day to get the elapsed time in s, and round to the
%nearest second, as it's the resolution of the machine.

  