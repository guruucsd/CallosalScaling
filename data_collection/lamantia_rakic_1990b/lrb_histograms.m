function vars = lrb_histograms(validate_data)
%

    if ~exist('validate_data', 'var'), validate_data = true; end;
    
    lrb_dir = fileparts(which(mfilename));

    
    %% Parse histograms from Lamantia & Rakic, 1990a
    % Figure 3
    if ~exist('lrb_fig3_data','var') || any(~all(sum(lrb_fig3_data,3)))
        lrb_fig3_sectors = {'2' '4' '6' '10'};
        lrb_fig3_age_names = {'E85' 'E128' 'E144'};
        lrb_fig3_ages = str2date(lrb_fig3_age_names, 'macaque');
        lrb_fig3_xbar_vals = 0:(0.2/5):1;
        lrb_fig3_ytick_vals = 0:25:175; 

        lrb_fig3_data = zeros(length(lrb_fig3_ages), length(lrb_fig3_sectors), 26);
        for ai=1:length(lrb_fig3_ages)
            for si=1:length(lrb_fig3_sectors)
                fn = sprintf('lrb_fig3_%s_sector%s.png', lrb_fig3_age_names{ai}, lrb_fig3_sectors{si});
                lrb_fig3_data(ai,si,:) = lrb_process_image(fullfile(lrb_dir, 'img', fn), lrb_fig3_xbar_vals, lrb_fig3_ytick_vals, 0, true);
            end;
        end;
    end;


    % Figure 15
    if ~exist('lrb_fig15_data','var') || any(~all(sum(lrb_fig15_data,3)))
        lrb_fig15_sectors = {'2' '4' '6' '10'};
        lrb_fig15_age_names = {'P0' 'P21' 'P60' 'P90'};
        lrb_fig15_ages = str2date(lrb_fig15_age_names, 'macaque');
        lrb_fig15_xbar_vals = 0:0.024:0.6;
        lrb_fig15_ytick_vals = 0:25:75; 
        lrb_fig15_rotang     = -1.21;

        lrb_fig15_data = zeros(length(lrb_fig15_ages), length(lrb_fig15_sectors), 26);
        for ai=1:length(lrb_fig15_ages)
            for si=1:length(lrb_fig15_sectors)
                fn = sprintf('lrb_fig15_%s_sector%s.png', lrb_fig15_age_names{ai}, lrb_fig15_sectors{si});
                lrb_fig15_data(ai,si,:) = lrb_process_image(fullfile(lrb_dir, 'img', fn), lrb_fig15_xbar_vals, lrb_fig15_ytick_vals, lrb_fig15_rotang, true);
            end;
        end;
    end;

    
    %% Reconstruct outputs
    varnames = who('lrb_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);

    
    %% Validate data
    if validate_data
    end;