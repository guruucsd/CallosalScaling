% estimates, based on formulas
rib_greysa_est = exp(0.84).*rib_table1_ccarea.^(0.88);
rib_whitevol_est = exp(-0.56).*rib_table1_ccarea.^(1.38);

rib_greyvol_est = rib_table1_greysa_est.*rib_table1_brainvol.^(1/9);
rib_density_est = rib_table1_brainvol.^-0.33;
rib_nn_est      = rib_greyvol_est.*rib_density_est;  %= sa*thickness*density % (a+bv^0.62)*(b+bv^1/9)*(c+bv^-0.33) = (ab+a*bv^1/9+b*bv^0.62+bv^73) % should be to 2/3; for this, estimate is to 0.4000
rib_nn_est_ok   = rib_table1_brainvol.^0.67;

polyfit(log10(rib_table1_brainvol), log10(rib_ccareatable1_), 1); %reproduce #s from fig1b
polyfit(log10(rib_table1_brainvol), log10(rib_greysa_est), 1); %should scale to 8/9 power
polyfit(log10(rib_table1_brainvol), log10(rib_greyvol_est), 1); %should scale isometrically
polyfit(log10(rib_nn_est), log10(rib_table1_ccarea), 1); % should be close to 2/3
polyfit(log10(rib_nn_est_ok), log10(rib_table1_ccarea), 1); % should be close to 2/3



