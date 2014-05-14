function [bvols, ccas, gmas] = ris_collate(collation)
%function [bvols, ccas, gmas] = ris_collate(collation)
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

    switch collation
        case {'family' 'family-i'} % from individual
            [~,famidxa] = ismember(ria_table1_families, rib_families);
            [~,famidxb] = ismember(rib_fig1b_families, rib_families);
            unfamidx      = unique(famidxb);
            nfamilies     = length(families);
            bvols = zeros(nfamilies, 1);%size(famidxb));
            ccas = zeros(nfamilies, 1);
            gmas = zeros(nfamilies, 1);
            for fi=families
                idxa = fi==famidxa;
                idxb = fi==famidxb;
                bvols(fi) = mean(rib_fig1b_brain_volumes(idxb));
                ccas(fi) = mean(rib_fig2_ccas(idxb));
                gmas(fi) = mean(rib_fig2_gmas(idxb));%.*mean(ria_table6_gi(idxa));
            end;

        case 'family-s' %from species
            error('must account for GI');
            bvols = zeros(size(nfamilies, 1));
            ccas = zeros(size(nfamilies, 1));
            gmas = zeros(size(nfamilies, 1));
            for fi=families
                fidx = ria_fam_idx==unfamidx(fi);
                bvols(fi) = mean(ria_table1_brainvol(fidx));
                ccas(fi) = mean(rib_table1_ccarea(fidx));
                gmas(fi) = mean(ria_table1_gmvol(fidx)./g_gmt(ria_table1_brainvol(fi)));
            end;

        case 'species'
            bvols = rib_table1_brainvol;%rib_fig1b_brain_volumes;
            ccas = rib_table1_ccarea;%rib_fig2_ccas;
            gmas = ria_table1_gmvol ./ predict_gm_thickness([], bvols);

        case 'individual'
            bvols = rib_fig1b_brain_volumes;
            ccas = rib_fig2_ccas;

            % Use the family GI
            gis  = zeros(size(rib_fig2_gmas));
            for fi=families
                gis(famidxb==fi) = mean(ria_table6_gi(famidxa==fi));
            end;

            gmas = rib_fig2_gmas;%.*gis;
            %keyboard

        otherwise, error('Unknown collation: %s', collation)
    end;
    
    %collation(:)', bvols(:)', ccas(:)', gmas(:)'