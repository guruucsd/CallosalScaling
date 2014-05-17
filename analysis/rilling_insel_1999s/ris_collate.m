function [bvols, ccas, gmas, gmvs] = ris_collate(collation)
%function [bvols, ccas, gmas, gmvs] = ris_collate(collation)
%
%

    if ~exist('collation','var'), collation='species'; end;

    ris_dir = fileparts(which(mfilename));

    %
    %addpath(genpath(fullfile(ris_dir, '..', '..', '_lib')));
    %addpath(genpath(fullfile(ris_dir, '..', '_lib')));
    %addpath(fullfile(ris_dir, '..', 'rilling_insel_1999a'));
    %addpath(fullfile(ris_dir, '..', 'rilling_insel_1999b'));
    %addpath(ris_dir);

    %
    load(fullfile(ris_dir, '..', 'rilling_insel_1999a', 'ria_data.mat'));
    load(fullfile(ris_dir, '..', 'rilling_insel_1999b', 'rib_data.mat'));


    %%
    [~,famidxa] = ismember(ria_table1_families, rib_families);
    [~,famidxb] = ismember(rib_fig1b_families, rib_families);
    families      = unique(famidxb);
    nfamilies     = length(families);
    cross_table_idx = abs(rib_table1_brainvol - ria_table1_brainvol) < eps ;

    switch collation
        case {'family' 'family-i', 'family-s'} % from individual
            bvols = zeros(nfamilies, 1);%size(famidxb));
            ccas = zeros(nfamilies, 1);
            gmas = zeros(nfamilies, 1);
            gmvs = zeros(nfamilies, 1);
            for fi=families
                
                if strcmp(collation, 'family-s')
                    [~,famidx] = ismember(ria_table1_families, rib_families);
                    idx = fi==famidx & cross_table_idx;
                    bvols(fi) = mean(ria_table1_brainvol(idx));
                    ccas(fi) = mean(rib_table1_ccarea(idx));
                    gmas(fi) = mean(ria_table1_gmvol(idx)./predict_gm_thickness([], ria_table1_brainvol(idx)));
                    gmvs(fi) = mean(ria_table1_gmvol(idx));

                else  % everything comes from rib, figure 2
                    [~,famidxb] = ismember(rib_fig1b_families, rib_families);
                    idxb = fi==famidxb;
                    bvols(fi) = mean(rib_fig1b_brain_volumes(idxb));
                    ccas(fi) = mean(rib_fig2_ccas(idxb));
                    gmas(fi) = mean(rib_fig2_gmas(idxb));%.*mean(ria_table6_gi(idxa));
                    gmvs(fi) = mean(rib_fig2_gmas(idxb) .* predict_gm_thickness([], rib_fig1b_brain_volumes(idxb)));%.*mean(ria_table6_gi(idxa));
                end;
            end;

        case 'species'
            % Mixed tables
            bvols = rib_table1_brainvol(cross_table_idx);
            ccas = rib_table1_ccarea(cross_table_idx);
            gmas = ria_table1_gmvol(cross_table_idx) ./ predict_gm_thickness([], bvols);
            gmvs = ria_table1_gmvol(cross_table_idx);
            

        case 'individual'
            bvols = rib_fig1b_brain_volumes;
            ccas = rib_fig2_ccas;

            % Use the family GI
            gis  = zeros(size(rib_fig2_gmas));
            for fi=families
                gis(famidxb==fi) = mean(ria_table6_gi(famidxa==fi));
            end;

            gmas = rib_fig2_gmas;
            gmvs = rib_fig2_gmas .* predict_gm_thickness([], rib_fig1b_brain_volumes);
            %keyboard

        otherwise, error('Unknown collation: %s', collation)
    end;
    
    %collation(:)', bvols(:)', ccas(:)', gmas(:)'