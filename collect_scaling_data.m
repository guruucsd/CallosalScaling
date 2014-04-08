addpath(genpath(fullfile(fileparts(which(mfilename)), 'data')));
datasets = { ...
    'aboitiz_etal_1992', ...  % human data comparison
    'aboitiz_thesis', ...  % age correction
    'lamantia_rakic_1990a', ... % age correction
    'lamantia_rakic_1990b', ... % age correction
    'rilling_insel_1999a', ... % GI
    'rilling_insel_1999b', ... %callosal area
    'tower_1954', ... % grey matter neuron density
    'wang_etal_2008' % callosal axon density
};
collect_all(datasets)