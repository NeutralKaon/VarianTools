function fdfwrite( fdf_filename, data, procpar, SLICE_NO, IMAGE_NO, ECHO_NO )
% fdfwrite Varian flexible data format writer
%
% Usage: fdfwrite( filename, data, procpar, slice_no, image_no, echo_no );
%
% procpar comes from readprocpar()
% data is a 2d array (image data)
%
% Angus Lau & Jack Miller 2016

fid = fopen([fdf_filename], 'w');

nx = size(data,1);
ny = size(data,2);

fprintf(fid, '#!/usr/local/fdf/startup\n');
fprintf(fid, 'float  rank = 2;\n');
fprintf(fid, 'char  *spatial_rank = "2dfov";\n');
fprintf(fid, 'char  *storage = "float";\n');
fprintf(fid, 'float  bits = 32;\n');
fprintf(fid, 'char  *type = "absval";\n');
fprintf(fid, 'float  matrix[] = {%d, %d};\n', nx, ny);
fprintf(fid, 'char  *abscissa[] = {"cm", "cm"};\n');
fprintf(fid, 'char  *ordinate[] = { "intensity" };\n');
fprintf(fid, 'float  span[] = {%.6f, %.6f};\n', procpar.lpe, procpar.lro);
fprintf(fid, 'float  origin[] = {%.6f,%.6f};\n', -procpar.ppe, procpar.pro);
fprintf(fid, 'char  *nucleus[] = {"%s","%s"};\n',procpar.tn{1}, procpar.dn{1});
fprintf(fid, 'float  nucfreq[] = {%.6f,%.6f};\n', procpar.sfrq, procpar.dfrq);
fprintf(fid, 'float  location[] = {%.6f,%.6f,%.6f};\n', -procpar.ppe, procpar.pro, procpar.pss);
fprintf(fid, 'float  roi[] = {%.6f,%.6f,%.6f};\n', procpar.lpe, procpar.lro, procpar.thk/10);
fprintf(fid, 'float  gap = %.6f;\n', procpar.gap);
fprintf(fid, 'char  *file = "/home/lab1/vnmrsys/exp1/acqfil/fid";\n');
fprintf(fid, 'int    slice_no = %d;\n', SLICE_NO);
fprintf(fid, 'int    slices = %d;\n', procpar.ns);
fprintf(fid, 'int    echo_no = %d;\n', ECHO_NO);
fprintf(fid, 'int    echoes = %d;\n', procpar.ne);
fprintf(fid, 'float  TE = %.3f;\n', procpar.te * 1e3);
fprintf(fid, 'float  te = %.6f;\n', procpar.te);
fprintf(fid, 'float  TR = %.3f;\n', procpar.tr * 1e3);
fprintf(fid, 'float  tr = %.6f;\n', procpar.tr);
fprintf(fid, 'int    ro_size = %d;\n', procpar.np/2);
fprintf(fid, 'int    pe_size = %d;\n', procpar.nv);
fprintf(fid, 'char  *sequence = "%s";\n', procpar.seqfil{1});
fprintf(fid, 'char  *studyid = "%s";\n', procpar.studyid_{1});
fprintf(fid, 'char  *position1 = "";\n');
fprintf(fid, 'char  *position2 = "";\n');
fprintf(fid, 'float  TI =  %.3f;\n', procpar.ti*1e3);
fprintf(fid, 'float  ti =  %.6f;\n', procpar.ti);
fprintf(fid, 'int    array_index = %d;\n', IMAGE_NO);
fprintf(fid, 'float  array_dim = %.4f;\n', procpar.arraydim);
fprintf(fid, 'float  image = %.1f;\n', IMAGE_NO);
fprintf(fid, 'int    display_order = 0;\n');
fprintf(fid, 'int    bigendian = 0;\n');
fprintf(fid, 'float  imagescale = 1.000000000;\n');
fprintf(fid, 'float  psi = %.4f;\n', procpar.psi);
fprintf(fid, 'float  phi = %.4f;\n', procpar.phi);
fprintf(fid, 'float  theta = %.4f;\n', procpar.theta);
% rotation matrix here:
DEG2RAD=pi/180;
psi=procpar.psi;
phi=procpar.phi;
theta=procpar.theta;

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

fprintf(fid,'float  orientation[] = {%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f};\n', or0,or1,or2,or3,or4,or5,or6,or7,or8);

%(As defined in Xrecon.c!) 
fprintf(fid, 'int checksum = 1291708713;\n'); 

fprintf(fid, '\f\n\n');

% write ASCII NULL ...
fprintf(fid, char(0), 'char');
fclose(fid);

%Write binary data
machineformat = 'ieee-le';
fid = fopen(fdf_filename, 'ab+');
fwrite(fid, data, 'float32', machineformat);
fclose(fid);

end
