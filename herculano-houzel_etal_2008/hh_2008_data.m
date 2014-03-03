function vars = hh_2008_data(validate_data)
%

    if ~exist('validate_data', 'var'), validate_data = true; end;

    hh_2008_dir = fileparts(which(mfilename));

    
    %% Gather data
    hh_2008_tab1_species = {'Tupaia glis' 'Callithrix jacchus' 'Otolemur garnetti' 'Aotus trivirgatus' 'Callimico goeldi' 'Saimiri sciureus' 'Macaca fasciularis' 'Macaca radiata' 'Cebus apella' 'Papio sp'};
    hh_2008_tab1_M = [0.515 2.042 2.556 3.698 3.827 6.996 10.459 15.493 15.820 36.334]'; % g
    hh_2008_tab1_A = [497 1534 1745 2214 1953 5250 9381 8441 7653 16689]'; %mm^2
    hh_2008_tab1_T = [1.089 1.310 1.462 1.499 1.600 1.465 1.413 1.572 1.767 2.034]'; %mm
    hh_2008_tab1_N = 1E6*[21.95 120.33 88.50 200.32 178.77 645.73 400.74 829.60 930.67 1420.34]';
    hh_2008_tab1_D = 1E3*[38.16 54.24 31.90 47.96 38.55 80.92 32.94 43.81 51.08 33.73]'; %N/mg
    hh_2008_tab1_NdivA = 1E3*[47.09 78.00 50.83 92.96 91.53 129.67 42.71 98.28 121.73 86.65]'; 

    hh_2008_tab1_V_est = hh_2008_tab1_A.*hh_2008_tab1_T;

    % N = hh_2008_tab1_A * hh_2008_tab1_NdivA
    
        
    %% Reconstruct outputs
    varnames = who('hh_2008_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);
    
    
    %% Validate data by reproducing some figures
    if validate_data
        %Fig 1a-c
        allometric_regression(zscore(log(hh_2008_tab1_N)), zscore(log(hh_2008_tab1_A)), 'linear', 1, true, true) %0.86 (/0.889), within 8/9
        allometric_regression(hh_2008_tab1_N, hh_2008_tab1_A, 'log', 1, true, true) %0.86 (/0.889), within 8/9
        allometric_regression(hh_2008_tab1_A, hh_2008_tab1_M, 'log', 1, true, true) %0.86 (/0.889), within 8/9
        allometric_regression(hh_2008_tab1_N, hh_2008_tab1_M, 'log', 1, true, true) %0.86 (/0.889), within 8/9

        %Fig 2a-c
        allometric_regression(hh_2008_tab1_D, hh_2008_tab1_T, 'log', 1, true, true) %0.86 (/0.889), within 8/9
        allometric_regression(hh_2008_tab1_A, hh_2008_tab1_T, 'log', 1, true, true) %0.86 (/0.889), within 8/9
        allometric_regression(hh_2008_tab1_A, hh_2008_tab1_D, 'log', 1, true, true) %0.86 (/0.889), within 8/9

        % Fig 3: note linear regression
        allometric_regression(hh_2008_tab1_D.*hh_2008_tab1_T, hh_2008_tab1_NdivA, 'linear', 1, true, true) %1.14 (/1.31); well above 1.0
        set(gcf,'Position', [16         110        1265         574]);
        subplot(1,2,1); title('Fig 3 (regress linear vals)');   xlabel('D x T'); ylabel('N / A'); 
        plot([1 1E6], [1 1E6], 'r--');  
        %plot([1 1E6], [1 1E6]+18181, 'g--')
        set(gca, 'xlim', [2E4 2E5], 'ylim', [2E4, 2E5]);%get(gca,'xlim')); set(gca, 'ytick', get(gca,'xtick'), 'yticklabel', get(gca,'xticklabel'))
        %set(gca, 'XScale', 'log', 'YScale', 'log')
        subplot(1,2,2); title('Inverse'); ylabel('D x T'); xlabel('N / A'); 
        plot([1 1E6], [1 1E6], 'r--');  
        %plot([1 1E6], [1 1E6]-16000, 'g--')
        set(gca, 'xlim', get(gca,'ylim')); set(gca, 'ytick', get(gca,'xtick'), 'yticklabel', get(gca,'xticklabel'))
        %set(gca, 'XScale', 'log', 'YScale', 'log')

        allometric_regression(hh_2008_tab1_D.*hh_2008_tab1_T, hh_2008_tab1_NdivA, 'log', 1, true, true) %1.14 (/1.31); well above 1.0
        set(gcf,'Position', [16         110        1265         574]);
        subplot(1,2,1); title('Fig 3 (regress log vals)');   xlabel('D x T'); ylabel('N / A'); 
        axis square; set(gca, 'xlim', get(gca,'ylim')); set(gca, 'ytick', get(gca,'xtick'), 'yticklabel', get(gca,'xticklabel'))
        plot([1 1E6], [1 1E6], 'r--');  
        subplot(1,2,2); title('Inverse'); ylabel('D x T'); xlabel('N / A'); 
        axis square; set(gca, 'xlim', get(gca,'ylim')); set(gca, 'ytick', get(gca,'xtick'), 'yticklabel', get(gca,'xticklabel'))
        plot([1 1E6], [1 1E6], 'r--');  
    end;
