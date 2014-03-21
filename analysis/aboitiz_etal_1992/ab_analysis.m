function ab_analysis(vars)
%

    %% Load variables into the current workspace
    varnames = fieldnames(vars);
    varvals = struct2cell(vars);
    for vi=1:length(varnames)
        eval(sprintf('%s = varvals{vi};', varnames{vi}))
    end;

    
    %% Do plots
    f = figure; set(gcf,'Position', [77   117   921   567]);

    % distributions
    IUBD = @(s,a,b) (1./(2*besselk(0,2*sqrt(a.*b))) .* exp(-b.*s - a./s)./s); % via eqn 13

    % Fitting functions
    dndist = @(d1,d2) (sum( (d1 - d2).^2 ));
    fitfn = @(data,x,dnf,p) (dndist(data,dnf(x,p(1),p(2))./sum(dnf(x,p(1),p(2)))));



    frac = 1/50;
    %x = 0.01:0.01:4; %in micrometers
    for hi=1:size(ab_fig4_data,1)
        subplot(1,5,hi);

        % normalize
        ab_fig4_data(hi,:) = ab_fig4_data(hi,:)/sum(ab_fig4_data(hi,:));

        end_idx = find(ab_fig4_data(hi,:)<(frac*max(ab_fig4_data(hi,:))), 1, 'first');
        end_um = ab_fig4_xbin_vals(end_idx-1)

        dndist(ab_fig4_data(hi,1:end_idx-1), IUBD(ab_fig4_xbin_vals(1:end_idx-1), 2.5, 3.4))


        pab1(hi,:) = fit_distns(ab_fig4_data(hi,1:end_idx-1), ab_fig4_xbin_vals(1:end_idx-1), [-3 1], 'lognormal', false);
        pab2(hi,:) = lognfit(ab_fig4_data(hi,1:end_idx-1));
        pab3(hi,:) = fminsearch(@(p) fitfn(ab_fig4_data(hi,1:end_idx-1), ab_fig4_xbin_vals(1:end_idx-1), IUBD, p), [-0.3 0.1], optimset('display', 'iter'))

        xv = ab_fig4_xbin_vals(1:end_idx);
        xv_sm = linspace(xv(1), xv(end), 100);

        bins = ab_fig4_xbin_vals(1:end_idx-1);
        distn = ab_fig4_data(hi,1:end_idx-1);

        bar(bins, distn);
        hold on;
        xvals = 0.01:0.01:max(bins); spacing_fact = mean(diff(bins))/0.01;
        p1 = lognpmf(xvals, pab1(hi,1), pab1(hi,2))*spacing_fact;
        plot(xvals, p1, 'r--', 'LineWidth', 4);
        p2 = lognpmf(xvals, pab2(hi,1), pab2(hi,2))*spacing_fact;
        plot(xvals, p2, 'g--', 'LineWidth', 4);
        p3 = IUBD(xvals, pab3(hi,1), pab3(hi,2)); p3 = p3./sum(p3)*spacing_fact;
        plot(xvals, p3, 'k--', 'LineWidth', 4);
        %set(gca, 'xlim', [0 0.8]);
        legend({'Original data', 'Curve [estimated]'}); 
        set(gca, 'FontSize', 14);
        title('Fitting using gradient descent', 'FontSize', 16);
        xlabel('axon diameter ( {\mu}m)', 'FontSize', 14);
        ylabel('proportion', 'FontSize', 14);
        %bar(xv, ab_fig4_data(hi, 1:end_idx));
        %hold on;
        %plot(xv_sm, lognpmf(xv_sm, pab(hi,1), pab(hi,2)), 'g--', 'LineWidth', 2);
        set(gca, 'ylim', [0 0.30], 'xlim', [0 3.2]);
        %legend({'Aboitiz et al (1992) data', 'Predicted data', 'Fit to Aboitiz data'})
    end;


