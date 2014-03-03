function collect_all(force)
%
% Collect all datasets

    if ~exist('force', 'var'), force = false; end;
    
    %% Add paths
    script_dir = fileparts(which(mfilename));
    addpath(genpath(fullfile(script_dir, '..', '..', '_lib')));
    addpath(genpath(fullfile(script_dir, '..', '_combined')));
    addpath(genpath(fullfile(script_dir, '..', '_lib')));
    addpath(genpath(fullfile(script_dir, '..', '_predict')));

    
    %% Loop over all directories and mat files to create datasets
    local_files = dir(script_dir);
    local_dirs = local_files([local_files.isdir]);
    for di = 1:length(local_dirs)
        local_dir = local_dirs(di);

        if ismember(local_dir.name, {'.', '..', 'riise_pakkenerg_2011'})% || ~ismember(local_dir.name, {'herculano-houzel_etal_2010'})
            fprintf('Skipping directory "%s"\n', local_dir.name);
            continue;
        end;

        % Find files for doing computations
        data_mfiles = dir(fullfile(script_dir, local_dir.name, '*_data.m'));
        if isempty(data_mfiles)
            continue;
        end;

        % Run each file
        cur_dir = pwd;
        cd(fullfile(script_dir, local_dir.name));
        for fi=1:length(data_mfiles)
            
            % MAT file is put in the 'analysis' directory; 
            %  if it's there, nothing left to do.
            data_mfile = data_mfiles(fi);
            mat_filepath = fullfile(strrep(script_dir, 'data_collection', 'analysis'), local_dir.name, sprintf('%s.mat', data_mfile.name(1:end-2)));
            if exist(mat_filepath, 'file') && ~force
                fprintf('Found existing mat file for %s\n', fullfile(local_dir.name, data_mfile.name));
                continue;
            end;

            % Need to run the mfile to get the vars out,
            %   then to dump the vars to a MAT file.
            %try
                % Run the data collection; output is a struct
                fprintf('Running "%s" ... ', fullfile(local_dir.name, data_mfile.name));
                vars = eval(sprintf('%s(false);', data_mfile.name(1:end-2))); % run as a matlab script
                close all;  % in case any plots were generated

                % Save the variables by decomposing the struct, 
                %   assigning the vars locally, saving,
                %   then cleaning up.
                varnames = fieldnames(vars);
                varvals = struct2cell(vars);
                for vi=1:length(varnames)
                    eval(sprintf('%s = varvals{%d};', varnames{vi}, vi));
                end;
                save(mat_filepath, varnames{:});
                if isempty(varnames)
                    error('no');
                else
                    clear(varnames{:});
                end;
                
                fprintf('DONE.\n');
            %catch err
            %    fprintf('FAILURE: %s\n', err);
            %    keyboard;
            %end;
        end;
        cd(cur_dir);

    end;

