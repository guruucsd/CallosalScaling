dndist = @(d1,d2) (sum( (d1./sum(d1) - d2./sum(d2)).^2 ));

IUBD = @(s,a,b) (1./(2*besselk(0,2*sqrt(a.*b))) .* exp(-b.*s - a./s)./s); % via eqn 13
lognpdf2 = @(x,a,b) ((1./(b*sqrt(2*pi))).*exp(-(log(x)-a).^2/(2*b.^2))); % via eqn 18 (no 1/x)

x = 0.01:0.01:4; %in micrometers

figure;
hold on;
title('For EMD3(1), using params from Table ST1');
plot(x, IUBD(x, 2.5, 3.4), 'r');
plot(x, gampdf(x, 6.6, 0.13), 'g');
plot(x, lognpdf(x, -0.15, sqrt(0.16)), 'b');
legend({'IUBD(x, 2.5, 3.4)' 'gampdf(x, 6.6, 0.13)' 'lognpdf(x, -0.15, sqrt(0.16))'});
    
dndist(IUBD(x, 2.5, 3.4), lognpdf(x, -0.15, sqrt(0.16)))

fitfn = @(data,x,dnf,p) (dndist(data,dnf(x,p(1),p(2))));

fminsearch(@(p) fitfn(ab_fig4_data(1,1:end_idx-1))