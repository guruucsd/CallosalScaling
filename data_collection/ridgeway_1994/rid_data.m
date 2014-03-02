rid_path = fileparts(which(mfilename));
data_file = fullfile(rid_path, 'ridt_data.mat');

consistency_check = false;

if ~exist(data_file, 'file')
    %% Fig 2
    [data_ypix,data_xpix] = get_pixels_by_color('img/Fig2_reddot.png', 'r', -0.05);
    [img] = scrub_image('img/Fig2.png', -0.05);

    % reorder in xy
    [data_xpix,idx1] = sort(data_xpix); data_ypix = data_ypix(idx1);

    % Get the (b&w) axes
    [yaxis_idx,yaxis_width]=get_groups(sum(img,1)>0.5*size(img,1));
    [xaxis_idx,xaxis_width]=get_groups(sum(img,2)>0.5*size(img,2));

    figure;
    imshow(img); hold on;

    % Grab the ticks
    xticks     = get_groups(img(floor(xaxis_idx-xaxis_width/2)-2,:)); xticks = xticks(3:end);
    yticks = get_groups(img(:,floor(yaxis_idx+yaxis_width/2)+2,:)); %yticks = yticks([1:3 5])

    figure;
    imshow(img); hold on;
    plot(yaxis_idx(1), yticks, 'r*');
    plot(xticks, xaxis_idx, 'b*');


    % Convert the datapoints from pixels to data(x,y) values
    rid_fig2_brain_weights = 10.^(2.6+(data_xpix - xticks(1))/mean(diff(xticks))*0.2); % average over cca and wmv; should have same xval!
    rid_fig2_ccas = 10.^(2+(yticks(end)-data_ypix)/mean(diff(yticks))*0.1);

    vars = who('rid_*');
    save(data_file, vars{:});
end;
    

if consistency_check
    % Re-create the plot!
    p_cca = polyfit(log10(rid_fig2_brain_weights), log10(rid_fig2_ccas), 1);
    figure; set(gcf, 'Position', [49         290        1194         394]);
    subplot(1,2,1);
    imshow(~img); hold on;
    plot(data_xpix, data_ypix, 'g*');

    subplot(1,2,2);
    plot(log10(rid_fig2_brain_weights), log10(rid_fig2_ccas), 'o');
    hold on; plot(log10([0.1; rid_fig2_brain_weights]), p_cca(1)*log10([0.1; rid_fig2_brain_weights])+ p_cca(2));

    set(gca, 'FontSize', 14, 'xlim', [2.6 4], 'ylim', [2 3]);
    xlabel('log(brain weight) (g)'); ylabel('log(cca) (mm^2)');
    title(sprintf('Regressions: %4.2fX + %4.2f', p_cca));
end;
