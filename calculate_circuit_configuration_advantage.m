function advantage = calculate_circuit_configuration_advantage(...
    state_advantage_coefs,states,strio,fsi,GPi,LH,RMTg,DA)
    
    % calculate the probability of specified state(s) occuring, given strio
    % excitability and fsi inputs to striosome
    
    % assume 4 dimensions, so state_advantage is a vector of length 2^4
    
    prob_in_space = algorithmic_model(strio,fsi,.1,GPi,LH,...
        RMTg,1,DA);

    % now find probability of states occuring, assuming components occur
    % with equal probability
    probability_components_occuring = prob_in_space * states;
    probability_components_not_occuring = (1-prob_in_space) * (1-states);
    total_probability = prod(probability_components_occuring + ...
        probability_components_not_occuring,2);
    
    % advantage = preference coefs * probability of occuring
    advantage = sum(total_probability .* state_advantage_coefs,'all');

end