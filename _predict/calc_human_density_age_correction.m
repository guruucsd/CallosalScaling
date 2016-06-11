function [age_correction] = calc_human_density_age_correction()
% Predict macaque callosum density given a specific age
%   using LaMantia & Rakic (1990a) data.
%
% Input:
%   age_m: macaque age (years)
%
% Output:
%   cc_dens_est: estimate of callosal density.

    an_dir = fullfile(fileparts(which(mfilename)), '..', 'analysis');
    load(fullfile(an_dir, 'lamantia_rakic_1990a', 'lra_data.mat'))
    human_age = 45;

    mean_macaque_age = mean(lra_cc_age);
    age_m_est = predict_macaque_age(human_age);

    age_correction = 1.2; %predict_cc_density(mean_macaque_age) ./ predict_cc_density(age_m_est);
