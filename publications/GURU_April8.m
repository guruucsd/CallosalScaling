function GURU_April8(fig_list, saving)

    if ~exist('fig_list','var'), fig_list={'all'}; end;
    if ~exist('saving','var'),   saving  = false; end;
    if ~exist('collation','var'), collation = 'individual'; end;
    if ~iscell(fig_list), fig_list = {fig_list}; end;

    rilling_dir = fullfile(fileparts(which(mfilename)), '..');
    GURU_dir = fullfile(rilling_dir, '..');

    % Add paths
    addpath(genpath(fullfile(rilling_dir, '_lib')))
    addpath(genpath(fullfile(rilling_dir, '_predict')))

    % Load data
    load(fullfile(rilling_dir, 'analysis', 'berbel_innocenti_1988', 'bi_data.mat'));
    load(fullfile(rilling_dir, 'analysis', 'rilling_insel_1999b', 'rib_data.mat'));
    load(fullfile(rilling_dir, 'analysis', 'wang_etal_2008', 'w_data.mat'));
    load(fullfile(rilling_dir, 'analysis', 'lamantia_rakic_1990s', 'lrs_data.mat'));
    load(fullfile(rilling_dir, 'analysis', 'herculano-houzel_etal_2010', 'hh_2010_data.mat'));

    addpath(genpath(fullfile(rilling_dir, 'analysis', 'rilling_insel_1999s')));
    rib_response(collation, {});
    load(sprintf('rib_response-%s.mat', collation));

    %Which corresponds to human datapoints?
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



    %
    for fi=1:numel(fig_list)
        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'demo_log')
            xvals = [0.01:0.01:2];

            figure('Name', 'demo_log', 'position', [83   325   976   357])

            subplot(1,3,1); set(gca, 'FontSize', 16)
            plot(log10(xvals), log10(xvals.^0.5), 'LineWidth', 5);
            hold on; title('Sub-linear: y=x^{0.5}');
            axis square; set(gca, 'xlim', [0 0.3], 'ylim', [0 0.3]);

            subplot(1,3,2); set(gca, 'FontSize', 16)
            plot(log10(xvals), log10(xvals.^1), 'LineWidth', 5);
            hold on; title('Linear: y=x^{1}');
            axis square; set(gca, 'xlim', [0 0.3], 'ylim', [0 0.3]);

            subplot(1,3,3); set(gca, 'FontSize', 16)
            plot(log10(xvals), log10(xvals.^2), 'LineWidth', 5);
            hold on; title('Supra-linear: y=x^{2}');
            axis square; set(gca, 'xlim', [0 0.3], 'ylim', [0 0.3]);
        end;

        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'demo_linear')
            xvals = [0.01:0.01:2];

            figure('Name', 'demo_log', 'position', [83   325   976   357])

            subplot(1,3,1); set(gca, 'FontSize', 16)
            plot(xvals, xvals.^0.5, 'LineWidth', 5);
            hold on; title('Sub-linear: y=x^{0.5}');
            axis square;

            subplot(1,3,2); set(gca, 'FontSize', 16)
            plot(xvals, xvals.^1, 'LineWidth', 5);
            hold on; title('Linear: y=x^{1}');
            axis square;

            subplot(1,3,3); set(gca, 'FontSize', 16)
            plot(xvals, xvals.^1.5, 'LineWidth', 5);
            hold on; title('Supra-linear: y=x^{2}');
            axis square;
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

        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'ril_comp')
            [p,g] = allometric_regression(nwm_fibers, ncc_fibers, 'log', 1, false, '3');
            set(gcf, 'Name', 'ril_comp');
            subplot(1,2,1);
            xlabel('# WM fibers'); ylabel('# CC fibers');
            guru_updatelegend(gca, 1, '[Computed]');
            subplot(1,2,2);
            xlabel('# WM fibers'); ylabel('# CC fibers');
            guru_updatelegend(gca, 1, '[Computed]');
        end;

        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'ril_perarea')
            %% Figure 3: Final data
            naconperarea = nareaconns;% ./ nareas;
            xv = naconperarea-1;
            yv =  nwm_fibers./ncc_fibers-1;
            [p,g] = allometric_regression(xv, yv, 'log', 1, false, '2');
            hold on;
            %loglog(xv(human_idx), (yv(human_idx)+1)./1.44-1, 'g*', 'LineWidth', 5, 'MarkerSize', 15);
            set(gcf, 'Name', 'ril_perarea');
            xlabel('# areas connected'); ylabel('[# non-CC WM fibers]/[# CC fibers]');
            guru_updatelegend(gca, 1, '[Computed data]');
    %            legend({' [Computed]', sprintf(' %4.2fX + {%4.2f}', p_cca),'humans'}, 'Location', 'NorthWest');
    %            axis square; set(gca, 'xlim', 1./10.^[-1.9 -1.1], 'ylim', 1/10.^[-1.2 -0.4]);
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

        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'ril_fig2')           %
            allometric_regression(rib_fig2_gmas, rib_fig2_ccas, 'log', 1, true, '2')
            set(gcf, 'Name', 'ril_fig2');
            set(gcf,'Position',[235    40   743   644]);
            guru_updatelegend(gca, 1, 'Rilling & Insel (1999)');
            xlabel('Grey Matter Area (cm^2)'); ylabel('CC area (mm^2)');
        end;

        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'ril_fig2_lin')           %
            [p,g] = allometric_regression(rib_fig2_gmas, rib_fig2_ccas)  ;
            allometric_plot2(rib_fig2_gmas, rib_fig2_ccas, p, g, 'linear');
            set(gcf, 'Name', 'ril_fig2_lin');
            set(gcf,'Position',[235    40   743   644]);
            guru_updatelegend(gca, 1, 'Rilling & Insel (1999)');
            xlabel('Grey Matter Area (cm^2)'); ylabel('CC area (mm^2)');
        end;


        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'w_dens')            % Wang plot (no human)
            [p,g] = allometric_regression(w_fig1e_weights, 1E3*w_fig1e_dens_est, 'log', 1, false, '2');
            set(gcf, 'Name', 'w_dens');
            legend('Location','NorthEast');
            guru_updatelegend(gca, 1, ' Wang et. al (2008)');
            set(gcf,'Position',[235    40   743   644]);
            xlabel('Brain mass (mm^3)'); ylabel('CC fiber density (fibers/ \mum^2)');
            for si=1:length(w_fig1c_species)
               if g.y(w_fig1e_weights(si))>1E3*w_fig1e_dens_est(si)
                   text(0.9*w_fig1e_weights(si), 0.8*1E3*w_fig1e_dens_est(si), w_fig1c_species{si}, 'FontSize', 14);
               else
                   text(0.9*w_fig1e_weights(si), 1.2*1E3*w_fig1e_dens_est(si), w_fig1c_species{si}, 'FontSize', 14);
               end;
            end;
        end;


        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'w_densh')            % Wang plot (w/ human)
            [p,g] = allometric_regression(w_fig1e_weights, 1E3*w_fig1e_dens_est, 'log', 1, false, '');
            allometric_plot2([w_fig1e_weights human_brain_weight], [1E3*w_fig1e_dens_est human_dens_ab], p, g, 'log')
            set(gcf, 'Name', 'w_densh');
            guru_updatelegend(gca, 1, ' Wang et. al (2008)');
            ah = plot(human_brain_weight, human_dens_ab_raw,'r*', 'MarkerSize',10,'LineWidth',5);
            ach = plot(human_brain_weight, human_dens_ab, 'g*', 'MarkerSize', 10, 'LineWidth',5);
            [~,~,ph,pt] = legend(gca); legend([ph; ah; ach], [pt {' Human (Aboitiz et. al, 1992; reported)' 'Human (Aboitiz et al., 1992; +missing)'}], 'Location', 'NorthEast');
            set(gcf,'Position',[235    40   743   644]);
            xlabel('Brain mass (mm^3)'); ylabel('CC fiber density (fibers/ \mum^2)');

            [p,g] = allometric_regression(rib_fig2_gmas, rib_fig2_ccas);
            human_cca_expected = g.y(mean(rib_fig2_ccas(human_idx)));
            human_nfibers_expected = human_cca_expected*human_dens_ab_raw*1E3;
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

        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'lma_dens')            % Lamantia & Rakic (1990a): density decreases with age
            [p,g] = allometric_regression(lra_cc_age, 1E4*lra_cc_density, 'log', 1, false, '2');
            allometric_plot2(lra_cc_age, 1E4*lra_cc_density, p, g, 'linear');
            set(gcf, 'Name', 'lm_dens');
            set(gcf,'Position',[235    40   743   644]);
            guru_updatelegend(gca, 1, ' Lamantia & Rakic (1990)');
            legend('Location','NorthEast');
            xlabel('Age (years)'); ylabel('CC fiber density (fibers/mm^2)');
        end;


        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'lms_dens')            % Lamantia & Rakic (1990a): density decreases with age
            plot(bi_fig7_dates, bi_fig7_total_fibers./bi_fig7_cca, 'ro');
            xl = get(gca, 'xlim');
            
            figure; set(gcf, 'Position', [ 69         258        1212         405]);
            subplot(1,3,3); set(gca, 'FontSize', 14);
            semilogx(lrs_age, 1E4*lrs_dens, 'o', 'MarkerSize', 4, 'LineWidth',4); hold on;
            semilogx(156*[1 1], get(gca, 'ylim'), 'r--', 'LineWidth', 2); hold on;
            
            set(gca, 'xlim', xl, 'xtick', 10.^[2:5]); axis square;
            xlabel('Age (days since conception)');
            ylabel('axons/ \mu m^2');
            title('Axon density', 'FontSize', 18);

            subplot(1,3,2); set(gca, 'FontSize', 14);
            semilogx(lrs_age, lrs_area/10^6, 'o', 'MarkerSize', 4, 'LineWidth',4); hold on;
            semilogx(156*[1 1], get(gca, 'ylim'), 'r--', 'LineWidth', 2); hold on;
            set(gca, 'xlim', xl, 'xtick', 10.^[2:5]); axis square;
            xlabel('Age (days since conception)');
            ylabel('mm^2');
            title('Cross-sectional area', 'FontSize', 18);

            subplot(1,3,1); set(gca, 'FontSize', 14);
            semilogx(lrs_age, lrs_nic/10^6, 'o', 'MarkerSize', 4, 'LineWidth',4); hold on;
            semilogx(156*[1 1], get(gca, 'ylim'), 'r--', 'LineWidth', 2);  hold on;
            set(gca, 'xlim', xl, 'xtick', 10.^[2:5]); axis square;
            xlabel('Age (days since conception)');
            ylabel('million axons')
            title('# axons', 'FontSize', 18);
            end;


        if ismember('all',fig_list) || strcmp(fig_list{fi}, 'lm_cca')            % ... despite CCA increasing with age
            [p,g] = allometric_regression(lra_cc_age, lra_cc_area/1E6, 'log', 1, false, '');
            allometric_plot2(lra_cc_age, lra_cc_area/1E6, p, g, 'linear');
            set(gcf, 'Name', 'lm_cca');
            set(gcf,'Position',[235    40   743   644]);
            guru_updatelegend(gca, 1, ' Lamantia & Rakic (1990)');
            xlabel('Age (years)'); ylabel('CC area (mm^2)');
        end;

        if saving
            export_fig(sprintf('%s_%s.png', mfilename, fig_list{fi}), '-transparent');
            close(gcf);
        end;
    end;
