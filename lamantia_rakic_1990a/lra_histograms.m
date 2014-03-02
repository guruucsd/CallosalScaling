lra_dir = fileparts(which(mfilename));
lra_hist_datafile = fullfile(lra_dir, 'lra_histograms.mat');


if exist(lra_hist_datafile, 'file')
    load(lra_hist_datafile);
else
    imgdir = fullfile(lra_dir, 'img');
    
    lra_fig7_sectors = {'2' '4' '6'};
    lra_fig7_ytick_vals = 0:25:75; 
    lra_fig7_xbar_vals = 0:.1:2.5;

    addpath(fullfile(lra_dir, '..', 'lamantia_rakic_1990b'));
    lra_fig7_data(1,:) = lrb_process_image(fullfile(imgdir, 'Fig7a.png'), lra_fig7_xbar_vals, lra_fig7_ytick_vals, 0, true);
    lra_fig7_data(2,:) = lrb_process_image(fullfile(imgdir, 'Fig7b.png'), lra_fig7_xbar_vals, lra_fig7_ytick_vals, 0, true);
    lra_fig7_data(3,:) = lrb_process_image(fullfile(imgdir, 'Fig7c.png'), lra_fig7_xbar_vals, lra_fig7_ytick_vals, 0, true);
    
    % normalize
    lra_fig7_data_distn = lra_fig7_data./repmat(sum(lra_fig7_data,2),[1 size(lra_fig7_data,2)]);


    % mean thickness
    lra_fig8_mean_thickness = nan(1,10);
    lra_fig8_mean_thickness(    [2 4 6]) = sum(lra_fig7_data_distn.*repmat(lra_fig7_xbar_vals, [3 1]),2) ;
    
    vars = who('lra_*');
    save(lra_hist_datafile, vars{:});
end;