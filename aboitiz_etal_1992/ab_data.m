ab_dir = fileparts(which(mfilename));
ab_datafile = fullfile(ab_dir, 'ab_data.mat');

if exist(ab_datafile,'file')
    load(ab_datafile);

else
    addpath(genpath(fullfile(ab_dir, '..','_lib')));
    addpath(genpath(fullfile(ab_dir, '..','..','_lib')));

    % Data from the papers
    ab_cc_areas = [102.5 46.26 38.76 34.0 30.6 27.2 35.77 32.11 45.53 36.47];
    ab_shrinkage = 0.35;
    ab_cc_areas_corrected = ab_cc_areas./(1-ab_shrinkage);
    
    % get histogram data
    if ~exist('ab_histograms.mat', 'file'), ab_histograms; close all; end;
    if ~exist('ab_densities.mat','file'), ab_densities;    close all; end;

    load('ab_histograms.mat');
    load('ab_densities.mat');

    %
    ab_cc_regions = ab_fig4_areas;
    ab_cc_rel_areas = ab_cc_areas./sum(ab_cc_areas);
    
    ab_cc_rel_areas = [sum(ab_cc_rel_areas(1:3)) sum([ab_cc_rel_areas(4) ab_cc_rel_areas(5)/2]) sum([ab_cc_rel_areas(6) ab_cc_rel_areas(5)/2])  sum(ab_cc_rel_areas(7)) sum(ab_cc_rel_areas(8:10)) ]
%    ab_fig4_cc_rel_areas = [sum(ab_fig1_cc_rel_areas(1:2)) sum(ab_fig1_cc_rel_areas(3:4)) sum(ab_fig1_cc_rel_areas(5)) sum(ab_fig1_cc_rel_areas(6:7)) sum(ab_fig1_cc_rel_areas(8:end))];

    ab_overall_histogram = sum(ab_fig4_data .* repmat(ab_fig4_cc_rel_areas', [1 size(ab_fig4_data,2)]), 1);
    ab_overall_distn = ab_overall_histogram / sum(ab_overall_histogram);

    vars = who('ab_*');
    save(ab_datafile, vars{:});
end;
