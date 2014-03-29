function vars = tom_data(validate_data)
% Dataset:
%   Tomasch (1954)
%
% Data:
%   Human callosal axon diameter distribution
%
% Figures:
%   Fig 1: splenium, stained with Weigert stain.
%   Fig 2: splenium, stained with Haeggquiest's method
%
% Tables:
%   Table 1: surface area (fibers/mm^2)
%
% Notes:
%   NO CORRECTION FOR SHRINKAGE
%   Estimated (by in-paper reference) to be ~25% for both methods.

    if ~exist('validate_data', 'var'), validate_data = true; end;
    if ~exist('visualize_data', 'var'), visualize_data = false; end;

    TOM_dirpath = fileparts(which(mfilename));
    TOM_dirname = guru_fileparts(TOM_dirpath, 'name');
    TOM_img_dirpath = fullfile(TOM_dirpath, '..', '..', 'img', TOM_dirname);


    tom_tab1_surface_area = [ ...
        142 107 119.5 156 524.5
        130.6 135 109 142 516.6
        228 88 91 148 555 ...
    ];
    tom_tab1_density_weigert = [218873 216728 187698 224936 213136];
    % other data from tables


    %% Figure 1
    [data] = parse_img_by_color(fullfile(TOM_img_dirpath, 'fig1_marked.png'), 'g', @(x)(0+0.5*x), @(y)(0+10*y));
    tom_fig1_xbar_vals = round(data{2}'*2)/2;
    tom_fig1_hist_vals = data{1}';



    %% Figure 2: Create diameter => weight mapping function
    [img,orig_img] = scrub_image(fullfile(TOM_img_dirpath, 'fig2_processed.png'));

    %
    [~,idx] = max(sum(img,2)); % find xticks row
    xtp = get_groups(img(idx,:));
    xticks = xtp(3:end);
    tom_fig2_xbar_vals = 0.5:0.5:8;
    if length(xticks) ~= length(tom_fig2_xbar_vals), error('?'); end;

    yticks = get_groups(img(:,round(xtp(2)+10)));
    ytick_vals = 10:10:60;
    if length(yticks) ~= length(ytick_vals), error('?'); end;

    baseline_pix = round(yticks(end)+mean(diff(yticks))); % approx zero line
    hist_pix = zeros(1, length(xticks));
    for xi=1:length(xticks)
        % some hack
        if xi==2,  pval = get_groups(img(1:round(baseline_pix), round(xticks(xi)-6)));
        else,      pval = get_groups(img(1:round(baseline_pix), round(xticks(xi))));
        end;

        if isempty(pval), hist_pix(xi) = round(baseline_pix);
        elseif length(pval)==1, hist_pix(xi) = pval;
        elseif length(pval)==2, hist_pix(xi) = pval(1);
        elseif length(pval)==3, hist_pix(xi) = mean(pval(1:2)); %special hack case
        else, pval, xi
        end;
    end;

    tom_fig2_hist_vals = (baseline_pix - hist_pix)/mean(diff(yticks))*10;

    if visualize_data
        figure;
        imshow(img);
        hold on;
        plot(xticks, baseline_pix, 'r*');
        plot(xticks, hist_pix, 'g*')
    end;


    %% Validate data
    if validate_data
        fprintf('Validation NYI\n');%keyboard;
    end;


    %% Construct outputs
    varnames = who('tom_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);

