tom_dir = fileparts(which(mfilename));
tom_hist_datafile = fullfile(tom_dir, 'tom_histograms.mat');

if exist(tom_hist_datafile, 'file')
    load(tom_hist_datafile);
    
else
    if ~exist('scrub_image','file'), addpath('../_lib'); end;

    
    %% Figure 1
    [data] = parse_img_by_color(fullfile(tom_dir, 'img','fig1_marked.png'), 'g', @(x)(0+0.5*x), @(y)(0+10*y));
    tom_fig1_xbar_vals = round(data{2}'*2)/2;
    tom_fig1_hist_vals = data{1}';
    
    
    
    %% Figure 2: Create diameter => weight mapping function
    [img,orig_img] = scrub_image(fullfile(tom_dir, 'img','fig2_processed.png'));
    
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
    tom_hist_pix = zeros(1, length(xticks));
    for xi=1:length(xticks)
        % some hack
        if xi==2,  pval = get_groups(img(1:round(baseline_pix), round(xticks(xi)-6)));  
        else,      pval = get_groups(img(1:round(baseline_pix), round(xticks(xi))));
        end;
          
        if length(pval) == 0, tom_hist_pix(xi) = round(baseline_pix);
        elseif length(pval)==1, tom_hist_pix(xi) = pval;
        elseif length(pval)==2, tom_hist_pix(xi) = pval(1);
        elseif length(pval)==3, tom_hist_pix(xi) = mean(pval(1:2)); %special hack case
        else, pval, xi
        end;    
    end;

    
    % Validate
    figure;
    imshow(img);
    hold on;
    plot(xticks, baseline_pix, 'r*');
    plot(xticks, tom_hist_pix, 'g*')

    tom_fig2_hist_vals = (baseline_pix - tom_hist_pix)/mean(diff(yticks))*10;
    
    % Save
    vars = who('tom_*');
    save(tom_hist_datafile, vars{:});
    
end;
