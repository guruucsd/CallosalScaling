ppmye = polyfit(log(lrb_tab3_ages),(lrb_tab3_pctmy), 1);
gpmye = @(d) max(0,polyval(ppmye,log(d)));

figure;
subplot(1,2,1);
plot(lrb_tab3_ages,lrb_tab3_pctmy, 'o');
hold on;
xvals = linspace(min(lrb_tab3_ages), max(lrb_tab3_ages), 100);
plot(xvals, gpmye(xvals),'r');

subplot(1,2,2);
plot(log(lrb_tab3_ages),(lrb_tab3_pctmy), 'o');
hold on;
plot(log(xvals), gpmye(xvals));
