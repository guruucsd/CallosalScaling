close all;
fig_list = {'w_densh', 'lms_dens_regression', 'wm_cxns_vs_cc_cxns_withrinsel', 'ri_connection_compare_allometric'};
out_path = '';
collation = 'species';

for fi=1:length(fig_list)
    Rinsel_paper(fig_list(fi), out_path, collation);

    if strcmp(fig_list{fi}, 'w_densh')  % 1
        set(gca, 'xtick', 10.^[0, 1, 2, 3]);

    elseif strcmp(fig_list{fi}, 'lms_dens_regression')  % 2
        subplot(1, 2, 1);
        text(8, 32, 'Age (years)', 'FontSize', 18);
        ylabel( 'Axon Density');

        subplot(1, 2, 2);
        xticks = 10.^[0.25, 0.5, 0.75, 1, 1.25];
        set(gca, 'xtick', xticks);
        set(gca, 'xticklabel', []);
        text(10^.20, 15.25, '10^{0.25}', 'FontSize', 18);
        text(10^.45, 15.25, '10^{0.5}', 'FontSize', 18);
        text(10^.70, 15.25, '10^{0.75}', 'FontSize', 18);
        text(10^.95, 15.25, '10^{1}', 'FontSize', 18);
        text(10^1.2, 15.25, '10^{1.25}', 'FontSize', 18);

        yticks = 10.^[1.25, 1.5, 1.75, 2, 2.25];
        set(gca, 'ytick', yticks);
        set(gca, 'yticklabel', []);
        text(1.02, 10^1.25, '10^{1.25}', 'FontSize', 18);
        text(1.02, 10^1.50, '10^{1.50}', 'FontSize', 18);
        text(1.02, 10^1.75, '10^{1.75}', 'FontSize', 18);
        text(1.02, 10^2.00, '10^{2.00}', 'FontSize', 18);
        text(1.02, 10^2.25, '10^{2.25}', 'FontSize', 18);
        text(4, 13, 'Age (log(years))', 'FontSize', 18)

    elseif strcmp(fig_list{fi}, 'wm_cxns_vs_cc_cxns_withrinsel')  % 3
        subplot(1, 2, 1);

        xlabel('');
        set(gca, 'xtick', 10.^[ 8.5,8.75, 9, 9.25, 9.5]);
        set(gca, 'xticklabel', []);
        text(10^8.40, 0.17*10^8, '10^{8.5}', 'FontSize', 18);
        text(10^8.65, 0.17*10^8, '10^{8.75}', 'FontSize', 18);
        text(10^8.90, 0.17*10^8, '10^{9}', 'FontSize', 18);
        text(10^9.15, 0.17*10^8, '10^{9.25}', 'FontSize', 18);
        text(10^9.40, 0.17*10^8, '10^{9.5}', 'FontSize', 18);
        text(10^8.6, 0.145* 10^8, 'total white matter fibers', 'FontSize', 18);

        ylabel('');
        set(gca, 'ytick', 10.^[7.5, 7.75, 8, 8.25, 8.5]);
        set(gca, 'yticklabel', []);
        text(10^8.1, 10^7.50, '10^{7.50}', 'FontSize', 18);
        text(10^8.1, 10^7.75, '10^{7.75}', 'FontSize', 18);
        text(10^8.1, 10^8.00, '10^{8.00}', 'FontSize', 18);
        text(10^8.1, 10^8.25, '10^{8.25}', 'FontSize', 18);
        text(10^8.1, 10^8.50, '10^{8.50}', 'FontSize', 18);
        h = text(10^8.025, 10^7.70, 'total white matter fibers', 'FontSize', 18);
        set(h, 'rot', 90);

        lh = legend();
        labels = get(lh, 'String');
        labels{3} = ' Rinsel Regression';
        set(lh, 'String',  labels);

    elseif strcmp(fig_list{fi}, 'ri_connection_compare_allometric')  % 4
        set(gca, 'xtick', 10.^[-1.75, -1.5, -1.25])
        set(gca, 'xticklabel', [' ', ' ', ' ']);
        text(10^-1.8, 0.043, '10^{-1.75}', 'FontSize', 18);
        text(10^-1.55, 0.043, '10^{-1.5}', 'FontSize', 18);
        text(10^-1.3, 0.043, '10^{-1.25}', 'FontSize', 18);

        set(gca, 'ytick', 10.^[-1.25, -1, -0.75])
        set(gca, 'yticklabel', ['    ', '    ', '    ']);
        text(10^-2.025, 10^-1.25, '10^{-1.25}', 'FontSize', 18);
        text(10^-2.025, 10^-1.00, '10^{-1.00}', 'FontSize', 18);
        text(10^-2.025, 10^-0.75, '10^{-0.75}', 'FontSize', 18);
    end;
end;
