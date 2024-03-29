function cost = calculate_circuit_configuration_cost(...
    FSI,strio,GPi,LH,RMTg,DA,baseline_FSI, baseline_strio, ...
    baseline_GPi, baseline_LH, baseline_RMTg, baseline_DA)

    cost = norm([FSI strio GPi LH RMTg DA] - [baseline_FSI baseline_strio ...
        baseline_GPi baseline_LH baseline_RMTg baseline_DA]);

end