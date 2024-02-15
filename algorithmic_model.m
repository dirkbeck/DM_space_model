function [prob_in_space,LH,RMTg] = ...
    algorithmic_model(sSPN0,FSI,FSI_c,GPi0,LH0,RMTg0,DA_a,DA_b)

    % how to combine sSPN data into a combined representation in GPi?
    GPi_dim_combination_rules = .2*[1 1 1 1];
    
    % sSPN is normalized by FSI
    sSPN = sSPN0./(FSI+FSI_c);

    % GPi combines sSPN data
    GPi = -sum(GPi0*GPi_dim_combination_rules.*sSPN);

    % LH changes the # dimensions used
    LH = GPi+LH0;

    % RMTg changes the # dimensions used
    RMTg = LH+RMTg0;

    % DA signals space
    DA = 1./(1 + exp(DA_a.*sSPN + RMTg - DA_b));
    prob_in_space = DA;
    
end