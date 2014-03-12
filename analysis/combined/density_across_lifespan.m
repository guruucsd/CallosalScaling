% Take data from across the cat, monkey, and human lifespans and show next
% to each other, to illustrate the missing human data.
curdir = fileparts(which(mfilename));
addpath(fullfile(curdir, '..', 'berbel_innocenti_1988')); bi_data;
addpath(fullfile(curdir, '..', 'lamantia_rakic_1990s'));  lrs_data;
addpath(fullfile(curdir, '..', 'luttenberg_1965'));       lut_data;
addpath(fullfile(curdir, '..', 'rakic_yaklovev_1968'));   ry_data;

species = {'cat' 'macaque' 'human'}
ages = { bi_fig7_dates   lrs_age      [lut_table1_age 270+365*44]};
dens = { bi_fig7_density lrs_dens/100 [lut_table2_nfibers(:,end)./lut_table2_areas(:,end)/1E6; 0.3717*1.2*1.2*0.65]};


yl = [0 10];

figure; set(gcf, 'Position', [ 69         258        1212         405]);
for si=1:length(species)
    subplot(1,length(species),si);
    set(gca, 'FontSize', 14);
    
    semilogx(str2date('P0',species{si})*[1 1], yl, 'r--', 'LineWidth', 2);
    hold on;
    semilogx(ages{si}, dens{si}, 'o', 'MarkerSize', 4, 'LineWidth',4); 
    axis square;
    set(gca, 'xlim', [0 str2date('death', species{si})]);
    set(gca, 'ylim', yl);
    xlabel('Age (days since conception)');
    ylabel('million axons/mm^2');
    title(species{si}, 'FontSize', 18); 

end;
