
function [t_to_decision_dat, actions_taken] = weiner_process_model( ...
    logodds_drift_rates,noise,max_t,threshold,tstep,n_sim,SV_b_param)

    % input log odds of drift rates and normal noise w.r.t log odds
    % output weiner processes after the activation function

    max_tsteps = max_t/tstep;
    n_action = length(logodds_drift_rates);
    weiner_process_progress = zeros(n_sim, n_action, max_tsteps);
    [actions_taken,t_to_decision_dat] = deal(nan(1,n_sim));

    drift_rates = 1./(1+exp(SV_b_param-logodds_drift_rates));

    for i=1:n_sim
        for j=2:max_tsteps
            weiner_process_progress(i,:,j) = ...
                squeeze(weiner_process_progress(i,:,j-1)) + ...
                tstep * (drift_rates + noise*randn(1,n_action));
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