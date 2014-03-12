%bi_dir = fileparts(which(mfilename));
bi_data;
addpath(genpath(fullfile(bi_dir, '..', '_lib')));

fit_type = 'IUBD';'lognormal';'IUBD';

%% empirical data

%turn into distributions
bi_fig9_myelinated_distn   = bi_fig9_myelinated  ./repmat(sum(bi_fig9_myelinated,2),   [1 size(bi_fig9_myelinated,2)]);
bi_fig9_unmyelinated_distn = bi_fig9_unmyelinated./repmat(sum(bi_fig9_unmyelinated,2), [1 size(bi_fig9_unmyelinated,2)]);

% Compute empirical mean
bi_fig9_myelinated_mean   = sum(bi_fig9_myelinated_distn .* repmat(bi_fig9_xvals, [size(bi_fig9_myelinated_distn,1) 1]), 2);
bi_fig9_unmyelinated_mean = sum(bi_fig9_unmyelinated_distn .* repmat(bi_fig9_xvals, [size(bi_fig9_unmyelinated_distn,1) 1]), 2);

% Compute empirical
bi_fig9_myelinated_var   = sum(bi_fig9_myelinated_distn   .* repmat(bi_fig9_xvals.^2, [size(bi_fig9_myelinated_distn,1)   1]), 2) -bi_fig9_myelinated_mean.^2 ;
bi_fig9_unmyelinated_var = sum(bi_fig9_unmyelinated_distn .* repmat(bi_fig9_xvals.^2, [size(bi_fig9_unmyelinated_distn,1) 1]), 2) -bi_fig9_unmyelinated_mean.^2;


switch fit_type
    case 'lognormal'
        % functions for computing mu and sigma from empirical mean and std
        % p(1) = ln(mn)-p(2).^2/2;
        % p(2) = sqrt(ln(var/mn.^2 + 1)) 
        sigmafn = @(mn,var) (sqrt(log(var./(mn.^2)+1)));
        mufn  = @(mn,var) (log(mn)-log(var./(mn.^2)+1)/2);

        %Estimate lognormal parameters based on empirical mean and variance
        mp_emp = [mufn(bi_fig9_myelinated_mean, bi_fig9_myelinated_var)'; ...    % myelinated
                  sigmafn(bi_fig9_myelinated_mean, bi_fig9_myelinated_var)'];

        up_emp = [mufn(bi_fig9_unmyelinated_mean, bi_fig9_unmyelinated_var)'; ... % unmyelinated
                  sigmafn(bi_fig9_unmyelinated_mean, bi_fig9_unmyelinated_var)';];

        % But we're going to fit these functions numerically.
        pmffn = @(x,p1,p2) cdf2pmf(@logncdf, x, p1, p2);
        pdffn = @lognpdf;
%        fitfn = @(d,b) fitpdf(pdffn,d,b,[-0.3 0.1]);
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

%% Fit using fitting function
frac = 0;%1/50;


% normalize distributions
u_distn = bi_fig9_unmyelinated./repmat(sum(bi_fig9_unmyelinated,2),[1 size(bi_fig9_unmyelinated,2)]);
m_distn = bi_fig9_myelinated  ./repmat(sum(bi_fig9_myelinated,2),  [1 size(bi_fig9_myelinated,2)]);

ndates = length(bi_fig9_dates);

uparams = nan(2,ndates);
mparams = nan(2,ndates);
uf = figure; set(gcf, 'position', [27          17        1254         667])
mf = figure; set(gcf, 'position', [27          17        1254         667])
for si=1:ndates
%    end_idx = round(size(u_distn,2)/2);
    end_idx = find(u_distn(si,:)>=(frac*max(u_distn(si,:))), 1, 'last');
    end_um = bi_fig9_xvals(end_idx-1)

    figure(uf); subplot(2,ceil(ndates/2),si);
%    uparams(:,si) = fit_lognormal(u_distn(si,1:end_idx-1), bi_fig9_xvals(1:end_idx-1), [-2 0.2]);
    uparams(:,si) = fitfn(u_distn(si,1:end_idx-1), bi_fig9_xvals(1:end_idx-1));
    
    
    figure(mf); subplot(2,ceil(ndates/2),si);
%    end_idx = round(size(m_distn,2));
    end_idx = find(m_distn(si,:)>=(frac*max(m_distn(si,:))), 1, 'last');
%    mparams(:,si) = fit_lognormal(m_distn(si,:), bi_fig9_xvals, [-0.2 0.2]); 
    if ~isempty(end_idx)
        mparams(:,si) = fitfn(m_distn(si,1:end_idx-1), bi_fig9_xvals(1:end_idx-1));
    end;
end;
