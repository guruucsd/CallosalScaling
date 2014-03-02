ab_dir = fileparts(which(mfilename));
ab_hist_datafile = fullfile(ab_dir, 'ab_histograms.mat');

if exist(ab_hist_datafile,'var')
    load(ab_hist_datafile);
    
else
    
    % Figure 4
    ab_fig4_areas = {'genu' 'ant_midbody' 'midbody' 'post_midbody' 'splenium'};
    ab_fig4_xtick_vals = 1:9;
    ab_fig4_xbin_vals  = 0.2:0.2:9; 
    ab_fig4_ytick_vals = 0:5:30; 
    ab_fig4_n_yticks = 1+[6 5 5 4 4]; % not all plots have same # yticks
    ab_fig4_rots = [0.25 0 0 0.25 0]; % some plots are rotated :(

    ab_fig4_data = zeros(length(ab_fig4_areas), length(ab_fig4_xbin_vals));
    for ai=1:length(ab_fig4_areas)
        fn = sprintf('aboitiz_etal_1992_fig4_%s.png', ab_fig4_areas{ai});
        ab_fig4_data(ai,:) = process_ab_histogram(fullfile(ab_dir,'img',fn), ab_fig4_xtick_vals, ab_fig4_ytick_vals(1:ab_fig4_n_yticks(ai)), ab_fig4_rots(ai));
    end;

    vars = who('ab_*');
    save(ab_hist_datafile, vars{:});
    %'ab_histograms.mat', 'ab_fig4_areas', 'ab_fig4_xbin_vals','ab_fig4_data');
end;
