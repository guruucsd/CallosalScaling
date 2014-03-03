function vars = lra_data(validate_data)
%

    if ~exist('validate_data', 'var'), validate_data = true; end;

    %% Gather data
    lra_cc_age = [17 4.5 2 2 5.0 3.0 3.0 5.0]; % in years
    lra_cc_area = [9.50 7.25 6.86 5.50 9.10 6.90 7.69 8.33]*1E7;
    lra_cc_density = [38.04 68.10 73.36 98.85 70.80 90.78 87.94 85.11];
    lra_cc_naxons = [3.69 4.90 4.96 5.47 6.04 6.13 6.61 7.03]*1E7;
    
    lra_cc_sector_density = [121.6 116.8 124.9 76.2 76.1 56.7 52.4 57.5 68.6 56.1];
    lra_cc_sector_pctmyelinated = [64.1 72.1 68.6 90.6 89.1 93.1 94.1 94.5 93.8 96.5];
    lra_cc_sector_area_est = [2735 13130 9928 8947 6988 7099 8350 8778 15384 17279];
    lra_cc_sector_rel_areas = lra_cc_sector_area_est./sum(lra_cc_sector_area_est);
    
    % tells us how reliable these area estimates are!!!!!
    % Take the reported densities over all individuals, and average them.
    % Then take the reported desnities for each sector, and do a weighted
    % sum based on the sector areas that we estimated.
    %
    % What's the difference?  Looks to be about 0.44%.  Pretty damn good :)
    sector_area_pct_diff = abs(mean(lra_cc_density) - sum(lra_cc_sector_density.* lra_cc_sector_rel_areas))/(mean(lra_cc_density)+sum(lra_cc_sector_density.* lra_cc_sector_rel_areas))/2;
    
    lra_cc_pctmyelinated_est = sum(lra_cc_sector_rel_areas.*lra_cc_sector_pctmyelinated);
    
    
    % anterior commissure
    lra_ac_age = [1.5 2.0 3.0 5.0 3.0 5.0 4.5 2.0]; % in years
    lra_ac_area = [2.50 3.31 3.14 3.21 3.41 4.44 4.30 3.69]*1E6 ;
    lra_ac_density = [108.24 83.11 97.29 110.48 106.79 88.45 92.81 127.55];
    lra_ac_naxons = [2.71 2.75 3.05 3.55 3.64 3.93 3.99 4.71]*1E6;
    lra_ac_pctmyelinated = [87.9 94.2 88.1 93.8 93.4 96.5 94.0 81.0];
    
    
    
    % hippocampal commissure
    lra_hc_age = [2.0 4.5 3.0 3.0 5.0 5.0]; % in years
    lra_hc_area = [2.72 3.84 5.05 2.61 2.20 5.80]*1E5;
    lra_hc_density = [72.99 52.98 49.62 111.71 60.81 59.44];
    lra_hc_naxons = [1.99 2.03 2.51 2.92 1.31 3.45]*1E5;
    lra_hc_pctmyelinated = [88.4 91.3 91.8 88.4 93.0 85.4];
    
    
    % bc
    lra_btc_age = [2.5 5.0 3.0 2.5 3.0]; % in years
    lra_btc_area = [25 43 59 57 77]*1E3;
    lra_btc_density = [481.35 338.90 341.59 382.30 362.04];
    lra_btc_naxons = [1.20 1.46 2.02 2.18 2.79]*1E5;
    lra_btc_pctmyelinated = [18.3 25.5 22.0 15.8 13.9];
    
    % Gather histogram data
    vars = lra_histograms(validate_data);
    varnames = fieldnames(vars);
    varvals = struct2cell(vars);
    for vi=1:length(varnames)
        eval(sprintf('%s = varvals{%d};', varnames{vi}, vi));
    end;

    
    %% Reconstruct outputs
    varnames = who('lra_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);

    
    %% Validate data
    if validate_data
    end;
    