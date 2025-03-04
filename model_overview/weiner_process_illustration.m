clear; close all

rng('default')

max_t = 5;
n_sim = 1000;
% using the SV example from mSPN_multinomial_regression_example.m
drift_rate = [0.9180, 0.2894, 0.2891, 0.6451]; 
titles = ["Non-impulsive","Impulsive"];
noise = 10;
threshold = 2;
tstep = .01; % in seconds
n_action = length(drift_rate);
max_tsteps = max_t/tstep;

weiner_process_progress = zeros(n_sim, n_action, max_tsteps);
[actions_taken,t_to_decision_dat] = deal(nan(n_sim,1));

%% Simulations

for i=1:n_sim
    for j=2:max_tsteps
        weiner_process_progress(i,:,j) = ...
            squeeze(weiner_process_progress(i,:,j-1)) + ...
            tstep * (drift_rate + noise*randn(1,n_action));
    end

    % when does the first line cross the threshold?
    tsteps_to_decision = ...
        find(any(weiner_process_progress(i,:,:) > threshold),1);
    
    % if the line doesn't cross, set it to the max time 
    if isempty(tsteps_to_decision)
        tsteps_to_decision = max_t;
    end

    if ~isempty(weiner_process_progress(i,:,tsteps_to_decision))
        [~,actions_taken(i)] = ...
            max(weiner_process_progress(i,:,tsteps_to_decision));
    end
    t_to_decision_dat(i) = tstep*tsteps_to_decision;
    weiner_process_progress(i,:,tsteps_to_decision+1:end) = nan;
end



%% Plots

cols = actioncmap();
max_t_observed = max(t_to_decision_dat,[],'all');
bar_bins = linspace(0,max_t_observed,20);

% randomly select a few sims for plotting Weiner process
n_plotted = 20;
plotted_sample = ismember(1:n_sim,randi(n_sim,n_plotted,1));
    
figure; t = tiledlayout(1,3);
title(t,"colors = different actions")
    
nexttile; hold on
for i=1:n_action
    actions_taken_idx = actions_taken' == i .* plotted_sample;
    if sum(actions_taken==i) > 0 && sum(actions_taken_idx) > 0
        plot((1:max_tsteps)*tstep,squeeze(weiner_process_progress(...
            actions_taken_idx,i,:))', ...
            "Color",cols(i+1,:));
    end
    yline(threshold,'--k');
end
scatter(0,0,20,'k','filled')
hold off
xlim([0 max_t_observed])
ylim([-threshold, threshold])
yticks([0 threshold])
yticklabels(["starting pt","action threshold"])
xlabel("time")
ylabel("progress to decision")

nexttile; hold on
for i=1:n_action
    histogram(squeeze(t_to_decision_dat(actions_taken'==i)), ...
        bar_bins,"FaceColor",cols(i+1,:))
end
xlim([0 max_t_observed])
xlabel("time (s)")
ylabel("deliberation time frequency")
hold off

nexttile; hold on
for i=1:n_action
    plot([0 1],[0 drift_rate(i)],'Color',cols(i+1,:))
end
xlabel('time')
ylabel('drift')
xticks('')
yticks('')