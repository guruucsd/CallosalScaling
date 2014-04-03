function vars = hh_2010_data(validate_data)
%

    if ~exist('validate_data', 'var'), validate_data = true; end;
    if ~exist('visualize_data', 'var'), visualize_data = false; end;

    HH_2010_dirpath = fileparts(which(mfilename));
    HH_2010_dirname = guru_fileparts(HH_2010_dirpath, 'name');
    HH_2010_img_dirpath = fullfile(HH_2010_dirpath, '..', 'img', HH_2010_dirname);
    HH_2008_dirpath = fullfile(HH_2010_dirpath, '..', strrep(HH_2010_dirname, '2010', '2008'));


    %% Gather data
    hh_2010_tabS2_species = {'Tupaia glis' 'Callithrix jacchus' 'Otolemur garnetti' 'Aotus trivirgatus' 'Callimico goeldi' 'Saimiri sciureus' 'Macaca fasciularis' 'Macaca radiata' 'Cebus apella' 'Macaca mulatta' 'Papio cynocephalus' 'Homo Sapiens'};
    hh_2010_tabS2_Mg = [0.515 2.042 2.556 3.698 3.827 6.996 10.459 15.493 15.820 21.430 36.334 285.860]'; % g
    hh_2010_tabS2_Mw = [0.190 0.800 0.840 1.870 2.620 3.650  7.650  8.640  8.360 13.100 22.880 261.320]'; % g
    hh_2010_tabS2_N  = 1E6*[21.95 120.33 88.50 200.32 178.77 645.73 400.74 829.60 930.67 795.52 1420.34 7530]';
    hh_2010_tabS2_Ow = [16.22 74.63 102.89 170.04 157.13 353.05 484.40 841.38 868.73 945.94 1860 18480]'; %
    hh_2010_tabS2_Fg = [1.04 1.18 1.25 1.36 1.26 1.57 1.65 1.81 1.69 NaN 1.92 NaN]';

    hh_2010_dm = log10([hh_2010_tabS2_Mg hh_2010_tabS2_Mw hh_2010_tabS2_N hh_2010_tabS2_Ow hh_2010_tabS2_Fg]);


    %hh_2010_Aw_est = hh_2010_tabS2_N.^0.873;
    %hh_2010_Vw_est = hh_2010_tabS2_N.^1.1; %SI methods


    %% Validate data by recreating some figures
    if validate_data
        keyboard;
    end;


    %% Visualize data
    if visualize_data
        % Fig1
        allometric_regression(hh_2010_tabS2_Mg, hh_2010_tabS2_Mw, 'log', 1, true, true) % Unequally divided into A and T
        title('Fig 1a: M_{gray} vs. M_{white}');
        allometric_regression(hh_2010_tabS2_N , hh_2010_tabS2_Mg+hh_2010_tabS2_Mw, 'log', 1, true, true) % Unequally divided into A and T
        title('Fig 1b: N_{neocortical} vs. (M_{gray} + M_{white})');

        % Fig 2
        allometric_regression(hh_2010_tabS2_Ow, hh_2010_tabS2_Mw, 'log', 1, true, true) % Unequally divided into A and T
        title('Fig 2a: N_{other} vs. M_{white}');
        allometric_regression(hh_2010_tabS2_N, hh_2010_tabS2_Mw, 'log', 1, true, true) % Unequally divided into A and T
        title('Fig 2b: N_{neocortical} vs. M_{white}');
        allometric_regression(hh_2010_tabS2_N, hh_2010_tabS2_Ow, 'log', 1, true, true) % Unequally divided into A and T
        title('Fig 2c: N_{neocortical} vs. N_{other}');

        % map 2008 paper to 2010 paper data
        addpath(HH_2008_dirpath); hh_2008_data;
        idx2008 = ismember(hh_2008_tab1_M, hh_2010_tabS2_Mg);
        idx2010 = ismember(hh_2010_tabS2_Mg, hh_2008_tab1_M);

        %% Fig 3a: Read missing data from graph
        [~,pix,xticks,yticks] = parse_img_by_color(fullfile(hh_2010_dir, 'img', 'Fig3a_marked.png'), 'r');
        N  = 10.^(7+(pix{2} - xticks{2}(1))./mean(diff(xticks{2})));
        Aw = 10.^(2+(yticks{1}(end) - pix{1})./mean(diff(yticks{1})));
        %find corresponding indices
        idx = zeros(size(N)); for ni=1:length(N), [~,idx(ni)] = min(abs(hh_2010_tabS2_N-N(ni))); end;
        hh_2010_Aw_est = nan(size(idx2010)); hh_2010_Aw_est(idx) = Aw;

        %% Fig 3b: Read missing data from graph
        [~,pix,xticks,yticks] = parse_img_by_color(fullfile(hh_2010_dir, 'img', 'Fig3b_marked.png'), 'r');
        Aw2 = 10.^(2+(pix{2} - xticks{2}(1))./mean(diff(xticks{2})));
        Vw  = 10.^(2+(yticks{1}(end) - pix{1})./mean(diff(yticks{1}))); %mm^3
        %find corresponding indices
        for ni=1:length(N), [~,idx(ni)] = min(abs(Aw2(ni)-hh_2010_Aw_est)); end;
        hh_2010_Vw_est  = nan(size(idx2010)); hh_2010_Vw_est(idx) = Vw;
        hh_2010_Aw2_est = nan(size(idx2010)); hh_2010_Aw2_est(idx) = Aw2;
        % average them
        hh_2010_Aw_est  = (hh_2010_Aw_est + hh_2010_Aw2_est)/2;


        % Simple! Radii of equivalent spheres
        hh_2010_R   = nan(size(idx2010)); hh_2010_R(idx2010)   = ((hh_2010_Vw_est(idx2010)+hh_2008_tab1_V_est(idx2008))*3/4/pi).^(1/3);
    %    hh_2010_Rw  = nan(size(idx2010)); hh_2010_Rw(idx2010)  = (hh_2010_Vw_est(idx2010)*3/4/pi).^(1/3);

        %Ag = dAg + AE;
        %Fg = Ag/AE;
        %Fg = (dAg+AE)/AE => dAg/AE=Fg-1 => dAg=AE(Fg-1)
        hh_2010_AE  = nan(size(idx2010)); hh_2010_AE(idx2010)  = hh_2008_tab1_A(idx2008)./hh_2010_tabS2_Fg(idx2010);
        hh_2010_dAg = nan(size(idx2010)); hh_2010_dAg(idx2010) = hh_2008_tab1_A(idx2008) - hh_2010_AE(idx2010);
        hh_2010_dAw = nan(size(idx2010)); hh_2010_dAw(idx2010) = hh_2010_dAg(idx2010); % assumption at bottom left col of p. S2
        hh_2010_h   = nan(size(idx2010)); hh_2010_h(idx2010)   = hh_2008_tab1_T(idx2008).*(hh_2010_tabS2_Fg(idx2010)-1); %
        hh_2010_Rw  = nan(size(idx2010)); hh_2010_Rw(idx2010)  = hh_2010_R(idx2010) - hh_2010_h(idx2010) - hh_2008_tab1_T(idx2008);

        %Fw = Aw/Aw0
        %Aw = Aw0 + dAw
        %Vw = (4/3)pi*((Aw0/4pi)^(1/2))^3
        hh_2010_Aw0 = nan(size(idx2010)); hh_2010_Aw0(idx2010) = (hh_2010_Aw_est(idx2010) - hh_2010_dAw(idx2010))
        hh_2010_Fw  = nan(size(idx2010)); hh_2010_Fw(idx2010)  = hh_2010_Aw_est(idx2010)./hh_2010_Aw0(idx2010);
    %    hh_2010_Vw  = Vw_est; %nan(size(idx2010)); hh_2010_Vw(idx2010)  = (4/3)*pi*(sqrt(hh_2010_Aw0(idx2010)/(4*pi)).^3);

        % Vb = Vw+Vg
        % R=(3*Vb/(4pi))^(1/3)=(3*(Vw+Vg)/(4pi))^(1/3)
        % Rw=(3*Vw/(4pi))^(1/3)
        % AW0 = AE*(Rw/R).^2 = AE*


        % Rw=R-h-T
        % 2R-2h-2T = 2R-2*T*Fg => 0 = 2*T*Fg+2T-2H, or T(Fg+1)=h

        % consistency checks:
        (hh_2008_tab1_A(idx2008)            - hh_2010_AE(idx2010).*(1+hh_2010_h(idx2010)./hh_2008_tab1_T(idx2008))) ./hh_2008_tab1_A(idx2008) % should be zeros
        (sqrt(hh_2010_Aw_est(idx2010)/4/pi) - (sqrt(hh_2008_tab1_A(idx2008)/4/pi)-hh_2008_tab1_T(idx2008)))         ./ sqrt(hh_2010_Aw_est(idx2010)/4/pi)
        (hh_2010_Rw(idx2010)                - (hh_2010_R(idx2010) - hh_2010_h(idx2010) - hh_2008_tab1_T(idx2008)) ) ./hh_2010_Rw(idx2010)
        % Aw0 vs. Vw
        (hh_2010_Aw0(idx2010)               - ((3/4/pi)*hh_2010_Vw_est(idx2010)).^(1/3))                            ./hh_2010_Aw0(idx2010)
        % Vw vs. Rw
        (hh_2010_Vw_est(idx2010)            - hh_2010_Rw(idx2010).^3*4*pi/3)                                        ./hh_2010_Vw_est(idx2010)
        % Hw0 vs. rw
        (hh_2010_Aw0(idx2010)               - 4*pi*hh_2010_Rw(idx2010).^2)                                          ./hh_2010_Aw0(idx2010)



        % Fig 3
        %
        % Note: fig3b has bad x-axis values
        %
        allometric_regression(hh_2010_tabS2_N(idx2010), hh_2010_Aw_est(idx2010), 'log', 1, true, true) % Unequally divided into A and T
        title('Fig 3a: N_{neurons} vs. Area_{white}(estimated)');
        set(gca, 'xlim', 10.^[7 11], 'ylim', 10.^[2 5]);
        allometric_regression(hh_2010_Aw_est(idx2010), hh_2010_Vw_est(idx2010), 'log', 1, true, true) % Unequally divided into A and T
        title('Fig 3b: Area_{white}(estimated) vs. Volume_{white}(estimated)');
        set(gca, 'xlim', 10.^[2 5], 'ylim', 10.^[2 5]);
    %    allometric_regression(hh_2010_tabS2_N(idx2010), hh_2010_Vw_est(idx2010), 'log', 1, true, true) % Unequally divided into A and T
    %    title('Fig 3b: N_{neocortical} vs. Volume_{white}(estimated)');

        % Fig 4
        hh_2010_l = nan(size(idx2010)); hh_2010_l(idx2010) = 2*hh_2010_Vw_est(idx2010)./hh_2010_Aw_est(idx2010);
        p_Rl = polyfit(log10(hh_2010_R(idx2010)), log10(hh_2010_l(idx2010)), 1);
        g_Rl = @(R) 10.^polyval(p_Rl,log10(R));
        %allometric_regression(hh_2010_R(idx2010), hh_2010_l(idx2010), 'log', 1, true, true) % Unequally divided into A and T
        Rs = linspace(min(hh_2010_R(idx2010)), max(hh_2010_R(idx2010)), 25);
        figure;
        plot(hh_2010_R(idx2010), hh_2010_l(idx2010), 'o');
        hold on;
        plot(Rs, g_Rl(Rs));
        set(gca, 'ylim', [0.8 4.0])
        xlabel('Cortical Radius (mm)'); ylabel('average axon length (mm)');
        title(sprintf('l \\propto R^{%4.3f}', p_Rl(1)));
    %     hh_2010_l = nan(size(idx2010)); hh_2010_l(idx2010) = 2*Vw_est(idx2010)./hh_2010_Aw_est(idx2010);
    %     p_Rl2 = polyfit(log10(R_est(idx2010)), log10(hh_2010_l(idx2010)), 1);
    %     g_Rl2 = @(R) 10.^polyval(p_Rl2,log10(R));
    %     %allometric_regression(hh_2010_R(idx2010), hh_2010_l(idx2010), 'log', 1, true, true) % Unequally divided into A and T
    %     Rs = linspace(min(R_est(idx2010)), max(R_est(idx2010)), 25);
    %     figure;
    %     plot(R_est(idx2010), hh_2010_l(idx2010), 'o');
    %     hold on;
    %     plot(Rs, g_Rl2(Rs));

        % Fig 5
        allometric_regression(hh_2010_Vw_est(idx2010)+hh_2008_tab1_V_est(idx2008), hh_2010_AE(idx2010), 'log', 1, true, true) % Unequally divided into A and T
        title('Fig 5a: Volume(estimated) vs. Exposed Area_{grey}(estimated)');
        allometric_regression(hh_2010_tabS2_N(idx2010), hh_2010_AE(idx2010), 'log', 1, true, true) % Unequally divided into A and T
        title('Fig 5b: N_{neurons} vs. Exposed Area_{grey}(estimated)');

        % Fig 6
        allometric_regression(hh_2010_tabS2_N(idx2010), hh_2010_Fw(idx2010), 'log', 1, true, true) % Unequally divided into A and T
        title('Fig 6: N_{neurons} vs. Folding_{white}(estimated)');
        set(gca,'ylim',[0.1 10])
    %     allometric_regression(hh_2010_tabS2_N(idx2010), Fw_est(idx2010), 'log', 1, true, true) % Unequally divided into A and T
    %     title('Fig 6: N_{neurons} vs. Folding_{white}(estimated)');
    end;


    %% Construct outputs
    varnames = who('hh_2010_*');
    varvals = cellfun(@eval, varnames, 'UniformOutput', false);
    vars = cell2struct(varvals, varnames);
