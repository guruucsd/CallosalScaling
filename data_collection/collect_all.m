%%
script_dir = fileparts(which(mfilename));
addpath(genpath(fullfile(script_dir, '..', '..', '_lib')));
addpath(genpath(fullfile(script_dir, '..', '_combined')));
addpath(genpath(fullfile(script_dir, '..', '_lib')));
addpath(genpath(fullfile(script_dir, '..', '_predict')));

%%
local_files = dir(script_dir);
local_dirs = local_files([local_files.isdir]);
for di = 1:length(local_dirs)
    local_dir = local_dirs(di);

    if ismember(local_dir.name, {'.', '..', 'riise_pakkenerg_2011'})
        fprintf('Skipping directory "%s"\n', local_dir.name);
        continue;
    end;
    
    % Find files for doing computations
    data_files = dir(fullfile(script_dir, local_dir.name, '*_data.m'));
    if isempty(data_files)
        continue;
    end;
    
    % Run each file
    cur_dir = pwd;
    cd(fullfile(script_dir, local_dir.name));
    for fi=1:length(data_files)
        data_file = data_files(fi);
        try
            fprintf('Running "%s" ... ', fullfile(local_dir.name, data_file.name));
            eval(data_file.name(1:end-2)); % run as a matlab script
            close all;
            fprintf('DONE.\n');
        catch err
            fprintf('FAILURE: %s\n', err);
            keyboard;
        end;
    end;
    cd(cur_dir);

end;

