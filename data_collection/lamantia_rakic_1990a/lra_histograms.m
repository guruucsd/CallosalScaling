function vars = lra_histograms(validate_data)
%

    if ~exist('validate_data', 'var'), validate_data = true; end;
    
    lra_dir = fileparts(which(mfilename));
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
    lra_fig8_mean_thickness([2 4 6]) = sum(lra_fig7_data_distn.*repmat(lra_fig7_xbar_vals, [3 1]),2) ;
    

    %% Reconstruct outputs
    varnames = who('lra_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);

    
    %% Validate data
    if validate_data
    end;
