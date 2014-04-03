function vars = ha_data(validate_data)
%

    if ~exist('validate_data', 'var'), validate_data = true; end;
    if ~exist('visualize_data', 'var'), visualize_data = false; end;

    HA_dirpath = fileparts(which(mfilename));
    HA_dirname = guru_fileparts(HA_dirpath, 'name');
    HA_img_dirpath = fullfile(HA_dirpath, '..', 'img', HA_dirname);


    %% Collect data
    ha_tab2_brain_volume = [715 1345 2720 483 3650 4148 510 140 259 63.7 84 28.7 43 45 1300 433 429 184 88 64 36 106 101 57 22.4 18.9 9.4 25.8 7.4 1.9 3.0 11.2 1.7 0.3 3.9 3.7 1.4 0.24 42.5 7.8 1.2 11.0];

    %        [d,xticks,yticks] = parse_img_by_color(fullfile(HA_img_dirpath, 'Fig7_marked.png'), 'g', @(x) (x), @(y) (0+10*y))
    img_file = fullfile(HA_img_dirpath, 'Fig7_marked.png');


    [d,pix,xticks,yticks] = parse_img_by_color(fullfile(HA_img_dirpath, 'Fig7_marked.png'), {'g' 'r'}, @(x) (nan(size(x))), @(y) (0+10*y));
    dc   = {vertcat(d{:,1})   vertcat(d{:,2})};
    pixc = {vertcat(pix{:,1}) vertcat(pix{:,2})};

    % X-axis is on log scale; convert data back to linear
    dc{2}  = 10.^((pixc{2} - xticks{2}(1))./mean(diff(xticks{2}(1:2:end))));
    d{2,2} = 10.^((pix{2,2} - xticks{2}(1))./mean(diff(xticks{2}(1:2:end))));

    ha_fig7_brain_volume = dc{2};
    ha_fig7_neuron_density = dc{1}*1E3;

    % regression: log-linear
    [ha_fig7_regress_p,r] = polyfit(log10(ha_fig7_brain_volume), ha_fig7_neuron_density, 1);
    ha_fig7_regress_fn = @(v) polyval(ha_fig7_regress_p,log10(v));


    %% Validate data
    if validate_data
        % reproduce fig7
        figure;
        semilogx(ha_fig7_brain_volume, ha_fig7_neuron_density, 'o');
        hold on;
        xvals = linspace(min(ha_fig7_brain_volume), max(ha_fig7_brain_volume), 100);
        semilogx(xvals, ha_fig7_regress_fn(xvals));
        title('Haug (1987), Fig. 7');
        xlabel('Brain volume (cm^3)'); ylabel('Neural density (#/mm^3)');

        vars  = who('ha_*');
        save(ha_datafile, vars{:});
    end;


    %% Construct outputs
    varnames = who('ha_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);
