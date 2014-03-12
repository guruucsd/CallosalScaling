

    % recreate Fig 9
    figure; hold on;
    plot(lrb_tab_age, lrb_tab_ccnic, 'o');
    plot(lrb_tab_age, 56E6*ones(size(lrb_tab_age)));

    % Fit exponentials
    pre_age = lrb_tab_age(1:11); pre_nic = lrb_tab_ccnic(1:11);
    % fit sigmoid

    post_age = lrb_tab_age(11:end) - lrb_tab_age(11); post_nic = lrb_tab_ccnic(11:end);
    %[post_c] = polyfit(log(1+post_age), log(max(1,post_nic-56E6)),1); % fit exponential decay
    figure; 
    subplot(1,3,1); plot(post_age, post_nic); 
    subplot(1,3,2); plot(post_age, log(post_nic));
    subplot(1,3,3); hold on; plot(post_age, post_nic, 'o'); %plot(post_age, post_c(2)*exp(post_c(1)*post_age));