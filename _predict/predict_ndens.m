function ndens = predict_ndens(brwt, bvol)
%function ndens = predict_ndens(brwt, bvol)
%
% Predict the neuron density using allometric regression,
%   based on data from Tower (1954)
%
% Input:
%   brwt: [native units] brain weight (g)
%   bvol: brain volume (cm^3)
%
% Output:
%   ndens: neuron density in the grey matter (neurons / mm^3)

    global g_ndens

    % convert to native units
    if ~exist('brwt','var') || isempty(brwt), brwt = predict_brwt(bvol); end;

    if isempty(g_ndens)
        an_dir = fullfile(fileparts(which(mfilename)), '..', 'analysis');

        %load(fullfile(an_dir, 'haug_1987', 'ha_data.mat'));
        %[~, g_ndens] = allometric_regression( ha_fig7_brain_volume, ha_fig7_neuron_density, 'log', 1, true );

        load(fullfile(an_dir, 'tower_1954', 'tow_data.mat'));
        [p_ndens, g_ndens, rsq] = allometric_regression( tow_fig1_brain_weight, tow_fig1_neuron_dens, 'log', 1, true, false);
        fprintf('Neuron density (Tower, 1954): %5.3e * brwt^%5.3f, r^2=%5.3f\n', 10.^p_ndens(2), p_ndens(1), rsq{1});
    end;

    ndens = g_ndens.y(brwt);  % neurons / g


