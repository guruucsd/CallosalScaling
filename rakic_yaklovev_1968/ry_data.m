ry_path = fileparts(which(mfilename));
data_file = fullfile(ry_path, 'oli0_data.mat');

if ~exist(data_file, 'file')
    ry_ages = [[20 24 28 32 36 40]*7 12*30 40*365];
    ry_areas = [22.6 37.0 52.0 51.8 55.6 67.2 147.9 325.1]; % (correct by /0.5?)

    vars = who('ry_*');
    save(data_file, vars{:});
end;

if consistency_check
    %figure; semilogx(ry_ages, ry_areas, 'o');
end;
