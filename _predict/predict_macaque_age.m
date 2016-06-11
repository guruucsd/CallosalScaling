function [age_m_est] = predict_macaque_age(age_h)
% Predict macaque age for given human age
%   using Finlay's procedure and data from online re: sexual maturity and lifespan.
%
% Input:
%   age_h: human age (years)
%
% Output:
%   age_m: macaque age (years)

    pct_life = @(age_h) (age_h - 15)/(73 - 15);
    age_m = @(pct_life) 4 + pct_life * (25 - 4);
    age_m_est = age_m(pct_life(age_h));  % what macaque age would 45 human be?
