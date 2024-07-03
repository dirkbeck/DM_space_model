clear; close all
addpath(fileparts(pwd))
cmap = actioncmap();
rng('default')

% action value profile params
grid_size = 10;
incsxy = linspace(-1,1,grid_size);
B = [1 -1; -1 1];

% Weiner process params
n_sim = 100;
max_t = 10;
threshold = 1.5;
tstep = .1;

% adjusted variables
spaces = [1 0 0 0; 1 1 0 0];
noises = 1:10;
space_titles = ["1D space","2D space"];
noise_titles = ["high SNR","low SNR"];

[expected_value, average_time] = deal(zeros(height(spaces),length(noises)));

for s=1:height(spaces)
    for n=1:length(noises)
        example_grid = zeros(grid_size,grid_size,4);
        added_values = zeros(grid_size,grid_size);
        noise = sum(spaces(s,:))*noises(n);
        for r=1:grid_size
            for c=1:grid_size
                rew = spaces(s,1) * incsxy(r);
                cost = spaces(s,2) * incsxy(c);
                action_scores = [rew cost] * B;
                [t_to_decision_dat, actions_taken] = weiner_process_model_cortex_noise(...
                    action_scores,noise,max_t,threshold,tstep,n_sim,-3);
                example_grid(r,c,:) = actions_taken(1)==[1 2 3 4];
                added_values(r,c) = (incsxy(r)-.75*incsxy(c)) * ...
                    mean(actions_taken==1);
                times_to_decision(r,c) = mean(t_to_decision_dat);
            end
        end
        expected_value(s,n) = sum(added_values,'all');
        average_time(s,n) = mean(times_to_decision,'all');
        if n==1 || n==5
            figure
            decision_making_map_plot(cmap,example_grid,incsxy,...
            space_titles((s>1)+1)+" "+noise_titles((n>1)+1))
        end
    end
end

figure; hold on
plot(1./noises,expected_value')
hold off
legend(["1D space","2D space"])
xlabel("cortex SNR")
ylabel("expected value")


function [t_to_decision_dat, actions_taken] = weiner_process_model_cortex_noise( ...
    logodds_drift_rates,noise,max_t,threshold,tstep,n_sim,SV_b_param)

    % input log odds of drift rates and normal noise w.r.t log odds
    % output weiner processes after the activation function

    max_tsteps = max_t/tstep;
    n_action = length(logodds_drift_rates);
    weiner_process_progress = zeros(n_sim, n_action, max_tsteps);
    [actions_taken,t_to_decision_dat] = deal(nan(1,n_sim));

    for i=1:n_sim
        for j=2:max_tsteps
            drift_rates = 1./(1+exp(-SV_b_param-logodds_drift_rates + ...
                noise*randn(1,n_action)));
            weiner_process_progress(i,:,j) = ...
                squeeze(weiner_process_progress(i,:,j-1)) + tstep*drift_rates;
        end

        % when does the first line cross the threshold?
        tsteps_to_decision = ...
            find(any(weiner_process_progress(i,:,:) > threshold),1);
        
        % if the line doesn't cross, set it to the max time 
        if isempty(tsteps_to_decision)
            tsteps_to_decision = max_tsteps;
        end

        if ~isempty(weiner_process_progress(i,:,tsteps_to_decision))
            [~,actions_taken(i)] = ...
                max(weiner_process_progress(i,:,tsteps_to_decision));
        end
        t_to_decision_dat(i) = tstep*tsteps_to_decision;
        weiner_process_progress(i,:,tsteps_to_decision+1:end) = nan;
    end

end