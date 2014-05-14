function w_regress_distns(vars, fit_type)

    %% load variables into the current workspace
    varnames = fieldnames(vars);
    varvals = struct2cell(vars);
    for vi=1:length(varnames)
        eval(sprintf('%s = varvals{vi};', varnames{vi}))
    end;

    human_brain_weight = get_human_brain_weight();


    %% Fit curves
    %if ~exist('fit_type','var'), fit_type = 'gamma';'lognormal';'IUBD'; end;
    fit_type = 'gamma';

    %turn into distributions
    w_fig4_myelinated_distn   = w_fig4_myelinated  ./repmat(sum(w_fig4_myelinated,2),   [1 size(w_fig4_myelinated,2)]);
    w_fig4_unmyelinated_distn = w_fig4_unmyelinated./repmat(sum(w_fig4_unmyelinated,2), [1 size(w_fig4_unmyelinated,2)]);

    % Compute empirical mean
    w_fig4_myelinated_mean   = sum(w_fig4_myelinated_distn .* repmat(w_fig4_xvals, [size(w_fig4_myelinated_distn,1) 1]), 2);
    w_fig4_unmyelinated_mean = sum(w_fig4_unmyelinated_distn .* repmat(w_fig4_xvals, [size(w_fig4_unmyelinated_distn,1) 1]), 2);

    % Compute empirical
    w_fig4_myelinated_var   = sum(w_fig4_myelinated_distn   .* repmat(w_fig4_xvals.^2, [size(w_fig4_myelinated_distn,1)   1]), 2) -w_fig4_myelinated_mean.^2 ;
    w_fig4_unmyelinated_var = sum(w_fig4_unmyelinated_distn .* repmat(w_fig4_xvals.^2, [size(w_fig4_unmyelinated_distn,1) 1]), 2) -w_fig4_unmyelinated_mean.^2;


    % Fit using fitting function
    frac = 1/50;

    [fitfn,pmffn,pdffn] = guru_getfitfns(fit_type, frac, true);

    %if strcmp(fit_type, 'lognormal')
    %         %Estimate lognormal parameters based on empirical mean and variance
    %         mp_emp = [mufn(w_fig4_myelinated_mean, w_fig4_myelinated_var)'; ...    % myelinated
    %                   sigmafn(w_fig4_myelinated_mean, w_fig4_myelinated_var)'];
    %
    %         up_emp = [mufn(w_fig4_unmyelinated_mean, w_fig4_unmyelinated_var)'; ... % unmyelinated
    %                   sigmafn(w_fig4_unmyelinated_mean, w_fig4_unmyelinated_var)';];
    %
    %end;


    % normalize distributions
    u_distn = w_fig4_unmyelinated./repmat(sum(w_fig4_unmyelinated,2),[1 size(w_fig4_unmyelinated,2)]);
    m_distn = w_fig4_myelinated  ./repmat(sum(w_fig4_myelinated,2),  [1 size(w_fig4_myelinated,2)]);

    nspecies = length(w_fig4_species);

    uparams = nan(2,nspecies);
    mparams = nan(2,nspecies);
    uf = figure('Name', 'Unmyelinated ADDs', 'position', [27          17        1254         667]);
    mf = figure('Name', 'Myelinated ADDs', 'position', [27          17        1254         667]);
    for si=1:nspecies
    %    end_idx = round(size(u_distn,2)/2);
        end_idx = find(u_distn(si,:)>=(frac*max(u_distn(si,:))), 1, 'last');
        end_um = w_fig4_xvals(end_idx-1);

        figure(uf); subplot(2,ceil(nspecies/2),si);
    %    uparams(:,si) = fit_lognormal(u_distn(si,1:end_idx-1), w_fig4_xvals(1:end_idx-1), [-2 0.2]);
        uparams(:,si) = fitfn(u_distn(si,1:end_idx-1), w_fig4_xvals(1:end_idx-1));


        figure(mf); subplot(2,ceil(nspecies/2),si);
    %    end_idx = round(size(m_distn,2));
        end_idx = find(m_distn(si,:)>=(frac*max(m_distn(si,:))), 1, 'last');
    %    mparams(:,si) = fit_lognormal(m_distn(si,:), w_fig4_xvals, [-0.2 0.2]);
        mparams(:,si) = fitfn(m_distn(si,1:end_idx-1), w_fig4_xvals(1:end_idx-1));
    end;


    %% Do regression of fit parameters

    w_regress_type = 'linear';

    switch w_regress_type
        case 'linear'
            switch fit_type
                case {'IUBD','gamma'}

                    [pmpm,Rmpm] = polyfit(log10([w_fig4_brain_weights])', log10([mparams(1,:)]'), 1);
                    [pmps,Rmps] = polyfit(log10([w_fig4_brain_weights])', log10([mparams(2,:)]'), 1);
                    [pupm,Rupm] = polyfit(log10(w_fig4_brain_weights)', log10(uparams(1,:)'), 1);
                    [pups,Rups] = polyfit(log10(w_fig4_brain_weights)', log10(uparams(2,:)'), 1);

                    gmpm = @(wt) 10.^(polyval(pmpm, log10(wt)));
                    gmps = @(wt) 10.^(polyval(pmps, log10(wt), Rmps));
                    gupm = @(wt) 10.^(polyval(pupm, log10(wt), Rupm));
                    gups = @(wt) 10.^(polyval(pups, log10(wt), Rups));


                case {'lognormal'}

                    [pmpm,Rmpm] = polyfit(log10([w_fig4_brain_weights])', ([mparams(1,:)]'), 1);
                    [pmps,Rmps] = polyfit(log10([w_fig4_brain_weights])', ([mparams(2,:)]'), 1);
                    [pupm,Rupm] = polyfit(log10(w_fig4_brain_weights)', (uparams(1,:)'), 1);
                    [pups,Rups] = polyfit(log10(w_fig4_brain_weights)', (uparams(2,:)'), 1);

                    gmpm = @(wt) (polyval(pmpm, log10(wt)));
                    gmps = @(wt) (polyval(pmps, log10(wt), Rmps));
                    gupm = @(wt) (polyval(pupm, log10(wt), Rupm));
                    gups = @(wt) (polyval(pups, log10(wt), Rups));


            end;

            %logbw = log(w_fig4_brain_weights);
            bw_range = linspace(min(w_fig4_brain_weights), human_brain_weight, 100);
            %lbw_range = bw_range;%linspace(min(logbw), log(human_brain_weight), 100);

            % On parameters
            f_regress = figure('Position', [94    33   751   651]);
            subplot(2,2,1); set(gca, 'FontSize', 14);
    %        [p,g] = allometric_regression(w_fig4_brain_weights, mparams(1,:), {'linear' 'log'});
    %        allometric_plot2(w_fig4_brain_weights, mparams(1,:),p,g,'linear',f_regress);
            loglog(w_fig4_brain_weights, [mparams(1,:)], 'ro', 'MarkerSize', 10, 'LineWidth',2); hold on;
            loglog(bw_range, gmpm(bw_range), 'LineWidth', 3);
            %xlabel('log_{10}(brain weight)');
            axis tight; set(gca, 'ylim', [0 20])
            ylabel('\alpha value');
            title('myelinated \alpha', 'FontSize', 16);

            subplot(2,2,2); set(gca, 'FontSize', 14);
    %        [p,g] = allometric_regression(w_fig4_brain_weights, mparams(2,:));
    %        allometric_plot2(w_fig4_brain_weights, mparams(2,:),p,g,'loglog',f_regress);
            loglog(([w_fig4_brain_weights]), [mparams(2,:)], 'ro', 'MarkerSize', 10, 'LineWidth',2); hold on;
            loglog(bw_range, gmps(bw_range), 'LineWidth', 3);
            axis tight; set(gca, 'ylim', [0 0.25])
            %xlabel('log_{10}(brain weight)');
            %ylabel('\beta value');
            title('myelinated \beta', 'FontSize', 16);

            subplot(2,2,3); set(gca, 'FontSize', 14);
    %        [p,g] = allometric_regression(w_fig4_brain_weights, uparams(1,:));
    %        allometric_plot2(w_fig4_brain_weights, uparams(1,:),p,g,'loglog',f_regress);
            loglog((w_fig4_brain_weights), uparams(1,:), 'ro', 'MarkerSize', 10, 'LineWidth',2); hold on;
            loglog(bw_range, gupm(bw_range), 'LineWidth', 3);
            axis tight; set(gca, 'ylim', [0 20])
            xlabel('brain weight');
            ylabel('\alpha value');
            title('unmyelinated \alpha', 'FontSize', 16);

            subplot(2,2,4); set(gca, 'FontSize', 14);
    %        [p,g] = allometric_regression(w_fig4_brain_weights, uparams(2,:));
    %        allometric_plot2(w_fig4_brain_weights, uparams(2,:),p,g,'loglog',f_regress);
            loglog((w_fig4_brain_weights), uparams(2,:), 'ro', 'MarkerSize', 10, 'LineWidth',2); hold on;
            loglog(bw_range, gups(bw_range), 'LineWidth', 3);
            axis tight; set(gca, 'ylim', [0 0.25])
            xlabel('brain weight');
            %ylabel('\beta value');
            title('unmyelinated \beta', 'FontSize', 16);


        case 'linear_mv' % linear regression, but indirectly--using mean and variance
            error('broken');
            % Mean & variance for myelinated
            m_mean = exp(mparams(1,:)+mparams(2,:).^2/2);
            m_var  = (exp(mparams(2,:).^2)-1).*exp(2*mparams(1,:)+mparams(2,:).^2);
            [pmm,Rmm] = polyfit(log(w_fig4_brain_weights)', m_mean', 1);
            [pmv,Rmv] = polyfit(log(w_fig4_brain_weights)', m_var', 1);

            % Mean & variance for unmyelinated
            u_mean = exp(uparams(1,:)+uparams(2,:).^2/2);
            u_var  = (exp(uparams(2,:).^2)-1).*exp(2*uparams(1,:)+uparams(2,:).^2);
            [pum,Rum] = polyfit(log(w_fig4_brain_weights)', u_mean', 1);
            [puv,Ruv] = polyfit(log(w_fig4_brain_weights)', u_var', 1);

            gmm = @(wt) polyval(pmm, log(wt), Rmm);
            gmv = @(wt) polyval(pmv, log(wt), Rmv);
            gum = @(wt) polyval(pum, log(wt), Rum);
            guv = @(wt) polyval(puv, log(wt), Ruv);


            % go backwards to estimate mu and sigma from mean & variance
            % (1) m_mu = ln(mean)-sigma^2/2
            % m_var= (exp(sigma^2)-1).*exp(2*ln(mean)-sigma^2/2+sigma^2)
            m_mean = exp(mparams(1,:)+mparams(2,:).^2/2);
            m_var  = (exp(mparams(2,:).^2)-1).*exp(2*mparams(1,:)+mparams(2,:).^2);

            %logbw = log(w_fig4_brain_weights);
            bw_range = linspace(min(w_fig4_brain_weights), human_brain_weight, 100);
            lbw_range = log(bw_range);%linspace(min(logbw), log(human_brain_weight), 100);

            % On mean
            f_regress = figure; set(f_regress, 'Position', [94    33   751   651]);
            subplot(2,2,1); set(gca, 'FontSize', 14);
            plot(log(w_fig4_brain_weights), m_mean, 'o'); hold on;
            plot(lbw_range, polyval(pmm, lbw_range));
            xlabel('log_{10}(brain weight)'); ylabel('mean value');
            title('myelinated mean (lognormal)', 'FontSize', 16);

            subplot(2,2,2); set(gca, 'FontSize', 14);
            plot(log(w_fig4_brain_weights), m_var, 'o'); hold on;
            plot(lbw_range, polyval(pmv, lbw_range));
            xlabel('log_{10}(brain weight)'); ylabel('variance value');
            title('myelinated variance (lognormal)', 'FontSize', 16);

            subplot(2,2,3); set(gca, 'FontSize', 14);
            plot(log(w_fig4_brain_weights), u_mean, 'o'); hold on;
            plot(lbw_range, polyval(pum, lbw_range));
            xlabel('log_{10}(brain weight)'); ylabel('mean value');
            title('unmyelinated mean (lognormal)', 'FontSize', 16);

            subplot(2,2,4); set(gca, 'FontSize', 14);
            plot(log(w_fig4_brain_weights), u_var, 'o'); hold on;
            plot(lbw_range, polyval(puv, lbw_range));
            xlabel('log_{10}(brain weight)'); ylabel('variance value');
            title('unmyelinated mean (lognormal)', 'FontSize', 16);

        case 'gp'
            % Do the regressions for each parameter, and get 95% confidence
            % intervals
            lbw = log([w_fig4_brain_weights]);
            [hyp_mmu, inffunc_mmu, meanfunc_mmu, covfunc_mmu, likfunc_mmu] = gpreg(lbw', mparams(1,:)', true);
            [hyp_msg, inffunc_msg, meanfunc_msg, covfunc_msg, likfunc_msg] = gpreg(lbw', mparams(2,:)', true);
            [hyp_umu, inffunc_umu, meanfunc_umu, covfunc_umu, likfunc_umu] = gpreg(lbw', uparams(1,:)', true);
            [hyp_usg, inffunc_usg, meanfunc_usg, covfunc_usg, likfunc_usg] = gpreg(lbw', uparams(2,:)', true);

            xdist = max(lbw)-min(lbw);
            zx = [linspace(min(lbw)-xdist*.25, max(lbw)+xdist*.25, 25)'; log(human_brain_weight)]; % interpolate, and extrapolate by 25%

            [zm_mmu zs2_mmu] = gp(hyp_mmu, inffunc_mmu, meanfunc_mmu, covfunc_mmu, likfunc_mmu, lbw', mparams(1,:)', zx);
            [zm_msg zs2_msg] = gp(hyp_msg, inffunc_msg, meanfunc_msg, covfunc_msg, likfunc_msg, lbw', mparams(2,:)', zx);
            [zm_umu zs2_umu] = gp(hyp_umu, inffunc_umu, meanfunc_umu, covfunc_umu, likfunc_umu, lbw', uparams(1,:)', zx);
            [zm_usg zs2_usg] = gp(hyp_usg, inffunc_usg, meanfunc_usg, covfunc_usg, likfunc_usg, lbw', uparams(2,:)', zx);

            %     f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
            %    fill([z; flipdim(z,1)], f, [7 7 7]/8);

            % Compute the different curves


    end;

