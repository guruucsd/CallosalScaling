function [gma] = predict_gm_area(brwt, bvol, area_type, collation)
%function [gmv,gma,gmt] = predict_gm_area(brwt, bvol)
%
% Predict grey matter volume, based on Rilling & Insel (1999a, 1999b)
%
% Fig 2 (Rilling & Insel, 1999a) reported grey matter area
% for the outer surface, not the true surface area.
% Multiply the area (per individual) by the gyrification
% index (per family) to estimate individual grey matter
% surface area.
%
% This had to be determined carefully, indicated by 1999a
% Figure 1.
%
% For grey matter volume, "inner" surface area should be
% used.
    global g_gmas g_gma_collations;

    if ~exist('area_type','var'), area_type = 'total'; end;
    if ~exist('collation','var'), collation = 'individual'; end;
    if ~exist('bvol','var'), bvol = predict_bvol(brwt); end;
    if isempty(g_gmas), g_gmas = {}; g_gma_collations = {}; end;
    
    if ~strcmp(area_type, 'total'), error('Area type "%s" is NYI.', area_type); end;
    
    
    if isempty(g_gmas) || ~ismember(collation, g_gma_collations)
        an_dir = fullfile(fileparts(which(mfilename)), '..', 'analysis');

        %
        load(fullfile(an_dir, 'rilling_insel_1999a', 'ria_data.mat'));
        load(fullfile(an_dir, 'rilling_insel_1999b', 'rib_data.mat'));

        %
        [~,famidxa] = ismember(ria_table1_families, rib_families);
        [~,famidxb] = ismember(rib_fig1b_families, rib_families);
        families      = unique(famidxb);
        nfamilies     = length(families);

        switch collation
            case {'family' 'family-i'}
                % We get the GMA from 1999b Fig 2, multiply by GI.
                [~,famidxa] = ismember(ria_table1_families, rib_families);
                [~,famidxb] = ismember(rib_fig1b_families, rib_families);
                bvols = zeros(nfamilies, 1);%size(famidxb));
                gmas = zeros(nfamilies, 1);
                for fi=families
                    idxa = fi==famidxa;
                    idxb = fi==famidxb;
                    bvols(fi) = mean(rib_fig1b_brain_volumes(idxb));
                    gmas(fi) = mean(rib_fig2_gmas(idxb)).*mean(ria_table6_gi(idxa));
                end;

            case 'species'
                % We get the species volume, then divide by the estimated
                % thickness.
                error('Species computation doesn''t yet use GI');
                bvols = rib_table1_brainvol;%rib_fig1b_brain_volumes;
                gmas = ria_table1_gmvol./predict_gm_thickness([], bvols);

            case 'individual'
                % We get the GMA from 1999b Fig 2, multiply by GI.
                bvols = rib_fig1b_brain_volumes;

                % Use the family GI
                gis  = zeros(size(rib_fig2_gmas));
                for fi=families
                    gis(famidxb==fi) = mean(ria_table6_gi(famidxa==fi));
                end;

                gmas = rib_fig2_gmas .* gis;
        end;

        % Now, do the regression
        [p_gma, g_gmas{end+1}] = allometric_regression(bvols, gmas);
        g_gma_collations{end+1} = collation;
        fprintf('Grey matter surface area (%s) (Rilling & Insel, 1999a/b): %5.3f * bvol^%5.3f', collation, p_gma(end:-1:1));
    end;

    % Now use the functions to compute # cc fibers and # neurons
    gma = g_gmas{strcmp(collation, g_gma_collations)}.y(bvol);
