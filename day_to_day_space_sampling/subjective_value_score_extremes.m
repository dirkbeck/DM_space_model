clear; close all
addpath(fileparts(pwd))
rng('default')

%% simulations
% simulated random decision making profiles in the 16 possible spaces
% for each simulation record the decision making ingredients

nsim = 1000;
rew_incs = linspace(-1,1,6);
cost_incs = linspace(-1,1,6);

[riskiness_sims,safety_sims,high_action_sims,low_action_sims,...
    exploit_sims,explore_sims] = deal(zeros(nsim,5));

Bs = {};

for i=1:nsim
    % build a random mSPN rules matrix
    B = [1 -1 0 0; -1 1 0 0; 0 0 0 0; 0 0 0 0] + randn(4,4);
    Bs{i} = B;

    % calculate subjective value grids
    action_values = zeros(5,6,6,4);
    for k=1:6
        for l=1:6
            action_values(1,k,l,:) = mean(B,'all'); %0D
            action_values(2,k,l,:) = B * [rew_incs(k) 0 0 0]'; %1D
            action_values(3,k,l,:) = B * [rew_incs(k) cost_incs(l) 0 0]'; %2d
            action_values(4,k,l,:) = B * [rew_incs(k) cost_incs(l) 1 0]'; %3D
            action_values(5,k,l,:) = B * [rew_incs(k) cost_incs(l) 1 1]'; %4D
        end
    end
    % record decision making ingredients
    for j=1:5
        [riskiness,safety,high_action,low_action,exploit,explore] = ...
            calculate_decision_making_ingredient_values(...
                squeeze(action_values(j,:,:,:)),6);
        riskiness_sims(i,j) = riskiness;
        safety_sims(i,j) = safety;
        high_action_sims(i,j) = high_action;
        low_action_sims(i,j) = low_action;
        exploit_sims(i,j) = exploit;
        explore_sims(i,j) = explore;

    end
end

sims = {riskiness_sims,high_action_sims,exploit_sims,safety_sims,...
    low_action_sims,explore_sims};

cutoff_pcntl = 90;
for i=1:length(sims)
    cutoffs = prctile(sims{i},cutoff_pcntl,'all');
    prop_outliers(i,:) = mean(sims{i}>cutoffs);
    sim_means(i,:) = mean(sims{i});
end

%% plotting

% outliers

th = pi/2:-pi/3:-4*pi/3;
cols = ['r','b','g','m','y'];


figure
for i=1:5
    [u,v] = pol2cart(th,prop_outliers(:,i)');
    compass(u+.00001,v+.00001,cols(i)); hold on
    zlim([0 max(prop_outliers,[],'all')])
end
zlim([0 0.3])
ph = allchild(gca);
set(ph(end),'FaceColor','none')
legend(["non-D",repelem("",5),"1D",repelem("",5),"2D",repelem("",5),...
    "3D",repelem("",5),"4D"])

% means

figure
bar(sim_means)
xticklabels(["Riskiness","High action","Exploit","Safety",...
    "Low action","Explore"])
legend(["0D","1D","2D","3D","4D"])
ylabel("mean score over simulations")
