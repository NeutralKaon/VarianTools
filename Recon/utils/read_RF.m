function [ out_mag, out_phase ] = read_RF( filename )

delimiter = ' ';
startRow = 1;
endRow = inf;
formatSpec = '%f%f%f%[^\n\r]';

filename=fullfile(filename);
fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'CommentStyle', '#');

% Close the text file.
fclose(fileID);

out_mag   = dataArray{2};
out_phase = dataArray{1};