rat_path = fileparts(which(mfilename));
data_file = fullfile(rat_path, 'rat_data.mat');

consistency_check = false;

if ~exist(data_file, 'file')
    rat_tab1_brain_weights = [2784 2738 2566 2448];


    data =  parse_img_by_color(fullfile(rat_path, 'img', 'Fig6_marked.png'), 'g', @(x)(x), @(y)(0+20*y));
    rat_fig6_distn = data{1}'./sum(data{1});
    rat_fig6_xbin_vals = [.822 1.14 1.59 2.21 10];

    vars = who('rat_*');
    save(data_file, vars{:});
end;

if consistency_check
    prat = fit_lognormal(rat_fig6_distn, rat_fig6_xbin_vals);

    minke_brain_weight = mean(rat_tab1_brain_weights);

    % p(1) = ln(mn)-p(2).^2/2;
    % p(2) = sqrt(ln(var/mn.^2 + 1))
    sigmafn = @(mn,var) (sqrt(log(var/(mn.^2)+1)));
    meanfn  = @(mn,var) (log(mn)-log(var/(mn.^2)+1)/2);

    % var = exp(p
    %mn = exp(p(1)+p(2).^2/2);
    %var = (exp(p(2).^2)-1).*exp(2*p(1)+p(2).^2);


    % Predict mean & variance
    predict_direct = true;
    if predict_direct
        minke_m_p = [polyval(pmpm, log(minke_brain_weight)) polyval(pmps, log(minke_brain_weight))];
        minke_u_p = [polyval(pupm, log(minke_brain_weight)) polyval(pups, log(minke_brain_weight))];
    else
        minke_m_p = [polyval(pmm, log(minke_brain_weight)) polyval(pmv,log(minke_brain_weight))];
        minke_u_p = [polyval(pum, log(minke_brain_weight)) polyval(puv,log(minke_brain_weight))];

        % back-predict mu and sigma
        minke_m_p = [meanfn(minke_m_p(1), minke_m_p(2)) sigmafn(minke_m_p(1), minke_m_p(2))];
        minke_u_p = [meanfn(minke_u_p(1), minke_u_p(2)) sigmafn(minke_u_p(1), minke_u_p(2))];
    end;


    %% Make a prediction for minke data distribution, and compare it to aboitiz et al


    % Predict the % myelination
    %for ii=1:length(unique(w_fig1c_weights)), mpmye(ii) = mean(w_fig1c_pctmye(j==ii)); end;
    %pmye = polyfit(log(unique(w_fig1c_weights)), mpmye, 2);
    %gmye = @(wt) (polyval(pmye, log(wt)));

    minke_pct_mye = .95;
    minke_m_distn = lognpmf(rat_fig6_xbin_vals, minke_m_p(1), minke_m_p(2));
    minke_u_distn = lognpmf(rat_fig6_xbin_vals, minke_u_p(1), minke_u_p(2));
    minke_distn   = minke_pct_mye*minke_m_distn + (1-minke_pct_mye)*minke_u_distn;

    figure; set(gcf,'position', [139   297   909   387]);
    subplot(1,2,1);
    bar(rat_fig6_xbin_vals, minke_m_distn);
    hold on;
    bar(rat_fig6_xbin_vals, minke_u_distn, 'r');
    set(gca, 'ylim', [0 0.60], 'xlim', [0 4]);

    subplot(1,2,2);
    bar(rat_fig6_xbin_vals, rat_fig6_distn);
    hold on;
    plot(rat_fig6_xbin_vals, minke_distn, 'r--', 'LineWidth', 2);
    plot(rat_fig6_xbin_vals, lognpmf(rat_fig6_xbin_vals, prat(1), prat(2)), 'g--', 'LineWidth', 2);
    set(gca, 'ylim', [0 0.750], 'xlim', [0 11]);

end;