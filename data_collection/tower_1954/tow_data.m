function vars = tow_data(validate_data)
%
% Extract cross-species neuron density from Tower (1954)
% images

    if ~exist('validate_data', 'var'), validate_data = true; end;

    tow_dir = fileparts(which(mfilename));

    
    %% Collect data
    [~,pix,xticks,yticks] = parse_img_by_color(fullfile(tow_dir, 'img', 'Fig1_marked.png'), 'g');
    tow_fig1_brain_weight = 0.5*10.^(0+(pix{2} - xticks{2}(1))./mean(diff(xticks{2})));
    tow_fig1_neuron_dens  = 3E3*10.^(0+(yticks{1}(end) - pix{1})./mean(diff(yticks{1})));

    
    %% Reconstruct outputs
    varnames = who('tow_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);
    
    
    %% Do validation
    if validate_data
    end;