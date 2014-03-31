function rib_response(collation, figs)

    if ~exist('collation','var'), collation = 'individual'; end;
    if ~exist('figs','var'), figs = {'all'}; end;
    if ~iscell(figs), figs = {figs}; end;

    %% Get data
    %ris_data_path = strrep(fileparts(which(mfilename)), 'analysis', 'data_collection');
    %addpath(ab_data_path);
    ris_dir = fileparts(which(mfilename));
    data_file = fullfile(ris_dir, sprintf('%s-%s.mat', mfilename, collation));

    %if exist(data_file,'file') && isempty(figs)
    %    return;
    %end;

    % Collate
    [bvols, ccas, gmas] = ris_collate(collation);

    % Now use the functions to compute # cc fibers and # neurons
    bwts = predict_brwt(bvols);
    gmvs = gmas.*predict_gm_thickness(bwts, bvols);
    [nwm_fibers,ncc_fibers,nintra_fibers] = predict_nfibers(bwts, bvols, gmvs, [], [], ccas, 0.33);
    [nareas, nareaconns]  = predict_nareas(bwts, bvols);


    % Brain weight vs. # cc fibers
    %if ismember('all',figs) || ismember('brwt_vs_cc_fibers', figs)
    fprintf('Regressing Brain weight vs. # cc fibers\n');
    [p,g] = allometric_regression(bvols, ncc_fibers, 'log', 1, true);
    if ismember('all', figs) || ismember('bv_vs_cc_cxns', figs)
        allometric_plot2(bvols, ncc_fibers, p, g);
        ylabel('# cc fibers'); xlabel('brain volume (mm^3)');
    end;


    % # wm fibers vs. # cc fibers
    fprintf('Regressing #wm fibers vs. # cc fibers\n');
    [p,g] = allometric_regression(nwm_fibers, ncc_fibers, 'log', 1, true);
    if ismember('all', figs) || ismember('wm_cxns_vs_cc_cxns', figs)
        allometric_plot2(nwm_fibers, ncc_fibers, p, g);
        ylabel('# cc fibers'); xlabel('# wm fibers');
    end;


    %% 2. Contrast connection types: fiber scaling vs area-area scaling
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
    %   suggests there are more fibers in a CC area-area connection than an
    %   INTRA area-area conection.  We will test this later.


    %
    fprintf('Regressing [proportion inter-fibers] vs. [proportion inter- area-area conns]\n');
    [p,g] = allometric_regression(ncc_fibers./nintra_fibers, 1./(nareaconns-1), 'log', 1, true);
    if ismember('all', figs) || ismember('prop_fibers_vs_prop_aa_cxns', figs)
        allometric_plot2(ncc_fibers./nintra_fibers, 1./(nareaconns-1), p, g, {'linear','loglog'});
        ylabel('1/([# area-area conns/area]-1)'); xlabel('[# cc cxns]/[# intra- wm cxns]');
        title('allometric version');
    end;

    [p,g] = allometric_regression(ncc_fibers./nintra_fibers, 1./(nareaconns-1), 'linear');
    if ismember('all', figs) || ismember('prop_fibers_vs_prop_aa_cxns_linear', figs)
        allometric_plot2(ncc_fibers./nintra_fibers, 1./(nareaconns-1), [1 p(1)], g, 'linear');
        ylabel('1/([# area-area conns/area]-1)'); xlabel('[# cc cxns]/[# intra- wm cxns]');
        title('linear version');
    end;

    % Now look on a per-area basis, instead of a per- area-area connection basis
    % fprintf('Regressing [proportion inter-fibers] vs. [proportion inter- area-area conns]\n');
    % [p,g] = allometric_regression(ncc_fibers./nintra_fibers, 1./(nareas-1), 'log', 1, true);
    % if ismember('all', figs) || ismember('prop_fibers_vs_prop_aa_cxns')
    %     allometric_plot2(ncc_fibers./nintra_fibers, 1./(nareas-1), p, g, {'linear','loglog'});
    %     ylabel('1/([# areas/conn]-1)'); xlabel('[# cc cxns]/[# intra- wm cxns]');
    %     title('allometric version');
    % end;
    %
    % [p,g] = allometric_regression(ncc_fibers./nintra_fibers, 1./(nareas-1), 'linear', 1, true);
    % allometric_plot2(ncc_fibers./nintra_fibers, 1./(nareas-1), [1 p(1)], g, 'linear');
    % ylabel('1/([# areas/conn]-1)'); xlabel('[# cc cxns]/[# intra- wm cxns]');
    % title('linear version');

    % Divide again by the # areas, so that we get an estimate of the
    %   # of fibers per area-area connection, across the whole brain.
    fprintf('Regressing [per- area-area inter-fibers] vs. [per- area-area intra-fibers]\n');
    [p,g] = allometric_regression(ncc_fibers./1./nareas, nintra_fibers./(nareaconns-1)./nareas, 'log', 1, true);
    if ismember('all', figs) || ismember('pa_fibers_vs_pa_aa_cxns', figs)
        allometric_plot2(ncc_fibers./1./nareas, nintra_fibers./(nareaconns-1)./nareas, p, g);
        ylabel('per- area-area (intra-) conn (avg)'); xlabel('per- area-area (CC) conn (avg)');
        title('allometric version');
    end;


    %% 3. Are the average CC and non-CC connections of the same strength?
    % Same quantities, but different algebra
    fprintf('Regressing [per area-area intra-fibers] vs. [inter-fibers]\n');
    [p,g] = allometric_regression(nintra_fibers./(nareaconns-1), ncc_fibers./1, 'log', 1, true);
    if ismember('all', figs) || ismember('intra_vs_cc_scaling', figs)
        allometric_plot2(nintra_fibers./(nareaconns-1), ncc_fibers./1, p, g, {'linear','loglog'});
        ylabel('[# cc conns]'); xlabel('[#intra cxns] / ([#narea-area cxns]-1)');
    end;

    [p,g] = allometric_regression(nintra_fibers./(nareaconns-1), ncc_fibers./1, 'linear');
    if ismember('all', figs) || ismember('intra_vs_cc_scaling_linear', figs)
        allometric_plot2(nintra_fibers./(nareaconns-1), ncc_fibers./1, [1 p(1)], g, 'linear');
        ylabel('[# cc conns]'); xlabel('[#intra cxns] / ([#narea-area cxns]-1)');
        title('linear version');
    end;

    % Save off data
    clear('p','g')
    save(data_file);
