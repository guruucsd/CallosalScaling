tom_data;

% Normalize
tom_fig1_hist_vals = tom_fig1_hist_vals./sum(tom_fig1_hist_vals); %normalize distribution
tom_fig2_hist_vals = tom_fig2_hist_vals./sum(tom_fig2_hist_vals); %normalize distribution


% Add 
xbar_vals = 0:0.5:8;
tom_fig1_hist_vals = rebin_distn(tom_fig1_hist_vals, tom_fig1_xbar_vals, xbar_vals); 
tom_fig2_hist_vals = rebin_distn(tom_fig2_hist_vals, tom_fig2_xbar_vals, xbar_vals); 

figure;
subplot(1,2,1);
bar([0:0.2:4], rebin_distn(ab_overall_distn, ab_fig4_xbin_vals, [0:0.2:4]), 'r')
hold on;
subplot(1,2,2);


[tom_fig1_hist_vals, xbar_vals2] = smooth_distn(tom_fig1_hist_vals, xbar_vals)
[tom_fig2_hist_vals, xbar_vals2] = smooth_distn(tom_fig2_hist_vals, xbar_vals)

% Shrin bin sizes
%xbar_vals2 = 0:0.1:8;
%tom_fig1_hist_vals = rebin_distn(tom_fig1_hist_vals, xbar_vals, xbar_vals2);
%tom_fig2_hist_vals = rebin_distn(tom_fig2_hist_vals, xbar_vals, xbar_vals2);
xbar_vals = xbar_vals2;

% Smooth

[ab_overall_distn, ab_fig4_xbin_vals] = rebin_distn(ab_overall_distn, ab_fig4_xbin_vals, [0 ab_fig4_xbin_vals]);
[ab_overall_distn, ab_fig4_xbin_vals] = smooth_distn(ab_overall_distn./sum(ab_overall_distn), ab_fig4_xbin_vals);
bh = bar([0:0.2:4], rebin_distn(ab_overall_distn, ab_fig4_xbin_vals, [0:0.2:4]), 'g');
ch = get(bh,'child');
set(ch,'facea',.5)


%
[fit_lognormal] = getfitfns('gamma');



curve_x = linspace(min(xbar_vals), max(xbar_vals), 25);

figure; set(gcf, 'Position', [52         156        1228         528]);

subplot(1,3,1);
pmye = fit_lognormal(tom_fig1_hist_vals, xbar_vals)
axis tight;

subplot(1,3,2);
pall = fit_lognormal(tom_fig2_hist_vals, xbar_vals)
axis tight;

subplot(1,3,3);
um = 111*tom_fig2_hist_vals - 65*tom_fig1_hist_vals;
um = um./sum(um);
pun = fit_lognormal(um, xbar_vals);
axis tight;

%figure;
%subplot(1,2,1);
%bar(tom_fig2_xtick_vals, tom_fig2_hist_vals);

%subplot(1,2,2);
%bar(tom_fig2_xtick_vals, tom_fig2_hist_vals); hold on;
%plot(curve_x, lognpmf(curve_x, p(1), p(2))*25/16, 'r--');

