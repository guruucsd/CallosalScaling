

%bi_dir = fileparts(which(mfilename));
lrb_data;
addpath(genpath(fullfile(lrb_dir, '..', '_lib')));

fit_type = 'lognormal';'lognormal';'IUBD';

for si=1:4
    params(si,:,1:size(lrb_fig3_data,1))                          = fit_distns(lrb_fig3_xbar_vals,  squeeze(lrb_fig3_data(:,si,:)),  fit_type);
    params(si,:,size(lrb_fig3_data,1)+[1:size(lrb_fig15_data,1)]) = fit_distns(lrb_fig15_xbar_vals, squeeze(lrb_fig15_data(:,si,:)), fit_type);
end;

fit_distns(lrb_fig3_xbar_vals,  squeeze(sum(lrb_fig3_data,2)),  fit_type)
fit_distns(lrb_fig15_xbar_vals, squeeze(sum(lrb_fig15_data,2)), fit_type)


squeeze(mean(params,1))
