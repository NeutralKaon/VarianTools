function [] = plot_sequence_adc(t, g, idx_adc)
%PLOT_SEQUENCE_ADC Plot sequence readout gradient with ADC events.
%
%   t:       vector containing times of each gradient point
%   g:       gradient array. Dimensions (ng, nd), where 
%               ng = number of gradient points
%               nd = number of gradient dimensions.
%   idx_adc: struct containing start and end indices:
%       start: indices for start of ADC events
%       end:   indices for end of ADC events

if (nargin<3)
    idx_adc = [];
    startind = [];
    endind = [];
else
    startind = find(idx_adc.start==1);
    endind = find(idx_adc.end==1);
end

hp = plot(t, g);

hold on;
for j=1:numel(startind)
    t_adc = [t(startind(j)) t(endind(j))];
    fill_between_vertical( t_adc, 'k', 0.25 );
end
hold off;

set(hp, 'LineWidth', 2)
xlabel('Time (ms)');
ylabel('Gradient (G/cm)');

%%


end

