ages = [lrb_fig3_ages lrb_fig15_ages];
for si=1:4
    [hparams,hfuns] = regress_distns(ages, squeeze(params(si,:,:)), fit_type)
    %subplot(1,2,1); set(gca, 'ylim', [2 10]);
    %subplot(1,2,2); set(gca, 'ylim', [0.02 0.1]);
end;
