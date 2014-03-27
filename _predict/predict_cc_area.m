function ccas = predict_cc_area(brwt,bvol)
% Predict the callosal area using allometric analysis
function ccas = predict_cca(brwt,bvol)
% Predict the callosal area from rilling & insel (1999) data
    global g_cca;

    % convert to native units
    if ~exist('bvol','var'), bvol = predict_bvol(brwt); end;

    if isempty(g_cca)
        an_dir = fullfile(fileparts(which(mfilename)), '..', 'analysis');

        load(fullfile(an_dir, 'rilling_insel_1999a', 'ria_data.mat'));
        load(fullfile(an_dir, 'rilling_insel_1999b', 'rib_data.mat'));

        [~,g_cca] = allometric_regress(rib_table1_brainvol, rib_table1_ccarea);
    end;

    ccas = g_cca.y(bvol);