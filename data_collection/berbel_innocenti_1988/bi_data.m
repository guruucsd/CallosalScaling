function vars = bi_data(validate_data)
%
% Extract cross-species neuron density from Tower (1954)
% images

    if ~exist('validate_data', 'var'), validate_data = true; end;
    if ~exist('visualize_data', 'var'), visualize_data = false; end;

    BI_dirpath = fileparts(which(mfilename));
    BI_dirname = guru_fileparts(BI_dirpath, 'name');
    BI_img_dirpath = fullfile(BI_dirpath, '..', 'img', BI_dirname);


    %% Fig 7
    img_file = fullfile(BI_img_dirpath, 'Fig7_marked.png');
    [tpixy,tpixx] = get_pixels_by_color(img_file, 'r');  % total fibers
    [cpixy,cpixx] = get_pixels_by_color(img_file, 'g');  % cca
    [dpixy,dpixx] = get_pixels_by_color(img_file, 'b');  % density
    [yticksy,yticksx] = get_pixels_by_color(img_file, 'y');   % 2 cols of them
    [~,xticks] = get_pixels_by_color(img_file, 'm'); xticks = sort(xticks);

    % separate yticks into groups
    yticks_tot = sort(yticksy(yticksx<max(yticksx)/2));
    yticks_cca = sort(setdiff(yticksy, yticks_tot));


    % Now convert into actual values
    bi_fig7_total_fibers = 0 + 20*(yticks_tot(end)-tpixy)/mean(diff(yticks_tot)); %tot fibers & cca correspondences
    bi_fig7_cca          = 0 +  5*(yticks_cca(end)-cpixy)/mean(diff(yticks_cca)); %   verified manually
    bi_fig7_density      = 0 + 20*(yticks_tot(end)-dpixy)/mean(diff(yticks_tot));
    bi_fig7_density      = [bi_fig7_density(1:2); nan(4,1); bi_fig7_density(3:end); nan(3,1)]; % make correspondences
    bi_fig7_date_names   = {'E53' 'E58' 'P0' 'P0' 'P0' 'P0' 'P4' 'P9' 'P15' 'P18' 'P21' 'P26' 'P39' 'P57' 'P92' 'P107' 'P150' 'adult' 'adult' 'adult'};
    bi_fig7_dates        = datefromtext(bi_fig7_date_names, 'cat');

    %% Fig 17
    img_file = fullfile(BI_img_dirpath, 'Fig17_marked.png');
    [mpixy,mpixx] = get_pixels_by_color(img_file, 'g');  % myelinated
    [yticksy,yticksx] = get_pixels_by_color(img_file, 'y');   % 2 cols of them
    [~,xticks] = get_pixels_by_color(img_file, 'm');
    xticks = sort(xticks);  xticks=xticks(2:end-1);

    % separate yticks into groups
    yticks_pctmy = sort(yticksy(yticksx>max(yticksx)/2));

    % Now convert into actual values
    bi_fig17_pctmy   = 0 + 20*(yticks_pctmy(end)-mpixy)/mean(diff(yticks_pctmy)); % % myelinated
    bi_fig17_dates1  = 0 + 20*(mpixx-xticks(1))/mean(diff(xticks));
    bi_fig17_date_names = {'P21' 'P26' 'P39' 'P57' 'P92' 'P107' 'P150' 'adult'};

    % Now add in data for zeros
    %added_dates = unique(bi_fig7_date_names(1:10));
    %bi_fig17_date_names = [added_dates bi_fig17_date_names];
    %bi_fig17_pctmy      = [zeros(length(added_dates),1); bi_fig17_pctmy];
    bi_fig17_dates   = datefromtext(bi_fig17_date_names, 'cat');



    %% Figure 9
    bi_fig9_date_names = {'E58' 'P4' 'P18', 'P26', 'P39', 'P92' 'P150'};
    bi_fig9_dates = datefromtext(bi_fig9_date_names, 'cat');

    bi_fig9_xbins = (1/20/2) + 0:(1/20):4;
    bi_fig9_xvals = bi_fig9_xbins;

    bi_fig9_unmyelinated = zeros(length(bi_fig9_dates),length(bi_fig9_xbins));
    bi_fig9_myelinated = zeros(size(bi_fig9_unmyelinated));

    % Collect the data
    for di=1:length(bi_fig9_dates)
        img_file = fullfile(BI_img_dirpath, sprintf('Fig9_%s_marked.png', bi_fig9_date_names{di}));
        [upixy,upixx] = get_pixels_by_color(img_file, 'r');  % unmyelinated
        [mpixy,mpixx] = get_pixels_by_color(img_file, 'g');  % myelinated
        [dbaseliney, dbaselinex] = get_pixels_by_color(img_file, 'b');
        [yticks] = sort(get_pixels_by_color(img_file, 'y'));
        [~,xticks] = get_pixels_by_color(img_file, 'm'); xticks = sort(xticks);

        binnum_raw = @(xpix) (1+20*(xpix-xticks(1)-mean(diff(xticks))/20/2)/mean(diff(xticks)));
        binnum = @(xpix) (round(binnum_raw(xpix)));
        invfn = @(xpix,ypix) (0 + 0.1*(dbaseliney(find(dbaselinex==xpix)) - ypix)/mean(diff(yticks)));

        %binnum_raw(upixx')
        % Recalc unmyelinated
        for pi=1:length(upixx),
            bn = binnum(upixx(pi));
            if bi_fig9_unmyelinated(di,bn), error('?'); end;
            bi_fig9_unmyelinated(di,bn) = invfn(upixx(pi), upixy(pi));
        end;
        for pi=1:length(mpixx)
            bn = binnum(mpixx(pi));
            if bi_fig9_myelinated(di,bn), error('?'); end;
            bi_fig9_myelinated(di,bn) = invfn(mpixx(pi), mpixy(pi));
        end;
    end;


    if validate_data
        sum(bi_fig9_unmyelinated,2)
        sum(bi_fig9_myelinated,2)
    end;


    %% Construct outputs
    varnames = who('bi_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);
