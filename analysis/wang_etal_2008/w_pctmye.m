function w_pctmye(vars, fit_type)

    %% load variables into the current workspace
    varnames = fieldnames(vars);
    varvals = struct2cell(vars);
    for vi=1:length(varnames)
        eval(sprintf('%s = varvals{vi};', varnames{vi}))
    end;
    human_brain_weight = get_human_brain_weight();

    
    % Set up data
    [~,~,uidx] = unique(w_fig1c_weights);
    mean_weights = zeros(length(w_fig1c_species), 1);
    mean_pctmye = zeros(length(w_fig1c_species), 1);
    for si=1:length(w_fig1c_species)  % average over datapoints within a species
        mean_pctmye(si) = 0.01 * mean(w_fig1c_pctmye(uidx == si)); % convert 0..100 to 0..1
        mean_weights(si) = mean(w_fig1c_weights(uidx == si)); % convert 0..100 to 0..1
    end;
    [x, sidx] = sort([mean_pctmye; human_brain_weight]); x = x';
    y = [mean_pctmye; 0.92]; y = 1 - y(sidx)';

    % Regress exponential decay WITH human
    [pmye,gmye.y] = fit_exp_decay(x, y, 100*rand(1,3), false);
    x2 = linspace(x(1), x(end), 100000);

    figure('Name', 'Exponential fit w/ human datapoint');
    subplot(1,2,1);
    semilogx(x, y, 'o');
    hold on;
    semilogx(x2, gmye.y(x2));
    title('semilog');
    xlabel('brain weight (g)'); ylabel('% unmyelinated');

    subplot(1,2,2);
    plot(x,y,'o');
    hold on;
    plot(x2,gmye.y(x2));
    title('cartesian')
    xlabel('brain weight (g)'); ylabel('% unmyelinated');

    % Regress exponential decay WITHOUT
    %figure;
    %semilogx(x(1:end-1),y(1:end-1),'o');
    %hold on;
    %semilogx(x(1:end-1),gmye.y(x(1:end-1)));
    %xlabel('brain weight (g)'); ylabel('% unmyelinated');


    % Regress logistic WITH human
    B = glmfit(x', [y'/100 ones(size(y'))], 'binomial', 'link', 'logit');

    logistic = @(x,p) 1./(1+exp(-p(1)-x.*p(2)));
    x2 = linspace(x(1),x(end),100);

    figure('Name', 'Logistic fit w/ human datapoint');
    semilogx(x,y,'o');
    hold on;
    semilogx(x2,100*logistic(x2,B));
    xlabel('brain weight (g)'); ylabel('% unmyelinated');
