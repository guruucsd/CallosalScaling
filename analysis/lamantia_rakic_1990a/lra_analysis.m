lra_dir = fileparts(which(mfilename));
addpath(lra_dir); lra_data;
addpath(genpath(fullfile(lra_dir, '..','..','_lib')));


%% Corpus callosum

lra_cc_age_s = sort(lra_cc_age);
figure; set(gcf, 'Position', [62         212        1156         472]);

% density decreases
p_lra_cc_d  = polyfit(lra_cc_age(lra_cc_age<10), lra_cc_density(lra_cc_age<10), 1);

subplot(1,3,1); hold on;
title('cc density (decreases with age)')
plot(lra_cc_age(lra_cc_age<10), lra_cc_density(lra_cc_age<10), 'o');
plot(lra_cc_age_s(lra_cc_age<10), p_lra_cc_d(2)+p_lra_cc_d(1)*lra_cc_age_s(lra_cc_age<10));

% not due to axon loss
p_lra_cc_ac = polyfit(lra_cc_age(lra_cc_age<10), lra_cc_naxons(lra_cc_age<10), 1);

subplot(1,3,2); hold on;
title('cc axon count (does not decrease with age (may increase)')
plot(lra_cc_age(lra_cc_age<10), lra_cc_naxons(lra_cc_age<10), 'o');
plot(lra_cc_age_s(lra_cc_age<10), p_lra_cc_ac(2)+p_lra_cc_ac(1)*lra_cc_age_s(lra_cc_age<10));

% not due to area decrease
p_lra_cc_ar = polyfit(lra_cc_age(lra_cc_age<10), lra_cc_area(lra_cc_age<10), 1);

subplot(1,3,3); hold on;
title('cc area (does not decrease with age (increases!))')
plot(lra_cc_age(lra_cc_age<10), lra_cc_area(lra_cc_age<10), 'o');
plot(lra_cc_age_s(lra_cc_age<10), p_lra_cc_ar(2)+p_lra_cc_ar(1)*lra_cc_age_s(lra_cc_age<10));


% relationship between ccarea and # fibers (Lamantia & Rakic say that no
% relationship exists)
% [~,~,r1] = allometric_regression(lra_cc_area, lra_cc_naxons,  'log', 1, true, '1');
% [~,~,r2] = allometric_regression(lra_cc_area, lra_cc_density, 'log', 1, true, '1');
%
% [~,~,ra] = allometric_regression(lra_cc_area,   lra_cc_age, 'log', 1, true, '1');
% [~,~,rn] = allometric_regression(lra_cc_naxons, lra_cc_age, 'log', 1, true, '1');
% allometric_regression(ra{1}, rn{1}, 'linear', 1, true, '1');
%
% But what if we partial out age? i.e. isn't this due to maturation
% differences?



%% Anterior commissure

% quick linear regression & plot

% density
p_lra_ac_d = polyfit(lra_ac_age, lra_ac_density, 1);
lra_ac_age_s = sort(lra_ac_age);

figure; set(gcf, 'Position', [62         212        1156         472]);
subplot(1,3,1); hold on;
title('AC density (decreases with age)')
plot(lra_ac_age, lra_ac_density, 'o');
plot(lra_ac_age_s, p_lra_ac_d(2)+p_lra_ac_d(1)*lra_ac_age_s);

% not due to axon loss
p_lra_ac_ac = polyfit(lra_ac_age, lra_ac_naxons, 1);

subplot(1,3,2); hold on;
title('AC axon count (does not decrease with age)')
plot(lra_ac_age, lra_ac_naxons, 'o');
plot(lra_ac_age_s, p_lra_ac_ac(2)+p_lra_ac_ac(1)*lra_ac_age_s);

% not due to area decrease
p_lra_ac_ar = polyfit(lra_ac_age, lra_ac_area, 1);

subplot(1,3,3); hold on;
title('AC area (does not decrease with age)')
plot(lra_ac_age, lra_ac_area, 'o');
plot(lra_ac_age_s, p_lra_ac_ar(2)+p_lra_ac_ar(1)*lra_ac_age_s);



%% Hippocampal commissure

% quick linear regression & plot

% density
p_lra_hc_d = polyfit(lra_hc_age, lra_hc_density, 1);
lra_hc_age_s = sort(lra_hc_age);

figure; set(gcf, 'Position', [62         212        1156         472]);
subplot(1,3,1); hold on;
title('HC density (decreases with age)')
plot(lra_hc_age, lra_hc_density, 'o');
plot(lra_hc_age_s, p_lra_hc_d(2)+p_lra_hc_d(1)*lra_hc_age_s);

% not due to axon loss
p_lra_hc_ac = polyfit(lra_hc_age, lra_hc_naxons, 1);

subplot(1,3,2); hold on;
title('HC axon count (does not decrease with age)')
plot(lra_hc_age, lra_hc_naxons, 'o');
plot(lra_hc_age_s, p_lra_hc_ac(2)+p_lra_hc_ac(1)*lra_hc_age_s);

% not due to area decrease
p_lra_hc_ar = polyfit(lra_hc_age, lra_hc_area, 1);

subplot(1,3,3); hold on;
title('HC area (does not decrease with age)')
plot(lra_hc_age, lra_hc_area, 'o');
plot(lra_hc_age_s, p_lra_hc_ar(2)+p_lra_hc_ar(1)*lra_hc_age_s);


%% btc

% quick linear regression & plot

% density
p_lra_btc_d = polyfit(lra_btc_age, lra_btc_density, 1);
lra_btc_age_s = sort(lra_btc_age);

figure; set(gcf, 'Position', [62         212        1156         472]);
subplot(1,3,1); hold on;
title('BTC density (decreases with age)')
plot(lra_btc_age, lra_btc_density, 'o');
plot(lra_btc_age_s, p_lra_btc_d(2)+p_lra_btc_d(1)*lra_btc_age_s);

% not due to axon loss
p_lra_btc_ac = polyfit(lra_btc_age, lra_btc_naxons, 1);

subplot(1,3,2); hold on;
title('BTC axon count (does not decrease with age)')
plot(lra_btc_age, lra_btc_naxons, 'o');
plot(lra_btc_age_s, p_lra_btc_ac(2)+p_lra_btc_ac(1)*lra_btc_age_s);

% not due to area decrease
p_lra_btc_ar = polyfit(lra_btc_age, lra_btc_area, 1);

subplot(1,3,3); hold on;
title('BTC area (does not decrease with age)')
plot(lra_btc_age, lra_btc_area, 'o');
plot(lra_btc_age_s, p_lra_btc_ar(2)+p_lra_btc_ar(1)*lra_btc_age_s);


%% plot pct myelination
figure; set(gcf, 'Position', [   106   446   796   181]);

% ac
p_lra_ac_pm = polyfit(lra_ac_age, lra_ac_pctmyelinated, 1);

subplot(1,3,1); hold on;
title('AC pct myelination (increases with age?)')
plot(lra_ac_age, lra_ac_pctmyelinated, 'o');
plot(lra_ac_age_s, p_lra_ac_pm(2)+p_lra_ac_pm(1)*lra_ac_age_s);

% hc
p_lra_hc_pm = polyfit(lra_hc_age, lra_hc_pctmyelinated, 1);

subplot(1,3,2); hold on;
title('HC pct myelination (increases with age?)')
plot(lra_hc_age, lra_hc_pctmyelinated, 'o');
plot(lra_hc_age_s, p_lra_hc_pm(2)+p_lra_hc_pm(1)*lra_hc_age_s);


% btc
p_lra_btc_pm = polyfit(lra_btc_age, lra_btc_pctmyelinated, 1);

subplot(1,3,3); hold on;
title('BTC pct myelination (increases with age?)')
plot(lra_btc_age, lra_btc_pctmyelinated, 'o');
plot(lra_btc_age_s, p_lra_btc_pm(2)+p_lra_btc_pm(1)*lra_btc_age_s);




%% Filling fraction of cc, at each age


