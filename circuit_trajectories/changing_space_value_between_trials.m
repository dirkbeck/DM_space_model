
[distance_to_pt_multiplier,gravity_multiplier,ews,...
    strio_incs,da_incs,lh_incs,strio_grid,da_grid,lh_grid,...
    circuit_preference_pt,unique_states,n_state_component,n_interp_inc] =...
    trajectory_params();

time_onset = 10;
time_incubation = 100;
time_stimulus = 10;
% amount weights change every time there's an event that changes space values
% (e.g. a modeled stressor)
state_weights_change = .1; 
strio = 1;
lh = 1;
da = 1;
gradient_delta = .01;
circuit_movement_speed = .001;
stressor_multiplier = 100;

starting_circuit_preference_pt = ones(3,1);


stressor_component_indx = 4; % 1,2,3, or 4

total_time = sum([time_onset,time_incubation,time_stimulus]);
is_stressor_state = unique_states(:,stressor_component_indx);
[state_values_weights_over_time, state_probs_over_time] = ...
    deal(zeros(height(unique_states),total_time));
circuit_preference_pts = zeros(3,total_time);
circuit_preference_pts(:,1) = starting_circuit_preference_pt;
state_vals = [stressor_multiplier*repmat(is_stressor_state,1,time_onset), ...
    rand(height(unique_states),time_incubation), repmat(is_stressor_state,1,time_stimulus)];

for i=2:total_time

    % find the state probs in the current configuration
    state_probs = energy_by_state(unique_states,...
        circuit_preference_pts(1,i-1),circuit_preference_pts(2,i-1),...
        circuit_preference_pts(3,i-1),ews);

    % calculate the gradient at the circuit pref point
    strio_incs = [circuit_preference_pts(1,i-1)-gradient_delta, ...
        circuit_preference_pts(1,i-1), circuit_preference_pts(1,i-1)+gradient_delta];
    da_incs = [circuit_preference_pts(2,i-1)-gradient_delta, ...
        circuit_preference_pts(2,i-1), circuit_preference_pts(2,i-1)+gradient_delta];
    lh_incs = [circuit_preference_pts(3,i-1)-gradient_delta, ...
        circuit_preference_pts(3,i-1), circuit_preference_pts(3,i-1)+gradient_delta];

    expected_values = ...
        optimal_circuit_configurations(circuit_preference_pts(:,i-1),gravity_multiplier,...
            distance_to_pt_multiplier,state_values_weights_over_time(:,i-1),...
            unique_states,strio_incs,da_incs,lh_incs,ews);
    
    % movement of the circuit preference point is then the gradient at the
    % circuit preference point
    dx = (expected_values(3,2,2)-expected_values(1,2,2))/(2*gradient_delta);
    dy = (expected_values(2,3,2)-expected_values(2,1,2))/(2*gradient_delta);
    dz = (expected_values(2,2,3)-expected_values(2,2,1))/(2*gradient_delta);

    % the weights are adjusted each time step
    state_values_weights_over_time(:,i) = state_values_weights_over_time(:,i-1) + ...
        state_probs .* state_vals(:,i);

    state_probs_over_time(:,i) = state_probs;

    % circuit changes in the direction of the gradient
    circuit_preference_pts(:,i) = circuit_preference_pts(:,i-1) + ...
        circuit_movement_speed * [dx; dy; dz];
end

cols(find(is_stressor_state),:) = [1 0 0].*ones(sum(is_stressor_state),3);
cols(find(~is_stressor_state),:) = [.5 .5 .5].*ones(sum(~is_stressor_state),3);

figure; hold on
for i=1:height(unique_states)
    plot(state_probs_over_time(i,2:end)','Color',cols(i,:))
end
xline(time_onset,'--k')
xline(time_onset+time_incubation,'--k')
hold off
xlabel("time")
ylabel("proportion space")
ylim([0 1])
