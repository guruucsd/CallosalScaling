% rib_response: explain why cc area increases at a slower rate than grey matter surface area

% here: try to predict aboitiz fiber distributions

% first: look over caminiti, tomasch

% create functions for overlaying actual and predicted, based on brain size

% create functions that relate fiber density, fiber distribution, and cca
%   across brain size, so that one can be related to another, and predictions
%   can be corroborated.

% calc
bins = 0:0.001:5;
[distn,distn_mye,distn_unmye,pct_mye] = predict_cc_add([], 14000, bins);   

figure; 
set(get(bar(bins,distn_mye,  'b','edgecolor','b'),'child'),'facea', 0.25); hold on; 
set(get(bar(bins,distn_unmye,'r','edgecolor','r'),'child'),'facea', 0.25); hold on;
bar(bins,distn); hold on; 
axis tight;

% What does the distribution look like when we can't image below 0.4 
%   (post-shrinkage)?
cutoff = 0.4/sqrt(0.65);
sum(distn(bins<cutoff));
figure; bar(bins(bins>cutoff), distn(bins>cutoff)./sum(distn(bins>cutoff)));


% What is our estimate for the fiber density?
calc_fiber_density(bins,distn_mye, bins, distn_unmye, pct_mye);
calc_fiber_density(bins, distn_mye, [],[], 1);



% Plot calculated & predicted fiber densities as a function of brain weight
brwt = [1/10 1 10 25 50 100 250 500 1000 2500];
%pct_mye = [linspace(0.2, 0.92, length(brwt)-1) 0.95];
calc_dens = zeros(size(brwt));
pred_dens = predict_cc_density(brwt);


figure;
for bwi=1:length(brwt)
    pct_mye = predict_pct_mye(brwt(bwi));
    
    [distn,distn_mye,distn_unmye] = predict_cc_add(brwt(bwi), [], bins, pct_mye, 'lognormal', 1/1000);   
    
    subplot(4,3,bwi);
    bar(bins/sqrt(2),distn); axis tight;
    
    calc_dens(bwi) = calc_fiber_density(bins,distn_mye, bins, distn_unmye, pct_mye, 0.87);
end;

w_data;
figure;
loglog(brwt, pred_dens, 'b');
hold on;
loglog(brwt, calc_dens/2, 'r*');
loglog(w_fig1e_weights, w_fig1e_dens_est, 'bo');
legend({'predicted density' 'calculated density'});
xlabel('brain weight'); ylabel('density');
axis tight;




    
