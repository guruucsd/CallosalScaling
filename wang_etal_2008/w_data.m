addpath(genpath('../_lib'));
w_dir = fileparts(which(mfilename));
w_datafile = fullfile(w_dir, 'w_data.mat');

human_brain_weight = 1300;

if exist(w_datafile,'file')
    load(w_datafile);
else
    %% Get species and brain weights, from supp materials
    w_species = {'least shrew' 'mouse' 'rat' 'marmoset' 'cat' 'macaque' 'orangutan' 'chimpanzee' 'harbor porpoise' 'gorilla' 'striped dolphin' 'human' 'bottlenose dolphin' 'humpback whale'};
    w_brain_weights = [0.14 0.4 1.6 nan 31 89 nan nan nan nan 936 1300 1824 7500]; %g
    w_brain_diameters = [0.6 0.9 1.4 2.4 3.8 5.5 8.6 8.9 9.7 9.7 12.0 14.5 14.9 22.7]; %cm


    % retrofit the weights
    plog = polyfit(log10(w_brain_diameters(~isnan(w_brain_weights)).^3), log10(w_brain_weights(~isnan(w_brain_weights))), 1);
%    plin = polyfit(w_brain_diameters(~isnan(w_brain_weights)).^3, w_brain_weights(~isnan(w_brain_weights)), 1); 
    est_brain_weights = 10.^(plog(1)*log10(w_brain_diameters.^3) + plog(2));
%    est_brain_weights = plin(1)*w_brain_diameters.^3 + plin(2);

    figure; 
    scatter(log(w_brain_diameters.^3), log(w_brain_weights)); 
    hold on; 
    plot(log(w_brain_diameters.^3), log(est_brain_weights)); 
    title('Measured vs. estimated, brain weights');
    axis square;
    
    %w_brain_weights, est_brain_weights
    w_brain_weights(isnan(w_brain_weights)) = est_brain_weights(isnan(w_brain_weights));

    
    
    %% Fig 1c: Get the progression of pct myelinated fibers!
    img_file = fullfile(w_dir,'img','Fig1c_marked.png');
    [mpixy,mpixx] = get_pixels_by_color(img_file, 'r');  % % myelinated
    [yticks] = get_pixels_by_color(img_file, 'y');   % 2 cols of them

    w_fig1c_species = {'least shrew' 'mouse' 'rat' 'marmoset' 'cat' 'macaque'};
    [~,species_idx] = ismember(w_fig1c_species, w_species);
    w_fig1c_weights = w_brain_weights(species_idx([1 1 2 2 2 3 4 4 5 6]));

    % Now convert into actual values
    w_fig1c_pctmye = 0 + 20*(yticks(end)-mpixy)/mean(diff(yticks)); %tot fibers & cca correspondences
    
    
    
    %% Fig. 4: Get the unmyelinated and myelinated axon distribution histograms!
    w_fig4_species = {'least shrew', 'mouse', 'rat', 'marmoset', 'cat', 'macaque'};
    for si=1:length(w_fig4_species)
        [um,m,xvals] = w_process_histogram(fullfile(fileparts(which(mfilename)), 'img', ['Fig4_' w_fig4_species{si} '.png']));
        w_fig4_unmyelinated(si,1:length(xvals)) = um;
        w_fig4_myelinated(si,1:length(xvals))   = m;
        w_fig4_xvals(1:length(xvals)) = xvals;
    end;
    w_fig4_myelinated_orig = w_fig4_myelinated;
    w_fig4_unmyelinated_orig = w_fig4_unmyelinated;
    w_fig4_brain_weights = w_brain_weights(ismember(w_species, w_fig4_species));
    
    
    %% Create diameter => weight mapping function (v1 now obsolete)
    %img = scrub_image(fullfile(fileparts(which(mfilename)), 'img', 'Fig1c_neutered.png'));
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
    img = scrub_image(fullfile(fileparts(which(mfilename)), 'img', 'Fig1c_xaxis.png'));
    
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
    img = scrub_image(fullfile(fileparts(which(mfilename)), 'img', 'Fig1e.png'));
    
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
    figure; imshow(data_pix)

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

    hold on;
    plot(gx,gy,'g*');    
    
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

    % Validate the y-value parsing and regression
    figure; hold on;
    plot(yticks(end:-1:1),[0.3 1 2 3 4 5 6],'o');
    plot(yticks(end:-1:1), gg(yticks(end:-1:1)));
    
    % Estimate, then discard
    %w_fig1e_brwt_est = [gw(diam_cm_data)];% 1300];
    w_fig1e_dens_est = [gg(gy)];% log10(3.8)];
    
    
    w_vars = who('w_*');
    save(w_datafile, w_vars{:});
end;
