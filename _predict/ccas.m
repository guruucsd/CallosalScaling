pdh_dir = fileparts(which(mfilename));

cat_brain_weight = 30;
macaque_brain_weight = 79; %rilling&insel
human_brain_weight = 1300;

addpath(fullfile(pdh_dir, '..', 'rilling_insel_1999b')); rib_data;

%% Get the wang data, fit and regress the distributions
if ~exist('gmps','var')
    addpath(fullfile(pdh_dir, '..', 'wang_etal_2008'));
    w_data;
    w_fit_distns;
    w_regress_distns;
end;



% Regress cca vs brain weight, regress density vs brain weight
wts = [1350 420 500 370 92 22]'; % http://faculty.washington.edu/chudler/facts.html
vols = [1298 337 383 407 79 23]'; %rilling & insel, 1999

figure; 
subplot(1,2,1); pwt  = allometric_regression(vols, wts);    hold on; title('vol vs wt');
subplot(1,2,2); pvol = allometric_regression(wts,  vols);   hold on; title('wt vs vol');

gwt = @(vol) (10.^polyval(pwt,log10(vol)));
gvol = @(wt) (10.^polyval(pvol,log10(wt)));

% Predict the # fibers, based on the density and cca
% nfibers(br_wt) = density(br_wt) * cca(br_wt)
figure; set(gcf,'position', [40         362        1079         322]);

subplot(1,3,1);
pdens = allometric_regression(w_fig1e_weights', w_fig1e_dens_est')
gdens = @(wt) 10.^(polyval(pdens, log10(wt)));
hold on; title('wt vs density');
plot((cat_brain_weight),     (mean([18/27 27/23 25/20])), 'r*');
plot((human_brain_weight),   (.33), 'g*');
plot((macaque_brain_weight), (.75), 'k*');
axis tight;

subplot(1,3,2);
pcca = allometric_regression(rib_fig1b_brain_volumes, rib_fig1b_ccas)
gcca = @(vol) 10.^(polyval(pcca, log10(vol)));
hold on; title('wt vs CCA');
plot((cat_brain_weight),     (mean([27 23 20])), 'r*');
plot((human_brain_weight),   (690), 'g*');
plot((macaque_brain_weight), (79.1), 'k*');
axis tight;

subplot(1,3,3);
gnfib = @(wt) 1E6*gdens(wt).*gcca(gvol(wt));
pnfib = allometric_regression(gwt(rib_fig1b_brain_volumes), gnfib(gwt(rib_fig1b_brain_volumes)))
hold on; title('wt vs # fibers');
plot((cat_brain_weight),     (25E6), 'r*');
plot((human_brain_weight),   (200E6), 'g*');
plot((macaque_brain_weight), (55E6), 'k*');

fprintf('%10s:\tCCA: %f\tDens: %f\t# Fibers: %f\n', 'human',   gcca(human_brain_weight), gdens(human_brain_weight), gnfib(human_brain_weight));
fprintf('%10s:\tCCA: %f\tDens: %f\t# Fibers: %f\n', 'macaque', gcca(macaque_brain_weight), gdens(macaque_brain_weight), gnfib(macaque_brain_weight));
fprintf('%10s:\tCCA: %f\tDens: %f\t# Fibers: %f\n', 'cat', gcca(cat_brain_weight), gdens(cat_brain_weight), gnfib(cat_brain_weight));

axis tight;

% 
% cat cca reported as ~20 by innocenti