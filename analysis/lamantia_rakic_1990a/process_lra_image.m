function [vals, xbar_vals] = process_lr_image(img_file, xbar_vals, ytick_vals, rotang, showfig)

    % Set defaults
    if ~exist('rotang','var'), rotang = 0; end;
    if ~exist('showfig','var'), showfig = false; end;
    
    % Read image
    [img,orig_img] = scrub_image(img_file, rotang);
    pixfact = size(orig_img,1)/187; % our hacky constants were computed with an image height of 187; to be flexible, multiply them by a reasonable scale factor.
    

    % Blank out text
    img(1:floor(size(img,1)/2), ceil(size(img,2)/2):end) = 0;
    
    % x and y axes must be at least 1/2 as long as the images
    %  Find them, then blank out any axis text
    [yaxis_idx] = find(sum(img,1)>size(img,1)/2);
    [xaxis_idx] = find(sum(img,2)>size(img,2)/2);
    
    img(:,1:yaxis_idx(1)-floor(4*pixfact)) = 0;
    img(xaxis_idx(end)+floor(4*pixfact):end,:) = 0;
    
    
    % to the left of the yaxis are the yticks
    % Should find 7 ticks (8 including 0)
    ytick_pix = max(0,sum(img(:,1:yaxis_idx(1)-1),2)-floor(1*pixfact));
    yticks = get_groups(ytick_pix, 'left', length(ytick_vals));
    
    % below the xaxis are the xticks
    % Should find 26 ticks (27 including 0)
    xtick_pix = max(0,sum(img(xaxis_idx(end)+1:end,:),1)-floor(1*pixfact));
    xticks = get_groups(xtick_pix, 'right', length(xbar_vals)+1);

    % Now get x and y values
    if showfig
        figure;
        set(gcf, 'Position', [ 38         381        1004         303]);

        subplot(1,3,1); hold on;
        title('Original image');
        imshow(orig_img);

        subplot(1,3,2); hold on;
        title('Parsed image');
        imshow(img);
        plot(yaxis_idx(1)-[1:10], ones(10,1)*yticks, 'r')    
        plot(ones(10,1)*xticks, xaxis_idx(end)+[1:10], 'r')    
    end;
    
    if length(yticks) ~= length(ytick_vals)
        if length(yticks)>length(ytick_vals)
            % Find distribution of ticks, locate the max
            dyticks = diff(yticks);
            [cy,by]=hist(dyticks);
            cyidx = find(cy==max(cy),1, 'last'); % find the max count

            % Try to reconstruct neighbors
            yticks_recovered = zeros(size(ytick_vals));
            yticks_recovered(1) = yticks(1);
            cur_tick_oldi = 1;
            cur_tick_newi = 2;
            for yi=2:length(yticks)
                dytick = yticks(yi)-yticks(cur_tick_oldi);
                if find(hist(dytick, by)) < cyidx
                    continue;
                else
                    yticks_recovered(cur_tick_newi) = yticks(yi);
                    cur_tick_newi = cur_tick_newi + 1;
                    cur_tick_oldi = yi;
                end;
            end;

            if length(yticks_recovered) == length(ytick_vals)
                warning(sprintf('yticks must be %d (it is %d); able to recover.', length(ytick_vals), length(yticks)));
                yticks = yticks_recovered;
            elseif ~showfig
                process_lr_image(img_file, xbar_vals, ytick_vals, rotang, true);
            else
                error(sprintf('yticks must be %d (it is %d); unable to recover.', length(ytick_vals), length(yticks)));
            end;
        else
            error(sprintf('yticks must be %d (it is %d); didn''t try to recover.', length(ytick_vals), length(yticks)));
        end;
    end;
    if length(xticks) ~= length(xbar_vals)+1
        if ~showfig
            process_lr_image(img_file, xbar_vals, ytick_vals, rotang, true);
        else
            warning(sprintf('xticks must be %d (it is %d)', length(xbar_vals)+1, length(xticks)));
            keyboard
        end;
    end;
   
     
    % Above the xaxis are the bars themselves.
    % Bars should lie between ticks.  Let's iterate over ticks, and look for bars between.
    % If we see a bar, let's grab the height.
    pixel_vals = zeros(length(xticks)-1,1);
    for ti=2:length(xticks)
      bar_pix = img(1:xaxis_idx(1)-1, floor(xticks(ti-1)+1):ceil(xticks(ti)-1));
      pix_vert = sum(bar_pix,1);
      [bar_borders,bar_widths] = get_groups((pix_vert-0.75*max(pix_vert))>0);
      
      % No bar there!
      if isempty(bar_borders), continue; 
      elseif length(bar_borders)==1, bar_borders = [bar_borders-bar_widths/2 bar_borders+bar_widths/2]; end;

      pix_horz = sum(bar_pix(:,ceil(bar_borders(1)):floor(bar_borders(2))), 2);
      bar_extremes = get_groups((pix_horz-0.75*max(pix_horz))>0);
      if length(bar_extremes)==1, pixel_vals(ti-1) = yticks(end)-bar_extremes;
      elseif length(bar_extremes)==2, pixel_vals(ti-1) = diff(bar_extremes);
      else, error('?'); end;
    end;

    % Estimate the values
    scalefactor = mean(diff(ytick_vals))/mean(diff(yticks));
    offset = ytick_vals(1);
    vals = offset+scalefactor.*pixel_vals;
        
    if showfig
        subplot(1,3,3); hold on;
        title('Parsed data');
        bar(xbar_vals, vals(1:length(xbar_vals)));
        set(gca, 'xlim', xbar_vals([1 end]), 'ylim', ytick_vals([1 end]), 'xtick', [0.2:0.2:1], 'ytick', ytick_vals);
    end;
    