
% match to Atanu's results: 
% 
% look at pairs of combinations of PFC-PL, fsi, and strio
% add some noise input to each connection, show the relationship between
% the pairs of firing rates

clear; close all
rng(1)

%% random PFC-PL values, find the respond of FSI and striosome Control

pfcpl_fsi_weight = .8;
pfcpl_strio_weight = .8;

other_ctx_input_to_FSI_noise = 1;
other_ctx_input_to_FSI_addition = 1;
other_ctx_input_to_strio_noise = 1;
other_ctx_input_to_strio_addition = 1;

n_sim = 100;
pfcpl = 10 * rand(1,n_sim);
noise_added_from_other_ctx_neurons = ...
    other_ctx_input_to_FSI_noise * (randn(1,n_sim) * 10) + other_ctx_input_to_FSI_addition; % increased noise in rand matrix by factor of 10


fsi = pfcpl_fsi_weight * pfcpl + noise_added_from_other_ctx_neurons;

strio = other_ctx_input_to_strio_addition + ...
    other_ctx_input_to_strio_noise * (randn(1,n_sim) * 10) + pfcpl; %increased noise in strio rand matrix by factor of 10

figure
scatter(pfcpl, fsi)
lsline;
xlabel("PFC-PL")
ylabel("FSI")
title("Modeled PFCPL-FSI pairs, Control")
subtitle("Created by fitting\_to\_Atanu\_neuron\_pairs.m")

figure
scatter(pfcpl, strio)
lsline;
xlabel("PFC-PL")
ylabel("strio")
title("Modeled PFC PL-strio pairs, Control")
subtitle("Created by fitting\_to\_Atanu\_neuron\_pairs.m")


%% random PFC-PL values, find the respond of FSI and striosome Stress

pfcpl_fsi_weight = .8;
pfcpl_strio_weight = .8;

other_ctx_input_to_FSI_noise = 1;
other_ctx_input_to_FSI_addition = 1;
other_ctx_input_to_strio_noise = 1;
other_ctx_input_to_strio_addition = 1;

n_sim = 100;
pfcpl = 10 * rand(1,n_sim);
noise_added_from_other_ctx_neurons = ...
    other_ctx_input_to_FSI_noise * (randn(1,n_sim)) + other_ctx_input_to_FSI_addition;


fsi = pfcpl_fsi_weight * pfcpl + noise_added_from_other_ctx_neurons;

strio = other_ctx_input_to_strio_addition + ...
    other_ctx_input_to_strio_noise * randn(1,n_sim) + pfcpl;

figure
scatter(pfcpl, fsi)
lsline;
xlabel("PFC-PL")
ylabel("FSI")
title("Modeled PFCPL-FSI pairs, Stress")
subtitle("Created by fitting\_to\_Atanu\_neuron\_pairs.m")

figure
scatter(pfcpl, strio)
lsline;
xlabel("PFC-PL")
ylabel("strio")
title("Modeled PFC PL-strio pairs, Stress")
subtitle("Created by fitting\_to\_Atanu\_neuron\_pairs.m")


%% random FSI values, find the respond of striosome
%% create strio vs fsi stress plot 
fsi_strio_weight = 2; % divisive
ctx_input_to_strio_addition = 10;
ctx_input_to_strio_noise = 2;

ctx_input_to_strio = 10 + 20*rand(1,n_sim);
fsi = (2 * rand(1,n_sim)) + 1; %added 1 to make sure there's not some weirdly high begining value %decreased multiple of rand matrix to 2 
strio = ctx_input_to_strio ./ fsi;

figure
scatter(fsi,strio)
lsline;
xlabel("FSI")
ylabel("strio")
title("modeled PFCPL-strio pairs, Control ")
subtitle("Created by fitting\_to\_Atanu\_neuron\_pairs.m")

%% create strio vs fsi stress plot 
fsi_strio_weight = 2; % divisive
ctx_input_to_strio_addition = 10;
ctx_input_to_strio_noise = 2;

ctx_input_to_strio = 10 + 2*rand(1,n_sim); %reduced noise in the random matrix
fsi = (3 * rand(1,n_sim)) + 1; %added 1 to make sure there's not some weirdly high begining value %lowered the amount of noise in the random matrix 
strio = ctx_input_to_strio ./ fsi;

figure
scatter(fsi,strio)
lsline;
xlabel("FSI")
ylabel("strio")
title("modeled PFCPL-strio pairs Stress")
subtitle("Created by fitting\_to\_Atanu\_neuron\_pairs.m")
