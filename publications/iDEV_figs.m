function iDEV_figs(fig_list, saving)
%

    script_dir  = fileparts(which(mfilename));
    rilling_dir = fullfile(script_dir, '..');
    GURU_dir = fullfile(rilling_dir, '..');
    analysis_dir = fullfile(rilling_dir, 'analysis');
    
    addpath(genpath(fullfile(rilling_dir, '_lib')));
    addpath(genpath(fullfile(rilling_dir, '_predict')));
    
    
    if ~exist('fig_list','var'), fig_list={'all'}; end;
    if ~exist('saving','var'),   saving  = false; end;
    if ~iscell(fig_list), fig_list = {fig_list}; end;

    for fi = 1:length(fig_list)

        % Rilling & Insel brain volume vs. inter- connections regression
        if ismember('all', fig_list) || strcmp(fig_list{fi}, 'ri_basic_compare')
            addpath(genpath(fullfile(analysis_dir, 'rilling_insel_1999s')));
            rib_response('individual', 'wm_cxns_vs_cc_cxns');
            if saving, export_fig(gcf, './ri_bv_vs_cc_cxns.png', '-transparent'); end;

            load(fullfile(analysis_dir, 'rilling_insel_1999b', 'rib_data.mat'));
            [p,g] = allometric_regression(rib_fig2_gmas, rib_fig2_ccas, 'log', 1, true);
            allometric_plot2(rib_fig2_gmas, rib_fig2_ccas, p, g);
            if saving, export_fig(gcf, './rilling_orig.png', '-transparent'); end;
        end;

        % Rilling & Insel connectivity scaling comparison
        if ismember('all', fig_list) || strcmp(fig_list{fi}, 'ri_scaling_compare')
            addpath(genpath(fullfile(analysis_dir, 'rilling_insel_1999s')));
            for collation = {'species' 'family'}
                rib_response(collation{1}, 'prop_fibers_vs_prop_aa_cxns');
                if saving, export_fig(gcf, sprintf('./ri_prop_fibers_vs_prop_aa_cxns_%s.png',collation{1}), '-transparent'); end;

                rib_response(collation{1}, 'prop_fibers_vs_prop_aa_cxns_linear');
                if saving, export_fig(gcf, sprintf('./ri_prop_fibers_vs_prop_aa_cxns_linear_%s.png',collation{1}), '-transparent'); end;
            end;
        end;

        % Rilling & Insel connection strength comparison
        if ismember('all', fig_list) || strcmp(fig_list{fi}, 'ri_strength_compare')
            addpath(genpath(fullfile(analysis_dir, 'rilling_insel_1999s')));
            for collation = {'species' 'family'}
                rib_response(collation{1}, 'intra_vs_cc_scaling_linear');
                if saving, export_fig(gcf, sprintf('./ri_intra_vs_cc_scaling_linear_%s.png',collation{1}), '-transparent'); end;
            end;
        end; 

        % Predict ADD
        if ismember('all', fig_list) || strcmp(fig_list{fi}, 'predict_add')
            clear global % force production of all predict_ figures
            addpath(genpath(fullfile(analysis_dir, 'predict')));
            predict_human('gamma', 'predict_ab');

            % Predicted aboitiz data
            set(gcf, 'Position', [-454         218        1735         466]);
            if saving, export_fig(gcf, './predict_ab_add.png', '-transparent'); close(gcf); end;

            % Predicted pct myelination
            if saving, export_fig(gcf, './predict_pct_mye.png', '-transparent'); close(gcf); end;

            % Regressed fit parameters
            if saving, export_fig(gcf, './predict_regress_add.png', '-transparent'); close(gcf); end;

            % Fit myelinated
            if saving, export_fig(gcf, './predict_fit_add_mye.png', '-transparent'); close(gcf); end;

            % Fit unmyelinated
            if saving, export_fig(gcf, './predict_fit_add_unmye.png', '-transparent'); close(gcf); end;
        end;

    end;
