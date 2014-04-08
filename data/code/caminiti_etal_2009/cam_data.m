function vars = cam_data(validate_data, visualize_data)
%

    if ~exist('validate_data', 'var'), validate_data = true; end;
    if ~exist('visualize_data', 'var'), visualize_data = false; end;

    CAM_dirpath = fileparts(which(mfilename));
    CAM_dirname = guru_fileparts(CAM_dirpath, 'name');
    CAM_img_dirpath = fullfile(CAM_dirpath, '..', '..', 'img', CAM_dirname);


    %% Collect data
    cam_species       = {'macaque' 'chimpanzee' 'human'};
    cam_vel_from_diam = @(diam) (5.5/0.7)*diam;
    cam_diam_from_vel = @(vel)  (0.7/5.5)*vel;

    cam_tabS2_regions = {'prefrontal'};% 'motor'};
    cam_tabS2_data = zeros(length(cam_species), length(cam_tabS2_regions), 3); % 3 subjects each
    cam_tabS2_data(1, 1, :) = [15674 14482 16866];  % macaque prefrontal
    cam_tabS2_data(2, 1, :) = 24943;                % chimp prefrontal
    cam_tabS2_data(3, 1, :) = 39637;                % human prefrontal
    cam_tabS2_factors = zeros(size(cam_species));   % brain size factor of macaque
    cam_tabS2_factors(1) = 1;                       % (by definition)
    cam_tabS2_factors(2) = mean(cam_tabS2_data(2, 1, :))/mean(cam_tabS2_data(1, 1, :));
    cam_tabS2_factors(3) = mean(cam_tabS2_data(3, 1, :))/mean(cam_tabS2_data(1, 1, :));


    %% parse Fig 2a-c
    cam_fig2_img    = {};%'Fig2a.png' 'Fig2b.png' 'Fig2c.png'};
    cam_fig2_colors = {'r' 'g' 'b'};

    data = cell(size(cam_fig2_img));
    for ii=1:length(cam_fig2_img)
        imfile = fullfile(CAM_img_dirpath, cam_fig2_img{ii});

        % Get xticks & yticks
        [bimg] = get_img_by_color(imfile, 'k', 0, 0.5);
        figure; imshow(bimg);
        [yaxis_x] = get_groups(sum(bimg(:,1:round(end/2)),  1)>0.75*size(bimg,1), 'center');
        [xaxis_y] = get_groups(sum(bimg(round(end/2):end,:),2)>0.75*size(bimg,2), 'center') + size(bimg,1)/2-2;
        xticks_x  = get_groups(bimg(round(xaxis_y+20),round(yaxis_x):end))+yaxis_x;
        yticks_y  = get_groups(bimg(1:round(xaxis_y),round(yaxis_x-20)));

        % Make sure we have the right #

        % Parse out the color info
        for ci=1:length(cam_fig2_colors)
            [cimg] = get_img_by_color(imfile, cam_fig2_colors{ci}, 0, 0.5);
            figure; imshow(cimg); hold on;
            plot(xticks_x, xaxis_y, 'w*');
            plot(yaxis_x, yticks_y, 'y*');

            xloc = get_groups(sum(cimg,1)>1); xloc = xloc(1:end-1); % remove key item
            yvals = sum(cimg(:,round(xloc)),1);

            plot(xloc,xaxis_y-yvals, [cam_fig2_colors{ci} '*']);
            plot(xloc,xaxis_y, [cam_fig2_colors{ci} '*']);

            data{ii}(ci,1:25) = zeros(1,5*5);
            data_idx = ceil((xloc-xticks_x(1))/mean(diff(xticks_x))/0.2);
            data{ii}(ci,data_idx) = 10*(yvals)/mean(diff(yticks_y));
            data{ii}(ci,:) = data{ii}(ci,:)/sum(data{ii}(ci,:));
        end;
    end;

    cam_fig2_data = data;


    %% Parse Fig S5
    cam_figS5_xvals   = 2:2:42;
    cam_figS5_diams   = cam_diam_from_vel(cam_figS5_xvals); % convert from velocity to diameter
    cam_figS5_regions = { 'prefrontal' 'motor' 'parietal' 'visual'};

    figS5_img     = { 'FigS5a.png' 'FigS5b.png' 'FigS5c.png' 'FigS5d.png'};
    figS5_colors  = {[hex2dec('04') hex2dec('05') hex2dec('7b')]/255 'm' 'y'};
    figS5_color_tol   = [0.2 0.45 0.45]; % for parsing
%    figS5_xtick_relpos= [5 2 5 5];
    fig5_ytick_spacing= [10 5 5 5];
    data = cell(size(cam_fig2_img));
    for ii=1:length(figS5_img)
        imfile = fullfile(CAM_img_dirpath, figS5_img{ii});

        % Get xticks & yticks
        [bimg] = get_img_by_color(imfile, 'k', 0, 0.2);
        %figure; imshow(bimg); hold on;
        [yaxis_x] = get_groups(sum(bimg(:,1:round(end/2)),  1)>0.5*size(bimg,1), 'center');
        yticks_y  = get_groups(bimg(:,round(yaxis_x-5)));
        xaxis_y   = yticks_y(end);
        xticks_x  = get_groups(sum(bimg(round(xaxis_y+[2:5]),round(yaxis_x):end),1))+yaxis_x;

        % Make sure we have the right #
        %plot(xticks_x,xaxis_y, ['bv']);
        guru_assert(length(xticks_x) == length(cam_figS5_xvals)+1, 'Missing xticks');

        % Parse out the color info
        for ci=1:length(figS5_colors)
            [cimg] = get_img_by_color(imfile, figS5_colors{ci}, 0, figS5_color_tol(ci));
            %figure; imshow(cimg); hold on;
            %plot(xticks_x, xaxis_y, 'w*');
            %plot(yaxis_x, yticks_y, 'y*');

            % get pixels BETWEEN xticks
            xloc = zeros(1,length(xticks_x)-1); yvals = zeros(size(xloc));
            for xi=2:length(xticks_x)
                xrange  = round(xticks_x(xi-1)+1):round(xticks_x(xi)-1);
                col_pix = cimg(1:round(xaxis_y),xrange);
                sum_col = sum(col_pix,2);

                g = get_groups(sum_col>7, 'center');
                xloc(xi-1) = mean(xrange);
                switch length(g)
                    case 0, yvals(xi-1) = 0;
                    case 1, yvals(xi-1) = xaxis_y-g(1);
                    otherwise,
                        [~,g_idx] = min(abs(g-get_groups(sum_col==max(sum_col))));
                        yvals(xi-1)=xaxis_y-g(g_idx);
                end;
            end;

            %plot(xloc,xaxis_y-yvals, ['gv'], 'MarkerSize', 10);

            data{ii}(ci,:) = fig5_ytick_spacing(ii)*(yvals)/mean(diff(yticks_y));
            data{ii}(ci,:) = data{ii}(ci,:)/sum(data{ii}(ci,:));
        end;


    end;
    cam_figS5_data = data;


    %% Validate data
    if validate_data
        % Now reconstruct figure S5
        figure('position', [149    -5   897   689]);
        for ri=1:length(figS5_img)
            subplot(2,2,ri); set(gca, 'FontSize',14);
            hold on;grid on;
            for si=1:3
                ph = plot(cam_figS5_xvals, cam_figS5_data{ri}(si,:), 'LineWidth', 2);
                set(ph, 'color', figS5_colors{si});
            end;
            set(gca, 'xlim', cam_figS5_xvals([1 end]));
            title(cam_figS5_regions{ri});

            if ri==1, legend(cam_species); end;
        end;


        % Now redo figure S5, but divide by the brain size factor
        figure('position', [149    -5   897   689]);
        for ri=1:length(figS5_img)
            subplot(2,2,ri); set(gca, 'FontSize',14);
            hold on;grid on;
            for si=1:3
                ss_xvals = cam_figS5_xvals/cam_tabS2_factors(si);
                mean_diam = ss_xvals*cam_figS5_data{ri}(si,:)';
                ph = plot(cam_figS5_xvals/cam_tabS2_factors(si), cam_tabS2_factors(si)*cam_figS5_data{ri}(si,:), 'LineWidth', 2);
                lh = plot(mean_diam*[1 1], [0 1], 'k--', 'LineWidth', 2);
                set(ph, 'color', figS5_colors{si});
                set(lh, 'color', figS5_colors{si})
            end;
            set(gca, 'xlim', cam_figS5_xvals([1 end]));
            title(cam_figS5_regions{ri});

            if ri==1, legend(cam_species); end;
        end;
    end;


    %% Construct outputs
    varnames = who('cam_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);
