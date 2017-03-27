We have modified Xrecon to include a matlab pipe, allowing for remote reconstructions on another (beefier) computer. 
This is particularly useful for compressed sensing and parallel imaging, as it allows the use of an off-host GPU. 

This is implemented via:

* a patched version of Xrecon, nominally located in `/vnmr/imaging/src`, 
* a pipe script that contains ssh details to the remote host, 
* and code that runs on the remote (GPU'd up, matlab-wielding) host. 

Naturally, wrappers can easily be written to gadgetron or BART as appropriate. 

To use this code in VnmrJ sequences, set `apptype='immatlab'`. 
