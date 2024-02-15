clear; close all
addpath('C:\UTEP\striosomal_circuit_paper\model_winter2023')
rng('default')

%% effects of D1 and D2 on subjective value for incremented reward

reward_incs = linspace(0,1,100);
constant_cost = .25;
D1s = [.1 5]; % low dopamine, high dopamine
D2s = [5 .1]; % low dopamine, high dopamine

% for conversion from logodds to SV
a_param = 2;
b_param = 0;

SV = []; SV_action = []; SV_no_action = [];
for i=1:2 % low dopamine, high
    % D1 is high when dopamine is high
    D1_level = i; 
    D1 = D1s(i);
    % D2 is high when dopamine is low
    D2_level = 3-i; 
    D2 = D2s(i);
    
    SV_action(i,:) = get_SV_action(a_param,b_param,D1,...
        reward_incs,constant_cost,D1_level);
    SV_no_action(i,:) = get_SV_no_action(a_param,b_param,D2,...
        reward_incs,constant_cost,D2_level);
    SV(i,:) = get_SV(a_param,b_param,D1,D2,reward_incs,...
        constant_cost,D1_level,D2_level);
end

cols = colororder;
figure; hold on
for i=1:2
    plot(reward_incs,SV_action(i,:),'Color',cols(i,:))
    plot(reward_incs,SV_no_action(i,:),'Color',cols(i,:),'Linestyle',':')
end
hold off
legend(["low dopamine action (direct pathway)",...
    "low dopamine less action (indirect pathway)",...
    "high dopamine action (direct pathway)",...
    "high dopamine less action (indirect pathway"])
xlabel("reward (arb. u.)")
ylabel("SV")

%% effects of disconnecting D1 or D2

n_inc = 100;
reward_incs = linspace(0,1,n_inc);
constant_cost = .5;
D1_levels = [2 1 2]; % control, disconnected D1, disconnected D2
D2_levels = [2 2 1]; % control, disconnected D1, disconnected D2
D1s = [2 0 2];
D2s = [2 2 0];

SV_disconnect = []; SV_action_disconnect = []; SV_no_action_disconnect = [];
decisions = zeros(3,n_inc);
for i=1:3
    % D1 is high when dopamine is high
    D1_level = D1_levels(i); 
    D1 = D1s(i);
    % D2 is high when dopamine is low
    D2_level = D2_levels(i); 
    D2 = D2s(i);
    SV_action_disconnect(i,:) = get_SV_action(a_param,b_param,D1,...
        reward_incs,constant_cost,D1_level);
    SV_no_action_disconnect(i,:) = get_SV_no_action(a_param,b_param,D2,...
        reward_incs,constant_cost,D2_level);
    SV_disconnect(i,:) = get_SV(a_param,b_param,D1,D2,reward_incs,...
        constant_cost,D1_level,D2_level);
end

figure
plot(reward_incs,SV_disconnect')
legend(["control","less direct pathway","less indirect pathway"])
xlabel("reward (arb. u.)")
ylabel("SV action - SV no action")
ylim([-1 1])


%% weiner process illustration of an example set of SVs

% select the drift rates to use as an example
slice_indx = 50;
drift_rates_action = SV_action_disconnect(:,slice_indx)';
drift_rates_no_action = SV_no_action_disconnect(:,slice_indx)';

% weiner process model params
max_ts = [1 2 5];
max_t = 5; % for incremented analysis
threshold = 2;
noise = 1;
t = linspace(0,max_t,100);
tstep = t(2)-t(1);
tsteps = length(t);

[weiner_process_progress_action, weiner_process_progress_no_action] = ...
    deal(zeros(3, tsteps));
for i=2:tsteps
    weiner_process_progress_action(:,i) = ...
        weiner_process_progress_action(:,i-1)' + ...
        tstep*(drift_rates_action + noise*randn(1,3));
    weiner_process_progress_no_action(:,i) = ...
        weiner_process_progress_no_action(:,i-1)' + ...
        tstep*(drift_rates_no_action + noise*randn(1,3));
end

action_threshold = max(weiner_process_progress_action,[],'all');
no_action_threshold = -action_threshold;

figure
hold on
for i=1:3
    plot(t,weiner_process_progress_action(i,:),"Color",cols(i,:));
    plot(t,weiner_process_progress_no_action(i,:),"Color",cols(i,:),...
        'LineStyle',':');
    plot(t(1:50), drift_rates_action(i)*t(1:50), "Color",cols(i,:));
    plot(t(1:50), drift_rates_no_action(i)*t(1:50), "Color",cols(i,:),...
        "LineStyle",':');
end
yline(action_threshold,'--k')
yline(no_action_threshold,'--k')
scatter(0,0,20,'k','filled')
hold off
ylim([-1 1])
xlabel("time (arb. u.)")
ylabel("progress to decision")
yticks([no_action_threshold 0 action_threshold])
yticklabels(["no action threshold","starting pt","action threshold"])
legend(["control action","control no action",'','',"no direct pathway action", ...
    "no direct pathway no action",'','',"no indirect pathway action", ...
    "no indirect pathway no action"])
ylim([no_action_threshold action_threshold])

%% plot of many decisions showing quicker deliberation time with dopamine

logodds_drift_rates = {[SV_action(1,100) -SV_no_action(1,100)],...
    [SV_action(2,100) -SV_no_action(2,100)]};
n_sim = 100;

for i=1:length(logodds_drift_rates)
    % use the inverse of "no action" as action 2
    [t_to_decision_dat, actions_taken] = weiner_process_model( ...
        logodds_drift_rates{i},1,5,2,tstep,n_sim,0); % b_downstreamBG already incorporated
    t_to_decision_dat(t_to_decision_dat==max_t) = nan;
    actions_taken(isnan(t_to_decision_dat)) = nan;
    delib_times{i} = t_to_decision_dat(actions_taken==1);
end

figure; hold on
for i=1:length(logodds_drift_rates)
    histogram(delib_times{i},linspace(0,max_t,20))
end
hold off
xlabel("deliberation time (arb. u.)")
ylabel("simulated count")
legend(["low dopamine","high dopamine"])



%% functions

function SV_action = get_SV_action(a_param,b_param,D1,reward,cost,D1_level)
    % when D1 is high, secondary D1 dimensions are used
    % (e.g. cost as well as reward)
    cost_in_space = D1_level==2;
    SV_action = 1./(1+exp(b_param - a_param*D1*(2*reward-cost_in_space*cost)));
end

function SV_no_action = get_SV_no_action(a_param,b_param,D2,reward,cost,D2_level)
    % when D2 is high, secondary D2 dimensions are used
    % (e.g. reward as well as cost)
    reward_in_space = D2_level==2;
    SV_no_action = -1./(1+exp(b_param - a_param*D2*(2*cost-reward_in_space*reward)));
end

function SV = get_SV(a_param,b_param,D1,D2,reward,cost,D1_level,D2_level)
    SV = get_SV_action(a_param,b_param,D1,reward,cost,D1_level) + ...
        get_SV_no_action(a_param,b_param,D2,reward,cost,D2_level);
end