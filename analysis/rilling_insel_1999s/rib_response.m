function rib_response(collation, figs)
    %clear all global
    %figs = {'all'};
    if ~exist('collation','var'), collation = 'species'; end;
    if ~exist('figs','var'), figs = {'all'}; end;
    if ~iscell(figs), figs = {figs}; end;

    fprintf('rib response(collation=%s)\n', collation);

    %% Get data
    %ris_data_path = strrep(fileparts(which(mfilename)), 'analysis', 'data_collection');
    %addpath(ab_data_path);
    ris_dir = fileparts(which(mfilename));
    data_file = fullfile(ris_dir, sprintf('%s-%s.mat', mfilename, collation));

    %if exist(data_file,'file') && isempty(figs)
    %    return;
    %end;

    % Collate
    [bvols, ccas, ~, gmvs] = ris_collate(collation);  % Only collate VOLUMES, no other values, to use standard code.

    % Now use the functions to compute # cc fibers and # neurons
    bwts = predict_brwt(bvols);
    %gmvs = gmas .* predict_gm_thickness(bwts, bvols);%predict_gm_volume(bwts, bvols, collation);
    [nwm_fibers, ncc_fibers, nintra_fibers] = predict_nfibers(bwts, bvols, collation, gmvs, [], [], ccas);
    [nareas, nareaconns]  = predict_nareas(bwts, bvols);


    % Brain weight vs. # cc fibers
    %if ismember('all',figs) || ismember('brwt_vs_cc_fibers', figs)
    fprintf('Regressing brain weight vs. # cc fibers...');
    [p,g,rsq] = allometric_regression(bvols, ncc_fibers, 'log', 1, true);
    fprintf('r^2=%5.3f\n', rsq{1})
    if ismember('all', figs) || ismember('bv_vs_cc_cxns', figs)
        allometric_plot2(bvols, ncc_fibers, p, g);
        ylabel('# cc fibers'); xlabel('brain volume (cm^3)');
    end;
    %keyboard;

    % # wm fibers vs. # cc fibers
    fprintf('Regressing # wm fibers vs. # cc fibers...');
    [p,g,rsq] = allometric_regression(nwm_fibers, ncc_fibers, 'log', 1, true);
    %keyboard

    fprintf('r^2=%5.3f\n', rsq{1})
    if ismember('all', figs) || ismember('wm_cxns_vs_cc_cxns', figs)
        allometric_plot2(nwm_fibers, ncc_fibers, p, g);
        subplot(1,2,1); ylabel('total callosal fibers'); xlabel('total white matter fibers');
        subplot(1,2,2); xlabel('total white matter fibers');

    elseif ismember('wm_cxns_vs_cc_cxns_withrinsel', figs)
        allometric_plot2(nwm_fibers, ncc_fibers, p, g);
        subplot(1,2,1); ylabel('total callosal fibers'); xlabel('total white matter fibers');
        subplot(1,2,2); xlabel('total white matter fibers');

        % Now go back and plot Ringo results
        p_rinsel = [0.88, 0.84]; % From Rilling & Insel (1999a) Figure 2
        y_rinsel = @(x) p_rinsel(2) * x.^p_rinsel(1);
        xl = get(gca, 'xlim');
        xvals = linspace(xl(1), xl(2), 100);
        subplot(1,2,2); hold on; rh = plot(xvals, y_rinsel(xvals), '-', 'Color', 0.85*[1 1 1], 'LineWidth', 12);

        % Now re-plot the above, but on top
        allometric_plot2(nwm_fibers, ncc_fibers, p, g, {'loglog','linear'}, gcf);
        subplot(1,2,2);
        [~,~,ph,pt] = legend(gca); legend([ph; rh], [pt {' y=0.84*x^{0.88}'}], 'Location', 'NorthWest');
    end;


    %% 2. Contrast connection types: fiber scaling vs area scaling
    % Testing for isometry

    % For all cortical areas, they project out to some proportion of areas
    % (nareas_projout) with some number of neurons (0.3*nneurons_perarea)
    %
    % OVER ALL areas, how many of the projecting white matter fibers GO
    % to a particular area?
    %
    % For cc, all fibers go to ONE area (homotopic)
    %
    % Note: The const difference between them (slope of line is non-zero)
    %   suggests there are more fibers in a CC area connection than an
    %   INTRA area conection.  We will test this later.
    %
    fprintf('Regressing [proportion inter-fibers] vs. [proportion inter- area conns]...\n');

    y1 = (ncc_fibers./nintra_fibers);
    x1 = 1./(nareaconns-1);
    [p1, g1, rsq1] = allometric_regression_offset(x1, y1);%, 'log', 1, true);
    rsq1 = {rsq1};
    fprintf('ALLOMETRIC r^2=%5.3f\n', rsq1{1})

    y2 = ncc_fibers./nintra_fibers;
    x2 =  1./(nareaconns-1);
    [p2, g2, rsq2] = allometric_regression(x2, y2, 'linear');
    fprintf('LINEAR r^2=%5.3f\n', rsq2{1})

    if ismember('all', figs) || length(intersect(figs, {'prop_fibers_vs_prop_aa_cxns', 'prop_fibers_vs_prop_aa_cxns_linear'})) == 2
        fh = figure('position', [131         220        1161         564]);

        subplot(1,2,1)
        allometric_plot2(x1, y1, p1, g1, 'linear', fh);
        xlabel('inter-area connection ratio'); ylabel('fiber count ratio');
        title(sprintf('allometric version (r^2=%5.3f)', rsq1{1}));

        subplot(1,2,2)
        allometric_plot2(x2, y2, [1 p2], g2, 'linear', fh);
        xlabel('inter-area connection ratio'); ylabel('fiber count ratio');
        title(sprintf('linear version (r^2=%5.3f)', rsq2{1}));
        

    elseif ismember('all', figs) || ismember('prop_fibers_vs_prop_aa_cxns', figs)
        allometric_plot2(x1, y1, p1, g1, {'loglog'});
        xlabel('inter-area connection ratio'); ylabel('fiber count ratio');
        title(sprintf('allometric version (r^2=%5.3f)', rsq1{1}));

    elseif ismember('all', figs) || ismember('prop_fibers_vs_prop_aa_cxns_linear', figs)
        allometric_plot2(x2, y2, [1 p2], g2, 'linear');
        xlabel('inter-area connection ratio'); ylabel('fiber count ratio');
        title(sprintf('linear version (r^2=%5.3f)', rsq2{1}));
    end;

    % Now look on a per-area basis, instead of a per- area connection basis
    % fprintf('Regressing [proportion inter-fibers] vs. [proportion inter- area conns]...');
    % [p,g,rsq] = allometric_regression(ncc_fibers./nintra_fibers, 1./(nareas-1), 'log', 1, true);
    % fprintf('r^2=%5.3f\n', rsq{1})
    % if ismember('all', figs) || ismember('prop_fibers_vs_prop_aa_cxns')
    %     allometric_plot2(ncc_fibers./nintra_fibers, 1./(nareas-1), p, g, {'linear','loglog'});
    %     ylabel('1/([# areas/conn]-1)'); xlabel('[# cc cxns]/[# intra- wm cxns]');
    %     title('allometric version');
    % end;
    %
    % [p,g,rsq] = allometric_regression(ncc_fibers./nintra_fibers, 1./(nareas-1), 'linear', 1, true);
    % allometric_plot2(ncc_fibers./nintra_fibers, 1./(nareas-1), [1 p(1)], g, 'linear');
    % ylabel('1/([# areas/conn]-1)'); xlabel('[# cc cxns]/[# intra- wm cxns]');
    % title('linear version');

    % Divide again by the # areas, so that we get an estimate of the
    %   # of fibers per area connection, across the whole brain.
    %fprintf('Regressing [per- area inter-fibers] vs. [per- area intra-fibers]...\n');

    %[p, g, rsq] = allometric_regression(ncc_fibers./1./nareas, nintra_fibers./(nareaconns-1)./nareas, 'log', 1, true);
    %fprintf('ALLOMETRIC r^2=%5.3f\n', rsq{1})

    %if ismember('all', figs) || ismember('pa_fibers_vs_pa_aa_cxns', figs)
    %    allometric_plot2(ncc_fibers./1./nareas, nintra_fibers./(nareaconns-1)./nareas, p, g);
    %    ylabel('per- area (intra-) conn (avg)'); xlabel('per- area (CC) conn (avg)');
    %    title(sprintf('allometric version (r^2=%5.3f)', rsq{1}));
    %end;


    %% 3. Are the average CC and non-CC connections of the same strength?
    % Same quantities, but different algebra
    %
    % NOTE NOTE NOTE NOTE NOTE NOTE NOTE
    %
    % We don't divide by # areas, because it's noisy, and algebraically the
    %   comparison should be the same (true?)
    %
    fprintf('Regressing [per area intra-fibers] vs. [inter-fibers]...\n');

    x1 = nintra_fibers./(nareaconns-1);
    y1 = ncc_fibers./1;
    [p1,g1,rsq1] = allometric_regression(x1, y1, 'log', 1, true);
    fprintf('ALLOMETRIC Callsoal fiber-count factor (vs. intrahemispheric bundles) for %s: %5.3f; r^2=%5.3f\n', collation, p1(1), rsq1{1});

    x2 = nintra_fibers./(nareaconns-1);
    y2 = ncc_fibers./1;
    [p2,g2,rsq2] = allometric_regression(x2, y2, 'linear');
    fprintf('LINEAR Callsoal fiber-count factor (vs. intrahemispheric bundles) for %s: %5.3f; r^2=%5.3f\n', collation, p2(1), rsq2{1});

    % Now combine the two graphs into a single one.
    if ismember('all', figs) || length(intersect(figs, {'intra_vs_cc_scaling', 'intra_vs_cc_scaling_linear'})) == 2
        fh = figure('position', [131         220        1161         564]);

        subplot(1,2,1);
        allometric_plot2(x1, y1, p1, g1, 'loglog', fh);
        ylabel('[# callosal fibers]'); xlabel('[# intra- fibers] / ([# inter-area cxns]-1)');
        title(sprintf('allometric version (r^2=%5.3f)', rsq1{1}));

        subplot(1,2,2);
        allometric_plot2(x2, y2, [1 p2], g2, 'linear', fh);
        ylabel('[# callosal fibers]'); xlabel('[# intra- fibers] / ([# inter-area cxns]-1)');
        title(sprintf('linear version (r^2=%5.3f)', rsq2{1}));

    % Just the non-linear plot
    elseif ismember('all', figs) || ismember('intra_vs_cc_scaling', figs)
        allometric_plot2(x1, y1, p1, g1, {'linear','loglog'});
        ylabel('[# callosal fibers]'); xlabel('[# intra- fibers] / ([# inter-area cxns]-1)');
        title(sprintf('allometric version (r^2=%5.3f)', rsq1{1}));

    % Just the linear plot
    elseif ismember('all', figs) || ismember('intra_vs_cc_scaling_linear', figs)
        allometric_plot2(x2, y2, [1 p2], g2, 'linear');
        ylabel('[# callosal fibers]'); xlabel('[# intra- fibers] / ([# inter-area cxns]-1)');
        title(sprintf('linear version (r^2=%5.3f)', rsq2{1}));
    end;

    %y-1 = ax-1b
    %1 = ayx-1b
    %x^b = ay
    %y = (1/a)x^b
    % Save off data
    for suffix={'', '1', '2'}
        for varname={'p', 'g', 'rsq'}
            clear([varname{1}, suffix{1}]);
        end;
    end;
    save(data_file);
