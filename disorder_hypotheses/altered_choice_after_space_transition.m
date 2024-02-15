clear; close all
addpath(fileparts(pwd))

cmap = actioncmap();

reward_input = .7;
cost_input = .3;

decision_making_grid_size = 10;
n_actions = 2;
x_axis = [1 0];
y_axis = [0 1];
incsxy = linspace(-1,1,decision_making_grid_size);

B = [-2 -2; 2 -2; 2 4];


%% state with only reward component

state0000 = [0 0];

values_state0000 = ...
    rundecisionsimgrid(state0000,n_actions,x_axis,y_axis,B,incsxy);
values_at_input0000 = rundecisionsim(state0000, ...
    [reward_input, 0], x_axis, y_axis, B);

figure; tiledlayout(1,2)

nexttile; hold on
decision_making_map_plot(cmap,values_state0000,incsxy,"Reward only");
plot([0 reward_input],[0, 0],'LineWidth',5,'Color','k');
hold off

nexttile
barplot(values_at_input0000)

%% state with reward component and cost component

state1000 = [1 0];

% build matrix of values at different reward and cost values
values_state1000 = ...
    rundecisionsimgrid(state1000,n_actions,x_axis,y_axis,B,incsxy);
values_at_input1000 = rundecisionsim(state1000, ...
    [reward_input, cost_input], x_axis, y_axis, B);

figure; tiledlayout(1,2)

nexttile; hold on
decision_making_map_plot(cmap,values_state1000,incsxy,"Reward + some cost");
plot([0 reward_input],[0, cost_input],'LineWidth',5,'Color','k');
hold off

nexttile
barplot(values_at_input1000)



function [] = barplot(values_at_input)
    bar(values_at_input)
    xticklabels(["approach","avoid"]);
    ylabel("Subjective value")
    title("Subjective values at current input")
    ylim([0 .5])
end
