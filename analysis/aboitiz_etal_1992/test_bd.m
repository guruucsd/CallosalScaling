fit_type = {'IUBD','gamma', 'lognormal'};

for fi=1:length(fit_type)
    switch fit_type{fi}
        case 'lognormal'
            % But we're going to fit these functions numerically.
            pmffn = @(x,p1,p2) cdf2pmf(@logncdf, x, p1, p2);
            pdffn = @lognpdf;
    %        fitfn = @(d,b) fitpdf(pdffn,d,b,[-0.2 0.4]);
            fitfn = @(d,b) fitpmf(pmffn,d,b,[-0.3 0.1]);

        case 'IUBD'
            pmffn = @(x,p1,p2) cdf2pmf(@IUBDcdf, x, p1, p2);
            pdffn = @IUBDpdf;
    %        fitfn = @(d,b) fitpdf(pdffn,d,b,[1 1]);
            fitfn = @(d,b) fitpmf(pmffn,d,b,[1 1]);

        case 'gamma'
            pmffn = @(x,p1,p2) cdf2pmf(@gamcdf, x, p1, p2);
            pdffn = @gampdf;
    %        fitfn = @(d,b) fitpdf(pdffn,d,b,[6 0.1]);
            fitfn = @(d,b) fitpmf(pmffn,d,b,[6 0.1]);
    end;

    for ri=1:5
        end_idx = find(ab_fig4_data(ri,:)>=(frac*max(ab_fig4_data(ri,:))), 1, 'last');
        %end_um = ab_fig4_xbin_vals(end_idx-1)
        subplot(1,5,ri);
        p_reg(fi, ri,:) = fitfn(ab_fig4_data(ri,1:end_idx-1), ab_fig4_xbin_vals(1:end_idx-1));
    end;
end;

% output table
for ri=0:5
    for fi=1:length(fit_type)
        if ri==0, fprintf('%20s\t', fit_type{fi}); 
        else,     fprintf('%9s%5.2f %5.2f\t', ' ', p_reg(fi,ri,:));
        end;
    end;
    fprintf('\n');
end;


% output figures
frac = 1/25;
c = 'krg';
for ri=1:5
    figure; set(gcf,'position', [ 137   406   477   278]);
    hold on;

    ab_fig4_data(ri,:) = ab_fig4_data(ri,:)./sum(ab_fig4_data(ri,:));
    end_idx = find(ab_fig4_data(ri,:)>=(frac*max(ab_fig4_data(ri,:))), 1, 'last');
    xvals = linspace(0, max(ab_fig4_xbin_vals(1:end_idx-1)), 200);
    xfact = length(ab_fig4_xbin_vals)/length(xvals);%*mean(diff(xvals))/mean(diff(ab_fig4_xbin_vals));

    plot(ab_fig4_xbin_vals(1:end_idx-1), ab_fig4_data(ri,1:end_idx-1), '.');
    
    for fi=1:length(fit_type)
        switch fit_type{fi}
            case 'lognormal'
                % But we're going to fit these functions numerically.
                pmffn = @(x,p1,p2) cdf2pmf(@logncdf, x, p1, p2);
                pdffn = @lognpdf;
                fitfn = @(d,b) fitpdf(pdffn,d,b,[-0.3 0.1]);
        %        fitfn = @(d,b) fitpmf(pmffn,d,b,[-0.3 0.1]);

            case 'IUBD'
                pmffn = @(x,p1,p2) cdf2pmf(@IUBDcdf, x, p1, p2);
                pdffn = @IUBDpdf;
                fitfn = @(d,b) fitpdf(pdffn,d,b,[1 1]);
        %        fitfn = @(d,b) fitpmf(pmffn,d,b,[1 1]);

            case 'gamma'
                pmffn = @(x,p1,p2) cdf2pmf(@gamcdf, x, p1, p2);
                pdffn = @gampdf;
                fitfn = @(d,b) fitpdf(pdffn,d,b,[6 0.1]);
        %        fitfn = @(d,b) fitpmf(pmffn,d,b,[6 0.1]);
        end;
        ypdf = pdffn(xvals, p_reg(fi,ri,1), p_reg(fi,ri,2));
        ypmf = pmffn(ab_fig4_xbin_vals, p_reg(fi,ri,1), p_reg(fi,ri,2));
        
        %plot(xvals, ypdf./max(ypdf)*max(ypmf), c(fi));
        plot(ab_fig4_xbin_vals(1:end_idx-1), ypmf(1:end_idx-1), [c(fi) '--']);
    end;
end;

