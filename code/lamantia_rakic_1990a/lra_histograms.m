function vars = lra_histograms(validate_data)
%
% Processes Figure 7 of Lamantia & Rakic (1990b)

    if ~exist('validate_data', 'var'), validate_data = true; end;
    if ~exist('visualize_data', 'var'), visualize_data = false; end;

    LRA_dirpath = fileparts(which(mfilename));
    LRA_dirname = guru_fileparts(LRA_dirpath, 'name');
    LRA_img_dirpath = fullfile(LRA_dirpath, '..', '..', 'img', LRA_dirname);
    LRB_dirpath = fullfile(LRA_dirpath, '..', strrep(LRA_dirname, '1990a', '1990b'));

    lra_fig7_sectors = {'2' '4' '6'};
    lra_fig7_ytick_vals = 0:25:75;
    lra_fig7_xbar_vals = 0:.1:2.5;

    addpath(LRB_dirpath);  % share function to process images
    lra_fig7_data(1,:) = lrb_process_image(fullfile(LRA_img_dirpath, 'Fig7a.png'), lra_fig7_xbar_vals, lra_fig7_ytick_vals, 0, true);
    lra_fig7_data(2,:) = lrb_process_image(fullfile(LRA_img_dirpath, 'Fig7b.png'), lra_fig7_xbar_vals, lra_fig7_ytick_vals, 0, true);
    lra_fig7_data(3,:) = lrb_process_image(fullfile(LRA_img_dirpath, 'Fig7c.png'), lra_fig7_xbar_vals, lra_fig7_ytick_vals, 0, true);

    % normalize
    lra_fig7_data_distn = lra_fig7_data./repmat(sum(lra_fig7_data,2),[1 size(lra_fig7_data,2)]);


    % mean thickness
    lra_fig8_mean_thickness = nan(1,10);
    lra_fig8_mean_thickness([2 4 6]) = sum(lra_fig7_data_distn.*repmat(lra_fig7_xbar_vals, [3 1]),2) ;


    %% Validate data
    if validate_data
        %keyboard
    end;


    %% Visualize data
    if visualize_data
    end;


    %% Construct outputs
    varnames = who('lra_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);


