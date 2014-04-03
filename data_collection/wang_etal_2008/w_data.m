function vars = w_data(validate_data)
%
% Dataset:
%   Wang et al. (2008)
%
% Data:
%   Cross-species callosal data , including:
%   * Axon diameter distributions (myelinated & unmyelinated, axons/um^2)
%   * Mean axon density (um)
%   * Brain diameter (cm)
%   * Brain weights (g)
%
% Figures:
%   Fig 1c: % myelination
%   Fig 1c: brain diameter vs. weight
%   Fig 1e: callosal axon density (vs. brain diameter (and weight))
%   Fig 4: axon diamter distributions (myelinated & unmyelinated) for all 6 species
%
% Notes:
%   Shrinkage was estimated to be ZERO in the paper.

    if ~exist('validate_data', 'var'), validate_data = true; end;
    if ~exist('visualize_data', 'var'), visualize_data = false; end;

    % Capital indicates constant / local variable
    W_dirpath = fileparts(which(mfilename));
    W_dirname = guru_fileparts(W_dirpath, 'name');
    W_img_dirpath = fullfile(W_dirpath, '..', '..', 'img', W_dirname);


    %% Get species and brain weights, from supp materials
    w_species = {'least shrew' 'mouse' 'rat' 'marmoset' 'cat' 'macaque' 'orangutan' 'chimpanzee' 'harbor porpoise' 'gorilla' 'striped dolphin' 'human' 'bottlenose dolphin' 'humpback whale'};
    w_brain_weights = [0.14 0.4 1.6 nan 31 89 nan nan nan nan 936 1300 1824 7500]; %g
    w_brain_diameters = [0.6 0.9 1.4 2.4 3.8 5.5 8.6 8.9 9.7 9.7 12.0 14.5 14.9 22.7]; %cm

    plog = polyfit(log10(w_brain_diameters(~isnan(w_brain_weights)).^3), log10(w_brain_weights(~isnan(w_brain_weights))), 1);
%    plin = polyfit(w_brain_diameters(~isnan(w_brain_weights)).^3, w_brain_weights(~isnan(w_brain_weights)), 1);
    est_brain_weights = 10.^(plog(1)*log10(w_brain_diameters.^3) + plog(2));
%    est_brain_weights = plin(1)*w_brain_diameters.^3 + plin(2);

    % retrofit the weights
    if visualize_data
        figure;
        scatter(log(w_brain_diameters.^3), log(w_brain_weights));
        hold on;
        plot(log(w_brain_diameters.^3), log(est_brain_weights));
        title('Measured vs. estimated, brain weights');
        axis square;
    end;

    %w_brain_weights, est_brain_weights
    w_brain_weights(isnan(w_brain_weights)) = est_brain_weights(isnan(w_brain_weights));



    %% Fig 1c: Get the progression of pct myelinated fibers!
    img_file = fullfile(W_img_dirpath, 'Fig1c_marked.png');
    [mpixy,mpixx] = get_pixels_by_color(img_file, 'r');  % % myelinated
    [yticks] = get_pixels_by_color(img_file, 'y');   % 2 cols of them

    w_fig1c_species = {'least shrew' 'mouse' 'rat' 'marmoset' 'cat' 'macaque'};
    [~,species_idx] = ismember(w_fig1c_species, w_species);
    w_fig1c_weights = w_brain_weights(species_idx([1 1 2 2 2 3 4 4 5 6]));

    % Now convert into actual values
    w_fig1c_pctmye = 0 + 20*(yticks(end)-mpixy)/mean(diff(yticks)); %tot fibers & cca correspondences
    w_fig1c_pctmye = w_fig1c_pctmye';


    %% Fig. 4: Get the unmyelinated and myelinated axon distribution histograms!
    w_fig4_species = {'least shrew', 'mouse', 'rat', 'marmoset', 'cat', 'macaque'};
    for si=1:length(w_fig4_species)
        img_filepath = fullfile(W_img_dirpath, ['Fig4_' w_fig4_species{si} '.png']);
        [um,m,xvals] = w_process_histogram(img_filepath, visualize_data);
        w_fig4_unmyelinated(si,1:length(xvals)) = um;
        w_fig4_myelinated(si,1:length(xvals))   = m;
        w_fig4_xvals(1:length(xvals)) = xvals;
    end;
    %w_fig4_myelinated_orig = w_fig4_myelinated;
    %w_fig4_unmyelinated_orig = w_fig4_unmyelinated;
    w_fig4_brain_weights = w_brain_weights(ismember(w_species, w_fig4_species));


    %% Create diameter => weight mapping function (v1 now obsolete)
    %img = scrub_image(fullfile(W_img_dirpath, 'Fig1c_neutered.png'));
    %
    %% Find x axes
    %[gx,gxs] = get_groups(sum(img,2) > size(img,2)*0.5, 'right');
    %[gy,gys] = get_groups(sum(img,1) > size(img,1)*0.5, 'left');
    %
    % Get x ticks after that
    %xticks_diam = get_groups(img(gx(1)+1,:));
    %xticks_wt   = get_groups(img(gx(2)+1,:));
    %data_pix = img(1:floor(gx(1)-gxs(1)/2)-2, ceil(gy+gys/2)+1:end);


    %% Fig 1c: Create diameter => weight mapping function (v2 now obsolete)
    img = scrub_image(fullfile(W_img_dirpath, 'Fig1c_xaxis.png'));

    % Find x axes
    g = get_groups(sum(img,2) > size(img,2)*0.75);

    % Get x ticks after that
    xticks_diam = get_groups(img(round(g(1)+2),:));
    xticks_wt   = get_groups(img(round(g(2)+2),:));

    % Compute the diameter from the pix
    diam_cm = @(px) (2*(px-xticks_diam(1))/mean(diff(xticks_diam)));
    diam2wt_pts = diam_cm(xticks_wt); %these correspond to 1,10,100gm

    pw = polyfit(diam_cm(xticks_wt),log10([1 10 100]),1);
    gw = @(cm) (10.^(pw(2)+pw(1)*cm));

    wts = [1 10 100]; wts2 = min(wts):max(wts);
    p = polyfit(log10(wts), diam2wt_pts, 2);
    diam2wt = @(wt) (p(1)*log10(wt).^2 + p(2).*log10(wt) + p(3));
%
%     % Plot to show fitting function
%     figure;    hold on;
%     plot(log10(wts), diam2wt_pts, 'o');
%     plot(log10(wts2), diam2wt(wts2));
%
%
%
    %% Grab points from Fig 1e
    img = scrub_image(fullfile(W_img_dirpath, 'Fig1e.png'));

    % find x and y axes
    xaxis_first = find(sum(img,2)>0.5*size(img,2),1,'first');
    xaxis_last = find(sum(img,2)>0.5*size(img,2),1,'last');
    yaxis_first = find(sum(img,1)>0.5*size(img,1),1,'first');
    yaxis_last = find(sum(img,1)>0.5*size(img,1),1,'last');

    % find x and y ticks
    yticks = get_groups(img(1:xaxis_last,yaxis_first-2));
    xticks = get_groups(img(xaxis_last+2, yaxis_first:end));

    % Grab data pixels, and find boxes
    data_pix = img(1:xaxis_first-1, yaxis_last+1:end);

    [gx,gs] = get_groups(sum(data_pix,1)); % get groups of pix
    double_idx = find(round(gs/min(gs)) > 1); % split any overlapping (works for 2 only)
    for ii = double_idx
        gxn = zeros(1,length(gx)+1); gsn = zeros(size(gxn));
        gxn(1:ii-1) = gx(1:ii-1); gxn(ii+2:end) = gx(ii+1:end);
        gsn(1:ii-1) = gs(1:ii-1); gsn(ii+2:end) = gs(ii+1:end);

        gxn(ii) = gx(ii)-gs(ii)/4; gxn(ii+1) = gx(ii)+gs(ii)/4;
        gsn(ii) = gs(ii)/2; gsn(ii+1) = gs(ii)/2;
    end;
    gx = gxn; gs=gsn;

    gy = zeros(size(gx));
    for gi=1:length(gx)
        %[gx2,gs2]    = get_groups(sum(data_pix(:,round(gx(gi)+[-gs(gi):gs(gi)]/2)),2));
        %[~,gy(gi)] = max(sum(data_pix(:,round(gx(gi)+[-gs(gi)/2:gs(gi)/2])),2));
        gy2 = get_groups(sum(data_pix(:,round(gx(gi)+[-gs(gi)/2:gs(gi)/2])),2)>0.95*gs(gi));
        if length(gy2)~=3, error('?'); end;

        gy(gi) = gy2(2);
    end;

    if visualize_data
        figure;
        imshow(data_pix)
        hold on;
        plot(gx,gy,'g*');
    end;

    % Convert from pixels to data
    diam_cm_ticks = (xticks -xticks(1)) / mean(diff(xticks)); %0 :6 on linear scale
    diam_cm_fn = @(xp) ((xp-xticks(1))/mean(diff(xticks)));
    diam_cm_data = diam_cm_fn(gx);
    wt_g_data = diam2wt(diam_cm_data);

    % assume a log scale on y-axis, and find the pix=>density scale factor
    pg = polyfit(yticks(end:-1:1),log10([0.3 1 2 3 4 5 6]),1) ;
    gg = @(y) (10.^(pg(2)+pg(1)*y));

    % hardcoded species names & weights
    w_fig1e_species = {'least shrew' 'mouse' 'rat' 'marmoset' 'cat' 'macaque'};
    [~,species_idx] = ismember(w_fig1e_species, w_species);
    w_fig1e_weights = w_brain_weights(species_idx);
    w_fig1e_dens_est = [gg(gy)];% log10(3.8)];  % axons / um^2

    if visualize_data
        figure; hold on;
        plot(yticks(end:-1:1),[0.3 1 2 3 4 5 6],'o');
        plot(yticks(end:-1:1), gg(yticks(end:-1:1)));
    end;


    %% Validate the y-value parsing and regression
    if validate_data
        fprintf('Validation NYI');%keyboard
    end;


    %% Construct outputs
    varnames = who('w_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);
