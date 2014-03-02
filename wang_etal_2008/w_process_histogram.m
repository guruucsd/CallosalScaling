function [c1,c2,xvals] = w_process_histogram(img_file, show_fig)
%
%
    if ~exist('img_file','var'), img_file = fullfile(fileparts(which(mfilename)), 'img', 'Fig4_Mouse.png'); end;
    if ~exist('show_fig','var'), show_fig = true; end;
    
    % Load the image
    img = scrub_image(img_file);

    % Find the x and y axes.  ticks are "outside" of them, data inside.
    [yaxis_idx, yaxis_width] = get_groups( sum(img,1)>0.95*max(sum(img,1)), 'right' );
    [xaxis_idx, xaxis_width] = get_groups( sum(img,2)>0.95*max(sum(img,2)), 'left' );

    % grab pixels that only contain data
    data_pix = img(1:floor(xaxis_idx-xaxis_width/2),ceil(yaxis_idx+yaxis_width/2):end);
    pix_bottom = (size(data_pix,1)+1);
    
    
    % Follow the two curves (myelinated, unmyelinated) in pixel space.  
    % Assumptions:
    %   c1 is the first curve
    %   c1 ends before c2 ends
    %   c2 starts before c2 ends
    %   There is only ONE crossing point
    %
    
    % Data variables
    c1 = pix_bottom*ones(size(data_pix,2),1);
    c2 = pix_bottom*ones(size(data_pix,2),1);

    % Tracking variables
    c1_started = false; c2_started = false; cross_point = nan; crossed = false;
    for xi=1:size(data_pix,2)
        [a,b] = get_groups(data_pix(:,xi)); % the two curves
        
        % Since we look in the past to make decisions, just get past the
        % past that we need; assume anything there is c1
        if xi<2
            if length(a)==1, c1(xi) = a; end;
            continue;
        end;
        
        % We only can deal with 2 curves at a time.  Anything else is
        % unexpected
        if length(a)>2,
            figure; subplot(2,1,1); imshow(data_pix); hold on; plot(xi, a, 'r*'); subplot(2,1,2); plot(-c1(1:xi)); hold on; plot(-c2(1:xi), 'r');
            error('?');
            
        % Nothing to do
        elseif isempty(a), continue;
            
        % Got 2 curves.  Could be that:
        % * curves just crossed.  Then assume c2 is larger, and need to do
        %    some interpolation to have the past look smooth..
        % * they've been nicely split; just associate the values with
        %    whatever is closest to what the curve was last time.
        elseif length(a)==2
            c2_started = true;
            
            if ~isnan(cross_point) && ~crossed % we stopped updating; now interpolate (linear)
                c1(xi) = a(2); c2(xi) = a(1);
                c1(cross_point-1:xi) = linspace(c1(cross_point-1), c1(xi), xi-cross_point+2);
                c2(cross_point-1:xi) = linspace(c2(cross_point-1), c2(xi), xi-cross_point+2);

                %figure; subplot(2,1,1); imshow(data_pix); hold on; plot(xi, a, 'r*'); subplot(2,1,2); plot(-c1(1:xi)); hold on; plot(-c2(1:xi), 'r');
                %keyboard
                crossed = true;
            else  % emerging out of a crossing point
                [~,c1idx] = min(abs(a-c1(xi-1)));
                [~,c2idx] = min(abs(a-c2(xi-1)));

                if c1idx == c2idx, error('?'); end;

                c1(xi) = a(c1idx);
                c2(xi) = a(c2idx);

                %figure; subplot(2,1,1); imshow(data_pix); hold on;
                %plot(xi, a, 'r*'); subplot(2,1,2); plot(-c1(1:xi)); hold on; plot(-c2(1:xi), 'r');
                %keyboard

            end;
            
        % Only one curve.  A few cases:
        %  * Only c1 (c2 didn't start)
        %  * Only c2 (c1 ended)
        %  * Some noise (c2 got too small); error correct!
        %  * They're crossing (do nothing; will interpolate the curves
        %    later)
        else % length(a)==1
            
            % These 2: only curve 1 (c2 didn't start)
            if ~c1_started, c1(xi) = a; c1_started = true; %started for first time
            elseif ~c2_started, c1(xi) = a;
            elseif c1(xi-1)<pix_bottom && c2(xi-1)==pix_bottom, c1(xi)=a;
                
            % only c2 (c1 ended)
            elseif c2(xi-1)<pix_bottom && c1(xi-1)==pix_bottom, c2(xi)=a;
                
            % could be noise, could be crossing
            elseif c2(xi-1)<pix_bottom && c2(xi-1)<pix_bottom
                dc1 = a-c1(xi-1); dc2 = a-c2(xi-1);
                
                % doesn't cross noise threshhold and haven't crossed... so
                %   let's assume they're crossing
                if abs(dc1)<10 && abs(dc2)<10 && ~crossed% error correction
                    cross_point = xi;
                    
                % Looks like noise.  Assign the curve to whichever was
                % closest on the last step!
                else
                    if abs(dc1) < abs(dc2), c1(xi) = a;
                    else,                   c2(xi) = a; % includes equal case, where we will assume that c1 ended
                    end;
                end;
            end;
        end;
    end;
    
    % Error tolerance 
    if any(diff(c1))>10, error('c1 error?'); end;
    if any(diff(c2))>10, error('c2 error?'); end;

    
    % Now convert from pixel space to data space
    yticks = get_groups(img(1:ceil(xaxis_idx+xaxis_width/2),round(yaxis_idx-yaxis_width-4)));
    xticks = floor(yaxis_idx-yaxis_width/2) + get_groups(img(round(xaxis_idx+xaxis_width+2),floor(yaxis_idx-yaxis_width/2):end));
    
    xvals = 0.5*[1:length(c1)]/mean(diff(xticks)); 
    c1    = 0.05*(pix_bottom-c1)/mean(diff(yticks));
    c2    = 0.05*(pix_bottom-c2)/mean(diff(yticks));

    % Normalize the histograms
    c1 = c1/sum(c1+c2)/.05;
    c2 = c2/sum(c1+c2)/.05;

    % Now choose just a subset of the measured values
    idx = 1:floor(0.05/mean(diff(xvals))):length(xvals);
    c1 = c1(idx);
    c2 = c2(idx);
    xvals = xvals(idx);
    
    % Show the result
    if show_fig
        figure; 
        subplot(2,1,1); 
        imshow(img); hold on;
        title('Original histogram');
        
        subplot(2,1,2); 
        plot(xvals, c1, 'b'); hold on; 
        plot(xvals, c2, 'r');
        title('Parsed data');
    end;

    