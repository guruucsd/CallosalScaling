    function w_gp_regress(vars)

    human_brain_weight = get_human_brain_weight();

    %% load variables into the current workspace
    varnames = fieldnames(vars);
    varvals = struct2cell(vars);
    for vi=1:length(varnames)
        eval(sprintf('%s = varvals{vi};', varnames{vi}))
    end;


    %% Now do gaussian process regression
    % comparing how the process fits
    % with and without data
    f = figure; set(gcf, 'Position', [10         317        1247         367]);
    subplot(1,4,1);    set(gca, 'FontSize', 14);
    imgpath = fullfile(strrep(pwd, 'analysis', 'data_collection'), 'img', 'wang_etal_fig1c.png');
    if exist(imgpath, 'file')
        img = imread(imgpath);
        imshow(img);
    end;
    hold on;
    title(sprintf('Wang et. al (2008) data'));

    % wang data, plus estimate for human
    x0 = log(w_fig1c_weights(:));
    y0 = w_fig1c_pctmye(:);
    gpreg(x0,y0); ax0 = gca;


    figure(f);
    subplot(1,4,2);    mfe_ax2ax(ax0,gca); axis square;
    set(gca, 'FontSize', 14);
    xlabel('log_{10}(brain weight)');
    ylabel('P(myelinated)')
    set(gca, 'ytick',[0 50 100], 'yticklabel', {'0%' '50%' '100%'});
    set(gca, 'ylim', [-25 125], 'xlim', [-3.5 5.5])
    title(sprintf('GP regression;\nOriginal data'));


    % wang data, plus estimate for human
    x1 = log([w_fig1c_weights(:);human_brain_weight]);
    y1 = [w_fig1c_pctmye(:); 95];
    gpreg(x1,y1); ax1 = gca;

    figure(f);
    subplot(1,4,3);    mfe_ax2ax(ax1,gca); axis square;
    set(gca, 'FontSize', 14);
    xlabel('log_{10}(brain weight)');
    ylabel('P(myelinated)')
    set(gca, 'ytick',[0 50 100], 'yticklabel', {'0%' '50%' '100%'});
    set(gca, 'ylim', [-25 125], 'xlim', [-3.5 5.5])
    title(sprintf('GP regression;\nData + human pt.'));


    % redo, but with fake data to show sigmoidal shape
    x2 = log([1E-2; w_fig1c_weights(:); human_brain_weight; 5000; 12000]);
    y2 = [mean(w_fig1c_pctmye(1:2)); w_fig1c_pctmye(:); 95; 96; 97];
    gpreg(x2,y2); ax2 = gca;

    figure(f);
    subplot(1,4,4);    mfe_ax2ax(ax2,gca); axis square;
    set(gca, 'FontSize', 14);
    xlabel('log_{10}(brain weight)');
    ylabel('P(myelinated)')
    set(gca, 'ytick',[0 50 100], 'yticklabel', {'0%' '50%' '100%'});
    set(gca, 'ylim', [-25 125], 'xlim', [-3.5 5.5])
    title(sprintf('GP regression;\nData + human + faux pts.'));


    %% Now do a gaussian process regression.
    %  Input dimensions:
    %  brain size (to represent species)
    %  brain_diameters
    %  pct_myelination
    %  density
    %  axon diameters
    % Train to compute:
    %  probability
    %

    % Try first on 1D regression
    % diameter vs probability
%    gpreg(w_fig4_xvals(1:10:end), w_fig4_myelinated(1,1:10:end)', 10);

%    w_fig4_brain_weights = w_brain_weights(ismember(w_fig4_species,w_species));

%    nspecies = length(w_fig4_species);





%% Not sure what this does
    samps = round(1:10:2*length(w_fig4_xvals)/3); nsamps = length(samps);
    axi = zeros(3,1);
    for ns = [2 3 6]
        nspecies = ns;
        w_fig4_myelinated    = w_fig4_myelinated_orig(1:nspecies,:);
        w_fig4_unmyelinated  = w_fig4_unmyelinated_orig(1:nspecies,:);
        w_fig4_brain_weights = w_brain_weights(ismember(w_fig4_species(1:nspecies),w_species));

        xvals_col     = repmat(w_fig4_xvals(samps)', [nspecies 1]);
        bws_col       = reshape(repmat(log(w_fig4_brain_weights(:)'), [nsamps 1]), [nsamps*nspecies 1]);
        myaxdiam_col  = reshape(w_fig4_myelinated(:,samps)', [nsamps*nspecies 1]);
        unmyaxdiam_col= reshape(w_fig4_unmyelinated(:,samps)', [nsamps*nspecies 1]);

        [hyp, inffunc, meanfunc, covfunc, likfunc] = gpreg([xvals_col bws_col], unmyaxdiam_col, true);

        axi(ns) = gca;
    end;

    figure('Name', 'Unknown plot in w_gp_regress');
    subplot(1,3,1);
    mfe_ax2ax(axi(1), gca);
    %view(47.5, 54)

    subplot(1,3,2);
    mfe_ax2ax(axi(2), gca);
    %view(47.5, 54)

    subplot(1,3,3);
    mfe_ax2ax(axi(3), gca);
    %view(47.5, 54)

