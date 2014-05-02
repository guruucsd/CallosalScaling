function [fit_type, u_params, m_params] = w_fit_distns(vars)
%

    %% load variables into the current workspace
    varnames = fieldnames(vars);
    varvals = struct2cell(vars);
    for vi=1:length(varnames)
        eval(sprintf('%s = varvals{vi};', varnames{vi}))
    end;


    %if ~exist('fit_type','var'), fit_type = 'gamma';'lognormal';'IUBD'; end;
    fit_type = 'gamma'
    %% empirical data

    %turn into distributions
    w_fig4_myelinated_distn   = w_fig4_myelinated  ./repmat(sum(w_fig4_myelinated,2),   [1 size(w_fig4_myelinated,2)]);
    w_fig4_unmyelinated_distn = w_fig4_unmyelinated./repmat(sum(w_fig4_unmyelinated,2), [1 size(w_fig4_unmyelinated,2)]);

    % Compute empirical mean
    w_fig4_myelinated_mean   = sum(w_fig4_myelinated_distn .* repmat(w_fig4_xvals, [size(w_fig4_myelinated_distn,1) 1]), 2);
    w_fig4_unmyelinated_mean = sum(w_fig4_unmyelinated_distn .* repmat(w_fig4_xvals, [size(w_fig4_unmyelinated_distn,1) 1]), 2);

    % Compute empirical
    w_fig4_myelinated_var   = sum(w_fig4_myelinated_distn   .* repmat(w_fig4_xvals.^2, [size(w_fig4_myelinated_distn,1)   1]), 2) -w_fig4_myelinated_mean.^2 ;
    w_fig4_unmyelinated_var = sum(w_fig4_unmyelinated_distn .* repmat(w_fig4_xvals.^2, [size(w_fig4_unmyelinated_distn,1) 1]), 2) -w_fig4_unmyelinated_mean.^2;


    [fitfn,pmffn,pdffn] = guru_getfitfns(fit_type);

    %if strcmp(fit_type, 'lognormal')
    %         %Estimate lognormal parameters based on empirical mean and variance
    %         mp_emp = [mufn(w_fig4_myelinated_mean, w_fig4_myelinated_var)'; ...    % myelinated
    %                   sigmafn(w_fig4_myelinated_mean, w_fig4_myelinated_var)'];
    %
    %         up_emp = [mufn(w_fig4_unmyelinated_mean, w_fig4_unmyelinated_var)'; ... % unmyelinated
    %                   sigmafn(w_fig4_unmyelinated_mean, w_fig4_unmyelinated_var)';];
    %
    %end;

    %% Fit using fitting function
    frac = 1/50;


    % normalize distributions
    u_distn = w_fig4_unmyelinated./repmat(sum(w_fig4_unmyelinated,2),[1 size(w_fig4_unmyelinated,2)]);
    m_distn = w_fig4_myelinated  ./repmat(sum(w_fig4_myelinated,2),  [1 size(w_fig4_myelinated,2)]);

    nspecies = length(w_fig4_species);

    uparams = nan(2,nspecies);
    mparams = nan(2,nspecies);
    uf = figure; set(gcf, 'position', [27          17        1254         667])
    mf = figure; set(gcf, 'position', [27          17        1254         667])
    for si=1:nspecies
    %    end_idx = round(size(u_distn,2)/2);
        end_idx = find(u_distn(si,:)>=(frac*max(u_distn(si,:))), 1, 'last');
        end_um = w_fig4_xvals(end_idx-1)

        figure(uf); subplot(2,ceil(nspecies/2),si);
    %    uparams(:,si) = fit_lognormal(u_distn(si,1:end_idx-1), w_fig4_xvals(1:end_idx-1), [-2 0.2]);
        uparams(:,si) = fitfn(u_distn(si,1:end_idx-1), w_fig4_xvals(1:end_idx-1));


        figure(mf); subplot(2,ceil(nspecies/2),si);
    %    end_idx = round(size(m_distn,2));
        end_idx = find(m_distn(si,:)>=(frac*max(m_distn(si,:))), 1, 'last');
    %    mparams(:,si) = fit_lognormal(m_distn(si,:), w_fig4_xvals, [-0.2 0.2]);
        mparams(:,si) = fitfn(m_distn(si,1:end_idx-1), w_fig4_xvals(1:end_idx-1));
    end;
