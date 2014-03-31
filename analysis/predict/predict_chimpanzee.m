pd_dir = fileparts(which(mfilename));

% predict chimp / lamantia
addpath(fullfile(pd_dir, '..','caminiti_etal_2009'));   cam_data; close all;
addpath(fullfile(pd_dir, '..','lamantia_rakic_1990s')); lrs_data; close all;
addpath(fullfile(pd_dir, '..','rilling_insel_1999a'));  ria_data; close all;
addpath(fullfile(pd_dir, '..','wang_etal_2008'));       w_data;   close all;

% Predict data using brain weight from rilling and/or wang
%chimp_brain_wt = w_fig1e_weights(find(strcmp('chimp', w_fig1e_species), 1, 'first'))
chimp_brain_wt = predict_brwt(ria_table1_brainvol(find(strcmp('p. troglodytes',ria_table1_species),1,'first')));

chimp_avg_adult_age = str2date(sprintf('P%d',10*365), 'chimp');

[~,d_chimp,m_chimp,u_chimp,pmye_chimp] = predict_cc_fiber_distn(chimp_brain_wt);
f_fiber_distn = gcf;
[dens_chimp] = predict_cc_density(chimp_brain_wt);
[cca_chimp]  = predict_cc_area(chimp_brain_wt);


% Gather caminiti data
cam_bins = linspace(0,4,100);
cam_distn = rebin_distn(cam_figS5_data{3}(strcmp('chimpanzee', cam_species),:), cam_figS5_xvals, cam_bins);


%% Look at predicted fiber distributions
figure(f_fiber_distn);
subplot(1,2,1);
hold on;
bh = bar(cam_bins, cam_distn, 1, 'y');
set(get(bh,'child'),'facea',.5)
[~,~,lh,lt] = legend();
legend([lh;bh], [guru_csprintf('%s (predicted)',lt) {'Caminiti et al. (2009)'}]);

subplot(1,2,2);
hold on;
ch = bar(cam_bins, cam_distn, 1, 'y');
set(get(ch,'child'),'facea',.5)
[~,~,lh,lt] = legend();
legend([lh;ch], [lt {'Caminiti et al. (2009)'}]);
