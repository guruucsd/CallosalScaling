function w_analysis(vars)
%

    %% load variables into the current workspace
    varnames = fieldnames(vars);
    varvals = struct2cell(vars);
    for vi=1:length(varnames)
        eval(sprintf('%s = varvals{vi};', varnames{vi}))
    end;

    human_brain_weight = get_human_brain_weight();  % grams

    %% Examine axon distributions


    %w_gp_regress(vars);  % gaussian process regression
    %w_fit_distns(vars);  % code moved to w_regress_distns
    w_regress_distns(vars);


    % Overlay unmyelinated distributions on each other
    figure;
    plot(w_fig4_xvals(1:round(end/2)), w_fig4_unmyelinated(:,1:round(end/2))');
    hold on;
    legend(w_fig4_species);
    title('Unmyelinated fibers, across species');


    % Overlay myelinated distributions on each other
    figure;
    plot(w_fig4_xvals, w_fig4_myelinated');
    hold on;
    legend(w_fig4_species);
    title('Myelinated fibers, across species');

    % Show CDF of myelinated fibers
    figure;
    plot(w_fig4_xvals, (cumsum(w_fig4_myelinated,2)./repmat(sum(w_fig4_myelinated,2), [1 size(w_fig4_myelinated,2)]))');
    hold on;
%    set(gca,'xlim', [1 2.5]);
    legend(w_fig4_species);
    title('Myelinated fibers, across species (cumulative distribution)');

    % Show CDF of unmyelinated fibers
    figure;
    plot(w_fig4_xvals, (cumsum(w_fig4_unmyelinated,2)./repmat(sum(w_fig4_unmyelinated,2), [1 size(w_fig4_unmyelinated,2)]))');
    hold on;
%    set(gca,'xlim', [1 2.5]);
    legend(w_fig4_species);
    title('Unmyelinated fibers, across species (cumulative distribution)');


    %% Densities: regress, show human & monkey data
    pdens = [polyfit(log10([w_fig1e_weights]), log10([w_fig1e_dens_est]),1)];
    gdens = @(wt) 10.^(polyval(pdens, log10(wt)));

    figure; set(gcf, 'Position', [25         313        1130         371]);
    subplot(1,2,1);
    hold on;
    plot(log10(w_fig1e_weights), w_fig1e_dens_est,'o');
    plot(log10([w_fig1e_weights human_brain_weight]),gdens([w_fig1e_weights human_brain_weight]) );
    plot(log10(human_brain_weight), 0.37*sqrt(0.65), 'r*');
    plot(log10(human_brain_weight), 0.37*sqrt(0.65)*1.2*1.2, 'g*');
    title('Brain weight vs. density (semilog)');

    subplot(1,2,2);
    hold on;
    plot(log10(w_fig1e_weights), log10(w_fig1e_dens_est),'o');
    plot(log10([w_fig1e_weights human_brain_weight]),log10(gdens([w_fig1e_weights human_brain_weight])) );
    plot(log10(human_brain_weight), log10(0.33), 'r*');
    plot(log10(human_brain_weight), log10(0.33*1.2), 'g*');
    title('Brain weight vs. density (loglog)');


    %% Try to compute CCA, then compare to actual CCA
    mean_pctmye = 0.01*[mean(w_fig1c_pctmye(1:2)); mean(w_fig1c_pctmye(3:5)); w_fig1c_pctmye(6); mean(w_fig1c_pctmye(7:8)); w_fig1c_pctmye(9:10)];
    myelinated_distn   = w_fig4_myelinated./repmat(sum(w_fig4_myelinated,2),[1 size(w_fig4_myelinated,2)]);
    unmyelinated_distn = w_fig4_unmyelinated./repmat(sum(w_fig4_myelinated,2),[1 size(w_fig4_unmyelinated,2)]);

    unmyelinated_area = sum(unmyelinated_distn .* repmat(2*pi*(w_fig4_xvals/2).^2,     [size(unmyelinated_distn,1) 1]), 2);
    myelinated_area   = sum(myelinated_distn   .* repmat(2*pi*(w_fig4_xvals/0.7/2).^2, [size(myelinated_distn,1)   1]), 2); %myelinated g-ratio 0.7 across species
    tot_area_perfiber = myelinated_area.*mean_pctmye + unmyelinated_area.*(1-mean_pctmye); %um^2


    figure;
    plot(1./w_fig1e_dens_est, tot_area_perfiber, 'o');
    xlabel('1/density (um^2)'); ylabel('area per fiber (um^2)');

    filling_frac = (1./w_fig1e_dens_est - tot_area_perfiber')./(1./w_fig1e_dens_est +tot_area_perfiber')/2 + 1;
    figure;
    plot(log10(w_fig1e_weights), log10(filling_frac), 'o');
    title('Filling fraction across species');






