function vars = ry_data(validate_data)
%
% Dataset:
%   Rakic & Yaklovev (1968)
%
% Data:
%   Human (infant) callosal cross-sectional area
%
% Tables:
%   Table 1: specimen age
%   Table 2: callosal mid-sagittal cross-sectional area (mm^2)
%
% Notes:
%   NO CORRECTION FOR SHRINKAGE

    if ~exist('validate_data', 'var'), validate_data = true; end;
    if ~exist('visualize_data', 'var'), visualize_data = false; end;

    ry_ages = [[20 24 28 32 36 40]*7 12*30 40*365];
    ry_areas = [22.6 37.0 52.0 51.8 55.6 67.2 147.9 325.1]; % (correct by /0.5?)

    if validate_data
        fprintf('All data taken from tables; no data to validate!\n');
    end;

    if visualize_data
        figure;
        semilogx(ry_ages, ry_areas, 'o');
    end;


    % Construct outputs
    varnames = who('ry_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);
