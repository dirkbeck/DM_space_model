function [expected_values,gravity_costs,prob_of_state_benefits] = ...
    optimal_circuit_configurations(circuit_preference_pt,gravity_multiplier,...
    distance_to_pt_multiplier,state_values_weights,...
    unique_states,strio_incs,da_incs,lh_incs,ews)

n_interp_inc = length(strio_incs);

[expected_values,gravity_costs,prob_of_state_benefits] = ...
    deal(zeros(n_interp_inc,n_interp_inc,n_interp_inc));

% how much to weight each brain region when calculating energy?
% helpful with strio, lh, and da are on different scales
circuit_weights = [1 1 1]; 


for i=1:n_interp_inc
    for j=1:n_interp_inc
        for k=1:n_interp_inc
            
            % calculate the benefit you get from being close to the
            % state(s) you like
            total_benefit = 0;
            for l = 1:height(unique_states)
                
                if state_values_weights(l) == 0
                    prob_of_state_benefit = 0; 
                else
                    % what is the probability of the given circuit config to
                    % attain the given state?
                    % calculate probability of the state
                    state_prob = energy_by_state(unique_states(l,:),...
                        strio_incs(i),da_incs(j),lh_incs(k),ews);
                    prob_of_state_benefit = ...
                        distance_to_pt_multiplier * state_values_weights(l) * state_prob;
                end

                total_benefit = total_benefit + prob_of_state_benefit;
            end
                
            % "gravity" towards the circuit centerpoint for values 
            % (for centerpoint_movement, gravity = 0)
            gravity_cost = gravity_multiplier * ...
                norm(circuit_weights.*[strio_incs(i),da_incs(j),lh_incs(k)]...
                - circuit_preference_pt);
            
            gravity_costs(i,j,k) = gravity_cost;
            prob_of_state_benefits(i,j,k) = total_benefit;
            expected_values(i,j,k) = total_benefit - gravity_cost;
        end
    end
end


end