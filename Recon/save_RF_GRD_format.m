function [ GRD_format RF_format ] = save_RF_GRD_format( b1, gr, b1max, gmax, save_RF_GRD_files, lobe_type, pulse_type, filename1, pulse_time, no_lobes, t_res );
% Write out apporpirate file format for use on varian or bruker
% spectrometers. 
% Note that equivalent bandwidth calculations should be performed and the
% results included in this script.
% JM '12. 
switch save_RF_GRD_files
    case 'varian'
        
        phase_ang(b1 < 0) = 180;
        phase_ang(b1 >= 0) = 0;
        
        b1 = abs(b1);
        
        RF_format=zeros(length(b1),3);
        RF_format(:,1) = phase_ang;
        RF_format(:,2) = b1/b1max*1023;
        RF_format(:,3) = ones(length(gr),1);
        integral=trapz(1:length(b1),b1/b1max*1023)/(1023*length(b1));
        
        
        GRD_format(:,1) = gr(1:10:length(gr))/gmax*32767;
        GRD_format(:,2) = ones(length(GRD_format),1);
        
        
        for i = 1:length(RF_format)
            RF_format_rounded{i,1} = sprintf('%0.1f', RF_format(i,1));
            RF_format_rounded{i,2} = sprintf('%0.1f', RF_format(i,2));
            RF_format_rounded{i,3} = sprintf('%0.1f', RF_format(i,3));
        end
        
        filename = [filename1 '_autocreate.RF'];
        fid = fopen(filename, 'w');
        fprintf(fid, '# /home/lab1/vnmrsys/shapelib/%s\n', filename);
        fprintf(fid, '# ***************************************************\n# Generation parameters:\n');
        fprintf(fid, '#   Shape = Spectral spatial\n');
        fprintf(fid, '#   Duration = %1.4f ms\n', pulse_time*1000);
        fprintf(fid, '#   Resolution = %6.1f usec\n', t_res*1000000);
        %fprintf(fid, '#   Flip = 90.0 degrees\n#   Bandwidth = 1486.0 Hz\n');
        fprintf(fid, '#   Lobes = %1.0f\n',no_lobes);
        fprintf(fid, '# ***************************************************\n');
        fprintf(fid, '# VERSION       SPLv1\n# TYPE          selective\n# MODULATION    amplitude\n');
        fprintf(fid, '# EXCITEWIDTH   5.9440\n# INVERTWIDTH   4.7020\n# INTEGRAL      %1.8f\n# RF_FRACTION   0.5000\n',integral);
        fprintf(fid, '# STEPS         %1.0f\n', length(RF_format));
        fprintf(fid, '# ***************************************************\n');
        
        
        for row=1:length(RF_format)
            fprintf(fid, '%s    %s    %s \n', RF_format_rounded{row,:});
        end
        
        fclose(fid);
        
        for i = 1:length(GRD_format)
            GRD_format_rounded{i,1} = sprintf('%1.0f', GRD_format(i,1));
            GRD_format_rounded{i,2} = sprintf('%1.0f', GRD_format(i,2));
        end
        
        filename = [filename1 '_autocreate_' num2str(round(no_lobes)) 'lobes.GRD'];
        fid = fopen(filename, 'w');
        
        fprintf(fid, '#\n# NAME:       %s\n# POINTS:     %1.0f\n', filename, length(GRD_format));
        fprintf(fid, '# RESOLUTION: %1.8fe-06\n',t_res*10000000);
        fprintf(fid, '# STRENGTH:   1.30000000e+00\n#:\n');
        
        for row=1:length(GRD_format)
            fprintf(fid, '%s    %s    \n', GRD_format_rounded{row,:});
        end
        
        fclose(fid);
        
    case 'bruker'
        
        
        phase_ang(find(b1 < 0)) = 180;
        phase_ang(find(b1 > 0)) = 0;
        
        b1 = abs(b1);
        
        RF_format(:,1) = phase_ang;
        RF_format(:,2) = b1/b1max*100;
               
            
        for i = 1:length(RF_format)
            RF_format_rounded{i,2} = sprintf('%1.6e', RF_format(i,1));
            RF_format_rounded{i,1} = sprintf('%1.6e', RF_format(i,2));
        end
        
        filename = ['spsp_br_' lobe_type '_' num2str(length(RF_format)) '_pts_' filename1 '.exc'];
        fid = fopen(filename, 'w');     
     
     
        fprintf(fid, ['##TITLE= /w/pv2.B40/exp/stan/nmr/lists/wave/' filename]);
        fprintf(fid, '\n##JCAMP-DX= 5.00 Bruker JCAMP library\n');
        fprintf(fid, '##DATA TYPE= Shape Data\n');
        fprintf(fid, '##ORIGIN= Bruker Analytik GmbH\n');
        fprintf(fid, '##OWNER= <klz>\n');
        fprintf(fid, '##DATE= 12/08/07\n');
        fprintf(fid, '##TIME= 17:05:46\n');
        fprintf(fid, '##MINX= 0.000000e+00\n');
        fprintf(fid, '##MAXX= 9.999852e+01\n');
        fprintf(fid, '##MINY= 0.000000e+00\n');
        fprintf(fid, '##MAXY= 1.800000e+02\n');
        fprintf(fid, '##$SHAPE_EXMODE= Excitation\n');
        fprintf(fid, '##$SHAPE_REPHFAC= 50.00\n');
        fprintf(fid, '##$SHAPE_TYPE= CONVENTIONAL\n');
        fprintf(fid, '##$SHAPE_TOTROT= 9.000000e+01\n');
        fprintf(fid, '##$SHAPE_BWFAC= 5.572000e+00\n');
        fprintf(fid, '##$SHAPE_INTEGFAC= 1.775197e-01\n');
        fprintf(fid, '##$SHAPE_MODE= 1\n');
        fprintf(fid, '##NPOINTS= %1.0f\n', length(RF_format));
        fprintf(fid, '##XYPOINTS= (XY..XY)\n');
        
        for row=1:length(RF_format)
            fprintf(fid, '%s,    %s \n', RF_format_rounded{row,:});
        end
        
        fclose(fid);
        
        GRD_format = 'We can''t work out how to actually do this'
        
        
        
    case 'none'
        GRD_format = 'Not saved' 
        RF_format = 'Not saved' 
        
    otherwise
        GRD_format = 'Not saved' 
        RF_format = 'Not saved' 
        warning('Not a valid save type parameter. Enter "varian" ,"bruker" or "none"');
end

end

