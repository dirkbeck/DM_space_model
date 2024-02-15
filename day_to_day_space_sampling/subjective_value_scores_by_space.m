% keep an arbitrary set of matrix rules, change space.
% show that different spaces can lead to different types of decisions
% this is relevant to disorders where oftentimes multiple abberant
% decision-making profiles take place at different times

clear; close all
rng('default')
addpath(fileparts(pwd))

% which space to use for the plotted examples
example_spaces = {[1 1 0 0],[1 0 0 0],[0 0 0 0]};
decision_making_grid_size = 8;

%% first, a normal grid to highlight day-to-day variability

% arbitrary mSPN rules
x_axis = [1 0 0 0];
y_axis = [0 1 0 0];
B = [-3 -3 -3 -3; 10 -10 0 0; -10 10 0 0; 0 0 0 0; 0 0 0 0];
[action_values,riskiness,safety,high_action,...
    low_action,exploit,explore] = ...
    get_action_vals_and_dm_ingredients(example_spaces, ...
    4,x_axis,y_axis,B,decision_making_grid_size);

%% plots

day_by_day_differences_plotter(example_spaces,decision_making_grid_size,...
    action_values,riskiness,safety,high_action,...
    low_action,exploit,explore)

differentD_spaces = {[0 0 0 0],[1 0 0 0],[1 1 0 0]};

[action_values,riskiness,safety,high_action,...
    low_action,exploit,explore] = ...
    get_action_vals_and_dm_ingredients(differentD_spaces, ...
    4,x_axis,y_axis,B,decision_making_grid_size);

comorbidity_plotter(riskiness,safety,high_action,low_action,...
    exploit,explore)



%% functions

function [action_values,riskiness,safety,high_action,...
    low_action,exploit,explore] = ...
    get_action_vals_and_dm_ingredients(example_spaces, ...
    n_actions,x_axis,y_axis,B,decision_making_grid_size)
    
    for i=1:length(example_spaces)
    
        space = example_spaces{i};
    
        % in the example space, form a subjective value grid
        action_values_i = ...
            rundecisionsimgrid(space,n_actions,x_axis,y_axis,B,...
            linspace(-1,1,decision_making_grid_size));
        action_values{i} = action_values_i;
        
        % what are the values along the decision-making ingredient axes?
        [riskiness(i),safety(i),high_action(i),low_action(i),...
            exploit(i),explore(i)] = ...
            calculate_decision_making_ingredient_values(action_values_i,...
            decision_making_grid_size);
    end

end


function [] = day_by_day_differences_plotter(example_spaces,...
    decision_making_grid_size,action_values,riskiness,safety,high_action,...
    low_action,exploit,explore)

    cmap = actioncmap();
    incsxy = linspace(-1,1,decision_making_grid_size);
    
    figure
    tiledlayout(round(length(example_spaces)/2),2);
    for i=1:length(example_spaces)
        nexttile
        ttle = strcat("State ", num2str(example_spaces{i}));
        decision_making_map_plot(cmap,action_values{i},incsxy,ttle)
    end
    set(gcf,'renderer','painters');

    dat = [riskiness;high_action;exploit;safety;low_action;explore]';

    figure
    spider_plot(dat,'AxesLabels',{"Riskiness","High action",...
        "Exploit","Safety","Low action","Explore"});
    legend(["2D space","1D space","non-D space"])
    ylabel('Relative score (remove ticks in Adobe)')
    set(gcf,'renderer','painters');
    
end


function [] = comorbidity_plotter(riskiness,safety,...
    high_action,low_action,exploit,explore)

    % probability of spaces at different sSPN levels, taken from Fig2 
    n_inc = 10;
    sSPN = linspace(-1,1,n_inc);
    for i=1:length(sSPN)
        p(i) = algorithmic_model(sSPN(i),1,0,1,0,0,10,1);
    end

    for k=0:2
        probs_spaces(:,k+1) = nchoosek(4,k).*p.^k.*(1-p).^(4-k);
    end

    dat = [riskiness;high_action;exploit;safety;low_action;explore]';
    mixed_dat = probs_spaces * dat;

    cols = jet(10);

    figure
    spider_plot(mixed_dat,'AxesLabels',{"Riskiness","High action",...
        "Exploit","Safety","Low action","Explore"},'Color',cols,...
        'FillOption','on');
    ylabel('Relative score (remove ticks in Adobe)')
    colorbar
    colormap jet
    clim([-1 1])
    set(gcf,'renderer','painters');

end