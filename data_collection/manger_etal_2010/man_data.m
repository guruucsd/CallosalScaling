function vars = man_data(validate_data)
%
% Corpus callosum of the elephant

    if ~exist('validate_data', 'var'), validate_data = true; end;
 
    
    %% Set variables
    man_table1_brain_weights = [5145 5250 4835 4026.6  4460 5220 1345.66 322.4 349.44 397.31 421.55 85.99 148.46 81.95 102.77 68.89 23.93 70.29 3.38 14 23.6 45.15 101 201 747.66  724.6 2549.33 1162 1217.5 6060.33 6052 4444.5 739.75 644.5 1539.63 630 1508.63 1567 2217 188 ...
    ...
     1250 488 345 2.59 1.52 0.84 0.62  0.13 0.58 0.56 2.77 1.15 4.15 1.13 0.74 4.72 6.08 1.20 3.26 3.37 1.88 4.00 1.33 1.02 0.88 1.31 0.26  0.22 0.17 .24 .12 .1 .28 .233 .39 .25 .39 .41 .20 .06 .38 .64 .17 .19 .37 .36 3.2 87 ...
    ...
    531 550 585 530 526 509 287 244 1.27 2.6 0.27 1.61 13.75 38.87 60 231 198 54 400 470 217 130 44 34 8.3];

    man_table1_ccas = [8.515 10.192 9.191 12.8 8.085 12.57 6.9 2.733 2.767 2.961 3.191 1.071 1.242 1.031 1.015 0.788 0.437 0.890 0.032 0.161 0.210 0.370 0.390 1.16 1.744 1.547 4.104 1.600 2.182 5.653  5.35 4.569 1.699 1.611 2.083 1.393  2.624 2.835 3.348 0.895...
    ...
    1.887 1.75 1.01 .009 .007 .005 .002 .001 .007 .007 .009 .017 .062 .011 .008 .027 .07 .014 .025 .015 .016 .051 .021 .011 .007 .019 .004 .003 .003 .005 .002 .002 .003 .004 .005 .003 .003 .004 .002 .001 .004 .006 .002 .002 .005 .006 .033 .605...
    ...
    2.515 2.385 2.425 1.79 1.735 1.801 .1345 1.173 .015 .017 .004 .027 .132 .379 .445 1.160 .815 .425 2.37 2.33 1.15 0.975 0.495 0.370 0.072
    ];

    man_table1_families = {'Elephants' 'Primates' 'Cetacea' 'Siriena' 'Pinnipedia' 'Insectivora' 'Tupaiidae' 'Myrmecophaga' 'Perissodactyla' 'Aritodactyla' 'Macroscelidadae' 'Chiroptera' 'Rodentia' 'Carnivora'};

    man_table1_family_indices = { 1:6 7:26 27:39 40 41:43 44:86 87 88 89:91 92:96 97 98:99 100:103 104:113};

    man_table1_family_brain_weights = cell(size(man_table1_families));
    man_table1_family_ccas = cell(size(man_table1_families));
    for fi=1:length(man_table1_families)
        man_table1_family_brain_weights{fi} = man_table1_brain_weights(man_table1_family_indices{fi});
        man_table1_family_ccas{fi} = man_table1_ccas(man_table1_family_indices{fi});
    end;

    
    %% Reconstruct outputs
    varnames = who('man_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);

    
    %% Validate data
    if validate_data
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
    end;
