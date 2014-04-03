function vars = tow_data(validate_data)
%
% Dataset:
%   Tower (1954)
%
% Data:
%   Cross-species grey matter neuron density (neurons / mm^3)
%
% Figures:
%   Fig 1: brain weight vs. grey matter neuron density

    if ~exist('validate_data', 'var'), validate_data = true; end;
    if ~exist('visualize_data', 'var'), visualize_data = false; end;

    % Mark directories as internal variables
    TOW_dirpath = fileparts(which(mfilename));
    TOW_dirname = guru_fileparts(TOW_dirpath, 'name');
    TOW_img_dirpath = fullfile(TOW_dirpath, '..', '..', 'img', TOW_dirname);

    %% Collect data
    [~,pix,xticks,yticks] = parse_img_by_color(fullfile(TOW_img_dirpath, 'Fig1_marked.png'), 'g');
    tow_fig1_brain_weight = 0.5*10.^(0+(pix{2} - xticks{2}(1))./mean(diff(xticks{2})))';
    tow_fig1_neuron_dens  = 3E3*10.^(0+(yticks{1}(end) - pix{1})./mean(diff(yticks{1})))';


    %% Do validation
    if validate_data
        fprintf('Validation NYI\n');
        %keyboard
    end;


    %% Construct outputs
    varnames = who('tow_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);

