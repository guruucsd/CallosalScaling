function [cc_dens_est] = predict_macaque_ccdens(age_m)
% Predict macaque callosum density given a specific age
%   using LaMantia & Rakic (1990a) data.
%
% Input:
%   age_m: macaque age (years)
%
% Output:
%   cc_dens_est: estimate of callosal density.

    load(fullfile(an_dir, 'lamantia_rakic_1990a', 'lra_data.mat'))

    [p1, g1, rsquared] = allometric_regression(lra_cc_age, lra_cc_density, 'log', 1, true);

    cc_dens_est = g1.y(age_m);
