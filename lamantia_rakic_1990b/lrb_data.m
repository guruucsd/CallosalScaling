function vars = lrb_data(validate_data)
%


    if ~exist('validate_data', 'var'), validate_data = true; end;

    %% Gather static data
    % table 1
    lrb_tab1_age_names    ={'E65' 'E72' 'E85' 'E88' 'E109' 'E120' 'E128' 'E144' 'E156' 'E156' 'E156'};
    lrb_tab1_ages   = str2date(lrb_tab1_age_names, 'macaque');
    lrb_tab1_ccarea =[1.2 1.49 15.2 20.7 20.7 21.3 21.9 20.9 27.6 25.6 23.8]*1E6;
    lrb_tab1_ccdens =[334 454 605 907 561 804 682 713 605 693 819];
    lrb_tab1_ccnic  =[4.01 6.77 87.8 178 115 180 146 156 174 189 200]*1E6;
    lrb_tab1_pctmy  =[0 0 0 0 0 0 0 0 2.36 3.38 0.31];
    %(lrb_tab1_ccnic./lrb_tab1_ccarea)./lrb_tab1_ccdens

    % table 3
    lrb_tab3_age_names ={'P0' 'P0' 'P0' 'P5' 'P8' 'P10' 'P14' 'P21' 'P22' 'P60' 'P60' 'P90' 'P134' 'P222'};
    lrb_tab3_ages   = str2date(lrb_tab3_age_names, 'macaque');
    lrb_tab3_ccarea =[27.6 25.6 23.8 25.8 35.5 34.2 26.2 30.3 26.5 43.5 49.7 41.5 55.5 53.4]*1E6;
    lrb_tab3_ccdens =[605 693 819 494 318 357 376 333 364 192 177 140 102 74];
    lrb_tab3_ccnic  =[174 189 200 131 115 133 113 113 108 94.7 97.6 66.8 61.9 40.0]*1E6;
    lrb_tab3_pctmy  =[3.4 2.4 0.3 5.3 5.9 7.1 3.5 8.6 11.0 29.2 33.2 48.0 61.2 74.6];

    %(lrb_tab3_ccnic./lrb_tab3_ccarea)./lrb_tab3_ccdens


    % combined
    lrb_tab_ages   = [lrb_tab1_ages lrb_tab3_ages(4:end)];
    lrb_tab_ccnic  = [lrb_tab1_ccnic lrb_tab3_ccnic(4:end)];
    lrb_tab_ccdens = [lrb_tab1_ccdens lrb_tab3_ccdens(4:end)];
    lrb_tab_ccarea = [lrb_tab1_ccarea lrb_tab3_ccarea(4:end)];
    lrb_tab_pctmy  = [lrb_tab1_pctmy lrb_tab3_pctmy(4:end)];
    

    % get histogram data
    vars = lrb_histograms(validate_data);
    varnames = fieldnames(vars);
    varvals = struct2cell(vars);
    for vi=1:length(varnames)
        eval(sprintf('%s = varvals{%d};', varnames{vi}, vi));
    end;

    
    %% Reconstruct outputs
    varnames = who('lrb_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);

    
    %% Validate data
    if validate_data
    end;
    