ki_path = fileparts(which(mfilename));
data_file = fullfile(ki_path, 'ki_data.mat');

consistency_check = false;

if ~exist(data_file, 'file')
    ki_tab1_age = {'N0' 'N0' 'N0' 'N0' 'adult' 'adult' 'adult'};
    ki_tab1_cca = [9.96 9.447 10.028 7.191 25.941 21.985 18.359];
    ki_tab1_nmye_large = [2.465 1.238 2.901 2.187 10.655 11.905 11.151]*1E6;
    ki_tab1_nmye_small = [79.007 86.970 76.441 65.442 7.601 14.996 14.286]*1E6;

    dens = (ki_tab1_nmye_large+ki_tab1_nmye_small)./ki_tab1_cca;

    vars = who('ki_*');
    save(data_file, vars{:});
end;

if consistency_check
    mean(dens(1:4))/1E6, mean(dens(5:end))/1E6
end;
