function fdfwrite( fdf_filename, data, procpar, ixslice, iximage, ixecho); 

% fdfwrite Varian flexible data format writer
%
% Usage: fdfwrite( filename, data, procpar, slice_no, image_no, echo_no );
%
% procpar comes from readprocpar()
% data is a 2d array (image data)
%
% Angus Lau & Jack Miller 2016
fid = fopen([fdf_filename], 'w');

fdf_header_string = fdfheader(ny, nx, nv, np, lpe, ppe, pro, pss, tn, dn, sfrq, dfrq, lpe, lro, thk, gap, ixslice, ns, ixecho, ne, te, tr, seqfil, studyid, ti, iximage, nimage, psi, phi, theta);

fprintf(fid, fdf_header_string);
fclose(fid);

%Write binary data

machineformat = 'ieee-le';
fid = fopen(fdf_filename, 'ab+');
fwrite(fid, data, 'float32', machineformat);
fclose(fid);

end


function s = fdfheader(ny, nx, nv, np, lpe, ppe, pro, pss, tn, dn, sfrq, dfrq, lpe, lro, thk, gap, ixslice, ns, ixecho, ne, te, tr, seqfil, studyid, ti, iximage, nimage, psi, phi, theta);

% rotation matrix here:
DEG2RAD=pi/180;
cospsi=cos(DEG2RAD*psi);
sinpsi=sin(DEG2RAD*psi);
cosphi=cos(DEG2RAD*phi);
sinphi=sin(DEG2RAD*phi);
costheta=cos(DEG2RAD*theta);
sintheta=sin(DEG2RAD*theta);
%This is the same "Euler" angles as used by VnmrJ (fdfwrite2D.c)
or0=-1*cosphi*cospsi - sinphi*costheta*sinpsi;
or1=-1*cosphi*sinpsi + sinphi*costheta*cospsi;
or2=-1*sinphi*sintheta;
or3=-1*sinphi*cospsi + cosphi*costheta*sinpsi;
or4=-1*sinphi*sinpsi - cosphi*costheta*cospsi;
or5=cosphi*sintheta;
or6=-1*sintheta*sinpsi;
or7=sintheta*cospsi;
or8=costheta;

s = [];
s = strcat(s, sprintf('#!/usr/local/fdf/startup\n');
s = strcat(s, sprintf('float  rank = 2;\n');
s = strcat(s, sprintf('char  *spatial_rank = "2dfov";\n');
s = strcat(s, sprintf('char  *storage = "float";\n');
s = strcat(s, sprintf('float  bits = 32;\n');
s = strcat(s, sprintf('char  *type = "absval";\n');
s = strcat(s, sprintf('float  matrix[] = {%d, %d};\n', ny, nx);
s = strcat(s, sprintf('char  *abscissa[] = {"cm", "cm"};\n');
s = strcat(s, sprintf('char  *ordinate[] = { "intensity" };\n');
s = strcat(s, sprintf('float  span[] = {%.6f, %.6f};\n', lpe, lro);
s = strcat(s, sprintf('float  origin[] = {%.6f,%.6f};\n', -ppe, pro);
s = strcat(s, sprintf('char  *nucleus[] = {"%s","%s"};\n',tn,dn);
s = strcat(s, sprintf('float  nucfreq[] = {%.6f,%.6f};\n', sfrq, dfrq);
s = strcat(s, sprintf('float  location[] = {%.6f,%.6f,%.6f};\n', -ppe, pro, pss);
s = strcat(s, sprintf('float  roi[] = {%.6f,%.6f,%.6f};\n', lpe, lro, thk/10);
s = strcat(s, sprintf('float  gap = %.6f;\n', gap);
s = strcat(s, sprintf('char  *file = "/home/lab1/vnmrsys/exp1/acqfil/fid";\n');
s = strcat(s, sprintf('int    slice_no = %d;\n', ixslice);
s = strcat(s, sprintf('int    slices = %d;\n', ns);
s = strcat(s, sprintf('int    echo_no = %d;\n', ixecho);
s = strcat(s, sprintf('int    echoes = %d;\n', ne);
s = strcat(s, sprintf('float  TE = %.3f;\n', te * 1e3);
s = strcat(s, sprintf('float  te = %.6f;\n', te);
s = strcat(s, sprintf('float  TR = %.3f;\n', tr * 1e3);
s = strcat(s, sprintf('float  tr = %.6f;\n', tr);
s = strcat(s, sprintf('int    ro_size = %d;\n', np/2);
s = strcat(s, sprintf('int    pe_size = %d;\n', nv);
s = strcat(s, sprintf('char  *sequence = "%s";\n', seqfil);
s = strcat(s, sprintf('char  *studyid = "%s";\n', studyid);
s = strcat(s, sprintf('char  *position1 = "";\n');
s = strcat(s, sprintf('char  *position2 = "";\n');
s = strcat(s, sprintf('float  TI =  %.3f;\n', ti*1e3);
s = strcat(s, sprintf('float  ti =  %.6f;\n', ti);
s = strcat(s, sprintf('int    array_index = %d;\n', iximage);
s = strcat(s, sprintf('float  array_dim = %.4f;\n', arraydim);
s = strcat(s, sprintf('float  image = %.1f;\n', iximage);
s = strcat(s, sprintf('int    display_order = 0;\n');
s = strcat(s, sprintf('int    bigendian = 0;\n');
s = strcat(s, sprintf('float  imagescale = 1.000000000;\n');
s = strcat(s, sprintf('float  psi = %.4f;\n', psi);
s = strcat(s, sprintf('float  phi = %.4f;\n', phi);
s = strcat(s, sprintf('float  theta = %.4f;\n', theta);
s = strcat(s, sprintf('float  orientation[] = {%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f};\n', or0,or1,or2,or3,or4,or5,or6,or7,or8);
s = strcat(s, sprintf('int checksum = 1291708713;\n'); 
%(As defined in Xrecon.c!) 
s = strcat(s, sprintf('\f\n\n');
% write ASCII NULL ...
s = strcat(s, sprintf(char(0), 'char');
fclose(fid);


