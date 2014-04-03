function [vals, xbar_vals] = process_ab_histogram(img_file, xtick_vals, ytick_vals, rotang, showfig)
% Process Fig. 4 histograms from Aboitiz et al, 1992a

    % Set defaults
    if ~exist('rotang','var'), rotang = 0; end;
    if ~exist('showfig','var'), showfig = true; end;

    % Read image
    orig_img = rgb2gray(imread(img_file));
    img = orig_img;

    % binarize and invert the image
    thresh = 170;
    img(img>=thresh) = 255; img(img<thresh) = 0;
    img(img>0)=1; img=~img;

    % rotate image. do this after inverting, so that added pixels don't
    % interfere.
    if rotang ~= 0, img = imrotate(img, rotang); end;
    pixfact = size(orig_img,1)/187; % our hacky constants were computed with an image height of 187; to be flexible, multiply them by a reasonable scale factor.


    % Blank out text
    img(1:floor(size(img,1)/2), ceil(size(img,2)/2):end) = 0;

    % x and y axes must be at least 1/2 as long as the images
    %  Find them, then blank out any axis text
    [yaxis_idx] = find(sum(img,1)>size(img,1)/2, 1, 'first');
    [xaxis_idx] = find(sum(img,2)>size(img,2)/2, 1, 'last');

    img(:,1:yaxis_idx-floor(4*pixfact)) = 0;
    img(xaxis_idx+floor(4*pixfact):end,:) = 0;


    % to the right of the yaxis are the yticks
    ytick_pix = max(0,sum(img(:,yaxis_idx+[6:10]),2)-floor(1*pixfact));
    yticks = get_groups(ytick_pix, 'center', length(ytick_vals));

    % below the xaxis are the xticks
    % Should find 26 ticks (27 including 0)
    xtick_pix = max(0,sum(img(xaxis_idx+1:end,:),1)-floor(2*pixfact));
    xticks = get_groups(xtick_pix, 'center', length(xtick_vals));

    % Now get x and y values
    if showfig
        figure;
        set(gcf, 'Position', [144         103        1029         581]);

        subplot(2,2,1); hold on;
        title('Original image');
        imshow(orig_img);

        subplot(2,2,2); hold on;
        title('Parsed image');
        imshow(img);
        plot(yaxis_idx+[1:10], ones(10,1)*yticks, 'r')
        plot(ones(10,1)*xticks, xaxis_idx+[1:10], 'r')
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
                process_lr_image(img_file, xtick_vals, ytick_vals, rotang, true);
            else
                error(sprintf('yticks must be %d (it is %d); unable to recover.', length(ytick_vals), length(yticks)));
            end;
        else
            error(sprintf('yticks must be %d (it is %d); didn''t try to recover.', length(ytick_vals), length(yticks)));
        end;
    end;
    if length(xticks) ~= length(xtick_vals)
        if ~showfig
            process_lr_image(img_file, xtick_vals, ytick_vals, rotang, true);
        else
            warning(sprintf('xticks must be %d (it is %d)', length(xtick_vals), length(xticks)));
            %keyboard
        end;
    end;


    % Above the xaxis are the bars themselves.
    % Bars can lie anywhere, so just find them!

    bins = 0.2:0.2:9;
    pixel_vals = zeros(1,length(bins));
    for ti=1:length(bins)
      % Find the bar locations
      bar_pix = img(1:xaxis_idx,yaxis_idx+5:round(xticks(end)));
%      bar_pix = img(xaxis_idx-[6], yaxis_idx+5:round(xticks(end)));

      % Clean top of image
      bar_start = 1;
      state = 0;
      while (true)
          [~,gs] = get_groups(bar_pix(bar_start,:));
          if state==0
              if max(gs)>100, state=1; end;
          elseif state==1
              if sum(bar_pix(bar_start,:))<100, break; end;
          end;
          if bar_start==size(bar_pix,1), error('?'); end;
          bar_start = bar_start+1;
      end;

      % clean bottom of image
      bar_end = size(bar_pix,1);
      while (true)
          [~,gs] = get_groups(bar_pix(bar_end,:));
          if max(gs)<25, break; end;
          if bar_end==bar_start, error('?'); end;
          bar_end = bar_end - 1;
      end;
      bar_pix = bar_pix(bar_start:bar_end,:);

      if showfig
          subplot(2,2,4);
          imshow(bar_pix);
      end;

      g= get_groups(bar_pix(end,:));
      dg = diff(g);
      [c] = hist(dg); ngood = max(c);
      sorted_binspacing = sort(dg);
      binspacing_pix = mean(sorted_binspacing(1:ngood));
      g_bins = [1 (1+floor(round(cumsum(diff(g))/binspacing_pix)))];

      if showfig
          hold on;
          plot(g,size(bar_pix,1)-5,'r*')
      end;

      % get the bar heights
      bar_heights = (sum(bar_pix(:,round(g)),1) + sum(bar_pix(:,round(g)-1),1) + sum(bar_pix(:,round(g)+1),1))/3;
      pixel_vals(g_bins) = bar_heights;
    end;

    % Estimate the values
    scalefactor = mean(diff(ytick_vals))/mean(diff(yticks));
    offset = ytick_vals(1);
    vals = offset+scalefactor.*pixel_vals;

    if showfig
        subplot(2,2,3); hold on;
        title('Parsed data');
        bar(bins, vals, 0.5);
        set(gca, 'xlim', [0 bins(end)], 'ylim', ytick_vals([1 end]), 'ytick', ytick_vals);
    end;
