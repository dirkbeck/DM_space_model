clear; %close all

rng(1)

max_t = 10;
n_sim = 1000;
% columns are the different actions, rows are different plots
drift_rates_per_s = [0.2,0.5]; 
n_drift_config = height(drift_rates_per_s);
titles = ["Non-impulsive","Impulsive"];
noise = 5;
threshold = 2;
tstep = .01; % in seconds
n_action = length(drift_rates_per_s);
max_tsteps = max_t/tstep;

weiner_process_progress = zeros(n_drift_config, n_sim, n_action, max_tsteps);
[actions_taken,t_to_decision_dat] = deal(nan(n_drift_config,n_sim));

%% Simulations

for d = 1:n_drift_config

    drift_rate = drift_rates_per_s(d,:);

    
    for i=1:n_sim
        for j=2:max_tsteps
            weiner_process_progress(d,i,:,j) = ...
                squeeze(weiner_process_progress(d,i,:,j-1))' + ...
                tstep * (drift_rate + noise*randn(1,n_action));
        end

        % when does the first line cross the threshold?
        tsteps_to_decision = ...
            find(any(weiner_process_progress(d,i,:,:) > threshold),1);
        
        % if the line doesn't cross, set it to the max time 
        if isempty(tsteps_to_decision)
            tsteps_to_decision = max_t;
        end

        if ~isempty(weiner_process_progress(d,i,:,tsteps_to_decision))
            [~,actions_taken(d,i)] = ...
                max(weiner_process_progress(d,i,:,tsteps_to_decision));
        end
        t_to_decision_dat(d,i) = (tstep*tsteps_to_decision) + .8;
        weiner_process_progress(d,i,:,tsteps_to_decision+1:end) = nan;
    end

end


%% Plots

cols = actioncmap();
max_t_observed = max(t_to_decision_dat,[],'all');
bar_bins = linspace(0,max_t_observed,20);

% randomly select a few sims for plotting Weiner process
n_plotted = 20;
plotted_sample = ismember(1:n_sim,randi(n_sim,n_plotted,1));
    
figure; t = tiledlayout(n_drift_config,2);
title(t,"colors = different actions")

for d = 1:n_drift_config
    
    nexttile; hold on
    for i=1:n_action
        actions_taken_idx = actions_taken(d,:) == i .* plotted_sample;
        if sum(actions_taken(d,:)==i) > 0 && sum(actions_taken_idx) > 0
            plot((1:max_tsteps)*tstep,squeeze(weiner_process_progress(d,...
                actions_taken_idx,i,:))', ...
                "Color",cols(i+1,:));
        end
        yline(threshold,'--k');
    end
    scatter(0,0,20,'k','filled')
    hold off
%     xlim([0 max_t_observed])
    ylim([-threshold, threshold])
    yticks([0 threshold])
    yticklabels(["starting pt","action threshold"])
    xlabel("time")
    ylabel("progress to decision")
    title(titles(d))
    
    nexttile; hold on
    for i=1:n_action
        histogram(t_to_decision_dat(d,actions_taken(d,:)==i), linspace(0,600,6000))
    end
    xlim([0 max_t_observed])
    xlabel("time")
    ylabel("deliberation time frequency")
    title(titles(d))
    hold off

end
