clear; close all
rng(0)

SPN_activities = linspace(0,1,100);
da_strio_changed = 1./(1+exp(SPN_activities));
da_matrix_changed = .5*ones(1,100);
das = {da_strio_changed,da_matrix_changed,da_strio_changed};

figure
tiledlayout(2,1)

nexttile; hold on
for i=1:length(das)
    plot(SPN_activities,das{i});
end
hold off
xlabel("SPN activity")
ylabel("probability decision-dimension is used")
legend("sSPN activity change","mSPN activity change","all SPN activity change")

matrixes = {.5*ones(1,100),SPN_activities,SPN_activities};
% intercept of four actions
intercept = rand;
% sum of W*X for a given cortex X and random weights and 1 action
sum_other_rules = rand;

for i=1:length(das)
    matrix_activity = sum_other_rules.*das{i}.*matrixes{i};
    action_values{i} = 1./(1+exp(intercept-matrix_activity));
end


nexttile; hold on
for i=1:length(das)
    plot(SPN_activities,action_values{i});
end
hold off
xlabel("SPN activity")
ylabel("action value")
legend("sSPN activity change","mSPN activity change","all SPN activity change")

