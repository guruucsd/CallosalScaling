hh_combined_species = hh_tab1_species(ismember(hh_tab1_species, hh_stab2_species));
hh_tab1_idx  = find(ismember(hh_tab1_species, hh_combined_species));
hh_stab2_idx = find(ismember(hh_stab2_species, hh_combined_species));

% eliminate the unbelievable point
hh_tab1_idx_clean = hh_tab1_idx(1:end-1);
hh_stab2_idx_clean = hh_stab2_idx(1:end-1);

% Validate computations

% Compare directly comparable numbers
allometric_regression(hh_stab2_cortex_Nn(:,hh_stab2_idx)/2, hh_tab1_N(hh_tab1_idx), 'linear', 1, true, true); %Nn vs N neocortical
allometric_regression(hh_stab2_cortex_Nn(:,hh_stab2_idx_clean)/2, hh_tab1_N(hh_tab1_idx_clean), 'linear', 1, true, true); %Nn vs N neocortical
allometric_regression(hh_stab2_cortex_Dn(:,hh_stab2_idx), hh_tab1_D(hh_tab1_idx), 'linear', 1, true, true); %Dn vs D neocortical
allometric_regression(hh_stab2_cortex_Dn(:,hh_stab2_idx_clean), hh_tab1_D(hh_tab1_idx_clean), 'linear', 1, true, true); %Dn vs D neocortical

allometric_regression(hh_stab2_cortex_Dn(:,hh_stab2_idx).*hh_stab2_cortex_M(:,hh_stab2_idx)*1000/2, hh_tab1_D(hh_tab1_idx).*hh_tab1_M(hh_tab1_idx), 'linear', 1, true, true); %Dn vs D neocortical
allometric_regression(hh_stab2_cortex_Dn(:,hh_stab2_idx_clean).*hh_stab2_cortex_M(:,hh_stab2_idx_clean)*1000/2, hh_tab1_D(hh_tab1_idx_clean).*hh_tab1_M(hh_tab1_idx_clean), 'linear', 1, true, true); %Dn vs D neocortical


allometric_regression(sum(hh_stab2_M(:,hh_stab2_idx),1), hh_tab1_M(hh_tab1_idx));  %title('total brain mass vs. grey matter volume');
allometric_regression(sum(hh_stab2_M(:,hh_stab2_idx),1), hh_tab1_N(hh_tab1_idx)); %TBM vs N neocortical
