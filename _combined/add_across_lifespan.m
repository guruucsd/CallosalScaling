% Attempts to combine human data from across studies, and compare them
%
% Rakic & Yaklovev, Luttenberg: CCA in development
%
% Tomasch & Aboitiz: fiber density in adults

warning('This uses old function calls and fails to smooth distributions before fitting them.');
warning('Migrate to new fitting functions, and smooth distributions before fitting!');
% Fit function:
%
% Smoothing:
%[ab_overall_smth, ab_fig4_xbin_smth] = smooth_distn(ab_overall_distn./sum(ab_overall_distn), ab_fig4_xbin_vals, [], 10, true);

clear all;
hc_dir = fileparts(which(mfilename));
addpath(fullfile(hc_dir, '..', 'aboitiz_etal_1992'));   ab_data;  close all;
addpath(fullfile(hc_dir, '..', 'luttenberg_1965'));     lut_data; close all;
addpath(fullfile(hc_dir, '..', 'rakic_yaklovev_1968')); ry_data;  close all;
addpath(fullfile(hc_dir, '..', 'tomasch_1954'));        tom_data; close all;
addpath(fullfile(hc_dir, '..', 'caminiti_etal_2009'));  cam_data; close all;


%% Calculate corrections
tom_correction = (1-0.25)^(2/3);
%ab_fig4_xbin_vals = ab_fig4_xbin_vals;
%tom_fig2_xbar_vals= tom_fig2_xbar_vals/tom_correction;



%% Fiber density
[fitfn,pmffn] = guru_getfitfns('IUBD', 1/50, true);

% Fit a lognormal to the original aboitiz et al distribution
figure;
xvals          = ab_fig4_xbin_vals;
[ab_p,fitidx]  = fitfn(ab_overall_distn, xvals);
set(gca, 'xlim', xvals(fitidx([1 end]))); title('Aboitiz et al. (1992)');

% Fit a lognormal to the tomasch distribution
figure;
xvals          = tom_fig2_xbar_vals/tom_correction;
[tom_p,fitidx] = fitfn(tom_fig2_hist_vals/sum(tom_fig2_hist_vals), xvals);
set(gca, 'xlim', xvals(fitidx([1 end]))); title('Tomasch (1954)');

% Fit a lognormal to the caminiti distribution
figure;
cam_add        = cam_figS5_data{2}(3,:);
xvals          = cam_diam_from_vel(cam_figS5_xvals);
[cam_p,fitidx] = fitfn(cam_add, xvals);
set(gca, 'xlim', xvals(fitidx([1 end]))); title('Caminiti et al. (2009)');

% Fit a lognormal to the last luttenberg distribution
figure;
lut_table3_add = squeeze(sum(repmat(lut_area_proportions, [1 1 length(lut_table3_diameters)]).*reshape([lut_table3_genu; lut_table3_truncus; lut_table3_splenium], [15 3 6]), 2));
lut_add        = lut_table3_add(1,:);
xvals          = lut_table3_diameters;
[lut_p,fitidx] = fitfn(lut_add, xvals);
set(gca, 'xlim', xvals(fitidx([1 end]))); title('Luttenberg et al. (1965)');


% Resample Aboitiz et al, according to Tomasch, 1954
%tom_fig2_xbin_vals = 0.5:0.5:10;
ab_overall_distn_tom = rebin_distn(ab_overall_distn,       ab_fig4_xbin_vals,    tom_fig2_xbar_vals/tom_correction);
cam_distn_tom        = rebin_distn(cam_add, cam_diam_from_vel(cam_figS5_xvals), tom_fig2_xbar_vals/tom_correction);
lut_disnt_tom        = rebin_distn(lut_add,  lut_table3_diameters, tom_fig2_xbar_vals/tom_correction);


% Now plot tomasch and aboitiz (resampled) distributions
figure;
plot([0 tom_fig2_xbar_vals/tom_correction], [0 ab_overall_distn_tom], 'b');
hold on;
plot([0 tom_fig2_xbar_vals/tom_correction], [0 tom_fig2_hist_vals/sum(tom_fig2_hist_vals)], 'r');
plot([0 tom_fig2_xbar_vals/tom_correction], [0 cam_distn_tom], 'g');
plot([0 tom_fig2_xbar_vals/tom_correction], [0 lut_disnt_tom], 'k');
legend({'Aboitiz et al (1992)', 'Tomasch (1954)' 'Caminiti et al. (2009)' 'Luttenberg (1965)'});
title('Plotting resampled data');


% Now plot the model functions more smoothly
figure;
xvals = 0:0.01:10;
plot(xvals, pmffn(xvals, ab_p),'b');
hold on;
plot(xvals, pmffn(xvals, tom_p),'r');
plot(xvals, pmffn(xvals, cam_p),'g');
plot(xvals, pmffn(xvals, lut_p),'k');
legend({'Aboitiz et al (1992)', 'Tomasch (1954)' 'Caminiti et al. (2009)'});
title('Plotting function fits');


% Finally, one plot to combine them all
% Now plot the model functions more smoothly
figure;
xvals = 0:0.05:10;
hold on;
bar(ab_fig4_xbin_vals, ab_overall_distn*length(ab_fig4_xbin_vals)/length(xvals), 'b');%_histogram)
tbh = bar(tom_fig2_xbar_vals/tom_correction, tom_fig2_hist_vals/sum(tom_fig2_hist_vals)*length(tom_fig2_xbar_vals)/length(xvals), 'r');
plot(xvals, pmffn(xvals, ab_p),'b');
plot(xvals, pmffn(xvals, tom_p),'r');
set(get(tbh,'child'),'facea',.5)
legend({'Aboitiz et al (1992)', 'Tomasch (1954)'});
title('Plotting function fits for both Abotitiz et al (1992) and Tomasch (1954)');
