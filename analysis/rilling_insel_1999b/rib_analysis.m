rib_data; close all


%% Convert weights to volumes
wts = [1350 420 500 370 92 22]'; % http://faculty.washington.edu/chudler/facts.html
vols = [1298 337 383 407 79 23]'; %rilling & insel, 1999

figure; 
subplot(1,2,1); pwt  = allometric_regression(vols, wts);    hold on; title('vol vs wt');
subplot(1,2,2); pvol = allometric_regression(wts,  vols);   hold on; title('wt vs vol');

gwt = @(vol) (10.^polyval(pwt,log10(vol)));
gvol = @(wt) (10.^polyval(pvol,log10(wt)));



%% Regress cca against gma and wmv
figure;
subplot(1,2,1);
plot(rib_fig2_gmas, rib_fig2_ccas, 'o'); hold on; 
[pgma,ggma] = allometric_regression(rib_fig2_gmas, rib_fig2_ccas);
title('GMA vs. CCA');

subplot(1,2,2);
plot(rib_fig2_wmvs, rib_fig2_ccas, 'o'); hold on;
[pwmv,gwmv] = allometric_regression(rib_fig2_wmvs, rib_fig2_ccas);
title('WMV vs. CCA');


%% Now redo, but using external data



%% 