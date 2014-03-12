function vars = ry_data(validate_data)
%
% Cross-species primate brain data from Rilling & Insel (1999a), 
%   largely complementary to callosal data in 1999b.
% Includes:
% * Brain volume
% * Grey & white matter volumes

    if ~exist('validate_data', 'var'), validate_data = true; end;

    
    ry_ages = [[20 24 28 32 36 40]*7 12*30 40*365];
    ry_areas = [22.6 37.0 52.0 51.8 55.6 67.2 147.9 325.1]; % (correct by /0.5?)

    % Reconstruct outputs
    varnames = who('ry_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);

    if validate_data
        figure; semilogx(ry_ages, ry_areas, 'o');
    end;
