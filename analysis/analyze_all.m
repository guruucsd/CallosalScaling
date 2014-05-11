function analyze_all(datasets, force, validate_data, visualize_data)

%
% Collect all datasets
    
    %% Add paths
    script_dir = fileparts(which(mfilename));
    rilling_dir = fullfile(script_dir, '..');
    addpath(genpath(fullfile(rilling_dir, '_lib')));
    addpath(genpath(fullfile(rilling_dir, '_predict')));

   %% Default values
    if ~exist('datasets', 'var') || isempty(datasets)
        local_files = dir(script_dir);
        local_dirs = local_files([local_files.isdir]);
        datasets = { local_dirs.name };
    elseif ischar(datasets)
        datasets = { datasets };
    end;
    if ~exist('force', 'var'), force = false; end;
    if ~exist('validate_data', 'var'), validate_data = false; end;
    if ~exist('visualize_data', 'var'), visualize_data = false; end;


    %% Loop over all directories and mat files to create datasets
    for di = 1:length(datasets)
        dataset = datasets{di};

        if ismember(dataset, {'.', '..', 'riise_pakkenerg_2011'})% || ~ismember(dataset, {'herculano-houzel_etal_2010'})
            fprintf('Skipping directory "%s"\n', dataset);
            continue;
        end;


        % Find files for doing computations
        local_dir = fullfile(script_dir, dataset);
        analysis_mfiles = dir(fullfile(local_dir, '*_analysis.m'));
        if isempty(analysis_mfiles), continue; end;

        data_matfiles = dir(fullfile(local_dir, '*_data.mat'));
        if isempty(data_matfiles),
            fprintf('Skipping directory with no data "%s"\n', local_dir);
        end;

        % Run each file
        cur_dir = pwd;
        cd(local_dir);
        for fi=1:length(analysis_mfiles)

            % MAT file is put in the 'analysis' directory;
            %  if it's there, nothing left to do.
            analysis_mfile = analysis_mfiles(fi);


            % load data
            varnames = {};
            varvals = {};
            for mfi=1:length(data_matfiles)
                data_matfile = data_matfiles(mfi);
                vars = load(fullfile(local_dir, data_matfile.name));
                varnames = [varnames fieldnames(vars)];
                varvals = [varvals struct2cell(vars)];
            end;
            vars = cell2struct(varvals, varnames);


            % Need to run the mfile to get the vars out,
            %   then to dump the vars to a MAT file.
            %try
                % Run the data analysis; output is a struct
                fprintf('Running "%s" ... ', fullfile(local_dir, analysis_mfile.name));
                eval(sprintf('%s(vars);', analysis_mfile.name(1:end-2))); % run as a matlab script
                %close all;  % in case any plots were generated

                fprintf('DONE.\n');
            %catch err
            %    fprintf('FAILURE: %s\n', err);
            %    keyboard;
            %end;
        end;
        cd(cur_dir);

    end;

