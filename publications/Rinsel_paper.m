function Rinsel_paper(fig_list, out_path, collation)
%

    script_dir  = fileparts(which(mfilename));
    rilling_dir = fullfile(script_dir, '..');
    analysis_dir = fullfile(rilling_dir, 'analysis');

    addpath(genpath(fullfile(rilling_dir, '_lib')));
    addpath(genpath(fullfile(rilling_dir, '_predict')));


    if ~exist('fig_list','var') || isempty(fig_list), fig_list={'all'}; end;
    if ~exist('collation','var') || isempty(collation), collation = 'species'; end;  % species
    if ~iscell(fig_list), fig_list = {fig_list}; end;


    % Load data
    load(fullfile(rilling_dir, 'analysis', 'aboitiz_thesis', 'ab_thesis_data.mat'));
    load(fullfile(rilling_dir, 'analysis', 'berbel_innocenti_1988', 'bi_data.mat'));
    load(fullfile(rilling_dir, 'analysis', 'rilling_insel_1999b', 'rib_data.mat'));
    load(fullfile(rilling_dir, 'analysis', 'wang_etal_2008', 'w_data.mat'));
    load(fullfile(rilling_dir, 'analysis', 'lamantia_rakic_1990s', 'lrs_data.mat'));
    load(fullfile(rilling_dir, 'analysis', 'herculano-houzel_etal_2010', 'hh_2010_data.mat'));
    addpath(genpath(fullfile(rilling_dir, 'analysis', 'rilling_insel_1999s')));
    rib_response(collation, {});  % suppress all plots
    load(sprintf('rib_response-%s.mat', collation)); % loads all wang data

    % Which corresponds to human datapoints?
    switch collation
        case {'family' 'species', 'family-s'}, [~, human_idx] = max(bvols);
        case 'individual', human_idx = length(bvols) - [0:4];
    end;

    human_brain_weight = predict_brwt(mean(bvols(human_idx)));%get_human_brain_weight();

    %
    human_dens_pred = 1000 * predict_cc_density(human_brain_weight, mean(bvols(human_idx))); % 1000 converts units to same scale as aboitiz
    human_dens_ab_raw = 100*3.717*(1-0.35)^(1); %correct for shrinkage
    human_dens_ab   = human_dens_ab_raw * 1.20;  %  correct for 20% missing fibers
    human_dens_abcor= human_dens_ab * 1.2;       % correct for age

    %chimp_idx = strcmp('p. troglodytes', rib_table1_species);
    %chimp_brain_vol = rib_table1_brainvol(chimp_idx);
    %chimp_dens = 1000*predict_cc_density([], chimp_brain_vol);
    %chimp_cca = rib_table1_ccarea(chimp_idx);
    %chimp_ncc = chimp_cca.*chimp_dens;





    for fi = 1:length(fig_list)

        % Literally Recreate figure 1
        %if ismember('all',fig_list) || strcmp(fig_list{fi}, 'ril_fig1')
        %    rib_response('individual', {}); % re-compute, to be sure...
        %    allometric_regression(rib_fig1b_brain_volumes, rib_fig1b_ccas, 'log', 1, true, '3');

        %    subplot(1,2,1);
        %    xlabel('Brain volume (cm^3)'); ylabel('CC area (mm^2)');
        %    guru_updatelegend(gca, 1, 'Rilling & Insel (1999)');
        %    subplot(1,2,2);
        %    xlabel('Brain volume (cm^3)'); ylabel('CC area (mm^2)');
        %    guru_updatelegend(gca, 1, 'Rilling & Insel (1999)');

        %    set(gcf, 'Name', 'ril_fig1');
        %end;

        
        %% Rilling & Insel redo: brain volume vs. interhemispheric connections
        % regression
        if ismember('all', fig_list) || strcmp(fig_list{fi}, 'ri_basic_compare')
            for col = unique({'individual', collation})
                rib_response(col{1}, 'wm_cxns_vs_cc_cxns');  % hard-code individual
                set(gcf, 'name', sprintf('ri_bv_vs_cc_cxns_%s', col{1}));  % used as filename.

                rib_response(col{1}, 'wm_cxns_vs_cc_cxns_withrinsel');  % hard-code individual
                set(gcf, 'name', sprintf('ri_bv_vs_cc_cxns_withrinsel_%s', col{1}));  % used as filename.
            end;
        end;


        % Rilling & Insel: check if fiber and inter-area connections scale together
        if ismember('all', fig_list) || strcmp(fig_list{fi}, 'ri_connection_compare')
            for col = {collation}  %{'individual', 'species', 'family'}
                rib_response(col{1}, {'prop_fibers_vs_prop_aa_cxns', 'prop_fibers_vs_prop_aa_cxns_linear'});
                set(gcf, 'name', sprintf('./ri_intra_vs_cc_scaling_connection_%s', col{1}));
            end;
        end;


        % Rilling & Insel connection strength comparison; species
        if ismember('all', fig_list) || strcmp(fig_list{fi}, 'ri_strength_compare')
            for col = {'species'}%{'individual', 'species', 'family'}
                rib_response(col{1}, {'intra_vs_cc_scaling', 'intra_vs_cc_scaling_linear'});
                set(gcf, 'name', sprintf('ri_intra_vs_cc_scaling_linear_%s', col{1}));
            end;
        end;

        % Rilling & Insel connection strength comparison; familiy
        %if ismember('all', fig_list) || strcmp(fig_list{fi}, 'ri_strength_compare')
        %    addpath(genpath(fullfile(analysis_dir, 'rilling_insel_1999s')));
        %    collation = 'family';
        %    rib_response(collation, 'intra_vs_cc_scaling_linear');
        %    set(gcf, 'name', sprintf('./ri_intra_vs_cc_scaling_linear_%s', collation));
        %end;

        % Regress proportion of cc fibers on brain volume.
        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'nwmfib_vs_cc')
            allometric_regression(bvols, ncc_fibers./nwm_fibers, 'log', 1, false, '2');

            guru_updatelegend(gca, 1, '[Computed]');
            xlabel('Brain volume (cm^3)'); ylabel('[# CC fibers]/[# intra-hem fibers]');

            set(gcf, 'Name', 'nwmfib_vs_cc');
        end;




        %% Proportion of cc fibers vs. brain volume.... on cartesian axis
        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'nwmfib_vs_cch_lin')
            [p,g] = allometric_regression(bvols, ncc_fibers./nintra_fibers, 'log', 1, false, '');
            allometric_plot2(bvols, ncc_fibers./nintra_fibers, p, g, 'linear');

            % Mark aboitiz data (corrected)
            human_ncc_fibers = (human_dens_abcor./human_dens_pred) * ncc_fibers(human_idx);  % mark aboitiz
            human_nintra_fibers = nwm_fibers(human_idx) - human_ncc_fibers;
            dh = plot(mean(bvols(human_idx)), human_ncc_fibers./human_nintra_fibers, 'g*', 'MarkerSize', 10, 'LineWidth',5);

            % Update legend and labels
            [~,~,ph,pt] = legend(gca); legend([ph; dh], [pt {' Human (Aboitiz et. al, 1992)'}], 'Location', 'NorthEast');
            guru_updatelegend(gca, 1, '[Computed]');
            xlabel('Brain volume (cm^3)'); ylabel('[# CC fibers]/[# intra-hem fibers]');
            axis tight;

            set(gcf, 'Name', 'nwmfib_vs_cch_lin');
        end;

        % Proportion of cc fibers vs. brain volume.... on log-log axis
        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'nwmfib_vs_cch_log')
            [p,g] = allometric_regression(bvols, ncc_fibers./nintra_fibers, 'log', 1, false, '');
            allometric_plot2(bvols, ncc_fibers./nintra_fibers, p, g, 'log');

            % Mark aboitiz data (corrected)
            human_ncc_fibers = (human_dens_abcor./human_dens_pred)*ncc_fibers(human_idx);
            human_nintra_fibers = (nwm_fibers(human_idx)-human_ncc_fibers);
            dh = loglog(mean(bvols(human_idx)), human_ncc_fibers./human_nintra_fibers, 'g*', 'MarkerSize', 10, 'LineWidth',5);
            [~,~,ph,pt] = legend(gca); legend([ph; dh], [pt {' Human (corrected)'}], 'Location', 'NorthEast');
            guru_updatelegend(gca, 1, '[Computed]');
            xlabel('Brain volume (cm^3)'); ylabel('[# CC fibers]/[# intra-hem fibers]');

            set(gcf, 'Name', 'nwmfib_vs_cch_log');
        end;



        %% Total cc fibers vs. brain volume on cartesian axis
        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'ncch_lin')
            [p,g] = allometric_regression(bvols, ncc_fibers, 'log', 1, false, '');
            allometric_plot2(bvols, ncc_fibers, p, g, 'linear');

            % Mark Aboitiz data (corrected)
            human_ncc_fibers = (human_dens_abcor./human_dens_pred) * predict_ncc_fibers(human_brain_weight);
            dh = plot(mean(bvols(human_idx)), human_ncc_fibers, 'g*', 'MarkerSize', 10, 'LineWidth',5);

            % Update legend and labels
            [~,~,ph,pt] = legend(gca); legend([ph; dh], [pt {' Human^* (Aboitiz et al., 1992)'}], 'Location', 'SouthEast');
            guru_updatelegend(gca, 1, '[Computed]');
            xlabel('Brain volume (cm^3)'); ylabel('[# CC fibers]');
            axis tight;

            set(gcf, 'Name', 'ncch_lin');
        end;

        % Total cc fibers vs. brain volume on log-log axis
        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'ncch_log')
            [p,g] = allometric_regression(bvols, ncc_fibers, 'log', 1, false, '');
            allometric_plot2(bvols, ncc_fibers, p, g, 'loglog');

            % Add human data point
            human_ncc_fibers = (human_dens_abcor./human_dens_pred) * predict_ncc_fibers(human_brain_weight);
            dh = loglog(mean(bvols(human_idx)), human_ncc_fibers, 'g*', 'MarkerSize', 10, 'LineWidth',5);

            % Update legend and axis labels
            [lh,~,ph,pt] = legend(gca); legend([ph; dh], [pt {' Human^* (Aboitiz et al., 1992)'}], 'Location', 'NorthWest');

            guru_updatelegend(gca, 1, '[Computed]');
            set(legend(gca), 'FontSize', 12);
            xlabel('Brain volume (cm^3)'); ylabel('[# CC fibers]');
            axis tight;

            set(gcf, 'Name', 'ncch_log');
        end;



        %% Total cc fibers vs. brain volume on cartesian axis
        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'nwm_lin')
            [p,g] = allometric_regression(bvols, nwm_fibers, 'log', 1, false, '');
            allometric_plot2(bvols, nwm_fibers, p, g, 'linear');

            % Mark Aboitiz data (corrected)
            human_nwm_fibers = (human_dens_abcor./human_dens_pred) * predict_nfibers(human_brain_weight);
            dh = plot(mean(bvols(human_idx)), human_nwm_fibers, 'g*', 'MarkerSize', 10, 'LineWidth',5);

            % Update legend and labels
            [~,~,ph,pt] = legend(gca); legend([ph; dh], [pt {' Human^* (Aboitiz et al., 1992)'}], 'Location', 'SouthEast');
            guru_updatelegend(gca, 1, '[Computed]');
            xlabel('Brain volume (cm^3)'); ylabel('[# white matter fibers]');
            axis tight;

            set(gcf, 'Name', 'nwmh_lin');
        end;

        % Total cc fibers vs. brain volume on log-log axis
        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'nwm_log')
            [p,g] = allometric_regression(bvols, nwm_fibers, 'log', 1, false, '');
            allometric_plot2(bvols, nwm_fibers, p, g, 'loglog');

            % Add human data point
            human_nwm_fibers = (human_dens_abcor./human_dens_pred) * predict_nfibers(human_brain_weight);
            dh = loglog(mean(bvols(human_idx)), human_nwm_fibers, 'g*', 'MarkerSize', 10, 'LineWidth',5);

            % Update legend and axis labels
            [lh,~,ph,pt] = legend(gca); legend([ph; dh], [pt {' Human^* (Aboitiz et al., 1992)'}], 'Location', 'NorthWest');

            guru_updatelegend(gca, 1, '[Computed]');
            set(legend(gca), 'FontSize', 12);
            xlabel('Brain volume (cm^3)'); ylabel('[# white matter fibers]');
            axis tight;

            set(gcf, 'Name', 'nwmh_log');
        end;


        %%if ismember('all',fig_list) || strcmp(fig_list{fi}, 'nwmfib_vs_cch_log')
        %    [p,g,rsq] = allometric_regression(bvols, ncc_fibers./nintra_fibers, 'log', 1, false, '');
        %    allometric_plot2(bvols, ncc_fibers./nintra_fibers, p, g, 'log');

        %    human_ncc_fibers = (human_dens_ab_raw./human_dens_pred)*ncc_fibers(human_idx);
        %    dh = loglog(mean(bvols(human_idx)), human_ncc_fibers./nintra_fibers(human_idx), 'g*', 'MarkerSize', 10, 'LineWidth',5);
        %    [~,~,ph,pt] = legend(gca); legend([ph; dh], [pt {' Human (Aboitiz et. al, 1992)'}], 'Location', 'NorthEast');
        %    guru_updatelegend(gca, 1, '[Computed]');
        %    xlabel('Brain volume (cm^3)'); ylabel('[# CC fibers]/[# intra-hem fibers]');

        %    set(gcf, 'Name', 'nwmfib_vs_cch_log');
        %end;

        %if ismember('all',fig_list) || strcmp(fig_list{fi}, 'nwmfib_vs_cchc_lin')
        %    [p,g] = allometric_regression(bvols, ncc_fibers./nintra_fibers, 'log', 1, false, '');
        %    allometric_plot2(bvols, ncc_fibers./nintra_fibers, p, g, 'linear');

        %    % Add human data point
        %    human_ncc_fibers = (human_dens_abcor./human_dens_pred)*ncc_fibers(human_idx);
        %    human_nintra_fibers = (nwm_fibers(human_idx)-human_ncc_fibers);
        %    dh = loglog(mean(bvols(human_idx)), human_ncc_fibers./human_nintra_fibers, 'g*', 'MarkerSize', 10, 'LineWidth',5);

        %    % Add chimpanzee data point
        %    ch = loglog(chimp_brain_vol, predict_ncc_fibers(chimp_brain_vol)./predict_nintra_fibers(chimp_brain_vol), 'b*', 'MarkerSize', 10, 'LineWidth',5);

        %    % Update legend and axis labels
        %    [~,~,ph,pt] = legend(gca); legend([ph; dh; ch], [pt {' Human (corrected)', 'chimp'}], 'Location', 'NorthEast');
        %    guru_updatelegend(gca, 1, '[Computed]');
        %    xlabel('Brain volume (cm^3)'); ylabel('[# CC fibers]/[# intra-hem fibers]');

        %    set(gcf, 'Name', 'nwmfib_vs_cchc_lin');
        %end;


        %% Wang plot, showing human data
        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'w_densh')            % Wang plot (w/ age-corrected human)
            [p,g] = allometric_regression(w_fig1e_weights, 1E3*w_fig1e_dens_est, 'log', 1, false, '');  % regress without human

            % Plot, then adjust size and labels
            allometric_plot2([w_fig1e_weights human_brain_weight], [1E3*w_fig1e_dens_est human_dens_abcor], p, g, 'log');  % plot with human
            guru_updatelegend(gca, 1, ' Wang et. al (2008)');  % label the last entry as Wang data
            set(gcf,'Position',[235    40   743   644]);
            xlabel('Brain mass (g)'); ylabel('CC fiber density (fibers/ \mum^2)');
            legend('Location', 'NorthEast');

            % Plot human, then update legend
            acch = plot(human_brain_weight, human_dens_abcor,  'g*', 'MarkerSize', 10, 'LineWidth',5);
            [~,~,ph,pt] = legend(gca); legend([ph; acch], [pt {' Aboitiz et. al, 1992 (corrected)'}], 'Location', 'NorthEast');

            % Add species labels
            for si=1:length(w_fig1c_species)
               if g.y(w_fig1e_weights(si)) > 1E3*w_fig1e_dens_est(si)
                   text(0.9*w_fig1e_weights(si), 0.7*1E3*w_fig1e_dens_est(si), w_fig1c_species{si}, 'FontSize', 14);
               else
                   text(0.9*w_fig1e_weights(si), 1.5*1E3*w_fig1e_dens_est(si), w_fig1c_species{si}, 'FontSize', 14);
               end;
            end;
            text(0.9*human_brain_weight, 1.5*human_dens_abcor, 'human', 'FontSize', 14);

            set(gcf, 'Name', 'w_densh');
        end;

        %% Wang data, regressed without human data
        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'w_dens')            % Wang plot (w/ age-corrected human)
            [p,g] = allometric_regression(w_fig1e_weights, 1E3*w_fig1e_dens_est, 'log', 1, false, '');

            % Plot, then adjust size and labels
            allometric_plot2([w_fig1e_weights], [1E3*w_fig1e_dens_est], p, g, 'log');
            guru_updatelegend(gca, 1, ' Wang et. al (2008)');  % label the last entry as Wang data
            set(gcf,'Position',[235    40   743   644]);
            xlabel('Brain mass (g)'); ylabel('CC fiber density (fibers/ \mum^2)');
            legend('Location', 'NorthEast');

            % Add species labels
            for si=1:length(w_fig1c_species)
               if g.y(w_fig1e_weights(si)) > 1E3*w_fig1e_dens_est(si)
                   text(0.9*w_fig1e_weights(si), 0.7*1E3*w_fig1e_dens_est(si), w_fig1c_species{si}, 'FontSize', 14);
               else
                   text(0.9*w_fig1e_weights(si), 1.5*1E3*w_fig1e_dens_est(si), w_fig1c_species{si}, 'FontSize', 14);
               end;
            end;

            set(gcf, 'Name', 'w_dens');
        end;

        %% Lamantia age vs. density
        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'lms_dens')            % Lamantia & Rakic (1990a): density decreases with age
            figure;
            semilogx(lrs_age, 1E4*lrs_dens, 'o', 'MarkerSize', 4, 'LineWidth',4); hold on;
            semilogx(156*[1 1], get(gca, 'ylim'), 'r--', 'LineWidth', 2); hold on;

            set(gca, 'FontSize', 14);
            set(gca, 'xtick', 10.^[2:5]); axis square;
            xlabel('Age (days since conception)');
            ylabel('axons/ \mu m^2');
            title('Axon density', 'FontSize', 18);

            set(gcf, 'Name', 'lms_dens');
        end;

        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'lms_dens_regression')
            [p1, g1, rsquared] = allometric_regression(lra_cc_age, lra_cc_density, 'log', 1, true);
            allometric_plot2(lra_cc_age, lra_cc_density, p1, g1, {'loglog'});

            legend('Location', 'NorthEast');
            legend('Location', 'NorthEast');

            set(gcf, 'Name', 'lms_dens_regression');
        end;


        %% Aboitiz scaling with age
        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'ab_dens')            % Aboitiz (1990): density decreases with age
            ab_density_correction      = 0.65*1.20;  % No correction for age
            ab_thesis_region_area_norm = ab_thesis_appendix8_data./repmat(sum(ab_thesis_appendix8_data,2),[1 size(ab_thesis_appendix8_data,2)]);
            ab_thesis_total_density    = ab_density_correction * sum(ab_thesis_appendix4_data.*ab_thesis_region_area_norm,2);
            ab_thesis_total_fibers     = ab_density_correction * sum(ab_thesis_appendix4_data.*ab_thesis_appendix8_data*1E2,2)/1E6;
            figure('Position', [680   327   667   631]);
            plot(ab_thesis_appendix3_data(idx8to2,1), ab_thesis_total_density, 'ro', 'MarkerSize', 10, 'LineWidth', 2)
            set(gca, 'fontsize', 14);
            %set(gca, 'ylim', [2200 3600]);%ab_density_correction*[min(ab_thesis_appendix4_data(:)) max(ab_thesis_appendix4_data(:))])
            title(sprintf('%s; corr=%.2f', ...
                          'Whole CC', ...
                          corr(ab_thesis_appendix3_data(idx8to2,1), ab_thesis_total_density)));
            xlabel('age (years)');
            ylabel('fiber density (fibers/cm^2)')
            hold on;
            plot(get(gca, 'xlim'), polyval(polyfit(ab_thesis_appendix3_data(idx8to2,1), ab_thesis_total_density, 1), get(gca, 'xlim')), 'b.-', 'LineWidth', 2);
            set(gcf, 'Name', 'ab_dens');
        end;


        %% Save outputs
        if exist('out_path', 'var') && ~isempty(out_path)
            while ~isempty(findobj('type','figure'))
                if ~get(gcf, 'Name'), continue; end;
                export_fig(gcf, fullfile(out_path, sprintf('%s.png', get(gcf, 'Name'))), '-transparent');
                close(gcf);
            end;
        end;
    end;
