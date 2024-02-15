function [dx,dy,dz] = ...
    circuit_configuration_trajectory(strio_incs,da_incs,lh_incs,...
    n_state_component,distance_to_pt_multiplier,...
    gravity_multiplier,state_values_weights,ews,n_inc)


% which way should the centerpoint of the circuit travel so that the
% decision is made with less energy?

[dx,dy,dz] = deal(zeros(n_inc-2,n_inc-2,n_inc-2));

% adjust these so we can estimate the gradient on the edges
strio_delta = strio_incs(2)-strio_incs(1);
da_delta = da_incs(2)-da_incs(1);
lh_delta = lh_incs(2)-lh_incs(1);

unique_states = dec2bin(0:2^n_state_component-1)-'0';

for i = 2:n_inc-1
    for j = 2:n_inc-1
        for k = 2:n_inc-1

            circuit_preference_pt = [strio_incs(i) da_incs(j) lh_incs(k)];
            
            % calculate the gradient at the circuit pref point
            strio_incs_i = strio_incs(i-1:i+1);
            da_incs_j = da_incs(j-1:j+1);
            lh_incs_k = lh_incs(k-1:k+1);

            expected_values = ...
                optimal_circuit_configurations(circuit_preference_pt,gravity_multiplier,...
                    distance_to_pt_multiplier,state_values_weights,...
                    unique_states,strio_incs_i,da_incs_j,lh_incs_k,ews);

            
            % movement of the circuit preference point is then the gradient at the
            % circuit preference point
            dx(i-1,j-1,k-1) = (expected_values(3,2,2)-expected_values(1,2,2))/(2*strio_delta);
            dy(i-1,j-1,k-1) = (expected_values(2,3,2)-expected_values(2,1,2))/(2*da_delta);
            dz(i-1,j-1,k-1) = (expected_values(2,2,3)-expected_values(2,2,1))/(2*lh_delta);

        end
    end
end



end