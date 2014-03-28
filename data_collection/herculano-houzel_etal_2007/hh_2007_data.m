function vars = hh_2007_data(validate_data)
%

    if ~exist('validate_data', 'var'), validate_data = true; end;
    if ~exist('visualize_data', 'var'), visualize_data = false; end;


    % Key:
    % M = brain (structure) mass
    % Nn = # neurons
    % No = # non-neurons (# "other")
    % Dn = Density of neurons (#/mg)
    % Do = Density of non-neurons (#/mg)


    %% Table 1 data
    hh_2007_tab1_species = {'Tupaia glis' 'Callithrix jacchus' 'Otolemur garnetti' 'Aotus trivirgatus' 'Saimiri sciureus' 'Cebus apella' 'Macaca mulatta' };
    hh_2007_tab1_body_mass = [172.5 361.0 946.7 925.0 nan 3340 3900]';
    hh_2007_tab1_M = [2.752 7.780 10.150 15.730 30.216 52.208 87.346]';
    hh_2007_tab1_Nn = 1E6*[261.40 635.8 936 1468.41 3246.43 3690.52 6376.16]';
    hh_2007_tab1_No = 1E6*[199.65 590.74 666.59 1195.13 2075.03 3297.74 7162.90]';

    %% Supplement data
    hh_2007_tabS2_species = hh_2007_tab1_species;%{'Tupaia glis' 'Callithrix jacchus' 'Otolemur garnetti' 'Aotus trivirgatus' 'Saimiri sciureus' 'Cebus apella' 'Macaca mulatta' };

    % Cortex
    hh_2007_tabS2_cortex_M = [1.455 5.561 6.290 10.617 20.652 39.178 69.832]';
    hh_2007_tabS2_cortex_Nn = 1E6*[60.39 244.72 226.09 441.90 1340 1140 1710]';
    hh_2007_tabS2_cortex_Dn = 1E3*[42.90 44.28 37.82 41.99 64.93 29.18 24.47]';
    hh_2007_tabS2_cortex_No = 1E6*[85.58 395.34 402.07 695.42 1610 2550 5270]';
    hh_2007_tabS2_cortex_Do = 1E3*[58.90 71.80 63.61 65.33 77.84 64.98 75.40]';

    % Cerebellum
    hh_2007_tabS2_cerebellum_M = [0.326 0.730 1.196 1.732 4.30 4.60 7.694]';
    hh_2007_tabS2_cerebellum_Nn = 1E6*[185.28 361.37 743.50 1040 1820 2490 4550]';
    hh_2007_tabS2_cerebellum_Dn = 1E3*[571.46 494.97 623.08 605.08 424.0 540.31 590.80]';
    hh_2007_tabS2_cerebellum_No = 1E6*[19.98 49.49 65.96 145.27 133.02 245.81 931.03]';
    hh_2007_tabS2_cerebellum_Do = 1E3*[61.60 68.17 54.46 82.89 30.94 53.44 121.01]';

    % "Other"
    hh_2007_tabS2_other_M = [0.919 1.489 2.131 3.104 5.004 8.430 9.204]';
    hh_2007_tabS2_other_Nn = 1E6*[22.48 29.72 20.80 49.34 65.53 61.85 121.90]';
    hh_2007_tabS2_other_Dn = 1E3*[25.90 19.65 9.73 15.90 13.09 7.34 12.41]';
    hh_2007_tabS2_other_No = 1E6*[87.08 145.91 147.44 313.46 302.59 506.11 966.52]';
    hh_2007_tabS2_other_Do = 1E3*[100.32 98.37 69.04 100.99 60.47 60.04 98.42]';

    % Combined
    hh_2007_tabS2_M  = [hh_2007_tabS2_cortex_M  hh_2007_tabS2_cerebellum_M hh_2007_tabS2_other_M ];
    hh_2007_tabS2_Nn = [hh_2007_tabS2_cortex_Nn hh_2007_tabS2_cerebellum_Nn hh_2007_tabS2_other_Nn ];
    hh_2007_tabS2_Dn = [hh_2007_tabS2_cortex_Dn hh_2007_tabS2_cerebellum_Dn hh_2007_tabS2_other_Dn ];
    hh_2007_tabS2_No = [hh_2007_tabS2_cortex_No hh_2007_tabS2_cerebellum_No hh_2007_tabS2_other_No ];
    hh_2007_tabS2_Do = [hh_2007_tabS2_cortex_Do hh_2007_tabS2_cerebellum_Do hh_2007_tabS2_other_Do ];


    %% Eliminate the questionable datapoint
    sidx = find(~strcmp(hh_2007_tab1_species, 'xxCebus apella'));


    %% Validate data, across tables
    if validate_data
        fprintf('All data taken from tables; no data to validate!\n');
    end;

    %% Visualize data
    if visualize_data
        % M in table 1 and M across all structures in supplement
        figure; allometric_regression(hh_2007_tab1_M, sum(hh_2007_tabS2_M,2), 'linear', 1, false, true);
        pct_diff_M = (sum(hh_2007_tabS2_M,2) - hh_2007_tab1_M)./(sum(hh_2007_tabS2_M,2)+hh_2007_tab1_M)/2*100;
        title(sprintf('Brain mass (max %4.1f%% diff)', max(abs(pct_diff_M))));
        xlabel('Table 1'); ylabel('\Sigma_{structures} Table S2');

        % Nn in table 1 and M across all structures in supplement
        figure; allometric_regression(hh_2007_tab1_Nn, sum(hh_2007_tabS2_Nn,2), 'linear', 1, false, true);
        pct_diff_Nn = (sum(hh_2007_tabS2_Nn,2) - hh_2007_tab1_Nn)./(sum(hh_2007_tabS2_Nn,2)+hh_2007_tab1_Nn)/2*100;
        title(sprintf('# Neurons (max %4.1f%% diff)', max(abs(pct_diff_Nn))));
        xlabel('Table 1'); ylabel('\Sigma_{structures} Table S2');

        % No in table 1 and M across all structures in supplement
        figure; allometric_regression(hh_2007_tab1_No, sum(hh_2007_tabS2_No,2), 'linear', 1, false, true);
        pct_diff_No = (sum(hh_2007_tabS2_No,2) - hh_2007_tab1_No)./(sum(hh_2007_tabS2_No,2)+hh_2007_tab1_No)/2*100;
        title(sprintf('# Non-neurons (max %4.1f%% diff)', max(abs(pct_diff_No))));
        xlabel('Table 1'); ylabel('\Sigma_{structures} Table S2');


        %% Validate data, within table
        figure; allometric_regression(hh_2007_tabS2_cortex_Dn.*hh_2007_tabS2_cortex_M*1000, hh_2007_tabS2_cortex_Nn, 'linear', 1, false, true); %Dn vs D neocortical
        pct_diff_Nn_calc = (hh_2007_tabS2_cortex_Dn.*hh_2007_tabS2_cortex_M*1000 - hh_2007_tabS2_cortex_Nn)./(hh_2007_tabS2_cortex_Dn.*hh_2007_tabS2_cortex_M*1000+hh_2007_tabS2_cortex_Nn)/2*100;
        title(sprintf('# Neurons, 2 ways, in Table S2 (max %4.1f%% diff)', max(abs(pct_diff_Nn_calc))));
        xlabel('[Density neurons*Structure Mass]'); ylabel('# neurons');


        %% Reproduce figures from paper, and from supplemental data

        % Fig 1
        allometric_regression(hh_2007_tab1_Nn(sidx), hh_2007_tab1_M(sidx), 'log', 1, true, true); %Fig 1a: M vs Nn
        allometric_regression(sum(hh_2007_tabS2_Nn(sidx,:),2), hh_2007_tab1_M(sidx), 'log', 1, true, false); %Fig 1a (supp): M vs Nn
        set(gcf, 'Position', [16         297        1247         387]);
        subplot(1,2,1); hold on; title('Fig 1a');  xlabel('# neurons'); ylabel('Brain Mass(g)');
        subplot(1,2,2); hold on; title('Inverse'); ylabel('# neurons'); xlabel('Brain Mass(g)');

        allometric_regression(hh_2007_tab1_No(sidx), hh_2007_tab1_M(sidx), 'log', 1, true, true); %Fig 1b: M vs No
        allometric_regression(sum(hh_2007_tabS2_No(sidx,:),2), hh_2007_tab1_M(sidx), 'log', 1, true, false); %Fig 1b (supp): M vs No
        set(gcf, 'Position', [16         297        1247         387]);
        subplot(1,2,1); title('Fig 1b');  xlabel('# non-neurons'); ylabel('Brain mass(g)');
        subplot(1,2,2); title('Inverse'); ylabel('# non-neurons'); xlabel('Brain mass(g)');


        % Fig 3
        allometric_regression(hh_2007_tabS2_Nn(sidx,:), hh_2007_tabS2_M(sidx,:), 'log', 1, true, true); %Fig 3a: Nn vs M
        set(gcf, 'Position', [16         297        1247         387]);
        subplot(1,2,1); title('Fig 3a');  xlabel('# neurons'); ylabel('Mass(g)');
        subplot(1,2,2); title('Inverse'); ylabel('# neurons'); xlabel('Mass(g)');

        allometric_regression(hh_2007_tabS2_No(sidx,:), hh_2007_tabS2_M(sidx,:), 'log', 1, true, true); %Fig 3b: No vs M
        set(gcf, 'Position', [16         297        1247         387]);
        subplot(1,2,1); title('Fig 3b');  xlabel('# non-neurons'); ylabel('Mass(g)');
        subplot(1,2,2); title('Inverse'); ylabel('# non-neurons'); xlabel('Mass(g)');


        % Fig 5
        allometric_regression(hh_2007_tabS2_Nn(sidx,:), hh_2007_tabS2_No(sidx,:), 'log', 1, true, true); %Fig 5a: Nn vs No
        set(gcf, 'Position', [16         297        1247         387]);
        subplot(1,2,1); title('Fig 5a');  xlabel('# neurons'); ylabel('# non-neurons');
        subplot(1,2,2); title('Inverse'); ylabel('# neurons'); xlabel('# non-neurons');

        allometric_regression(hh_2007_tabS2_M(sidx,:), hh_2007_tabS2_No(sidx,:)./hh_2007_tabS2_Nn(sidx,:), 'log', 1, true, true); %Fig 5b: M vs Nn/No
        set(gcf, 'Position', [16         297        1247         387]);
        subplot(1,2,1); title('Fig 5b');   xlabel('Structure mass (g)'); ylabel('NN/N');
        subplot(1,2,2); title('Inverse');  ylabel('Structure mass (g)'); xlabel('NN/N');


        %allometric_regression(sum(hh_2007_tabS2_M, 1), hh_2007_tabS2_cortex_Nn); %TBM vs N neocortical
        %allometric_regression(sum(hh_2007_tabS2_cortex_M, 1), hh_2007_tabS2_cortex_Nn); %TBM vs N neocortical
    end;


    %% Construct outputs
    varnames = who('hh_2007_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);
