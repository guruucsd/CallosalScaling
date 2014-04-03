function vars = oli0_data(validate_data)
%
% Cross-Species and Intraspecies Morphometric Analysis of the Corpus
% Callosum

    if ~exist('validate_data', 'var'), validate_data = true; end;
    if ~exist('visualize_data', 'var'), visualize_data = false; end;

    OLI0_dirpath = fileparts(which(mfilename));
    OLI0_dirname = guru_fileparts(OLI0_dirpath, 'name');
    OLI0_img_dirpath = fullfile(OLI0_dirpath, '..', 'img', OLI0_dirname);


    %% Gather data
    [img, orig_img] = scrub_image(fullfile(OLI0_img_dirpath, 'Fig3_greendot.png'), 0, 'g', 255);

    % Get the (colored) datapoints
    oli0_fig3_species = {'Rat','Rabbit','Cat','Dog','Cow','Horse','Human'};
    oli0_species_n = [14 6 19 20 19 17 40];

    [data_ypix,data_xpix] = find(~img);
    if length(data_ypix)~=length(oli0_fig3_species), error('?'); end;

    % Get the (b&w) axes
    [yaxis_idx,yaxis_width]=get_groups(sum(~orig_img,1)>0.75*size(orig_img,1));
    [xaxis_idx,xaxis_width]=get_groups(sum(~orig_img,2)>0.75*size(orig_img,2));

    % Grab the ticks
    xticks = get_groups(~orig_img(floor(xaxis_idx-xaxis_width/2)-2,:));
    yticks = get_groups(~orig_img(:,floor(yaxis_idx+yaxis_width/2)+2,:));

    % Convert the datapoints from pixels to data(x,y) values
    oli0_fig3_brain_weights = 10.^((data_xpix - xticks(1))/mean(diff(xticks))*0.5);
    oli0_fig3_ccas = 10.^((yticks(end)-data_ypix)/mean(diff(yticks))*1);


    %% Validate data
    if validate_data
        keyboard

        % Re-create the plot!
        p_cca = polyfit(log10(o_fig3_brain_weights), log10(o_fig3_ccas), 1);
        figure; plot(log10(o_fig3_brain_weights), log10(o_fig3_ccas), 'o');
        hold on; plot(log10(o_fig3_brain_weights), p_cca(1)*log10(o_fig3_brain_weights)+ p_cca(2));
        set(gca, 'FontSize', 14, 'ylim', [0 3], 'ytick',1:3);
        xlabel('log(brain weight) (g)'); ylabel('log(cca) (mm^2)');

        % Add data from Nieto et al 1976
        n_tab1_species = {'man' 'horse' 'Dolphin' 'Zebra' 'Papio papio' 'Deer' 'Antelope' 'Rhesus monkey' 'Cat' 'Raccoon' 'Squirrel' 'Weasel' 'Rabbit' 'Rat'};
        n_tab1_ccas    = [991.36 200.80 180.48 160.64 150.40 70.88 60.48 35.0 31.3 29.7 13.12 11.04 8.64 3.84];
        n_tab1_brain_weights = [1085 385 832 213 74 90 81.5 61.5 16 43.5 3.5 3 5 1];
        plot(log10(n_tab1_brain_weights), log10(n_tab1_ccas), 'ro');
        plot(log10(n_tab1_brain_weights(3)), log10(n_tab1_ccas(3)), 'go');

        % Plot Nieto's original plot
        p_cca_n = polyfit(n_tab1_brain_weights(setdiff(1:end,3)), n_tab1_ccas(setdiff(1:end,3)), 1);
        figure; set(gcf, 'Position', [360   143   339   535]);
        plot(n_tab1_brain_weights(setdiff(1:end,3)), n_tab1_ccas(setdiff(1:end,3)), 'ro');
        hold on;
        plot(n_tab1_brain_weights, p_cca_n(1)*n_tab1_brain_weights+p_cca_n(2));

        % Recalc Olivares et al (2000) regression, but adding in Nieto's data (no
        % dolphin)
        p_cca_all = polyfit(log10([o_fig3_brain_weights' n_tab1_brain_weights(setdiff(1:end,3))]), ...
                            log10([o_fig3_ccas' n_tab1_ccas(setdiff(1:end,3))]), ...
                            1);
    end;


    %% Construct outputs
    varnames = who('oli0_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);

