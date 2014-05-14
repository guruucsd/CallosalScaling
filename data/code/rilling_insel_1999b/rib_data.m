function vars = rib_data(validate_data, visualize_data)
%
% Dataset:
%   Rilling & Insel 1999b
%
% Data:
%   Extract cross-primate callosal data from Rilling & Insel (1999b)
%
% Figures:
%   Figure 1b: brain volume (cm^3) vs. cc area (mm^2)
%   Figure 2: grey matter surface area (cm^2) vs. cca (mm^2), white matter volume (cm^3)
%
% Tables:
%   Table 1: body weight (kg), brain vol (cm^3), cca (mm^2), aca (mm^2)

    if ~exist('validate_data', 'var'), validate_data = true; end;
    if ~exist('visualize_data', 'var'), visualize_data = false; end;

    RIB_dirpath = fileparts(which(mfilename));
    RIB_dirname = guru_fileparts(RIB_dirpath, 'name');
    RIB_img_dirpath = fullfile(RIB_dirpath, '..', '..', 'img', RIB_dirname);


    %% Static data
    rib_table1_species = {'h. sapiens', 'p. paniscus', 'p. troglodytes', 'g. gorilla', 'P. pygmaeus', 'H. lar', 'P. cynocephalus', 'M. mulatta', 'C. atys', 'C. apella', 'S. sciureus'};
    rib_table1_bodyweight = [67.7 45.4 55.4 85.0 73.5 5.4 21.9 10.4 10.5 3.2 0.9];
    rib_table1_brainvol =   [1298.9 311.2 337.3 383.5 406.9 83.0 143.3 79.1 99.2 66.5 23.1];
    rib_table1_ccarea   =   [690.0 273.3 276.7 296.1 319.1 107.1 124.2 103.1 101.5 78.8 43.7];
    rib_table1_acarea   =   [8.47 5.00 4.95 3.30 7.45 1.95 4.80 4.33 2.68 2.33 1.78];


    %% Fig 1b
    %rib_fig1_families = {'cercopithecids' 'cebids' };
    rib_fig1_family_n = [[9] [8] [4 16 6]];
    [oir] = scrub_image(fullfile(RIB_img_dirpath, 'Fig1b_reddot.png'),   0, 'r', 255); [data_ypix_r, data_xpix_r] = find(~oir);
    [oig] = scrub_image(fullfile(RIB_img_dirpath, 'Fig1b_greendot.png'), 0, 'g', 255); [data_ypix_g, data_xpix_g] = find(~oig);
    [oib] = scrub_image(fullfile(RIB_img_dirpath, 'Fig1b_bluedot.png'),  0, 'b', 255); [data_ypix_b, data_xpix_b] = find(~oib);
    [img]   = scrub_image(fullfile(RIB_img_dirpath, 'Fig1b.png'));
    data_xpix_b = [data_xpix_b(1:10); data_xpix_b(9:end)]; %duplicate two overlapping ones
    data_ypix_b = [data_ypix_b(1:10); data_ypix_b(9:end)]; %duplicate two overlapping ones

    data_ypix = [data_ypix_g; data_ypix_r; data_ypix_b];
    data_xpix = [data_xpix_g; data_xpix_r; data_xpix_b];

    % get family indices
    rib_families = {'cebids'    'cercopithecids'    'hylobatids'    'pongids' 'humans'};
    [idx,c] = kmeans(data_xpix_b, 3);  % separate pongids, humans, and everybody else
    [~,idx2] = sort(c);
    for ci=1:length(c), b_fam_idx(idx==idx2(ci))=ci; end;
    rib_fig1b_fam_idx = [1*ones(1, length(data_xpix_g)) 2*ones(1, length(data_xpix_r)) 2+b_fam_idx];
    rib_fig1b_families = rib_families(rib_fig1b_fam_idx);
    if validate_data
        % taken from fig 1 caption
        guru_assert(8 == sum(strcmp('cebids', rib_fig1b_families)), 'Wrong cebid count');
        guru_assert(9 == sum(strcmp('cercopithecids', rib_fig1b_families)), 'Wrong cercopithecid count');
        guru_assert(4 == sum(strcmp('hylobatids', rib_fig1b_families)), 'Wrong hylobatid count');
        guru_assert(16 == sum(strcmp('pongids', rib_fig1b_families)), 'Wrong pongid count');
        guru_assert(6 == sum(strcmp('humans', rib_fig1b_families)), 'Wrong human count');
    end;

    % Get the (b&w) axes
    [yaxis_idx,yaxis_width]=get_groups(sum(img,1)>0.75*size(img,1));
    [xaxis_idx,xaxis_width]=get_groups(sum(img,2)>0.75*size(img,2));

    % Grab the ticks
    xticks = get_groups(img(floor(xaxis_idx-xaxis_width/2)-2,:)); xticks = xticks([4 6:end]);
    yticks = get_groups(img(:,floor(yaxis_idx+yaxis_width/2)+2,:)); yticks = yticks(1:end-1);

    % Convert the datapoints from pixels to data(x,y) values
    rib_fig1b_brain_volumes = 10.^(1+(data_xpix - xticks(1))/mean(diff(xticks))*1);
    rib_fig1b_ccas = 10.^(1.5+(yticks(end)-data_ypix)/mean(diff(yticks))*0.5);

    % Re-create the plot!
    p_cca = polyfit(log10(rib_fig1b_brain_volumes), log10(rib_fig1b_ccas), 1);  % Rilling & Insel used regular linear regression
    if validate_data
        p_cca_reported = [0.70, 0.65];
        cca_error_estimate = abs(100 * (p_cca - p_cca_reported) ./ ((p_cca + p_cca_reported) / 2));
        fprintf('CCA (Fig 1b) error estimate: %4.2f - %4.2f%%\n', cca_error_estimate);
    end;
    if visualize_data
        figure; set(gcf, 'Position', [19         303        1122         381]);
        subplot(1,2,1);
        imshow(~img); hold on;
        plot(data_xpix_g, data_ypix_g, 'g*');
        plot(data_xpix_r, data_ypix_r, 'r*');
        plot(data_xpix_b, data_ypix_b, 'b*');

        subplot(1,2,2);
        plot(log10(rib_fig1b_brain_volumes), log10(rib_fig1b_ccas), 'o');
        hold on; plot(log10(rib_fig1b_brain_volumes), p_cca(1)*log10(rib_fig1b_brain_volumes)+ p_cca(2));
        set(gca, 'FontSize', 14, 'xlim', [1 4], 'ylim', [1.5 3]);
        xlabel('log(brain volume) (g)'); ylabel('log(cca) (mm^2)');
        title(sprintf('Regression: %4.2fX + %4.2f', p_cca));
    end;


    %% Fig 2
    [data_ypix_cca,data_xpix_cca] = get_pixels_by_color(fullfile(RIB_img_dirpath, 'Fig2_reddot.png'), 'r');
    [data_ypix_wmv,data_xpix_wmv] = get_pixels_by_color(fullfile(RIB_img_dirpath, 'Fig2_greendot.png'), 'g');
    % reorder in xy
    [data_xpix_cca,idx1] = sort(data_xpix_cca); data_ypix_cca = data_ypix_cca(idx1);
    [data_xpix_wmv,idx2] = sort(data_xpix_wmv); data_ypix_wmv = data_ypix_wmv(idx2);

    data_xpix_wmv = [data_xpix_wmv(1:8); data_xpix_wmv(8:end)]; %duplication of an overlapping guy
    data_ypix_wmv = [data_ypix_wmv(1:8); data_ypix_wmv(8:end)];
    sort(data_xpix_wmv'-data_xpix_cca');
    [img]   = scrub_image(fullfile(RIB_img_dirpath, 'Fig2.png'));

    % Get the (b&w) axes
    [yaxis_idx,yaxis_width]=get_groups(sum(img,1)>0.75*size(img,1));
    [xaxis_idx,xaxis_width]=get_groups(sum(img,2)>0.75*size(img,2));

    % Grab the ticks
    xticks     = get_groups(img(floor(xaxis_idx(2)-xaxis_width(2)/2)-2,:)); xticks = xticks([5 7:9]);
    yticks_cca = get_groups(img(:,floor(yaxis_idx(1)+yaxis_width(1)/2)+2,:)); yticks_cca = yticks_cca([1:3 5]);
    yticks_wmv = get_groups(img(:,ceil(yaxis_idx(2)-yaxis_width(2)/2)-2,:)); yticks_wmv = yticks_wmv([1:4]);
    if visualize_data
        figure; imshow(img); hold on; plot(yaxis_idx(1), yticks_cca, 'r*');
        plot(yaxis_idx(2), yticks_wmv, 'g*'); plot(xticks, xaxis_idx(2), 'b*');
    end;

    % Convert the datapoints from pixels to data(x,y) values
    rib_fig2_gmas = 10.^(0+((data_xpix_cca+data_xpix_wmv)/2 - xticks(1))/mean(diff(xticks))*1); % average over cca and wmv; should have same xval!
    rib_fig2_ccas = 10.^(0+(yticks_cca(end)-data_ypix_cca)/mean(diff(yticks_cca))*1);  % y axis starts at zero, each tick represents 1
    rib_fig2_wmvs = 10.^(0+(yticks_wmv(end)-data_ypix_wmv)/mean(diff(yticks_wmv))*1);  % y axis starts at zero, each tick represents 1

    % Re-create the plot!
    p_cca = polyfit(log10(rib_fig2_gmas), log10(rib_fig2_ccas), 1);  % Rilling & Insel used regular linear regression
    p_wmv = polyfit(log10(rib_fig2_gmas), log10(rib_fig2_wmvs), 1);  % Rilling & Insel used regular linear regression
    if validate_data
        p_cca_reported = [0.88, 0.84];
        cca_error_estimate = abs(100 * (p_cca - p_cca_reported) ./ ((p_cca + p_cca_reported) / 2));
        fprintf('CCA (Fig 2) error estimate: %4.2f - %4.2f%%\n', cca_error_estimate);

        p_wmv_reported = [1.38, -0.56];
        wmv_error_estimate = abs(100 * (p_wmv - p_wmv_reported) ./ ((p_wmv + p_wmv_reported) / 2));
        fprintf('WMV (Fig 2) error estimate: %4.2f - %4.2f%%\n', wmv_error_estimate);
    end;

    if visualize_data
        figure; set(gcf, 'Position', [49         290        1194         394]);
        subplot(1,2,1);
        imshow(~img); hold on;
        plot(data_xpix_cca, data_ypix_cca, 'g*');
        plot(data_xpix_wmv, data_ypix_wmv, 'r*');

        subplot(1,2,2);
        plot(log10(rib_fig2_gmas), log10(rib_fig2_ccas), 'o');
        hold on; plot(log10([0.1; rib_fig2_gmas]), p_cca(1)*log10([0.1; rib_fig2_gmas])+ p_cca(2));

        plot(log10(rib_fig2_gmas), log10(rib_fig2_wmvs), 'o');
        hold on; plot(log10([0.1; rib_fig2_gmas]), p_wmv(1)*log10([0.1; rib_fig2_gmas])+ p_wmv(2));

        set(gca, 'FontSize', 14, 'xlim', [0 3], 'ylim', [0 3]);
        xlabel('log(grey matter surface area) (g)'); ylabel('log(cca) (mm^2)');
        title(sprintf('Regressions: %4.2fX + %4.2f\n\t%4.2fX+%4.2f', p_cca, p_wmv));
    end;

    % now build a database
    [rib_fig1b_ccas,idx1] = sort(rib_fig1b_ccas); rib_fig1b_brain_volumes = rib_fig1b_brain_volumes(idx1);
    [rib_fig2_ccas, idx2] = sort(rib_fig2_ccas);  rib_fig2_gmas = rib_fig2_gmas(idx2); rib_fig2_wmvs = rib_fig2_wmvs(idx2);

    rib_data_names = {'CCA (fig1b)' 'CCA (fig2)' 'Brain Volume' 'Grey Matter Volume' 'White Matter Volume'};
    rib_database = [rib_fig1b_ccas rib_fig2_ccas rib_fig1b_brain_volumes rib_fig2_gmas rib_fig2_wmvs]; % the database


    %% Validate outputs
    if validate_data
        %keyboard
    end;

    %% Construct outputs
    varnames = who('rib_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);

