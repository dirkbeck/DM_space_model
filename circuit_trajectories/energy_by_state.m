function state_prob = energy_by_state(states,strio,da,lh,ews)

% calculate probability of a state by looking at the probabilties
% of individual components occuring/not occuring

da_addition = .5; % to avoid / 0
strio_addition = .5; % to avoid / 0
lh_addition = .5; % to avoid sigma 0

state_prob = zeros(height(states),1);

for i=1:height(states)
    state = states(i,:);
    % calculate probability either that the components occur/don't occur
    state_probs = 1-state' + (-1).^(1-state').*...
        logncdf(strio/(da+da_addition)*ews,0,(lh+lh_addition)./((strio+strio_addition)*ews));
    state_prob(i) = prod(state_probs);
end

end