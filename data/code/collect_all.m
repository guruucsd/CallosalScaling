function collect_all(datasets, force, validate_data, visualize_data)
%
% Collect all datasets

    %% Add paths
    script_dir = fileparts(which(mfilename));
    project_dir = fileparts(script_dir);  % parent directory
    addpath(genpath(fullfile(project_dir, '_lib')));

    % Default values
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
        if ~exist(local_dir, 'file')
            fprintf('WARNING: files for creating requested dataset do not exist: %s, %s\n', dataset, local_dir);
            continue;
        end;

        data_mfiles = dir(fullfile(local_dir, '*_data.m'));
        if isempty(data_mfiles)
            continue;
        end;

        % Run each file
        cur_dir = pwd;
        cd(local_dir);
        for fi=1:length(data_mfiles)

            % MAT file is put in the 'data' directory;
            %  if it's there, nothing left to do.
            data_mfile = data_mfiles(fi);
            [~, cwd_name] = fileparts(script_dir);
            mat_dirpath = strrep(script_dir, cwd_name, 'matfiles');
            mat_filepath = fullfile(mat_dirpath, sprintf('%s.mat', dataset));
            if exist(mat_filepath, 'file') && ~force
                fprintf('Found existing mat file for %s in %s\n', fullfile(dataset, data_mfile.name), mat_filepath);
                continue;
            end;

            % Need to run the mfile to get the vars out,
            %   then to dump the vars to a MAT file.
            %try
                % Run the data collection; output is a struct
                fprintf('Running "%s" ... ', fullfile(dataset, data_mfile.name));
                vars = eval(sprintf('%s(validate_data, visualize_data);', data_mfile.name(1:end-2))); % run as a matlab script
                close all;  % in case any plots were generated

                % Save the variables by decomposing the struct,
                %   assigning the vars locally, saving,
                %   then cleaning up.
                varnames = fieldnames(vars);
                varvals = struct2cell(vars);
                for vi=1:length(varnames)
                    eval(sprintf('%s = varvals{%d};', varnames{vi}, vi));
                end;

                % Create directory and save
                if ~exist(mat_dirpath, 'dir')
                    mkdir(mat_dirpath);
                end;
                save(mat_filepath, varnames{:});

                % Clean up variables.
                if isempty(varnames)
                    error('no');
                else
                    clear(varnames{:});
                end;

                fprintf('DONE.\n');
            %catch err
            %    fprintf('FAILURE: %s\n', err);
            %    %keyboard;
            %end;
        end;
        cd(cur_dir);

    end;

