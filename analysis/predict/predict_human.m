function predict_human( fit_fn, figs )

if ~exist('fit_fn','var'), fit_fn = 'gamma'; end;
if ~exist('frac','var'), frac = 1/50; end;
if ~exist('figs','var'), figs = {'predict_ab'}; end;
if ~iscell(figs), figs = {figs}; end;

pdh_dir = fileparts(which(mfilename));
analysis_dir = fullfile(pdh_dir, '..');

%% Load data
load(fullfile(analysis_dir, 'aboitiz_etal_1992', 'ab_data.mat'));
human_brain_weight = get_human_brain_weight();

%% Correct data
% Space out
%xvals = guru_newbins( ab_fig4_xbin_vals, 5 );
%[ab_overall_distn, ab_fig4_xbin_vals] = rebin_distn(ab_overall_distn./sum(ab_overall_distn), ab_fig4_xbin_vals, xvals, (ismember('rebin',figs) || ismember('all',figs)));

% Smooth
[ab_overall_distn, ab_fig4_xbin_vals] = smooth_distn(ab_overall_distn, ab_fig4_xbin_vals, 5, 10, true);

area_distn = cumsum(ab_overall_distn.^2)./sum(ab_overall_distn.^2);  % 1.2%
keyboard
ab_fig4_xbin_vals = ab_fig4_xbin_vals / sqrt(0.65) / 1.2 / sqrt(1.2);  % fake the corrections


%% Validation 1: Aboitiz et al, 1992
%xvals = guru_newbins( ab_fig4_xbin_vals, 5 );
%[ab_overall_distn, ab_fig4_xbin_vals] = rebin_distn(ab_overall_distn./sum(ab_overall_distn), ab_fig4_xbin_vals, xvals, (ismember('rebin',figs) || ismember('all',figs)));
%[ab_overall_distn, ab_fig4_xbin_vals] = rebin_distn(ab_overall_distn./sum(ab_overall_distn), ab_fig4_xbin_vals, [0 ab_fig4_xbin_vals]);

%% Predict distribution parameters, for humans
%% Predict the % myelination
[cc_add, cc_add_mye, cc_add_unmye, pct_mye, xvals] = predict_cc_add([], human_brain_weight, ab_fig4_xbin_vals, [], fit_fn, frac);
%close(gcf); f_regress = gcf;

% Fit that data directly, plot it
do_fitab_fig = (ismember('fit_ab',figs) || ismember('all',figs));
if do_fitab_fig, figure; end;
[fitfn,pmffn] = guru_getfitfns(fit_fn, frac, do_fitab_fig);
[pab] = fitfn(ab_overall_distn, ab_fig4_xbin_vals)

% Plot human distribution parameters on the distribution parameter
% regression plots, ASSUMING ALL FIBERS TO BE MYELINATED
%
%if exist('f_regress','var')
%    figure(f_regress);
%    for ii=1:length(pab), subplot(2,length(pab),ii); loglog(human_brain_weight, pab(ii), 'r*'); end;
%end;

% Smooth the Aboitiz data, and fit that
%[ab_overall_smth, ab_fig4_xbin_smth] = rebin_distn(ab_overall_distn./sum(ab_overall_distn), ab_fig4_xbin_vals, xvals);
%[ab_overall_smth, xvals_smth] = smooth_distn(ab_overall_distn./sum(ab_overall_distn), xvals, [], 10, true);
%f_abfit_smth = figure;
%pab_smth = fitfn(ab_overall_smth, xvals_smth), close(f_abfit_smth);

% Plot human distribution parameters on the distribution parameter
% regression plots, ASSUMING ALL FIBERS TO BE MYELINATED
%if exist('f_regress','var')
%    figure(f_regress);
%    for ii=1:length(pab_smth), subplot(2,length(pab_smth),ii); loglog(human_brain_weight, pab(ii), 'g*', 'MarkerSize', 10, 'LineWidth', 3); end;
%end;


% Plot the results:
% subplot 1: myelinated and unmyelinated distributions
if ismember('predict_ab',figs) || ismember('all',figs)
    f_predict = figure; set(f_predict,'position', [5         229        1276         455]);
    subplot(1,3,1);
    bh = bar(xvals, cc_add_unmye, 1, 'r', 'EdgeColor','r');
    hold on;
    bar(xvals, cc_add_mye, 1, 'b', 'EdgeColor','b');
    ch = get(bh,'child');
    set(ch, 'facea', .5)

    axis tight;%set(gca, 'ylim', [0 0.60], 'xlim', [0 4]);
    set(gca, 'xlim', [0 4]);
    legend({'unmyelinated','myelinated'});
    title('Predicted (human) histograms');

    % subplot 2: show the predicted and aboitiz distns
    subplot(1,3,2); set(gca, 'FontSize', 14)
    [bh] = bar(ab_fig4_xbin_vals, ab_overall_distn);
    hold on;
    ph1 = plot(ab_fig4_xbin_vals, cc_add, 'r--', 'LineWidth', 3);
    ph2 = plot(ab_fig4_xbin_vals, pmffn(ab_fig4_xbin_vals, pab), 'g--', 'LineWidth', 3);
    %ph3 = plot(xvals, cc_add_mye, 'y--', 'LineWidth', 3);
    %set(gca, 'ylim', [0 0.005], 'xlim', [0 4]);
    set(gca, 'xlim', [0 4]);
    legend([bh ph1 ph2], {'Aboitiz et al (1992) data', 'Predicted data', 'Fit to Aboitiz data'})
    title('Predicted (combined) histograms vs. data');
    xlabel('axon diameter (\mu m)'); ylabel('proportion');

    % subplot 3: compare the measured and predicted distributions
    subplot(1,3,3);
    %dff = ab_overall_distn - pmffn(ab_fig4_xbin_vals, pab);  % compare actual data
    dff = ab_overall_distn - cc_add;  % compare fit data
    bar(xvals, dff);
    axis tight;
    [~,idx] = max(abs(dff))   % find the peak point of difference
    idx = find(dff(idx:end)>0, 1,'first') + idx-1;  % find starting positive point
    pct_diff = sum(dff(1:idx-1));  % should be same as sum(dff(idx:end))
    title(sprintf('%5.2f%% difference', 100 * -sum(dff(1:idx-1))));  %
    sum(cc_add(xvals<=1))
    sum(ab_overall_distn(xvals<=1))
    hold on;
    plot(xvals(idx),0,'r*');
    %keyboard
end;

fprintf('Aboitiz effective density: %f\n', calc_fiber_density(xvals, -ab_overall_distn + pmffn(xvals, pab), xvals, cc_add_unmye, 1));
fprintf('Aboitiz effective density: %f\n', calc_fiber_density(xvals, ab_overall_distn, xvals, cc_add_unmye, 1));
%fprintf('Aboitiz effective density: %f\n', calc_fiber_density(xvals, (ab_overall_distn.*(xvals>0.4))./sum((ab_overall_distn.*(xvals>0.3))), xvals, cc_add_unmye, pct_mye));
fprintf('Predicted distribution''s effective fiber density: %f\n', calc_fiber_density(xvals, cc_add_mye, xvals, cc_add_unmye, 1));



% subplot 2: show the predicted and smoothed aboitiz distns
%subplot(1,3,3);
%bar(ab_fig4_xbin_smth, ab_overall_smth);
%hold on;
%plot(ab_fig4_xbin_smth, human_distn(ab_fig4_xbin_smth), 'r--', 'LineWidth', 2);
%plot(ab_fig4_xbin_smth, pmffn(ab_fig4_xbin_smth, pab_smth(1), pab_smth(2)), 'g--', 'LineWidth', 2);
%plot(ab_fig4_xbin_smth, pmffn(ab_fig4_xbin_smth, pab(1), pab(2)), 'y--', 'LineWidth', 2);
%axis tight;set(gca, 'xlim', [0 4], 'ylim', [0 1.25*max(ab_overall_smth)]);
%legend({'Aboitiz et al (1992) data', 'Predicted data', 'Fit to Aboitiz data (smoothed)' 'Fit to Aboitiz data (unsmoothed)'})
%title('Predicted (combined) histograms vs. data');


%% Validation 2: Tomasch
load(fullfile(analysis_dir, 'tomasch_1954', 'tom_data.mat'));


%% Validation 3: CCA



%% Old
if false
    [X,Y] = meshgrid(w_fig4_xvals(1:round(end/2)), 1:length(w_fig4_species));
    figure;
    caxis([0 0.05])
    waterfall(X, Y, w_fig4_unmyelinated(end:-1:1,(1:round(end/2))));
    hold on;
    waterfall(X, Y, w_fig4_myelinated(end:-1:1,(1:round(end/2))));

    % Make a density prediction, and compare it to 3.3
end;

keyboard