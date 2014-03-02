function [vals, xbar_vals] = lrb_process_image(img_file, xbar_vals, ytick_vals, rotang, showfig)

    % Set defaults
    if ~exist('rotang','var'), rotang = 0; end;
    if ~exist('showfig','var'), showfig = false; end;
    
    % Read image
    [~,oimgnm] = fileparts(img_file);
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
    

    % Blank out text...
    % with a $HACK
    bly = [1 floor(size(img,1)*.4)]; blx = [ceil(size(img,2)*.45) size(img,2)];
    nl = 0;
    while nl<5
      [gr,grsz] = get_groups(sum(img(bly(1):bly(2),blx(1):blx(2)),2), 'right');
      if isempty(gr), break;
      elseif gr(1)==diff(bly), break;
      else, img(floor(gr(1)-grsz(1)):ceil(gr(1)), blx(1):blx(end)) = 0;
      end;
      nl = nl + 1;
    end;
    img(bly(1):bly(2),blx(2)-[round(diff(blx)/2):-1:0]) = 0;
    %if any(sum(img(bly(1):bly(2),blx(1):blx(2)),2)), 
    %    figure; imshow(img(bly(1):bly(2),blx(1):blx(2)))     ;
    %    keyboard;
    %end;
    
    % x and y axes must be at least 1/2 as long as the images
    %  Find them, then blank out any axis text
    [ya,yb] = get_groups(sum(img,1)>size(img,1)/1.5, 'left'); yaxis_idx = ya(1)+[0:(yb(1)-1)];
    [xa,xb] = get_groups(sum(img,2)>size(img,2)/1.5, 'left'); xaxis_idx = xa(1)+[0:(xb(1)-1)];
    
    if isempty(yaxis_idx), keyboard; end;
    if isempty(xaxis_idx), keyboard; end;
    
    img(:,1:yaxis_idx(1)-floor(4*pixfact)) = 0;
    img(xaxis_idx(end)+floor(4*pixfact):end,:) = 0;
    
    
    % to the left of the yaxis are the yticks
    % Should find 7 ticks (8 including 0)
    ytick_pix = max(0,sum(img(:,1:yaxis_idx(1)-1),2)-floor(1.5*pixfact)); %outer/left
    yticks = get_groups(ytick_pix, 'center', length(ytick_vals)); 
    
    % below the xaxis are the xticks
    % Should find 26 ticks (27 including 0)
    xtick_pix = max(0,sum(img(xaxis_idx(end)+1:end,:),1)-floor(1.5*pixfact)); %outer/below
    xticks = get_groups(xtick_pix, 'center', length(xbar_vals)+1);

    % Now get x and y values
    if showfig
        f = figure;
        set(gcf, 'Position', [ 38         447        1243         237]);

        subplot(1,3,1); hold on;
        title(sprintf('Original image: %s', strrep(oimgnm, '_', '\_')));
        imshow(orig_img);

        subplot(1,3,2); hold on;
        title('Parsed image');
        imshow(img);
        plot(yaxis_idx(1)-[1:10], ones(10,1)*yticks, 'r')    
        plot(ones(10,1)*xticks, xaxis_idx(end)+[1:10], 'r')    
        plot(yaxis_idx(end), 1:size(img,2), 'g');
        plot(1:size(img,1), xaxis_idx(1), 'g');
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
    %if strcmp(oimgnm, 'Fig7b'), keyboard; end;
    
    pixel_vals = zeros(length(xticks)-1,1);
    for ti=2:length(xticks)
      bar_pix = img(1:xaxis_idx(1), floor(xticks(ti-1)+2):ceil(xticks(ti)-2));
      pix_sum_vn = sum(bar_pix,1)./max(sum(bar_pix,1)); pix_sum_h = sum(bar_pix,2);
%      pix_sum_vn<0.02;
      
      transitions = sum(abs(diff(bar_pix,[],2)),2); transitions = transitions+mod(transitions,2);
      [bars,bar_sz] = get_groups((pix_sum_h>=size(bar_pix,2)*.40 & transitions<4) | pix_sum_h>=size(bar_pix,2)*.70);
      if isempty(bars), pixel_vals(ti-1) = 0;
      elseif length(bars)==1, pixel_vals(ti-1) = max(0,xaxis_idx(1) - bars(1) - 1);
      elseif length(bars)==2, pixel_vals(ti-1) = bars(end)-bars(1)+1; %diff(bars);
      else,                   pixel_vals(ti-1) = bars(end)-bars(1)+1;
      end;
      %if ti>7 && ti<=22 && pixel_vals(ti-2)/max(pixel_vals)>0.1 && ~pixel_vals(ti-1), keyboard; end;
      %if pixel_vals(ti-1) ==0 &&  strcmp(oimgnm, 'Fig7b'), keyboard; end;
          %figure; imshow(bar_pix(bars(1):bars(end)+1,:)); hold on; for ii=1:length(bars), plot(plot(1:10, bars(ii)-bars(1)+1,'g')); end;
          %bakeyboard; 
%      end;
      %max(0, max(bars)-2);
    end;

    % Estimate the values
    scalefactor = mean(diff(ytick_vals))/mean(diff(yticks));
    offset = ytick_vals(1);
    vals = offset+scalefactor.*pixel_vals;
    
    % Preliminary plot, for debugging
    if showfig
        figure(f);
        subplot(1,3,3); hold on;
        title('Parsed data');
        bar(xbar_vals, vals(1:length(xbar_vals)), 0.75, 'b');
        set(gca, 'xlim', xbar_vals([1 end]), 'ylim', ytick_vals([1 end]), 'xtick', [0.2:0.2:1], 'ytick', ytick_vals);
    end;
    
    % clean back-end
    if vals(end) ~= 0,
        if all(abs(diff(vals(end-2:end)))./max(vals)<7E-3), vals = vals-vals(end);
        elseif vals(end)/max(vals)<7E-3, vals = vals-vals(end);
        else, ;%keyboard; 
        end;
    end;
    vals(vals<0) = 0;
    
    % clean front-end
    if vals(1)   ~= 0 
        if vals(1)/max(vals)<7E-3, vals = vals-vals(1); 
        elseif vals(1)/max(vals)>1E-2, vals(1) = 0;
        elseif vals(1)/max(vals)>1.5 && vals(2)<vals(1)
            keyboard; vals = vals-vals(2); vals(1)=0;
        else,  keyboard; 
        end;
    end;
    vals(vals<0) = 0;
    
    %if max(vals)==vals(1) || max(vals)==vals(end), keyboard; end;
    if showfig
        figure(f);
        subplot(1,3,3); hold on;
        title('Parsed data');
        bar(xbar_vals, vals(1:length(xbar_vals)), 0.75, 'b');
        set(gca, 'xlim', xbar_vals([1 end]), 'ylim', ytick_vals([1 end]), 'xtick', [0.2:0.2:1], 'ytick', ytick_vals);
    end;
    