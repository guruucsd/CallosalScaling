w_dir = fileparts(which(mfilename));

addpath(w_dir);
addpath(genpath(fullfile(w_dir, '..','..','_lib')));
w_data;

% Regress exponential decay WITH human
human_brain_weight = get_human_brain_weight();
x = [w_fig1c_weights human_brain_weight];
y = 100-[w_fig1c_pctmye' 92];
[pmye,gmye.y] = fit_exp_decay(x, y, 100*rand(1,3), false);

x2 = linspace(x(1),x(end),100);

figure;
subplot(1,2,1);
semilogx(x,y,'o');
hold on;
semilogx(x2,gmye.y(x2));

subplot(1,2,2);
plot(x,y,'o');
hold on;
plot(x2,gmye.y(x2));

% Regress exponential decay WITHOUT
figure;
semilogx(x(1:end-1),y(1:end-1),'o');
hold on;
semilogx(x(1:end-1),gmye.y(x(1:end-1)));

% Regress logistic WITH human
x = [w_fig1c_weights human_brain_weight];
y = [w_fig1c_pctmye' 92];
B = glmfit(x', [y'/100 ones(size(y'))], 'binomial', 'link', 'logit');

logistic = @(x,p) 1./(1+exp(-p(1)-x.*p(2)));
x2 = linspace(x(1),x(end),100);

figure;
semilogx(x,y,'o');
hold on;
semilogx(x2,100*logistic(x2,B));
