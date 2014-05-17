clear all global

colors = 'rgbk';
dotstyles = '*.^+';

collations = {'individual', 'species', 'family', 'family-s'};
%collations = {'species', 'family-s'};
figure;
h = [];
for ci = 1:length(collations)
    [bvols, ccas, gmas, gmvs] = ris_collate(collations{ci});
    [ntot, ncc, nintra] = predict_nfibers(predict_brwt(bvols), bvols, collations{ci}, gmvs, [], [], ccas);
    xvals = ntot;
    yvals = ncc;
    plotfn = @plot;
    h(ci) = plotfn(xvals, yvals, [colors(ci) dotstyles(ci)]);
    hold on;
    %loglog(sort(gmas), 8* 0.8363*sort(gmas).^0.8885, colors(ci))
    %sort(ccas), 0.8363*sort(gmas).^0.8885, sort(ccas)./(0.8363*sort(gmas).^0.8885)

    %fprintf('%s means: gma: %f, cca: %f\n', collations{ci}, mean(gmas), mean(ccas));
    %collations{ci}, gmas(:)', ccas(:)'
%    loglog(sort(gmas), 0.84 * (sort(gmas).^0.88), colors(ci))
    coeffs = polyfit(log10(xvals), log10(yvals), 1)
    fn = @(xvals) 10^coeffs(2)*sort(xvals).^coeffs(1);

    [coeffs, fns] = allometric_regression_offset(xvals, yvals);
    fn = fns.y;

    %ccas(:)), [log(gmas(:)) ones(size(gmas(:)))])
    x = sort([.01; 1; xvals(:)]);
    x = linspace(min(x), max(x), 1000);
    plotfn(x, fn(x), colors(ci))
end;
legend(h, collations, 'Location', 'NorthWest');
set(gca, 'FontSize', 14);

