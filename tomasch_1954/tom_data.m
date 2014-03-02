tom_dir = fileparts(which(mfilename));
tom_datafile = fullfile(tom_dir, 'tom_data.mat');

if exist(tom_datafile, 'file')
    load(tom_datafile);
    
else
    tom_histograms;

    tom_tab1_surface_area = [142 107 119.5 156 524.5
    130.6 135 109 142 516.6
    228 88 91 148 555];
    tom_tab1_density_weigert = [218873 216728 187698 224936 213136]
    % other data from tables


    vars = who('tom_*');
    save(tom_datafile, vars{:})
end;
