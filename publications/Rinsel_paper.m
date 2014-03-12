function Rinsel_paper(fig_list, saving)
%

    script_dir  = fileparts(which(mfilename));
    rilling_dir = fullfile(script_dir, '..');
    analysis_dir = fullfile(rilling_dir, 'analysis');
    
    addpath(genpath(fullfile(rilling_dir, '_lib')));
    addpath(genpath(fullfile(rilling_dir, '_predict')));
    
    
    if ~exist('fig_list','var'), fig_list={'all'}; end;
    if ~exist('saving','var'),   saving  = false; end;
    if ~exist('collation','var'), collation = 'individual'; end;
    if ~iscell(fig_list), fig_list = {fig_list}; end;


    % Load data
    load(fullfile(rilling_dir, 'analysis', 'berbel_innocenti_1988', 'bi_data.mat'));
    load(fullfile(rilling_dir, 'analysis', 'rilling_insel_1999b', 'rib_data.mat'));
    load(fullfile(rilling_dir, 'analysis', 'wang_etal_2008', 'w_data.mat'));
    load(fullfile(rilling_dir, 'analysis', 'lamantia_rakic_1990s', 'lrs_data.mat'));
    load(fullfile(rilling_dir, 'analysis', 'herculano-houzel_etal_2010', 'hh_2010_data.mat'));
    addpath(genpath(fullfile(rilling_dir, 'analysis', 'rilling_insel_1999s')));
    rib_response(collation, {});
    load(sprintf('rib_response-%s.mat', collation));

    % Which corresponds to human datapoints?
    switch collation
        case {'family' 'species'}, human_idx = length(bvols);
        case 'individual', human_idx = length(bvols) - [0:4];
    end;

    human_brain_weight = 1300;
    human_brain_volume = mean(bvols(human_idx));

    %
    human_dens_pred = 1000*predict_cc_density(human_brain_weight)%[], human_brain_volume);
    human_dens_ab_raw = 100*3.7*(1-0.35)^(1); %correct for shrinkage
    human_dens_ab   = human_dens_ab_raw*1.20;  %  correct for 20% missing fibers
    human_dens_abcor= human_dens_ab*1.2       % correct for age

    chimp_idx = strcmp('p. troglodytes', rib_table1_species);
    chimp_brain_vol = rib_table1_brainvol(chimp_idx);
    chimp_dens = 1000*predict_cc_density([], chimp_brain_vol);
    chimp_cca = rib_table1_ccarea(chimp_idx);
    chimp_ncc = chimp_cca.*chimp_dens;


    
    
    
    for fi = 1:length(fig_list)
        % Rilling & Insel brain volume vs. inter- connections regression
        if ismember('all', fig_list) || strcmp(fig_list{fi}, 'ri_basic_compare')
            addpath(genpath(fullfile(analysis_dir, 'rilling_insel_1999s')));
            rib_response('individual', 'wm_cxns_vs_cc_cxns');
            if saving, export_fig(gcf, './ri_bv_vs_cc_cxns.png', '-transparent'); end;
        end;

        % Rilling & Insel connectivity scaling comparison
        if ismember('all', fig_list) || strcmp(fig_list{fi}, 'ri_scaling_compare')
            addpath(genpath(fullfile(analysis_dir, 'rilling_insel_1999s')));
            collation = 'species';
            rib_response(collation, 'prop_fibers_vs_prop_aa_cxns');
            if saving, export_fig(gcf, sprintf('./ri_prop_fibers_vs_prop_aa_cxns_%s.png',collation), '-transparent'); end;
        end;

        % Rilling & Insel connection strength comparison
        if ismember('all', fig_list) || strcmp(fig_list{fi}, 'ri_strength_compare')
            addpath(genpath(fullfile(analysis_dir, 'rilling_insel_1999s')));
            collation = 'species';
            rib_response(collation, 'intra_vs_cc_scaling_linear');
            if saving, export_fig(gcf, sprintf('./ri_intra_vs_cc_scaling_linear_%s.png',collation), '-transparent'); end;
        end; 
        

        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'nwmfib_vs_cc')
            [p,g] = allometric_regression(bvols, ncc_fibers./nwm_fibers, 'log', 1, false, '2');
            set(gcf, 'Name', 'nwmfib_vs_cc');
            guru_updatelegend(gca, 1, '[Computed]');
            xlabel('Brain volume (mm^3)'); ylabel('[# CC fibers]/[# intra-hem fibers]');
        end;

        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'nwmfib_vs_cch_lin')
            [p,g] = allometric_regression(bvols, ncc_fibers./nintra_fibers, 'log', 1, false, '');
            allometric_plot2(bvols, ncc_fibers./nintra_fibers, p, g, 'linear');
            set(gcf, 'Name', 'nwmfib_vs_cch_lin');
            human_ncc_fibers = (human_dens_ab_raw./human_dens_pred)*ncc_fibers(human_idx);
            dh = plot(bvols(human_idx), human_ncc_fibers./(nwm_fibers(human_idx)-human_ncc_fibers), 'g*', 'MarkerSize', 10, 'LineWidth',5);
            [~,~,ph,pt] = legend(gca); legend([ph; dh], [pt {' Human (Aboitiz et. al, 1992)'}], 'Location', 'NorthEast');
            guru_updatelegend(gca, 1, '[Computed]');
            xlabel('Brain volume (mm^3)'); ylabel('[# CC fibers]/[# intra-hem fibers]');
        end;

        % Showing # cc fibers
        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'ncch_lin')
            [p,g] = allometric_regression(bvols, ncc_fibers, 'log', 1, false, '');
            allometric_plot2(bvols, ncc_fibers, p, g, 'linear');
            set(gcf, 'Name', 'nwmfib_vs_cch_lin');
            human_ncc_fibers = (human_dens_ab_raw./human_dens_pred)*ncc_fibers(human_idx);
            dh = plot(bvols(human_idx), human_ncc_fibers, 'g*', 'MarkerSize', 10, 'LineWidth',5);
            [~,~,ph,pt] = legend(gca); legend([ph; dh], [pt {' Human (Aboitiz et. al, 1992)'}], 'Location', 'SouthEast');
            guru_updatelegend(gca, 1, '[Computed]');
            xlabel('Brain volume (mm^3)'); ylabel('[# CC fibers]');
            axis tight;
        end;

        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'nwmfib_vs_cch_log')
            [p,g] = allometric_regression(bvols, ncc_fibers./nintra_fibers, 'log', 1, false, '');
            allometric_plot2(bvols, ncc_fibers./nintra_fibers, p, g, 'log');
            set(gcf, 'Name', 'nwmfib_vs_cch_log');
            human_ncc_fibers = (human_dens_ab_raw./human_dens_pred)*ncc_fibers(human_idx);
            dh = loglog(bvols(human_idx), human_ncc_fibers./nintra_fibers(human_idx), 'g*', 'MarkerSize', 10, 'LineWidth',5);
            [~,~,ph,pt] = legend(gca); legend([ph; dh], [pt {' Human (Aboitiz et. al, 1992)'}], 'Location', 'NorthEast');
            guru_updatelegend(gca, 1, '[Computed]');
            xlabel('Brain volume (mm^3)'); ylabel('[# CC fibers]/[# intra-hem fibers]');
        end;

        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'nwmfib_vs_cchc_lin')
            [p,g] = allometric_regression(bvols, ncc_fibers./nintra_fibers, 'log', 1, false, '');
            allometric_plot2(bvols, ncc_fibers./nintra_fibers, p, g, 'linear');
            set(gcf, 'Name', 'nwmfib_vs_cchc_lin');
            human_ncc_fibers = (human_dens_abcor./human_dens_pred)*ncc_fibers(human_idx);
            dh = loglog(bvols(human_idx), human_ncc_fibers./nintra_fibers(human_idx), 'g*', 'MarkerSize', 10, 'LineWidth',5);
            ch = loglog(chimp_brain_vol, predict_ncc_fibers(chimp_brain_vol)./predict_nintra_fibers(chimp_brain_vol), 'b*', 'MarkerSize', 10, 'LineWidth',5);

            [~,~,ph,pt] = legend(gca); legend([ph; dh], [pt {' Human (corrected)','chimp'}], 'Location', 'NorthEast');
            guru_updatelegend(gca, 1, '[Computed]');
            xlabel('Brain volume (mm^3)'); ylabel('[# CC fibers]/[# intra-hem fibers]');
        end;

        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'ncchc_lin')
            [p,g] = allometric_regression(bvols, ncc_fibers, 'log', 1, false, '');
            allometric_plot2(bvols, ncc_fibers, p, g, 'linear');
            set(gcf, 'Name', 'ncchc_lin');
            human_ncc_fibers = (human_dens_abcor./human_dens_pred)*ncc_fibers(human_idx);
            dh = loglog(bvols(human_idx), human_ncc_fibers, 'g*', 'MarkerSize', 10, 'LineWidth',5);
            [~,~,ph,pt] = legend(gca); legend([ph; dh], [pt {' Human (corrected)'}], 'Location', 'SouthEast');
            guru_updatelegend(gca, 1, '[Computed]');
            xlabel('Brain volume (mm^3)'); ylabel('[# CC fibers]');
            axis tight;
        end;

        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'nwmfib_vs_cchc_log')
            [p,g] = allometric_regression(bvols, ncc_fibers./nintra_fibers, 'log', 1, false, '');
            allometric_plot2(bvols, ncc_fibers./nintra_fibers, p, g, 'log');
            set(gcf, 'Name', 'nwmfib_vs_cchc_log');
            human_ncc_fibers = (human_dens_abcor./human_dens_pred)*ncc_fibers(human_idx);
            dh = loglog(bvols(human_idx), human_ncc_fibers./(nwm_fibers(human_idx)-human_ncc_fibers), 'g*', 'MarkerSize', 10, 'LineWidth',5);
            [~,~,ph,pt] = legend(gca); legend([ph; dh], [pt {' Human (corrected)'}], 'Location', 'NorthEast');
            guru_updatelegend(gca, 1, '[Computed]');
            xlabel('Brain volume (mm^3)'); ylabel('[# CC fibers]/[# intra-hem fibers]');
        end;


        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'ril_fig1')
            allometric_regression(bvols, rib_fig1b_ccas, 'log', 1, true, '3');
            set(gcf, 'Name', 'ril_fig1');
            subplot(1,2,1);
            xlabel('Brain volume (mm^3)'); ylabel('CC area (mm^2)');
            guru_updatelegend(gca, 1, 'Rilling & Insel (1999)');
            subplot(1,2,2);
            xlabel('Brain volume (mm^3)'); ylabel('CC area (mm^2)');
            guru_updatelegend(gca, 1, 'Rilling & Insel (1999)');
        end;

        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'w_denshc')            % Wang plot (w/ age-corrected human)
            [p,g] = allometric_regression(w_fig1e_weights, 1E3*w_fig1e_dens_est, 'log', 1, false, '');
            allometric_plot2([w_fig1e_weights human_brain_weight], [1E3*w_fig1e_dens_est human_dens_abcor], p, g, 'log')
            set(gcf, 'Name', 'w_denshc');
            guru_updatelegend(gca, 1, ' Wang et. al (2008)');
            %ah   = plot(human_brain_weight, human_dens_ab_raw, 'r*', 'MarkerSize', 10, 'LineWidth',5);
            acch = plot(human_brain_weight, human_dens_abcor,  'g*', 'MarkerSize', 10, 'LineWidth',5);
            [~,~,ph,pt] = legend(gca); legend([ph; acch], [pt {' Aboitiz et. al, 1992 (corrected)'}], 'Location', 'NorthEast');
            set(gcf,'Position',[235    40   743   644]);
            xlabel('Brain mass (mm^3)'); ylabel('CC fiber density (fibers/ \mum^2)');
            for si=1:length(w_fig1c_species)
               if g.y(w_fig1e_weights(si))>1E3*w_fig1e_dens_est(si)
                   text(0.9*w_fig1e_weights(si), 0.7*1E3*w_fig1e_dens_est(si), w_fig1c_species{si}, 'FontSize', 14);
               else
                   text(0.9*w_fig1e_weights(si), 1.5*1E3*w_fig1e_dens_est(si), w_fig1c_species{si}, 'FontSize', 14);
               end;
            end;
            text(0.9*human_brain_weight, 1.5*human_dens_abcor, 'human', 'FontSize', 14);
        end;

        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'lms_dens')            % Lamantia & Rakic (1990a): density decreases with age
            figure;
            semilogx(lrs_age, 1E4*lrs_dens, 'o', 'MarkerSize', 4, 'LineWidth',4); hold on;
            semilogx(156*[1 1], get(gca, 'ylim'), 'r--', 'LineWidth', 2); hold on;
            
            set(gca, 'FontSize', 14);
            set(gca, 'xlim', xl, 'xtick', 10.^[2:5]); axis square;
            xlabel('Age (days since conception)');
            ylabel('axons/ \mu m^2');
            title('Axon density', 'FontSize', 18);

        end;

    end;
