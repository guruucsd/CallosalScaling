hh_data;


    %% partial correlations
    dm = log10([hh_2008_tab1_M/1E-3 hh_2008_tab1_A hh_2008_tab1_T/1E-4 hh_2008_tab1_N/1E5 hh_2008_tab1_D]/1E4)
    [C,p] = fpc(dm)
    [Vp,Dp] = eig(C) %PCA of partial correlations;1. M,N.  2: M(ish),-N,-D 3: A,-T 4: A,T,-N,D
    
    %% PCA
    [Vm,Dm] = eig(cov(dm)) %PCA of covariance factor 1: M A * N *; factor 2: * * * N D

    % First PC:
    %allometric_regression(hh_2008_tab1_M, hh_2008_tab1_A, 'log', 1, true, true) %0.86 (/0.889), within 8/9
    %allometric_regression(hh_2008_tab1_M, hh_2008_tab1_N, 'log', 1, true, true) %0.86 (/0.889), within 8/9
    %allometric_regression(hh_2008_tab1_N, hh_2008_tab1_A, 'log', 1, true, true) %0.86 (/0.889), within 8/9

    % 2nd PC
    %allometric_regression(hh_2008_tab1_N, hh_2008_tab1_D, 'log', 1, true, true) %0.86 (/0.889), within 8/9
    %allometric_regression(hh_2008_tab1_M, hh_2008_tab1_D, 'log', 1, true, true) %0.86 (/0.889), within 8/9


    %% Is this different than Changizi, 2009?

    % good
    allometric_regression(hh_2008_tab1_M, hh_2008_tab1_A, 'log', 1, true, true) %0.86 (/0.889), within 8/9
    subplot(1,2,1); title('Changizi, 2009?');   xlabel('Grey matter mass (g)'); ylabel('Area (mm^2)'); 
    subplot(1,2,2); title('Inverse');           ylabel('Grey matter mass (g)'); xlabel('Area (mm^2)'); 

    allometric_regression(hh_2008_tab1_M, hh_2008_tab1_T, 'log', 1, true, true) %0.12 (/0.153), within 1/9
    subplot(1,2,1); title('Changizi, 2009?');   xlabel('Grey matter mass (g)'); ylabel('Thickness (mm)'); 
    subplot(1,2,2); title('Inverse');           ylabel('Grey matter mass (g)'); xlabel('Thickness (mm)'); 

    % bad
    allometric_regression(hh_2008_tab1_M, hh_2008_tab1_N) %1.02 (/1.07), far from 0.67
    allometric_regression(hh_2008_tab1_M, hh_2008_tab1_N./hh_2008_tab1_V_est) %BUT no relationship; far from -0.33

    % why is this?
    allometric_regression(hh_2008_tab1_M, hh_2008_tab1_V_est) %mass and volume are tightly correlated
    allometric_regression(hh_2008_tab1_N, hh_2008_tab1_V_est) %but relationships between quantities differ with M and V

    %N/A
    allometric_regression(hh_2008_tab1_M, hh_2008_tab1_D) %no relationship
    allometric_regression(hh_2008_tab1_M, hh_2008_tab1_NdivA) %0.15 (weak) 

    allometric_regression(hh_2008_tab1_N, hh_2008_tab1_A) % 0.81 (/0.87) but relationships between quantities differ with M and V


    % Are their claims true?
    allometric_regression(hh_2008_tab1_D.*hh_2008_tab1_T, hh_2008_tab1_NdivA) %1.14 (/1.31); well above 1.0
    allometric_regression(hh_2008_tab1_N./hh_2008_tab1_A, hh_2008_tab1_NdivA) %why aren't these identical??


    %%
    allometric_regression(hh_2008_tab1_T.*hh_2008_tab1_A, hh_2008_tab1_N, 'log', 1, true, true) %t*a = volume, so of course N scales with that.
    allometric_regression(hh_2008_tab1_N, hh_2008_tab1_NdivA, 'log', 1, true, true) %t*a = volume, so of course N scales with that.

    
    
    
    %% Some more, from 2010 (white matter) paper
    
    %allometric_regression(hh_2008_tab1_M, hh_2008_tab1_V_est, 'log', 1, true, true) % Mass and Volume essentially the same...
    allometric_regression(hh_2008_tab1_M, hh_2008_tab1_A, 'log', 1, true, true) % Unequally divided into A and T
    allometric_regression(hh_2008_tab1_M, hh_2008_tab1_T, 'log', 1, true, true)
    allometric_regression(hh_2008_tab1_T, hh_2008_tab1_A, 'log', 1, true, true) % ... but those two don't correlate all that well.  Why? :(

    allometric_regression(hh_2008_tab1_V_est, hh_2008_tab1_T, 'log', 1, true, true) % ... 

    %%
    allometric_regression(hh_2008_tab1_N, hh_2008_tab1_T, 'log', 1, true, true) % yes; cortical column
    allometric_regression(hh_2008_tab1_N, hh_2008_tab1_A, 'log', 1, true, true) % yes; spacing of columns
    allometric_regression(hh_2008_tab1_D, hh_2008_tab1_N./hh_2008_tab1_A, 'log', 1, true, true)

