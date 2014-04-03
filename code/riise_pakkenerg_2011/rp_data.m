function vars = rp_data(validate_data)
%
% Dataset:
%   Riise & Pakkenberg (2011)
%
% Data:
%   Old age axon diameter distributions
%
% Tables:
%    Table 1: Age, CC area (cm^2), # MYELINATED fibers, Body height (cm), body weight (kg), brain weight (g), # neurons
%
% Notes:
%   "Fiber sizes and fiber densities ... were not corrected for shrinkage,
%    as tissue shrinkage had a diminutive value (< 1%) negligible for the results."

    if ~exist('validate_data', 'var'), validate_data = true; end;
    if ~exist('visualize_data', 'var'), visualize_data = false; end;

    error('NYI');

    rp_age = [39 40 40 48 52 52 52 59 59 60];
    rp_cc_area = [7.07 nan 8.03 8.84 6.81 5.43 7.54 6.43 6.91 7.85]; %cm^2
    rp_cc_myelinated_fibers = [150 124 148 195 153 126 133 104 106 139] * 10^6; %total # fibers
    rp_body_height = [183 179 167 186 171 175 169 178 185 171]; %cm
    rp_body_weight = [80 85 75 110 77 73 74 87 98 78]; %kg
    rp_brain_weight = [1550 1620 1710 1290 1340 1435 1650 1475 1400 1375]; %g
    rp_number_neurons = [21.0 22.6 23.0 17.6 21.0 30.2 22.8 21.8 17.0 20.2] * 10^9; %10^9



    hp_age = [65 71 72 73 73 74 75 80 81 81 83 83 84 85 94 94 85 97 98 102 105];
    hp_body_height = [nan 157 nan 164 177 nan 160 162 157 157 146 160 169 159 151 nan 151 153 nan nan 150];
    hp_body_weight = [nan 57 nan 52 51 nan 65 47 51 68 46 71 81 39 73 nan 69 36 nan nan 44];
    hp_brain_weight = [1200 1251 1150 1235 1230 1200 nan 1170 1090 1230 1100 1080 1220 1180 1112 940 1180 1100 1170 nan 1129];
    hp_cc_fibers = [];
    hp_cca = [];
    hp_fiber_diameter = [];


    % brain weight (and # neurons) decreases severely with age
    [r,p] = corr(rp_brain_weight', rp_age')
    [r,p] = corr(rp_brain_weight(setdiff(1:end,4))', rp_age(setdiff(1:end,4))')

    % But it's age-related decline, not a relationship between weight and # neurons
    %[r,p] = corr(rp_number_neurons', rp_age')
    [r,p] = corr(rp_number_neurons(setdiff(1:end,4))', rp_age(setdiff(1:end,4))')
    %[r,p] = partialcorr(rp_brain_weight', rp_number_neurons', rp_age')
    [r,p] = partialcorr(rp_brain_weight(setdiff(1:end,4))', rp_number_neurons(setdiff(1:end,4))', rp_age(setdiff(1:end,4))')

    % STRONG negative correlation between #cc fibers and brain weight?
    [r,p] = partialcorr(rp_brain_weight(setdiff(1:end,2))', rp_cc_myelinated_fibers(setdiff(1:end,2))', [rp_age(setdiff(1:end,2))'])

    % but POSITIVE correlation between brain weights and cc area
    [r,p] = corr(rp_brain_weight(setdiff(1:end,[2 4]))', rp_cc_area(setdiff(1:end,[2 4]))')
    [r,p] = partialcorr(rp_brain_weight(setdiff(1:end,[2 4]))', rp_cc_area(setdiff(1:end,[2 4]))', [rp_age(setdiff(1:end,[2 4]))'])

    % NEGATIVE relationship between # neurons and # fibers...
    [r,p] = partialcorr(rp_number_neurons(setdiff(1:end,2))', rp_cc_myelinated_fibers(setdiff(1:end,2))', [rp_age(setdiff(1:end,2))'])


    % Run PCA
    data_names = {'age' 'cc_area' 'cc_fibers' 'body_height' 'body_weight' 'brain_weight' 'number_neurons'};
    all_data = [rp_age' rp_cc_area' rp_cc_myelinated_fibers' rp_body_height' rp_body_weight' rp_brain_weight' rp_number_neurons'];
    good_data = all_data(setdiff(1:end,[2 4]),:);
    norm_data = (good_data-repmat(mean(good_data,1), [size(good_data,1) 1]))./repmat(std(good_data,[],1), [size(good_data,1) 1]))
    %norm_data = (good_data)./repmat(std(good_data,[],1), [size(good_data,1) 1])./repmat(mean(good_data,1), [size(good_data,1) 1]);
    %norm_data = (good_data)./repmat(mean(good_data,1), [size(good_data,1) 1]);
    %C = cov(norm_data);


    [C,p] = partialcorr(norm_data(:,setdiff(1:end,[1 4 5])),norm_data(:,1));
    C = cov(norm_data(:,setdiff(1:end,[4 5])));
    used_data_idx = setdiff(1:length(data_names),[1 4 5]);

    [D,V] = eig(C); [sV,sidx] = sort(diag(V), 'descend');
    for di=1:size(D,2)
        fprintf('%3.1f%% variance', 100*sV(di)/sum(sV));
        for ci=1:size(D,1)
          fprintf('\t%10s: %4.2f', data_names{used_data_idx(ci)}, D(ci,sidx(di)));
        end;
        fprintf('\n');
    end;
    %47.5% variance	       age: -0.60	   cc_area: 0.09	 cc_fibers: 0.51	body_height: -0.09	body_weight: -0.39	brain_weight: 0.23	number_neurons: 0.41
    %32.9% variance	       age: 0.22	   cc_area: -0.54	 cc_fibers: -0.29	body_height: 0.00	body_weight: -0.13	brain_weight: -0.11	number_neurons: 0.74
    %11.0% variance	       age: 0.59	   cc_area: 0.17	 cc_fibers: 0.50	body_height: -0.18	body_weight: -0.39	brain_weight: -0.43	number_neurons: 0.02
    %7.9% variance	       age: 0.31	   cc_area: 0.56	 cc_fibers: -0.37	body_height: -0.22	body_weight: -0.23	brain_weight: 0.55	number_neurons: 0.21
    %0.5% variance	       age: -0.14	   cc_area: 0.56	 cc_fibers: -0.04	body_height: 0.09	body_weight: 0.48	brain_weight: -0.46	number_neurons: 0.46
    %0.2% variance	       age: 0.06	   cc_area: 0.16	 cc_fibers: -0.06	body_height: 0.92	body_weight: -0.35	brain_weight: -0.01	number_neurons: 0.00
    %0.0% variance	       age: -0.36	   cc_area: 0.11	 cc_fibers: -0.51	body_height: -0.23	body_weight: -0.52	brain_weight: -0.49	number_neurons: -0.18


    %42.7% variance	   cc_area: 0.15	 cc_fibers: 0.44	body_height: -0.58	body_weight: -0.59	brain_weight: 0.09	number_neurons: 0.30
    %31.5% variance	   cc_area: -0.70	 cc_fibers: -0.20	body_height: 0.14	body_weight: -0.19	brain_weight: -0.23	number_neurons: 0.60
    %23.4% variance	   cc_area: 0.06	 cc_fibers: -0.55	body_height: -0.16	body_weight: -0.01	brain_weight: 0.78	number_neurons: 0.23
    %1.7% variance	   cc_area: 0.21	 cc_fibers: 0.20	body_height: 0.78	body_weight: -0.49	brain_weight: 0.25	number_neurons: 0.07
    %0.7% variance	   cc_area: 0.65	 cc_fibers: -0.20	body_height: 0.06	body_weight: 0.21	brain_weight: -0.35	number_neurons: 0.60
    %0.1% variance	   cc_area: -0.13	 cc_fibers: 0.62	body_height:
    %0.08	body_weight: 0.57	brain_weight: 0.37	number_neurons: 0.36

    % brain w
    [V,D] = EIG(X)


    %% Validate data
    if validate_data
        fprintf('All data taken from tables; no data to validate!\n');
    end;


    % Construct outputs
    varnames = who('rp_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);

