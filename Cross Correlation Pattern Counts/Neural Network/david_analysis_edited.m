%% TO DO

% add matrix ensembles from the neural net model

% steps:
% 1) take the mSPN neurons activities matrix
% 2) manually "disengage" ensembles depending on task
% similar to the lines below with the [1 0 0 0], [0 1 0 0], etc.

% where engaged = 1, disengaged = 0;
% CB dissimilar = [ 0 0 0 0]
% BB = [1 0 0 0]
% two reward = [0 1 0 0]
% CB = [1 1 0 0]

% for all disengaged ensembles, set matrix activities 
% in that ensembles to a constant higher number, replacing
% the activites in the original mSPN matrix

% for all engaged ensembles, keep the mSPN neuron
% activites as is

%%


clc; %close all

rng(1)

excitation_threshold = 1.5;
inhibition_threshold = -.40;
n_strio = 100;
n_matrix = 100;
n_SPN_ensembles = 4;
general_task_activity_addition = 0.8;
engaged_ensemble_noise_coeff = 2;


% striosomes
common_noise = randn(n_strio,n_SPN_ensembles) + ...
    general_task_activity_addition;

cb_unequal = common_noise + engaged_ensemble_noise_coeff * ...
    [.01 .01 0 0] .* rand(n_strio,n_SPN_ensembles);

BB = common_noise + engaged_ensemble_noise_coeff * ... %mostly paying attention to reward 
    [1 0 0 0] .* randn(n_strio,n_SPN_ensembles); 

twoR = common_noise + engaged_ensemble_noise_coeff * ... %mostly paying attention to cost
    [0.7 1 0 0] .* randn(n_strio,n_SPN_ensembles);

cb = common_noise + engaged_ensemble_noise_coeff * ...
    [1 1 0 0] .* randn(n_strio,n_SPN_ensembles);

% matrix
mSPN = randn(n_matrix,n_SPN_ensembles) + general_task_activity_addition;

% calculate pattern counts
tasks = {cb_unequal, BB, twoR, cb};
task_names = ["CB unequal","BB","two reward","CB"];
all_pattern_counts = [];
for task = 1:length(tasks)
    disp(task_names(task));
    dat = tasks{task};

    n_strio_excited = sum(dat >= excitation_threshold,'all');
    disp(strcat("n_strio_excited: ",string(n_strio_excited)))

    n_strio_inhibited = sum(dat <= inhibition_threshold,'all');
    disp(strcat("n_strio_inhibited: ",string(n_strio_inhibited)))

    n_mSPN_excited = sum(mSPN >= excitation_threshold,'all');
    disp(strcat("n_matrix_excited: ",string(n_mSPN_excited)))

    n_mSPN_inhibited = sum(mSPN <= inhibition_threshold,'all');
    disp(strcat("n_matrix inhibited: ",string(n_mSPN_inhibited)))
    
    n_EE = n_strio_excited * n_mSPN_excited; % excited-excited
    n_EI = n_strio_excited * n_mSPN_inhibited; % excited-inhibited
    n_IE = n_strio_inhibited * n_mSPN_excited; % inhibited-excited
    n_II = n_strio_inhibited * n_mSPN_inhibited; % excited-inhibited

    pattern_counts{task} = [n_EE,n_EI,n_IE,n_II];

%     figure
%     bar([n_EE n_EI n_IE n_II]);
    all_pattern_counts = [all_pattern_counts;[n_EE, n_EI, n_IE, n_II]];
%     title(task_names(task));
%     xticklabels(["EE","EI","IE","II"])

end

figure; hold on;
difficulty_matrix = [1.02225, 1.3739, 1.5316, 2];
% disp(all_pattern_counts)
plot(difficulty_matrix,all_pattern_counts(:,1),'-o',LineWidth=1)
plot(difficulty_matrix,all_pattern_counts(:,2),'-o',LineWidth=4)
plot(difficulty_matrix,all_pattern_counts(:,3),'-o',LineWidth=2)
plot(difficulty_matrix,all_pattern_counts(:,4),'-o',LineWidth=1)
text(difficulty_matrix,[max(all_pattern_counts(1,2:end)),max(all_pattern_counts(2,2:end)),max(all_pattern_counts(3,2:end)),max(all_pattern_counts(4,2:end))],["Rev CB","EQR","TR","CB"]);
legend("Excited Excited","Excited Inhibited", "Inhibited Excited", "Inhibited Inhibited")
xlabel("Number of Components")
ylabel("Pattern Count")
title("Simulated Number Of Components Vs Pattern Counts")
subtitle("Created by david\_analysis\_edited.m")