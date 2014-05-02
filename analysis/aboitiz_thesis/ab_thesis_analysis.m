function ab_thesis_analysis(vars, figs)

    if ~exist('figs','var')
        figs = {'all'};
    end;

    %% load variables into the current workspace
    varnames = fieldnames(vars);
    varvals = struct2cell(vars);
    for vi=1:length(varnames)
        eval(sprintf('%s = varvals{vi};', varnames{vi}))
    end;

    ab_density_correction      = 0.65*1.20;
    ab_thesis_region_area_norm = ab_thesis_appendix8_data./repmat(sum(ab_thesis_appendix8_data,2),[1 size(ab_thesis_appendix8_data,2)]);
    ab_thesis_total_density    = sum(ab_thesis_appendix4_data.*ab_thesis_region_area_norm,2);
    ab_thesis_total_fibers     = sum(ab_thesis_appendix4_data.*ab_thesis_appendix8_data*1E2,2)/1E6*ab_density_correction;


    %% Look at the relationship between density and age, over the whole callosum
    if ismember(figs, 'all')
        figure('Position', [680   327   667   631]);
        plot(ab_thesis_appendix3_data(idx8to2,1), ab_density_correction*ab_thesis_total_density, 'ro', 'MarkerSize', 10, 'LineWidth', 2)
        set(gca, 'fontsize', 14);
        set(gca, 'ylim', [2200 3600]);%ab_density_correction*[min(ab_thesis_appendix4_data(:)) max(ab_thesis_appendix4_data(:))])
        title(sprintf('%s; corr=%.2f', ...
                      'Whole CC', ...
                      corr(ab_thesis_appendix3_data(idx8to2,1), ab_density_correction*ab_thesis_total_density)));
        xlabel('age (years)');
        ylabel('fiber density (fibers/cm^2)')
        hold on;
        plot(get(gca, 'xlim'), polyval(polyfit(ab_thesis_appendix3_data(idx8to2,1), ab_density_correction*ab_thesis_total_density, 1), get(gca, 'xlim')), 'b.-', 'LineWidth', 2);
    end;

    % partialing out brain size doesn't diminish the effect of age.
    corr(ab_thesis_appendix3_data(idx8to2,1), ab_thesis_total_density)
    partialcorr(ab_thesis_appendix3_data(idx8to2,1), ab_thesis_total_density, ab_thesis_appendix3_data(idx8to2,2))

    %% now do the same thing for each region
    if ismember(figs, 'all')
        figure('Position', [-23         314        1304         370]);
        for ri=1:length(ab_thesis_appendix8_cols)
            subplot(2,5,ri);
            scatter(ab_thesis_appendix3_data(idx8to2,1), ab_density_correction*ab_thesis_appendix4_data(:,ri));
            set(gca, 'ylim', ab_density_correction*[min(ab_thesis_appendix4_data(:)) max(ab_thesis_appendix4_data(:))])
            title(sprintf('%s (mean=%.1f%%); corr=%.2f', ...
                          ab_thesis_appendix8_cols{ri}, ...
                          100*mean(ab_thesis_region_area_norm(:,ri)), ...
                          corr(ab_thesis_appendix3_data(idx8to2,1), ab_thesis_appendix4_data(:,ri))));
            if ri > 5, xlabel('age'); end;
            if ismember(ri, [1 6]), ylabel('fiber density'); end;
        end;
    end;


    %% Relationship between asymmetry and ....
    ab_thesis_SF_asymmetry_idx = diff(-ab_thesis_appendix1_data(idx8to2,1:2),[],2)./mean(ab_thesis_appendix1_data(idx8to2,1:2),2);
    ab_thesis_PT_asymmetry_idx = diff(-ab_thesis_appendix1_data(idx8to2,3:4),[],2)./mean(ab_thesis_appendix1_data(idx8to2,3:4),2);
    ab_thesis_OT_asymmetry_idx = diff(-ab_thesis_appendix3_data(idx8to2,3:4),[],2)./mean(ab_thesis_appendix3_data(idx8to2,3:4),2);

    % very little correlation between the asymmetries
    corr(ab_thesis_PT_asymmetry_idx, ab_thesis_SF_asymmetry_idx)

    % correlation with total fibers
    fprintf('Asymmetry correlation .... with total fibers:\n');
    corr(ab_thesis_SF_asymmetry_idx, ab_thesis_total_fibers), corr(abs(ab_thesis_SF_asymmetry_idx), ab_thesis_total_fibers)
    corr(ab_thesis_PT_asymmetry_idx, ab_thesis_total_fibers), corr(abs(ab_thesis_PT_asymmetry_idx), ab_thesis_total_fibers)
    partialcorr(ab_thesis_SF_asymmetry_idx, ab_thesis_total_fibers, ab_thesis_appendix3_data(idx8to2,1)),

    if ismember(figs, 'all')
        figure;
        scatter(ab_thesis_SF_asymmetry_idx(setdiff(1:end,5)), ab_thesis_total_fibers(setdiff(1:end,5)));
        %hold on;
        %scatter(ab_thesis_PT_asymmetry_idx(setdiff(1:end,5)), ab_thesis_total_fibers(setdiff(1:end,5)), 'r');
        xlabel('Asymmetry index'); ylabel('Total fibers')
    end;

    % correlation with overall density
    fprintf('with overall density:\n');
    corr(ab_thesis_SF_asymmetry_idx, ab_thesis_total_density), corr(abs(ab_thesis_SF_asymmetry_idx), ab_thesis_total_density)
    corr(ab_thesis_PT_asymmetry_idx, ab_thesis_total_density), corr(abs(ab_thesis_PT_asymmetry_idx), ab_thesis_total_density)

    % correlation with age
    fprintf('with age:\n');
    corr(ab_thesis_SF_asymmetry_idx, ab_thesis_appendix3_data(idx8to2,1)), corr(abs(ab_thesis_SF_asymmetry_idx), ab_thesis_appendix3_data(idx8to2,1))
    corr(ab_thesis_PT_asymmetry_idx, ab_thesis_appendix3_data(idx8to2,1)), corr(abs(ab_thesis_PT_asymmetry_idx), ab_thesis_appendix3_data(idx8to2,1))

    %% total fibers and...

    % with age
    if any(ismember(figs, {'f1', 'all'}))
        fprintf('Total fibers vs. age:\n');
        figure('Position', [680   327   667   631]);
        set(gca, 'FontSize', 14);
        plot(ab_thesis_appendix3_data(idx8to2,1),ab_thesis_total_fibers, 'ro', 'MarkerSize', 10, 'LineWidth', 2)
        hold on; % add tomasch
        %plot(55, 177*1.2, 'go')
        %plot(55, 175*1.2, 'go')
        %plot(55, 193.5*1.2, 'go')
        title(sprintf('%s; corr=%.2f', ...
                      'Whole CC', ...
                      corr(ab_thesis_appendix3_data(idx8to2,1), ab_thesis_total_fibers)));
        xlabel('Age'); ylabel('Total fibers (10^6)');
        plot(get(gca, 'xlim'), polyval(polyfit(ab_thesis_appendix3_data(idx8to2,1),ab_thesis_total_fibers,1), get(gca, 'xlim')), 'b.-', 'LineWidth', 2)
    end;

    ab_thesis_appendix8_sex = cellfun(@(s) ~isempty(findstr(s,'F')), ab_thesis_appendix4_subj);
    ab_thesis_appendix8_male_idx   = find(~ab_thesis_appendix8_sex);
    ab_thesis_appendix8_female_idx = find(ab_thesis_appendix8_sex);

    if ismember(figs, 'all')
        figure;
        shm = scatter(ab_thesis_appendix3_data(idx8to2(ab_thesis_appendix8_male_idx),1), ab_thesis_total_fibers(ab_thesis_appendix8_male_idx), 'b')
        hold on;
        shf = scatter(ab_thesis_appendix3_data(idx8to2(ab_thesis_appendix8_female_idx),1), ab_thesis_total_fibers(ab_thesis_appendix8_female_idx), 'r')
        legend([shm shf], {'Male', 'Female'});
        plot(get(gca, 'xlim'), polyval(polyfit(ab_thesis_appendix3_data(idx8to2(ab_thesis_appendix8_male_idx),1),ab_thesis_total_fibers(ab_thesis_appendix8_male_idx),1), get(gca, 'xlim')), 'b--')
        plot(get(gca, 'xlim'), polyval(polyfit(ab_thesis_appendix3_data(idx8to2(ab_thesis_appendix8_female_idx),1),ab_thesis_total_fibers(ab_thesis_appendix8_female_idx),1), get(gca, 'xlim')), 'r--')
        xlabel('Age'); ylabel('Total fibers');
    end;
    return

    % total fibers with density
    corr(ab_thesis_total_fibers, ab_thesis_total_density)
    pc(ab_thesis_appendix2_data(idx8to2,1), ab_thesis_total_density, [ab_thesis_appendix3_data(idx8to2,1)])

    % relationship between total fibers and # small fibers
    [a] = pc(ab_thesis_total_fibers, sum(ab_thesis_region_area_norm.*ab_thesis_appendix4_data,2), [ab_thesis_appendix2_data(idx8to2,1)])
    [a] = pc(ab_thesis_total_fibers, sum(ab_thesis_region_area_norm.*ab_thesis_appendix5_data,2), [ab_thesis_appendix2_data(idx8to2,1)])

    % how does callosal area change with # fibers, with age partialed out?
    [a] = pc(ab_thesis_appendix2_data(idx8to2,1), sum(ab_thesis_region_area_norm.*ab_thesis_appendix4_data,2), [ab_thesis_appendix3_data(idx8to2,1)])
    [a] = pc(ab_thesis_appendix2_data(idx8to2,1), sum(ab_thesis_region_area_norm.*ab_thesis_appendix5_data,2), [ab_thesis_appendix3_data(idx8to2,1)])

    figure;
    scatter(ab_thesis_total_fibers, ab_thesis_total_density)
    xlabel('Total fibers'); ylabel('Total density');

    %% callosal area

    % with age
    corr(ab_thesis_appendix2_data(:,1), ab_thesis_appendix3_data(:,1))

    % with density
    corr(ab_thesis_appendix2_data(idx8to2,1), ab_density_correction*ab_thesis_total_density)
    partialcorr(ab_thesis_appendix2_data(idx8to2,1), ab_density_correction*ab_thesis_total_density, ab_thesis_appendix3_data(idx8to2,1)) % partial out age
    figure;
    scatter(ab_thesis_appendix2_data(idx8to2,1), ab_density_correction*ab_thesis_total_density)
    hold on;
    plot(get(gca, 'xlim'), polyval(polyfit(ab_thesis_appendix2_data(idx8to2,1), ab_density_correction*ab_thesis_total_density, 1), get(gca, 'xlim')), 'b--')
    set(gca, 'ylim', [2200 3600]);%ab_density_correction*[min(ab_thesis_appendix4_data(:)) max(ab_thesis_appendix4_data(:))])
    xlabel('CC area'); ylabel('Density');

    % since area does not correlate with age, but # fibers does, that means
    %   that


    % Correlation with

    % missing data:
    %   we know how much volume each axon takes
    %   we know the filling fraction (87%)
    %   we know the shape of the distribution of missing fibers
    %   therefore we can estimate the area that has fibers but we missed
    %   therefore we can estimate the number of fibers that we missed
    %
    %
    ab_thesis_database = [ab_thesis_appendix1_data(idx8to2,:) ab_thesis_appendix2_data(idx8to2,:) ab_thesis_appendix3_data(idx8to2,:) ab_thesis_appendix4_data ab_thesis_appendix8_data]
    ab_thesis_features = [ab_thesis_SF_asymmetry_idx ab_thesis_PT_asymmetry_idx ab_thesis_OT_asymmetry_idx ab_thesis_total_density.^2];

    ab_thesis_headers = [ab_thesis_appendix1_cols ab_thesis_appendix2_cols ab_thesis_appendix3_cols ab_thesis_appendix4_cols ab_thesis_appendix8_cols]

    %% correlate across fiber sizes
    figure;
    scatter( sum(ab_thesis_region_area_norm.*ab_thesis_appendix7_data,2), ... %
          sum(ab_thesis_region_area_norm.*ab_thesis_appendix6_data,2))
    xlabel(sprintf('Fiber count (%s)', ab_thesis_appendix7_title));
    ylabel(sprintf('Fiber count (%s)', ab_thesis_appendix6_title));

    corr( sum(ab_thesis_region_area_norm.*ab_thesis_appendix7_data,2), ...
          sum(ab_thesis_region_area_norm.*ab_thesis_appendix6_data,2))
    corr( sum(ab_thesis_region_area_norm.*ab_thesis_appendix6_data,2), ...
          sum(ab_thesis_region_area_norm.*ab_thesis_appendix5_data,2))
    corr( sum(ab_thesis_region_area_norm.*ab_thesis_appendix5_data,2), ...
          sum(ab_thesis_region_area_norm.*ab_thesis_appendix4_data,2))

    figure;
    scatter( sum(ab_thesis_region_area_norm.*ab_thesis_appendix5_data,2), ...
          sum(ab_thesis_region_area_norm.*ab_thesis_appendix4_data,2))
    xlabel(sprintf('Fiber count (%s)', ab_thesis_appendix5_title));
    ylabel(sprintf('Fiber count (%s)', ab_thesis_appendix4_title));

    [a,rx1,ry1] = pc( sum(ab_thesis_region_area_norm.*ab_thesis_appendix5_data,2), ...
                 sum(ab_thesis_region_area_norm.*ab_thesis_appendix4_data,2), ...
                 ab_thesis_appendix3_data(idx8to2,1)) % something with age
    [a,rx2,ry2] = pc( sum(ab_thesis_region_area_norm.*ab_thesis_appendix5_data,2), ...
                 sum(ab_thesis_region_area_norm.*ab_thesis_appendix4_data,2), ...
                 ab_thesis_appendix2_data(idx8to2,1)) % something with callosal area
    [a,rx3,ry3] = pc( sum(ab_thesis_region_area_norm.*ab_thesis_appendix6_data,2), ...
                 sum(ab_thesis_region_area_norm.*ab_thesis_appendix4_data,2), ...
                 [ab_thesis_appendix2_data(idx8to2,1) ab_thesis_appendix3_data(idx8to2,1)] ) % something age and callosal area partialed out

    partialcorr( sum(ab_thesis_region_area_norm.*ab_thesis_appendix5_data,2), ...
                 sum(ab_thesis_region_area_norm.*ab_thesis_appendix4_data,2), ...
                 ab_thesis_OT_asymmetry_idx) % nothing



    %function scatter_corr(X,Y,Z)


    %    if exist('Z','var')
    %        t = sprintf('partial corr = %.3f', partialcorr(X,Y,Z));
    %    else
    %        t = sprintf('corr = %.3f', corr(X,Y))
    %    end;

    %    figure;
    %    set(gca, 'fontsize', 14)
    %    scatter(X,Y);
    %    title(t);


