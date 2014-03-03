function vars = lrs_data(validate_data)
%
% Cross-species primate brain data from Rilling & Insel (1999a), 
%   largely complementary to callosal data in 1999b.
% Includes:
% * Brain volume
% * Grey & white matter volumes

    if ~exist('validate_data', 'var'), validate_data = true; end;

    lrs_dir = fileparts(which(mfilename));

    
    %% Collect data
    % Run data collection for lamantia
    for lc='ab'
        addpath(fullfile(lrs_dir, '..', sprintf('lamantia_rakic_1990%s', lc)));
        eval(sprintf('vars = lr%s_data(validate_data);', lc));
        close all;

        % Parse variables
        varnames = fieldnames(vars);
        varvals = struct2cell(vars);
        for vi=1:length(varnames)
            eval(sprintf('%s = varvals{%d};', varnames{vi}, vi));
        end;
    end;
    
    % Combine density, area, connections, across lifespan
    lrs_age  = [lrb_tab_ages lra_cc_age*365];
    lrs_dens = [lrb_tab_ccdens lra_cc_density];
    lrs_area = [lrb_tab_ccarea lra_cc_area];
    lrs_nic  = [lrb_tab_ccnic lra_cc_naxons];
    lrs_pctmy= [lrb_tab_pctmy lra_cc_pctmyelinated_est*ones(size(lra_cc_naxons))];% fudge it
    
    
    %% Reconstruct outputs
    varnames = 	who('lrs_*', 'lra_*', 'lrb_*');  
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);

    
    %%
    if validate_data
    end;