function ccas = predict_cc_area(brwt,bvol)
% Predict the callosal area using allometric analysis
%   from Rilling & Insel (1999a/b) data

    global g_cca;

    % convert to native units
    if ~exist('bvol','var') || isempty(bvol), bvol = predict_bvol(brwt); end;

    if isempty(g_cca)
        an_dir = fullfile(fileparts(which(mfilename)), '..', 'analysis');

        load(fullfile(an_dir, 'rilling_insel_1999a', 'ria_data.mat'));
        load(fullfile(an_dir, 'rilling_insel_1999b', 'rib_data.mat'));

        [p_cca, g_cca] = allometric_regress(rib_table1_brainvol, rib_table1_ccarea);
        fprintf('Corpus callosum area (Rilling & Insel, 1999a/b): %5.3f * bvol^%5.3f', 10.^p_cca(2), p_cca(1));
    end;

    ccas = g_cca.y(bvol);