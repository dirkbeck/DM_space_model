clear; close all
rng('default')
addpath(fileparts(pwd))

%% stress vs control T-maze

n_inc = 15;
incsxy = linspace(0,1,15);
n_actions = 2;

B = [-3 -3; 1 -1; -1 1; 0 0; 0 0];
x_axis = [1 0 0 0];
y_axis = [0 1 0 0];

action_values_1100 = ...
    rundecisionsimgrid([1 1 0 0],n_actions,x_axis,y_axis,B,10*incsxy);
action_values_1000 = ...
    rundecisionsimgrid([1 0 0 0],n_actions,x_axis,y_axis,B,10*incsxy);
action_values_0000 = ...
    rundecisionsimgrid([0 0 0 0],n_actions,x_axis,y_axis,B,10*incsxy);
action_values_stress1 = action_values_0000;
action_values_stress2 = action_values_0000;
action_values_stress2(end-2:end,:,:) = action_values_1000(end-2:end,:,:);

action_values_by_task = {action_values_1100, action_values_stress1, ...
    action_values_stress2};
state_dims_by_task = [2 1 2];

titles = ["Control","Stress 1","Stress 2"];

cmap = actioncmap();

CBC_indxs = [round(n_inc/2) round(n_inc/2) n_inc round(n_inc/2)+2];
BB_indxs = [1 n_inc-2 n_inc n_inc];

for i=1:length(action_values_by_task)

    action_values = action_values_by_task{i};
    state_dims = state_dims_by_task(i);
    
    % plot decision-making grid with task rectangles and decision boundary

    figure; hold on
    decision_making_map_plot(cmap,action_values,incsxy,titles(i))
    contour(incsxy,incsxy,action_values(:,:,1)'-...
                    action_values(:,:,2)',[0 0],':k','LineWidth',5)
        
    xlabel("reward difference, right - left")
    ylabel("cost difference, right - left")
    xlim([incsxy(1) incsxy(end)])
    ylim([incsxy(1) incsxy(end)])
    xticks([0 1]); xticklabels(["neg","0"])
    yticks([0 1]); yticklabels(["neg","0"])


    action_values_by_task{i} = action_values;

end


% Weiner process parameters
noise = 1;
max_t = 8;
threshold = 2;
tstep = .1;
n_sim = 2000;

% for the CBC task across the concentrations
for i=1:CBC_indxs(3)-CBC_indxs(1)+1
    indx = CBC_indxs(1)+i-1;
    for j=1:length(action_values_by_task)
        drift_rates_control{j}(i,:) = squeeze(action_values_by_task{j}(indx,5,1:2));
        [t_to_decision_dat_control{j}{i}, actions_taken_control{j}{i}] = ...
            weiner_process_model(drift_rates_control{j}(i,:),...
            noise,max_t,threshold,tstep,n_sim,0); % b_downstreamBG is the first row of B above
        approached{j}(i) = sum(actions_taken_control{j}{i}==1);
    end
end

figure; hold on
for j=1:length(action_values_by_task)
    y = approached{j}(1:end-1)/n_sim;
    plot(linspace(0,1,length(y)),y)
end
hold off
legend(["control","stress, non-D space",...
    "stress, transition from non-D to 1D space"])
xlabel("incremented reward (arb. u.)")
ylabel("prop. turn right")


