%%
bi_dir = fileparts(which(mfilename));

addpath(bi_dir);
addpath(genpath(fullfile(bi_dir, '..','..','_lib')));
bi_data;


[ppmye,gpmye] = allometric_regression(bi_fig17_dates, bi_fig17_pctmy', {'loglog', 'log'}, 1, true, '1');

figure;
subplot(1,2,1);
plot(bi_fig17_dates,bi_fig17_pctmy, 'o');
hold on;
xvals = linspace(min(bi_fig17_dates), max(bi_fig17_dates), 100);
plot(xvals, gpmye.y(xvals));

subplot(1,2,2);
plot(log(bi_fig17_dates),(bi_fig17_pctmy), 'o');
hold on;
plot(log(xvals), gpmye.y(xvals));
