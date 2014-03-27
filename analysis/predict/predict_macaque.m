pd_dir = fileparts(which(mfilename));
rilling_dir = fullfile(pd_dir, '..', '..');
analysis_dir = fullfile(rilling_dir, 'analysis');

% predict macaque / lamantia
addpath(genpath(fullfile(rilling_dir,'_lib')));
addpath(genpath(fullfile(rilling_dir,'_predict')));
load(fullfile(analysis_dir, 'caminiti_etal_2009', 'cam_data.mat'));
load(fullfile(analysis_dir, 'lamantia_rakic_1990s', 'lrs_data.mat'));
load(fullfile(analysis_dir, 'rilling_insel_1999a', 'ria_data.mat'));
load(fullfile(analysis_dir, 'wang_etal_2008', 'w_data.mat'));

% Predict data using brain weight from rilling and/or wang
%macaque_brain_wt = w_fig1e_weights(find(strcmp('macaque', w_fig1e_species), 1, 'first'))
nbins = 100;
pred_bins = linspace(0,4,nbins);

macaque_brain_wt = predict_bwt(ria_table1_brainvol(find(strcmp('M. mulatta',ria_table1_species),1,'first')));
macaque_avg_adult_age = str2date(sprintf('P%d',365*mean(lra_cc_age)), 'macaque');

[pmye_macaque] = predict_pct_mye(macaque_brain_wt);
[dens_macaque] = predict_cc_density(macaque_brain_wt);
[cca_macaque]  = predict_cc_area(macaque_brain_wt);


% Gather lamantia data
distn_weights = lra_cc_sector_rel_areas(cellfun(@str2num, lra_fig7_sectors));
distn_weights(1) = 0;  %
distn_weights = distn_weights./sum(distn_weights);
lam_distn = rebin_distn(distn_weights*lra_fig7_data_distn, lra_fig7_xbar_vals, pred_bins);

% Gather caminiti data
cam_distn = rebin_distn(cam_figS5_data{1}(strcmp('macaque', cam_species),:), cam_figS5_xvals, pred_bins);


%% Look at predicted fiber distributions
figure(f_fiber_distn);
subplot(1,2,1);
hold on;
bh = bar(pred_bins, lam_distn, 1, 'g');
set(get(bh,'child'),'facea',.5)
[~,~,lh,lt] = legend();
legend([lh;bh], [guru_csprintf('%s (predicted)',lt) {'LaMantia & Rakic (1990a)'}]);

subplot(1,2,2);
hold on;
bh = bar(pred_bins, pmye_macaque*lam_distn, 1, 'g');
set(get(bh,'child'),'facea',.5)
ch = bar(pred_bins, pmye_macaque*cam_distn, 1, 'y');
set(get(ch,'child'),'facea',.5)
[~,~,lh,lt] = legend();
legend([lh;bh;ch], [guru_csprintf('%s (predicted)',lt) {'LaMantia & Rakic (1990a)' 'Caminiti et al. (2009)'}]);


%% Look at density predicitions
figure;

set(gca, 'FontSize', 14);
semilogx(lrs_age, lrs_dens/100, 'o', 'MarkerSize', 4, 'LineWidth',4); hold on;
semilogx(156*[1 1], get(gca, 'ylim'), 'r--', 'LineWidth', 2); hold on;
%set(gca, 'xlim', xl, 'xtick', 10.^[2:5]); axis square;
xlabel('Age (days since conception)');
ylabel('axons/mm^2');
title('Macaque (Lamantia & Rakic (1990a,b)', 'FontSize', 16);
prh = semilogx(macaque_avg_adult_age, dens_macaque, 'ro');
legend(prh, {'Predicted density (Wang et al., 2008)'})


%% Look at predicted ccas (rilling)
figure;
set(gca, 'FontSize', 14);
semilogx(lrs_age, lrs_area/10^6, 'o', 'MarkerSize', 4, 'LineWidth',4); hold on;
semilogx(156*[1 1], get(gca, 'ylim'), 'r--', 'LineWidth', 2); hold on;
%set(gca, 'xlim', xl, 'xtick', 10.^[2:5]); axis square;
xlabel('Age (days since conception)');
ylabel('mm^2');
title('Cross-sectional area', 'FontSize', 18);
prh = semilogx(macaque_avg_adult_age, cca_macaque, 'ro');
legend(prh, {'Predicted CCA (Rilling & Insel, 1999)'})
