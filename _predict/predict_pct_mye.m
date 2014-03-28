function pct_mye = predict_pct_mye(brwt, bvol)
% Predict the total pct myelinated axons in the CC.
% Assumes functional form is a logistic function.


    global g_gmye;

    % convert to native units
    if ~exist('brwt','var'), brwt = predict_bwt(bvol); end;


    %% Predict the % myelination
    if isempty(g_gmye)
        an_dir = fullfile(fileparts(which(mfilename)), '..', 'analysis');

        % Collect data, then predict!
        load(fullfile(an_dir, 'aboitiz_etal_1992', 'ab_data.mat'));
        load(fullfile(an_dir, 'wang_etal_2008', 'w_data.mat'));

        % Collect data
        human_brain_weight = get_human_brain_weight();
        human_pct_mye = 100*sum(ab_fig4_cc_rel_areas .* [.84 .95 .95 .95 .95]); %report that genu is 16% unmyelinated, the rest<5% unmyelinated

        % Average over species with multiple samples.
        [spec_wt,~,spec_idx] = unique(w_fig1c_weights);
        for ii=1:length(spec_wt),
            mpmye(ii) = mean(w_fig1c_pctmye(spec_idx==ii));
        end;

        x = linspace(-human_brain_weight, human_brain_weight, 100);

        % sigmoid
        figure; set(gca, 'FontSize', 14);

        plot(x, 20+73*(atan(0.025*x)*2/pi), 'b--', 'LineWidth', 3); hold on;
        plot([spec_wt human_brain_weight], [mpmye(1:end) human_pct_mye], 'r*', 'MarkerSize', 5, 'LineWidth', 2)

        xlabel('brain weight (g)'); ylabel('%% myelinated fibers');

        g_gmye = struct('y', @(brwt) (20+73*(atan(0.025*brwt)*2/pi)));
    end;

    pct_mye = g_gmye.y(brwt)/100;
%    pct_mye     = 0.92;
