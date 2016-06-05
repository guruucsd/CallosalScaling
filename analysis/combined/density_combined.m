clear all;

curdir = fileparts(which(mfilename));
project_dir = fullfile(curdir, '..', '..');
addpath(fullfile(project_dir, '_lib'));
addpath(fullfile(project_dir, '_predict'));

% Get density data across studies
analysis_dir = fullfile(project_dir, 'analysis');
load(fullfile(analysis_dir, 'wang_etal_2008', 'w_data'));
load(fullfile(analysis_dir, 'lamantia_rakic_1990a', 'lra_data'));

human_brain_weight = get_human_brain_weight();
human_brain_dens = 0.3717*1.2*0.65;  % shrinkage and microscopy corrections; age done afterwards.
human_brain_age = mean([43.5 46.4]);

    %% Regress Wang data, show human & macaque data
    pdens = [polyfit(log10([w_fig1e_weights]), log10([w_fig1e_dens_est]),1)];
    gdens = @(wt) 10.^(polyval(pdens, log10(wt)));

    figure; set(gcf, 'Position', [25         313        1130         371]);
    subplot(1,2,1);    hold on;
    plot(log10(w_fig1e_weights), w_fig1e_dens_est,'o');
    plot(log10([w_fig1e_weights human_brain_weight]),gdens([w_fig1e_weights human_brain_weight]) );
    plot(log10(human_brain_weight), human_brain_dens, 'g*');
    plot(log10(w_fig1e_weights(end)), (lra_cc_density/100), 'k*');
    title('Macaque Brain weight vs. density (semilog)');

    subplot(1,2,2);    hold on;
    plot(log10(w_fig1e_weights), log10(w_fig1e_dens_est),'o');
    plot(log10([w_fig1e_weights human_brain_weight]),log10(gdens([w_fig1e_weights human_brain_weight])) );
    plot(log10(human_brain_weight), log10(human_brain_dens), 'g*');
    plot(log10(w_fig1e_weights(end)), log10(lra_cc_density/100), 'k*');
    title('Macaque Brain weight vs. density (loglog)');


    %% Regress macaque data on age, predict human data over lifespan
    % Get a function of density vs age for macaque
    p_maqdens  = polyfit(log10(lra_cc_age), log10(lra_cc_density), 1);
    g_maqdens  = @(m_age) 10.^polyval(p_maqdens, log10(m_age));

    % Get a function of human post-natal age vs macaque post-natal age
    % macaque: sexual maturity at 4, lifespan 25
    % human: sexual maturity at 15, lifespan 73
    h_age = @(m_age) ((m_age<=4) .*(m_age/4*15) + (m_age>4) .*(15+((m_age-4) /(25-4) *(73-15))));
    m_age = @(h_age) ((h_age<=15).*(h_age/15*4) + (h_age>15).*( 4+((h_age-15)/(73-15)*(25-4))));

    % Get a function of human density vs macaque density
    %
    % Get the base human density at age=human_brain_age, then map the
    h_dens = @(h_age) human_brain_dens * g_maqdens(m_age(h_age)) / g_maqdens(human_brain_age);

    % Now plot estimated human density, across the lifespan
    [lra_cc_age_s,sidx] = sort(lra_cc_age);
    mages = linspace(min(lra_cc_age), max(lra_cc_age), 50);
    figure; set(gcf, 'Position', [25         313        1130         371]);
    subplot(1,2,1);    hold on;
    plot((h_age(lra_cc_age_s)), h_dens(h_age(lra_cc_age_s)), 'o');
    plot((h_age(mages)),        h_dens(h_age(mages)));
    title('Human axon density, over the life-span (semilog)');

    subplot(1,2,2);    hold on;
    plot(log10(h_age(lra_cc_age_s)), log10(h_dens(h_age(lra_cc_age_s))), 'o');
    plot(log10(h_age(mages)),        log10(h_dens(h_age(mages))));
    title('Human axon density, over the life-span (loglog)');

    %% Show wang data again, with human predictions across the lifespan

    figure; set(gcf, 'Position', [25         313        1130         371]);
    subplot(1,2,1);    hold on;
    plot(log10(w_fig1e_weights), w_fig1e_dens_est,'o');
    plot(log10([w_fig1e_weights human_brain_weight]),gdens([w_fig1e_weights human_brain_weight]) );
%    plot(log10(human_brain_weight), human_brain_dens/1.2, 'r*');
%    plot(log10(human_brain_weight), human_brain_dens, 'g*');
    plot(log10(w_fig1e_weights(end)), (lra_cc_density/100), 'k*');
    plot(log10(human_brain_weight), (h_dens(h_age(lra_cc_age_s))), 'g*');
    title('Macaque Brain weight vs. density (semilog)');

    subplot(1,2,2);    hold on;
    plot(log10(w_fig1e_weights), log10(w_fig1e_dens_est),'o');
    plot(log10([w_fig1e_weights human_brain_weight]),log10(gdens([w_fig1e_weights human_brain_weight])) );
%    plot(log10(human_brain_weight), log10(human_brain_dens/1.2), 'r*');
%    plot(log10(human_brain_weight), log10(human_brain_dens), 'g*');
    plot(log10(w_fig1e_weights(end)), log10(lra_cc_density/100), 'k*');
    plot(log10(human_brain_weight), log10(h_dens(h_age(lra_cc_age_s))), 'g*');
    title('Macaque Brain weight vs. density (loglog)');




    % How to show that this is reasonable?  Luttenberg data is weak.
    %
    % Compare human cca across development to macaque cca.  If curves are
    % similar, then suggestive.
    %
    % Also, may want to model cca, based on Wang's "fill %"
