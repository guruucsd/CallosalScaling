ria_dir = fileparts(which(mfilename));
ria_datafile = fullfile(ria_dir, 'ria_data.mat');

if exist(ria_datafile, 'file')
    load(ria_datafile);

else
    addpath(genpath(fullfile(ria_dir, '..', '..', '_lib'))); 

    %% Static data
    ria_table1_species = {'h. sapiens', 'p. paniscus', 'p. troglodytes', 'g. gorilla', 'P. pygmaeus', 'H. lar', 'P. cynocephalus', 'M. mulatta', 'C. atys', 'C. apella', 'S. sciureus'};
    ria_table1_bodyweight = [67.7 45.4 55.4 61.7 73.5 5.4 21.9 10.4 8.8 3.2 0.9]; % how can brain vol & body vol diverge for gorilla?
    ria_table1_spine_area = [103.0 70.9 106.4 117.6 110.5 43.6 73.4 51.2 nan 38.6 18.8];
    ria_table1_brainvol =   [1298.9 311.2 337.3 397.5 406.9 83.0 143.3 79.1 98.9 66.5 23.1];
    ria_table1_gmvol    =   [583 142.9 147.1 152.7 193.3 39.9 65.0 36.5 42.7 31.9 11.7];
    ria_table1_wmvol    =   [397.4 75.6 4.7 90.9 94.2 94.4 16.7 35.1 19.2 21.2 13.1 4.8];
    ria_table1_families = {'humans' 'pongids' 'pongids' 'pongids' 'pongids' 'hylobatids' 'cercopithecids' 'cercopithecids' 'cercopithecids' 'cebids' 'cebids'};
    
    ria_table6_gi = [2.57 2.17 2.19 2.07 2.29 1.90 2.03 1.73 1.84 1.60 1.56];
    vars = who('ria_*');
    save(ria_datafile, vars{:});
end;
