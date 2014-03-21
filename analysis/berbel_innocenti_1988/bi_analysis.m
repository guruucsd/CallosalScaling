bi_data;

    % Redo figure 9
    figure; set(gcf, 'Position', [72         306        1037         301]);

    for di=1:length(bi_fig9_date_names)
        subplot(2,length(bi_fig9_date_names),di);
        bar(xbins, bi_fig9_unmyelinated(di,:));
        hold on;
        title(sprintf('Unmyelinated; %s', bi_fig9_date_names{di}));
        set(gca, 'xlim', [0 1.5], 'ylim', [0 0.25]);
    
        subplot(2,length(bi_fig9_date_names),di+length(bi_fig9_date_names));
        bar(xbins, bi_fig9_myelinated(di,:));
        hold on;
        title(sprintf('Myelinated; %s', bi_fig9_date_names{di}));
        set(gca, 'xlim', [0 1.5], 'ylim', [0 0.10]);
    end;




    % Now, do fig 9 as differences across time
    [~,idx] = ismember(bi_fig9_date_names, bi_fig7_date_names);
    nbins = size(bi_fig9_myelinated,2);
    
    tot_myelinated   = bi_fig9_myelinated   .* repmat(bi_fig7_total_fibers(idx)./sum(bi_fig9_myelinated,2), [1 nbins]);
    tot_unmyelinated = bi_fig9_unmyelinated .* repmat(bi_fig7_total_fibers(idx)./sum(bi_fig9_unmyelinated,2), [1 nbins]);
    tot_myelinated(isnan(tot_myelinated))=0;
    tot_unmyelinated(isnan(tot_unmyelinated))=0;
    
   % Redo figure 9, as a total histogram (not %)
    figure; set(gcf, 'Position', [72         306        1037         301]);

    for di=1:length(bi_fig9_date_names)
        subplot(2,length(bi_fig9_date_names),di);
        bar(xbins, tot_unmyelinated(di,:));
        hold on;
        title(sprintf('Unmyelinated; %s', bi_fig9_date_names{di}));
        set(gca, 'xlim', [0 1.5]);%, 'ylim', [0 0.25]);
    
        subplot(2,length(bi_fig9_date_names),di+length(bi_fig9_date_names));
        bar(xbins, tot_myelinated(di,:));
        hold on;
        title(sprintf('Myelinated; %s', bi_fig9_date_names{di}));
        set(gca, 'xlim', [0 1.5]);%, 'ylim', [0 0.10]);
    end;


    dmyelinated = diff(tot_myelinated, [], 1); % diff over date_names
    dunmyelinated = diff(tot_unmyelinated, [], 1);
    [yn,idx] = ismember(bi_fig9_date_names, bi_fig17_date_names);
    pctmy = yn.*bi_fig17_pctmy(max(1,idx))'/100;
    relcoeff = repmat((pctmy(1:end-1)+pctmy(2:end))'/2, [1 size(dmyelinated,2)]);
    pred_unmyel = dunmyelinated.*(1-relcoeff)+ dmyelinated.*relcoeff;
    
    
    figure; set(gcf, 'Position', [72         306        1037         301]);
    for di=1:length(bi_fig9_date_names)-1
        subplot(3,length(bi_fig9_date_names)-1,di);
        bar(xbins, dunmyelinated(di,:));
        hold on;
        title(sprintf('\\Delta Diff Unmyelinated; %s-%s', bi_fig9_date_names{di+1}, bi_fig9_date_names{di}));
        set(gca, 'xlim', [0 1.5]);%, 'ylim',  0.10*[-1 1]);
    
        subplot(3,length(bi_fig9_date_names)-1,di+length(bi_fig9_date_names)-1);
        bar(xbins, dmyelinated(di,:));
        hold on;
        title(sprintf('\\Delta Myelinated; %s-%s', bi_fig9_date_names{di+1}, bi_fig9_date_names{di}));
        set(gca, 'xlim', [0 1.5]);%, 'ylim',  0.10*[-1 1]);

        subplot(3,length(bi_fig9_date_names)-1,di+2*(length(bi_fig9_date_names)-1));
        bar(xbins, pred_unmyel(di,:));
        hold on;
        title(sprintf('Predicted pruned unmyelinated %s-%s', bi_fig9_date_names{di+1}, bi_fig9_date_names{di}));
        set(gca, 'xlim', [0 1.5]);%, 'ylim',  0.10*[-1 1]);
    end;

    figure; set(gcf, 'Position', [0 208        1279         476]);
    for di=1:length(bi_fig9_date_names)-1
        subplot(2,length(bi_fig9_date_names)-1,di+length(bi_fig9_date_names)-1); set(gca, 'FontSize', 12)
        bar(xbins, dmyelinated(di,:));
        hold on;
        axis square;
        title(sprintf('\\Delta Myelinated\n%s-%s', bi_fig9_date_names{di+1}, bi_fig9_date_names{di}), 'FontSize', 14);
        set(gca, 'xlim', [0 1.5]);%, 'ylim',  0.10*[-1 1]);
        if di==1, ylabel('10^6 axons'); end;
        xlabel('axon diameter ( {\mu}m)');
            
        subplot(2,length(bi_fig9_date_names)-1,di); set(gca, 'FontSize', 12);
        bar(xbins, pred_unmyel(di,:));
        hold on;
        axis square;
        title(sprintf('\\Delta Unmyelinated\n%s-%s', bi_fig9_date_names{di+1}, bi_fig9_date_names{di}), 'FontSize', 14);
        set(gca, 'xlim', [0 1.5]);%, 'ylim',  0.10*[-1 1]);
        if di==1, ylabel('10^6 axons'); end;
    end;
    