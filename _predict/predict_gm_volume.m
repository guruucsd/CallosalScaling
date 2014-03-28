function [gmv] = predict_gm_volume(brwt, bvol, collation)
%function [gmv] = predict_gm_volume(brwt, bvol)
%
% Predict grey matter volume (cm^3) via grey matter thickness and surface area.
%
% Collation: individual, species, or family

    if ~exist('collation','var'), collation='species'; end;
    if ~exist('bvol','var') || isempty(bvol), bvol = predict_bvol(brwt); end;

    global g_gmv

    if isempty(g_gmv) && strcmp(collation, 'species')
        an_dir = fullfile(fileparts(which(mfilename)), '..', 'analysis');

        %
        load(fullfile(an_dir, 'rilling_insel_1999a', 'ria_data.mat'));
        load(fullfile(an_dir, 'rilling_insel_1999b', 'rib_data.mat'));

        %
        [~,famidxa] = ismember(ria_table1_families, rib_families);
        [~,famidxb] = ismember(rib_fig1b_families, rib_families);
        families      = unique(famidxb);
        nfamilies     = length(families);

        % We get the species volume, then divide by the estimated
        % thickness.
        bvols = rib_table1_brainvol;%rib_fig1b_brain_volumes;
        gmvs = ria_table1_gmvol;

        % Now, do the regression
        [p_gmv, g_gmv] = allometric_regression(bvols, gmvs);
        fprintf('Grey matter volume (%s) (Rilling & Insel, 1999a/b): %5.3f * bvol^%5.3f', collation, 10.^p_gmv(2), p_gmv(1));
    end;

    % Now use the functions to compute # cc fibers and # neurons
    switch (collation)
        case 'species'
            gmv = g_gmv.y(bvol);
        otherwise
            gma = predict_gm_area(brwt, bvol, 'total', collation);
            gmt = predict_gm_thickness(brwt, bvol);
            gmv = gma .* gmt;
    end;