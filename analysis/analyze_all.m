function analyze_all()
%
% Collect all datasets

    if ~exist('force', 'var'), force = false; end;

    %% Add paths
    script_dir = fileparts(which(mfilename));
    rilling_dir = fullfile(script_dir, '..');
    addpath(genpath(fullfile(rilling_dir, '_lib')));
    addpath(genpath(fullfile(rilling_dir, '_predict')));


    %% Loop over all directories and mat files to create datasets
    local_files = dir(script_dir);
    local_dirs = local_files([local_files.isdir]);
    for di = 1:length(local_dirs)
        local_dir = local_dirs(di);

        if ismember(local_dir.name, {'.', '..', 'riise_pakkenerg_2011'}) || ~ismember(local_dir.name, {'aboitiz_thesis'})
            fprintf('Skipping directory "%s"\n', local_dir.name);
            continue;
        end;

        % Find files for doing computations
        analysis_mfiles = dir(fullfile(script_dir, local_dir.name, '*_analysis.m'));
        if isempty(analysis_mfiles), continue; end;

        data_matfiles = dir(fullfile(script_dir, local_dir.name, '*_data.mat'));
        if isempty(data_matfiles),
            fprintf('Skipping directory with no data "%s"\n', local_dir.name);
        end;

        % Run each file
        cur_dir = pwd;
        cd(fullfile(script_dir, local_dir.name));
        for fi=1:length(analysis_mfiles)

            % MAT file is put in the 'analysis' directory;
            %  if it's there, nothing left to do.
            analysis_mfile = analysis_mfiles(fi);


            % Load data
            varnames = {};
            varvals = {};
            for mfi=1:length(data_matfiles)
                data_matfile = data_matfiles(mfi);
                vars = load(fullfile(script_dir, local_dir.name, data_matfile.name));
                varnames = [varnames fieldnames(vars)];
                varvals = [varvals struct2cell(vars)];
            end;
            vars = cell2struct(varvals, varnames);


            % Need to run the mfile to get the vars out,
            %   then to dump the vars to a MAT file.
            %try
                % Run the data analysis; output is a struct
                fprintf('Running "%s" ... ', fullfile(local_dir.name, analysis_mfile.name));
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

