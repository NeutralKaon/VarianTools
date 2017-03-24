function [ idx_adc_total, n_read ] = build_index_adc( idx_adc_single, n_g_ro, nv )
%BUILD_INDEX_ADC Build the index vector for ADC events.
%
%   Use with a ssfp sequence where the readout gradient event is
%   concatenated multiple times, with no gap.
%
%   inputs:
%       idx_adc_single: ADC index vector into single gradient event
%       n_g_ro:         length of single gradient event
%       nv:             number of repetitions (views) during full sequence
% AZL 2015
n_read = numel(idx_adc_single);

idx_adc_total = zeros(n_g_ro,nv);
idx_adc_total(idx_adc_single,:) = 1;

idx_adc_total = logical(idx_adc_total);
idx_adc_total = idx_adc_total(:);

end

