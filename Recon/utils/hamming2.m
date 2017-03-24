% h = hamming2(a,b) returns a 2d hamming filter of dimensions (a,b)
function h = hamming2(a,b)
h = hamming(a) * hamming(b)';