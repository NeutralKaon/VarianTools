d_epip = 'data/DNP-EPIP-Sinc_20140728_13c_urea02.fid';

%% Load data
[raw_epip, params] = load_varian( d_epip, 1 );
raw_epip = double(raw_epip);