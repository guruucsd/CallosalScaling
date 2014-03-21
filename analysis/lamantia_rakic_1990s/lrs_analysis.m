lrs_path = fileparts(which(mfilename));
addpath(lrs_path);
lrs_data;


    % plots over all data
    xl = [min(lrs_age)*.9 max(lrs_age)*1.1];

    figure; set(gcf, 'Position', [ 69         258        1212         405]);
    subplot(1,3,3); set(gca, 'FontSize', 14);
    semilogx(lrs_age, lrs_dens/100, 'o', 'MarkerSize', 4, 'LineWidth',4); hold on;
    semilogx(156*[1 1], get(gca, 'ylim'), 'r--', 'LineWidth', 2); hold on; 
    set(gca, 'xlim', xl, 'xtick', 10.^[2:5]); axis square;
    xlabel('Age (days since conception)');
    ylabel('axons/mm^2');
    title('Axon density', 'FontSize', 18); 

    subplot(1,3,2); set(gca, 'FontSize', 14);
    semilogx(lrs_age, lrs_area/10^6, 'o', 'MarkerSize', 4, 'LineWidth',4); hold on;
    semilogx(156*[1 1], get(gca, 'ylim'), 'r--', 'LineWidth', 2); hold on; 
    set(gca, 'xlim', xl, 'xtick', 10.^[2:5]); axis square;
    xlabel('Age (days since conception)');
    ylabel('mm^2');
    title('Cross-sectional area', 'FontSize', 18);

    subplot(1,3,1); set(gca, 'FontSize', 14);
    semilogx(lrs_age, lrs_nic/10^6, 'o', 'MarkerSize', 4, 'LineWidth',4); hold on;
    semilogx(156*[1 1], get(gca, 'ylim'), 'r--', 'LineWidth', 2);  hold on; 
    set(gca, 'xlim', xl, 'xtick', 10.^[2:5]); axis square;
    xlabel('Age (days since conception)');
    ylabel('million axons')
    title('# axons', 'FontSize', 18);


%% Look at histogram of unmyelinated fibers, across the lifespan.
% Requires rebinning distributions into a common set of bins... or fitting
% them with gamma functions!

lra_fig7_sectors = {'2' '4' '6'};
%lrb_fig3_sectors %'2'    '4'    '6'    '10'
%lrb_fig15_sectors%'2'    '4'    '6'    '10'

% normalize data
lra_fig7_data_normd = lra_fig7_data./repmat(sum(lra_fig7_data,2),[1 size(lra_fig7_data,2)]);
lrb_fig3_data_normd = lrb_fig3_data./repmat(reshape(sum(lrb_fig3_data,3), [size(lrb_fig3_data,1), size(lrb_fig3_data,2) 1]), [1 1 size(lrb_fig3_data,3)]);
lrb_fig15_data_normd = lrb_fig15_data./repmat(reshape(sum(lrb_fig15_data,3), [size(lrb_fig15_data,1), size(lrb_fig15_data,2) 1]), [1 1 size(lrb_fig15_data,3)]);


lra_fig7_mean_diameter = sum(lra_fig7_data_normd.*repmat(lra_fig7_xbar_vals, [size(lra_fig7_data,1) 1]), 2);
lrb_fig3_mean_diameter = sum(lrb_fig3_data_normd.*repmat(reshape(lrb_fig3_xbar_vals(:)', [1 size(lrb_fig3_xbar_vals)]), [size(lrb_fig3_data,1) size(lrb_fig3_data,2) 1]), 3);
lrb_fig15_mean_diameter = sum(lrb_fig15_data_normd.*repmat(reshape(lrb_fig15_xbar_vals(:)', [1 size(lrb_fig15_xbar_vals)]), [size(lrb_fig15_data,1) size(lrb_fig15_data,2) 1]), 3);

% Now compile into a single database.
% Will resample by UPSAMPLING
bin_diffs = [diff(lra_fig7_xbar_vals(1:2)) diff(lrb_fig3_xbar_vals(1:2)) diff(lrb_fig15_xbar_vals(1:2))];
bin_mins  = [min(lra_fig7_xbar_vals) min(lrb_fig3_xbar_vals) min(lrb_fig15_xbar_vals)];
bin_maxes = [max(lra_fig7_xbar_vals) max(lrb_fig3_xbar_vals) max(lrb_fig15_xbar_vals)];
min_bin_dist = min(bin_diffs);
min_bin_val  = min(bin_mins - bin_diffs/2);
max_bin_val  = max(bin_maxes + bin_diffs/2);
if min_bin_val<0, max_bin_val = max_bin_val-min_bin_val; min_bin_val=0; end;

lrb_lrs_xbar_vals = min_bin_val:min_bin_dist:max_bin_val;
lrb_lrs_data = zeros(1+size(lrb_fig3_data_normd,1)+size(lrb_fig15_data_normd,1), ...
                    size(lra_fig7_data_normd,1)+ size(lrb_fig3_data_normd,2)+size(lrb_fig15_data_normd,2), ...
                    length(lrb_lrs_xbar_vals));
% 1990b, fig3
ri = 1;
for ai=1:size(lrb_fig3_data_normd,1), for si=1:size(lrb_fig3_data_normd,2)-1
  fprintf('lrb_fig3: %s %s\n', lrb_fig3_age_names{ai}, lrb_fig3_sectors{si})
  lrb_lrs_data(ri,si,:) = rebin_distn(squeeze(lrb_fig3_data_normd(ai,si,:)), lrb_fig3_xbar_vals, lrb_lrs_xbar_vals, false);
  ri = ri+1;
end; end;

% 1990b, fig15
for ai=1:size(lrb_fig15_data_normd,1), for si=1:size(lrb_fig15_data_normd,2)-1
  fprintf('lrb_fig15: %s %s\n', lrb_fig15_age_names{ai}, lrb_fig15_sectors{si});
  lrb_lrs_data(ri,si,:) = rebin_distn(squeeze(lrb_fig15_data_normd(ai,si,:)), lrb_fig15_xbar_vals, lrb_lrs_xbar_vals, false);
  ri = ri+1;
end; end;

% 1990a, fig7
for si=1:size(lra_fig7_data_normd,1)
  fprintf('lra_fig7: %s %s\n', 'adult', lra_fig7_sectors{si});
  lrb_lrs_data(ri,si,:) = rebin_distn(squeeze(lra_fig7_data_normd(si,:)), lra_fig7_xbar_vals, lrb_lrs_xbar_vals, false);
  ri = ri+1;
end;


%% Show overall distribution as a function of age, per study.
lrb_lra_cc_area_est_proportions = lra_cc_sector_area_est./sum(lra_cc_sector_area_est);
sector_indices = [1 1 1 2 2 3 3 3 2 4]; %as per methods, some distributions were so similar, stats were only computed with some of them.
%lrb_fig3_summary_hist = squeeze(mean(lrb_fig3_data_normd(:,sector_indices,:).*repmat(lrb_lra_cc_area_est_proportions, [3 1 26]),2));
lrb_fig3_summary_hist = squeeze(mean(lrb_fig3_data_normd(:,sector_indices,:).*repmat(lrb_lra_cc_area_est_proportions, [size(lrb_fig3_data_normd,1) 1 size(lrb_fig3_data_normd,3)]),2));
lrb_fig15_summary_hist = squeeze(mean(lrb_fig15_data_normd(:,sector_indices,:).*repmat(lrb_lra_cc_area_est_proportions, [size(lrb_fig15_data_normd,1) 1 size(lrb_fig15_data_normd,3)]),2));

figure;
for ai=1:size(lrb_fig3_summary_hist,1)
    subplot(1,size(lrb_fig3_summary_hist,1),ai);
    
    bar(lrb_fig3_xbar_vals, lrb_fig3_summary_hist(ai,:),1);
    set(gca, 'xlim', lrb_fig3_xbar_vals([1 end]));
    hold on; title(lrb_fig3_age_names{ai});
end;

figure;
for ai=1:size(lrb_fig15_summary_hist,1)
    subplot(1,size(lrb_fig15_summary_hist,1),ai);
    bar(lrb_fig15_xbar_vals, lrb_fig15_summary_hist(ai,:),1);
    set(gca, 'xlim', lrb_fig15_xbar_vals([1 end]));
    hold on; title(lrb_fig15_age_names{ai});
end;

lra_fig7_summary_hist = mean(lra_fig7_data,1);

%%
fit_type = 'gamma';'lognormal';'IUBD';
params=zeros(2,8);
params(:,1:3)  = fit_distns(lrb_fig3_xbar_vals,   lrb_fig3_summary_hist, fit_type)
params(:,4:7)  = fit_distns(lrb_fig15_xbar_vals,  lrb_fig15_summary_hist, fit_type)
params(:,8)    = fit_distns(lra_fig7_xbar_vals,   lra_fig7_summary_hist, fit_type)


squeeze(mean(params,1))


%% now compare mean diameter over age
diameter_persector_byage = [lrb_fig3_mean_diameter(:,1:3); lrb_fig15_mean_diameter(:,1:3); lra_fig7_mean_diameter'];

%figure;
%plot(diameter_persector_byage);
%set(gca, 'xticklabel',{lrb_fig3_ages{:} lrb_fig15_ages{:} 'adult'});
%legend(lra_fig7_sectors);

%figure;
%p = zeros(4,4,6);
%for ai=1:4
%    for si=1:4
%        subplot(4,4,(si-1)*4+ai)

%% Now demix distributions
ai=2;si=4;
figure; pq(ai,si,:) = demix_distributions(lrb_fig15_xbar_vals, squeeze(lrb_fig15_data_normd(ai,si,:))');
figure; pq(ai,si,:) = demix_distributions(lra_fig7_xbar_vals, lra_fig7_data_normd(3,:));
%    end;

%end;