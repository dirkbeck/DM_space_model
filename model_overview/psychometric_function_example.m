clear; close all
addpath(fileparts(pwd))
rng('default')

n_left_inc = 3;
n_right_inc = 10;

% arbitrary scale; "value" of reward - cost for two options
left_incs = linspace(-5,0,n_left_inc);
right_incs = linspace(-5,5,n_right_inc);

noise = 1;
max_t = 5;
threshold = 1;
n_sim = 1000;
tstep = .1;

for i=1:n_left_inc
    for j=1:n_right_inc
        logodds_drift_rates2D = [left_incs(i) right_incs(j)];
        logodds_drift_rates1D = [mean(left_incs) right_incs(j)];
        [~, actions_taken2D] = weiner_process_model(logodds_drift_rates2D,...
            noise,max_t,threshold,tstep,n_sim,-3);
        [~, actions_taken1D] = weiner_process_model(logodds_drift_rates1D,...
            noise,max_t,threshold,tstep,n_sim,-3);
        appr_rate2D(i,j) = mean(actions_taken2D==2);
        appr_rate1D(i,j) = mean(actions_taken1D==2);
    end
end

% plotted on an arbitrary scale from 0 = cost, no reward; to 1 =
% cost+reward

figure
plot(linspace(0,1,n_right_inc),appr_rate2D')
xlabel("incremented reward (arb. u.)")
ylabel("approach rate")
legend(["low cost","medium cost","high cost"])
title("2D space")
ylim([0 1])

figure
plot(linspace(0,1,n_right_inc),appr_rate1D')
xlabel("incremented reward (arb. u.)")
ylabel("approach rate")
legend(["low cost","medium cost","high cost"])
title("1D space")
ylim([0 1])