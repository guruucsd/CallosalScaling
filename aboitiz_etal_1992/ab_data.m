function vars = ab_data(validate_data)
%

    if ~exist('validate_data', 'var'), validate_data = true; end;
    if ~exist('visualize_data', 'var'), visualize_data = false; end;

    %% Collect data
    % Data from the papers
    ab_cc_areas = [102.5 46.26 38.76 34.0 30.6 27.2 35.77 32.11 45.53 36.47];
    ab_shrinkage = 0.35;
    ab_cc_areas_corrected = ab_cc_areas./(1-ab_shrinkage);


    % get histogram data, and load variables into the current workspace.
    for fil={'histograms', 'densities'}
        eval(sprintf('vars = ab_%s(validate_data);', fil{1}));
        varnames = fieldnames(vars);
        varvals = struct2cell(vars);
        for vi=1:length(varnames)
            eval(sprintf('%s = varvals{%d};', varnames{vi}, vi));
        end;
    end;

    % Continue collecting data based on the above
    ab_cc_regions = ab_fig4_areas;

    ab_cc_rel_areas = ab_cc_areas./sum(ab_cc_areas); % weighting is specified in paper, as below.  this was naive
    ab_cc_rel_areas = [sum(ab_cc_rel_areas(1:3)) sum([ab_cc_rel_areas(4) ab_cc_rel_areas(5)/2]) sum([ab_cc_rel_areas(6) ab_cc_rel_areas(5)/2])  sum(ab_cc_rel_areas(7)) sum(ab_cc_rel_areas(8:10)) ];

    ab_fig4_cc_rel_areas = [sum(ab_fig1_cc_rel_areas(1:2)) sum(ab_fig1_cc_rel_areas(3:4)) sum(ab_fig1_cc_rel_areas(5)) sum(ab_fig1_cc_rel_areas(6:7)) sum(ab_fig1_cc_rel_areas(8:end))];

    ab_overall_histogram = sum(ab_fig4_data .* repmat(ab_fig4_cc_rel_areas', [1 size(ab_fig4_data,2)]), 1);
    ab_overall_distn = ab_overall_histogram / sum(ab_overall_histogram);


    %% Do validation
    if validate_data
        fprintf('All data taken from tables; no data to validate!\n');
    end;


    %% Construct outputs
    varnames = who('ab_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);
