lrs_dir = fileparts(which(mfilename));
lrs_datafile = fullfile(lrs_dir, 'lrs_data.mat');

if exist(lrs_datafile,'file')
    load(lrs_datafile);
    
else
    
    addpath(genpath(fullfile(lrs_dir, '..','..','_lib')));
    addpath(fullfile(lrs_dir, '..','lamantia_rakic_1990a')); lra_data; close all;
    addpath(fullfile(lrs_dir, '..','lamantia_rakic_1990b')); lrb_data; close all;
    close all; % get rid of previous plots
    
    %% Combine density, area, connections, across lifespan
    lrs_age  = [lrb_tab_ages lra_cc_age*365];
    lrs_dens = [lrb_tab_ccdens lra_cc_density];
    lrs_area = [lrb_tab_ccarea lra_cc_area];
    lrs_nic  = [lrb_tab_ccnic lra_cc_naxons];
    lrs_pctmy= [lrb_tab_pctmy lra_cc_pctmyelinated_est*ones(size(lra_cc_naxons))];% fudge it

    vars = who('lrs_*','lra_*','lrb_*');
    save(lrs_datafile,vars{:});
end;

