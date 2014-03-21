pd_dir = fileparts(which(mfilename));
rilling_dir = fullfile(pd_dir, '..', '..');
analysis_dir = fullfile(rilling_dir, 'analysis');

% predict macaque / lamantia
addpath(genpath(fullfile(rilling_dir,'_lib')));
addpath(genpath(fullfile(rilling_dir,'_predict')));
load(fullfile(analysis_dir, 'berbel_innocenti_1988', 'bi_data.mat'));
load(fullfile(analysis_dir, 'lamantia_rakic_1990s', 'lrs_data.mat'));
load(fullfile(analysis_dir, 'wang_etal_2008', 'w_data.mat'));

bi_fig7_dates
% Predict from wang data
[cat_dens] = predict_cc_density(w_fig1e_weights(strcmp('cat', w_fig1e_species)));

figure; set(gcf, 'Position', [ 69         258        1212         405]);

% cat
subplot(1,2,1);
plot(bi_fig7_dates, bi_fig7_density, 'bo');
hold on;
plot(bi_fig7_dates(end), cat_dens, 'ro');
title('Cat (Berbel & Innocenti, 1988)', 'FontSize', 16);

% monkey
subplot(1,2,2); set(gca, 'FontSize', 14);
semilogx(lrs_age, lrs_dens/100, 'o', 'MarkerSize', 4, 'LineWidth',4); hold on;
semilogx(156*[1 1], get(gca, 'ylim'), 'r--', 'LineWidth', 2); hold on;
%set(gca, 'xlim', xl, 'xtick', 10.^[2:5]); axis square;
xlabel('Age (days since conception)');
ylabel('axons/mm^2');
title('Macaque (Lamantia & Rakic, 1990a;b)', 'FontSize', 16);



%%%%%%%%%%%%%%

keyboard;

cam_bins = cam_figS5_xvals./(1-0.35).^(2/3);

% Predict data using brain weight from rilling and/or wang
%macaque_brain_wt = w_fig1e_weights(find(strcmp('macaque', w_fig1e_species), 1, 'first'))
cat_brain_wt = w_brain_weights(strcmp('cat', w_species));
cat_avg_adult_age = bi_fig17_dates(end);

[~,d_cat,m_cat,u_cat,pmye_cat] = predict_cc_fiber_distn(cat_brain_wt);
f_fiber_distn = gcf;
[dens_cat] = predict_cc_density(cat_brain_wt);
[cca_cat]  = predict_cca(cat_brain_wt);


% Gather Berbel & Innocenti data
lam_bins = linspace(0,4,100);
lam_distn = rebin_distn(distn_weights*lra_fig7_data_distn, lra_fig7_xbar_vals, lam_bins);

% Gather caminiti data
cam_bins = linspace(0,4,100);
cam_distn = rebin_distn(cam_figS5_data{1}(strcmp('cat', cam_species),:), cam_figS5_xvals, cam_bins);


%% Look at predicted fiber distributions
figure(f_fiber_distn);
subplot(1,2,1);
hold on;
bh = bar(lam_bins, lam_distn, 1, 'g');
set(get(bh,'child'),'facea',.5)
[~,~,lh,lt] = legend();
legend([lh;bh], [guru_csprintf('%s (predicted)',lt) {'LaMantia & Rakic (1990a)'}]);

subplot(1,2,2);
hold on;
bh = bar(lam_bins, pmye_cat*lam_distn, 1, 'g');
set(get(bh,'child'),'facea',.5)
ch = bar(cam_bins, pmye_cat*cam_distn, 1, 'y');
set(get(ch,'child'),'facea',.5)
[~,~,lh,lt] = legend();
legend([lh;bh;ch], [guru_csprintf('%s (predicted)',lt) {'LaMantia & Rakic (1990a)' 'Caminiti et al. (2009)'}]);


keyboard
%% Look at density predicitions
figure;

set(gca, 'FontSize', 14);
semilogx(lrs_age, lrs_dens/100, 'o', 'MarkerSize', 4, 'LineWidth',4); hold on;
semilogx(156*[1 1], get(gca, 'ylim'), 'r--', 'LineWidth', 2); hold on;
%set(gca, 'xlim', xl, 'xtick', 10.^[2:5]); axis square;
xlabel('Age (days since conception)');
ylabel('axons/mm^2');
title('cat (Berbel & Innocenti (1988)', 'FontSize', 16);
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
