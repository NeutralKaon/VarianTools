#!/bin/bash
# Remote matlab reconstruction script 
# Adjust username/hostname for remote server below 
# Set up ssh key exchange prior to using this in anger
# It is recommended that you use a dedicated low-priv user on the remote host 
matlab_remote_server="YOUR_USER_NAME@YOUR_SERVER_FOR_REMOTE_RECON"

# JJM/AZL 2016 
title=$(cat <<- EOF
XreconMatlab:
    AZL,JJM 2016
    Calling external reconstruction...
EOF
)

# Need a better usage string
usage="Xrecon matlab pipe script. Usage: $0 [options] <path_to_fid>"

echo "$title"
echo "$usage"
echo "$1"

matlab_cmd="matlab -nodesktop -nosplash -noawt -nojvm"
#Recon string below 
#Change to taste. 
recon_call="try; xrecon('~/xrecon_tmp/acqfil', '~/xrecon_tmp/recon'); catch exception; disp('***Recon failed!***'); disp('Trace:'); msgString=getReport(exception,'extended','hyperlinks','off'); disp(msgString); exit; end; exit;"

# get paths to data, build fid directory
acqfil_dir=$(dirname $1)
exp_dir=$(dirname $acqfil_dir)
rsync -avz $acqfil_dir -e ssh $matlab_remote_server:~/xrecon_tmp/
rsync -avz $exp_dir/procpar -e ssh $matlab_remote_server:~/xrecon_tmp/$(basename $acqfil_dir)

#Actual pipe
ssh $matlab_remote_server << EOF
rm -rf xrecon_tmp/recon/*
$matlab_cmd -r "$recon_call"
EOF

echo "Copying back to $acqfil_dir"
rsync -avz -e ssh $matlab_remote_server:~/xrecon_tmp/recon $exp_dir/

echo "Copying procpar..."
cp $acqfil_dir/procpar $exp_dir/recon/.
touch $exp_dir/recon/pport

exit 0
