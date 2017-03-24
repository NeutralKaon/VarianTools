function [A,B] = shift_relative( A,B,delay )
% shift_relative Shifts two arrays relative to each other.
%
% usage: [A,B] = shift_relative(A,B, delay);
%
% input:
%   A,B     N-d arrays
%   delay   integer shift 
%           (delay>0: remove first components of B)
%           (delay<0: remove first components of A)
%
% output:
%   A,B     shifted versions
%
% example:
%   A = [1,2,3,4,5]
%   B = [1,2,3,4,5]
%   delay = 2
%       A_out = [1,2,3]
%       B_out = [3,4,5]

sA = size(A);
sB = size(B);

if delay>0
A = A(1:end-delay,:);
B = B(delay+1:end,:);
elseif delay<0
    delay = abs(delay);
A = A(delay+1:end,:);
B = B(1:end-delay,:);
end    

if delay~=0
A = reshape(A, [ sA(1)-delay sA(2:end) ]);
B = reshape(B, [ sB(1)-delay sB(2:end) ]);
end