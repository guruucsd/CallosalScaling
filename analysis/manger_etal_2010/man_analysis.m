function w_analysis(vars)
%

    %% load variables into the current workspace
    varnames = fieldnames(vars);
    varvals = struct2cell(vars);
    for vi=1:length(varnames)
        eval(sprintf('%s = varvals{vi};', varnames{vi}))
    end;


    %% Data analysis
    [p_cca,fns_cca] = allometric_regression(man_table1_brain_weights, man_table1_ccas);

    % All data as one
    %allometric_plot(man_table1_brain_weights, man_table1_ccas)
    h = allometric_plot(man_table1_family_brain_weights, man_table1_family_ccas);
    legend(h, man_table1_families, 'Location', 'NorthWest');

    % Separate regressions for each famiy
    for fi=1:length(man_table1_families)
        %if length(man_table1_family_brain_weights{fi})==1, continue; end;
        [p_family_cca{fi}, fns_family_cca{fi}] = allometric_regression(man_table1_family_brain_weights{fi}, man_table1_family_ccas{fi});
    end;
    h = allometric_plot(man_table1_family_brain_weights, man_table1_family_ccas, p_family_cca, fns_family_cca);
    legend(h, man_table1_families, 'Location', 'NorthWest');

    % Average over families, then plot as one
    for fi=1:length(man_table1_families)
        mean_family_brain_weights(fi) = mean(man_table1_family_brain_weights{fi});
        mean_family_ccas(fi) = mean(man_table1_family_ccas{fi});
    end;

    % Linear regression
    [p_mean_cca,fns_mean_cca] = allometric_regression(mean_family_brain_weights, mean_family_ccas);
    h = allometric_plot(num2cell(mean_family_brain_weights), num2cell(mean_family_ccas), p_mean_cca, fns_mean_cca);
    legend(h, man_table1_families, 'Location', 'NorthWest');

    % Quadratic regression
    [p_mean_cca,fns_mean_cca] = allometric_regression(mean_family_brain_weights, mean_family_ccas, 'log', 2);
    h = allometric_plot(num2cell(mean_family_brain_weights), num2cell(mean_family_ccas), p_mean_cca, fns_mean_cca);
    legend(h, man_table1_families, 'Location', 'NorthWest');

    % Quadratic regression on original data
    [p_mean_cca,fns_mean_cca] = allometric_regression(mean_family_brain_weights, mean_family_ccas, 'linear', 2);
    h = allometric_plot(num2cell(mean_family_brain_weights), num2cell(mean_family_ccas), p_mean_cca, fns_mean_cca);
    legend(h, man_table1_families, 'Location', 'NorthWest');
