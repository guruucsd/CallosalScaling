
        % regression: loglog
        p2 = polyfit(log10(dc{2}), log10(dc{1}),1)
        g2 = @(v) 10.^polyval(p2,log10(v));

        % reproduce fig7
        figure;
        semilogx(dc{2},dc{1}, 'o');
        hold on;
        xvals = 10.^linspace(log10(min(dc{2})),log10(max(dc{2})),100);
        semilogx(xvals, g2(xvals), 'r');
        
        
        % regression: loglog
        p3 = polyfit(log10(d{2,2}), log10(d{2,1}),1)
        g3 = @(v) 10.^polyval(p2,log10(v));
