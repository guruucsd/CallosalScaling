function [dens] = predict_cc_density(brwt, bvol, use_human)
% Predict cc density using allometric regression
%   with Wang et al (2008) data
%   and (optionally) corrected aboitiz data for humans

    global g_ccdens;
        
    if ~exist('use_human','var'), use_human = false; end;

    % convert to native units
    if ~exist('brwt','var') || isempty(brwt), brwt = predict_bwt(bvol); end;

    if isempty(g_ccdens) || use_human
        %% Compare # neurons to # cc connections
        % Function for computing cc density from brain volume
        an_dir = fullfile(fileparts(which(mfilename)), '..', 'analysis');
        load(fullfile(an_dir, 'wang_etal_2008', 'w_data.mat'));

        if ~use_human
            br_wts = w_fig1e_weights;
            cc_dens = w_fig1e_dens_est;
        else
            human_dens_ab_raw = 3.717 * 1E5 * (1-0.35)^(1); % correct for shrinkage
            human_dens_ab     = human_dens_ab_raw*1.21;     % correct for 20% missing fibers
            human_dens_abcor  = human_dens_ab*1.2;          % correct for age
            
            br_wts = [w_fig1e_weights get_human_brain_weight()];
            cc_dens = [w_fig1e_dens_est human_dens_abcor/1E6];
        end;
        
        [p_ccdens, g_ccdens] = allometric_regression(br_wts, cc_dens);%, 'log', 1, true, '3' );
        fprintf('Corpus callosum density (Wang et al., 2008): %5.3f * bvol^%5.3f', 10.^p_ccdens(2), p_ccdens(1));
    end;

    dens = g_ccdens.y(brwt);
    
    if use_human
        clear g_ccdens; % Don't save the variable.
    end;