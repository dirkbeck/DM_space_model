
clear; close all
addpath('C:\UTEP\striosomal_circuit_paper\model_winter2023')
rng('default')

% show that D1 biases towards the more proximate option (proximity measured
% along a dimension)

% reward, cost, proximity; the more proximate, higher approaches
B_D1 = [-1 1 1]';
B_D2 = -B_D1;

rew = 1;
cost = 1;

n_proximity_inc = 10;
dop_incs = linspace(.5,2,3);
proximities = linspace(0,1,10);

% how many dimensions to use at different levels of dopamine?
% this is calculated in striosomes -- more dopamine leads to more D1
% dimension weights, less D2 dimensions weights

dim_weights_D1 = [3 1 1]; % reward more important for D1
dim_weights_D2 = [1 3 1]; % cost more important for D2
dims_D1 = 1./(1+exp(1-dop_incs-dim_weights_D1')); % models DA activity forming space
dims_D2 = 1./(1+exp(1-dop_incs-dim_weights_D2')); % models DA activity forming space

% Weiner process params
noise = 1;
max_t = 10;
threshold = .5;
tstep = .1;
n_sim = 10000;


for i=1:n_proximity_inc
    for j=1:length(dop_incs)
        logodds_drift_rate_action = dop_incs(j)*(dims_D1(:,j)'.*...
            [rew cost proximities(i)])*B_D1; % rew, cost, proximity
        logodds_drift_rate_no_action = dop_incs(j)*(dims_D2(:,j)'.*...
            [rew cost proximities(i)])*B_D2;
        logodds_drift_rates = [logodds_drift_rate_action, ...
            logodds_drift_rate_no_action];
        [~, actions_taken] = weiner_process_model( ...
                logodds_drift_rates,noise,max_t,threshold,tstep,n_sim,0);
        prop_action(i,j) = mean(actions_taken==1);
    end
end

plot(proximities,prop_action)
xlabel("proximity (arb. u.)")
ylabel("prop. proximate action")
legend(["low dopamine","medium dopamine","high dopamine"])
ylim([0 1])