clear; close all

rng('default')
addpath(fileparts(pwd))

% for example space preferences,
% value the [0 0 0 0], [1 1 0 0], and [1 1 1 1] spaces 
space_advantage_coefs = 50*rand(16,1) .* [1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1]'; 
n_interp_inc = 10;
baseline_strio = 5;
baseline_fsi = 5;
GPi = 1;
LH = 0;
RMTg = 1;
DA = 0;
spaces = dec2bin(0:16-1)' - '0';
space_diamonds_to_plot_indxs = [1 16];
space_diamonds_to_plot = spaces(:,space_diamonds_to_plot_indxs)';
diamond_size = .75;

[strio_incs,fsi_incs] = deal(linspace(0,10,n_interp_inc));

% first, for plotting, find the circuit configuration where the advantage of 
% each space is maximized given the example space advantage coefficients

for i=1:16
    individual_space_advantage_coefs = zeros(16,1);
    individual_space_advantage_coefs(i) = 1; % only this space is valued
    space_i_advantages = ...
        get_advantage_and_cost_grids(strio_incs,fsi_incs,...
        individual_space_advantage_coefs,baseline_strio,baseline_fsi, ...
        GPi,LH,RMTg,DA);
    space_advantage_maximum_indxs = ...
        get_critical_pts(space_i_advantages,nan,nan);
    space_advantage_maxima(i,1) = ...
        strio_incs(space_advantage_maximum_indxs(1));
    space_advantage_maxima(i,2) = ...
        strio_incs(space_advantage_maximum_indxs(2));
    space_advantages{i} = space_i_advantages;
end

% form grids of advantage, cost, and net advantage on the strio & fsi space
% with baseline [0 0] and an example space advantage coefficients 

[advantages,costs,net_advantages] = ...
    get_advantage_and_cost_grids(strio_incs,fsi_incs,space_advantage_coefs,...
    baseline_strio,baseline_fsi,GPi,LH,RMTg,DA);

n_col_inc = 100;
green_cmap = [linspace(1,0,n_col_inc)' ones(n_col_inc,1) linspace(1,0,n_col_inc)'];
red_cmap = [ones(n_col_inc,1) linspace(1,0,n_col_inc)' linspace(1,0,n_col_inc)'];

% max/min indices
[advantage_critical_pts,cost_critical_pts, ...
    net_advantage_critical_pts] = get_critical_pts(advantages,costs,...
    net_advantages);

heatmap_plotter(advantages,advantage_critical_pts,...
    strio_incs,fsi_incs,baseline_strio,baseline_fsi,space_diamonds_to_plot,...
    space_advantage_maxima,diamond_size,"Advantage",green_cmap)

heatmap_plotter(costs,cost_critical_pts,...
    strio_incs,fsi_incs,baseline_strio,baseline_fsi,space_diamonds_to_plot,...
    space_advantage_maxima,diamond_size,"Cost",red_cmap)

heatmap_plotter(net_advantages, net_advantage_critical_pts,...
    strio_incs,fsi_incs,baseline_strio,baseline_fsi,space_diamonds_to_plot,...
    space_advantage_maxima,diamond_size,"Net advantage","parula")

[dx, dy] = gradient(net_advantages);
[X, Y] = meshgrid(strio_incs,fsi_incs);
% movement is in the increasing direction of the gradient
trajectory_verts = stream2(X,Y,dx,dy,baseline_strio,baseline_fsi);
streamline_plotter(net_advantages,strio_incs,fsi_incs,trajectory_verts)

% now look at what happens when the circuit reaches the end of its
% trajectory. Keep the same example space advantage coefficients vector but
% use a new circuit baseline to calculate cost

new_baseline_strio = trajectory_verts{1}(end,1);
new_baseline_fsi = trajectory_verts{1}(end,2);

[new_advantages,new_costs,new_net_advantages] = ...
    get_advantage_and_cost_grids(strio_incs,fsi_incs,space_advantage_coefs,...
    new_baseline_strio,new_baseline_fsi,GPi,LH,RMTg,DA);
[~,~,new_net_advantage_critical_pts] = get_critical_pts(new_advantages,new_costs,...
    new_net_advantages);

heatmap_plotter(new_net_advantages,new_net_advantage_critical_pts,...
    strio_incs,fsi_incs,new_baseline_strio,new_baseline_fsi,...
    space_diamonds_to_plot,space_advantage_maxima,diamond_size,...
    "Net advantage at the end of the trajectory","parula")



%% functions

function [advantages,costs,net_advantages] = ...
    get_advantage_and_cost_grids(strio_incs,fsi_incs,space_advantage_coefs, ...
    baseline_strio,baseline_FSI,GPi,LH,RMTg,DA)
    
    [net_advantages,costs,advantages] = ...
        deal(zeros(length(strio_incs),length(fsi_incs)));
    spaces = (dec2bin(0:2^4-1)' - '0')';

    for i=1:length(strio_incs)
        for j=1:length(fsi_incs)
    
            strio = strio_incs(i);
            FSI = fsi_incs(j);
                
            advantage = calculate_circuit_configuration_advantage(...
                space_advantage_coefs,spaces,strio_incs(i),fsi_incs(j),...
                GPi,LH,RMTg,DA);
            cost = calculate_circuit_configuration_cost(FSI,strio,GPi,...
                LH,RMTg,DA,baseline_FSI, baseline_strio, GPi, LH, RMTg, DA);
            net_advantages(i,j) = advantage - cost;
    
            advantages(i,j) = advantage;
            costs(i,j) = cost;
    
        end
    end

end


function [advantage_critical_pts,cost_critical_pts, ...
    net_advantage_critical_pts] = get_critical_pts(advantages,costs,...
    net_advantages)

    [max_advantage_strio_i,max_advantage_fsi_i] = ...
    find(advantages==max(advantages(:)));
    [min_cost_strio_i,min_cost_fsi_i] = ...
        find(costs==min(costs(:)));
    [max_net_advantage_strio_i,max_net_advantage_fsi_i] = ...
        find(net_advantages==max(net_advantages(:)));

    advantage_critical_pts = [max_advantage_strio_i,max_advantage_fsi_i];
    cost_critical_pts = [min_cost_strio_i,min_cost_fsi_i];
    net_advantage_critical_pts = ...
        [max_net_advantage_strio_i,max_net_advantage_fsi_i];

end


function [] = heatmap_plotter(dat,critical_pt_idx,strio_incs,fsi_incs,...
    baseline_strio,baseline_fsi,space_diamonds_to_plot,...
    space_advantage_maxima,diamond_size,ttl,cmap)

    figure
    hold on
    pcolor(strio_incs, fsi_incs, dat')
    if ~isempty(critical_pt_idx)
        scatter(strio_incs(critical_pt_idx(1)), ...
            fsi_incs(critical_pt_idx(2)),'+k')
        scatter(baseline_strio,baseline_fsi,"*k")
        for i=1:height(space_diamonds_to_plot)
        plot_space_diamond(space_diamonds_to_plot(i,:),...
            space_advantage_maxima(i,1),space_advantage_maxima(i,2),...
            diamond_size);
        end
    end
    hold off

    xlabel('sSPN activity (arb. u.)')
    ylabel('FSI activity (arb. u.)')
    title(ttl)
    colorbar
    colormap(cmap)
    xlim([strio_incs(1), strio_incs(end)])
    ylim([fsi_incs(1), fsi_incs(end)])

    set(gcf,'renderer','painters')

end

function [] = streamline_plotter(net_advantages,strio_incs,fsi_incs,...
    trajectory_verts)
    
    n_trajectories = 30;

    [dx, dy] = gradient(net_advantages);
    [X, Y] = meshgrid(strio_incs,fsi_incs);

    figure
    tiledlayout(2,1)

    nexttile
    scatter(trajectory_verts{1}(:,1),trajectory_verts{1}(:,2),"*k")
    title("Example of the movement of one baseline configuration over time")
    xlabel('sSPN activity (arb. u.)')
    ylabel('FSI activity (arb. u.)')
    xlim([strio_incs(1), strio_incs(end)])
    ylim([fsi_incs(1), fsi_incs(end)])
    set(gcf,'renderer','painters');
    
    nexttile
    random_starting_pts_strio = range(strio_incs)*rand(n_trajectories,1) + ...
        strio_incs(1);
    random_starting_pts_fsi = range(fsi_incs)*rand(n_trajectories,1) + ...
        fsi_incs(1);
    streamline(X,Y,dx,dy,random_starting_pts_strio,random_starting_pts_fsi);
    xlabel('sSPN activity (arb. u.)')
    ylabel('FSI activity (arb. u.)')
    title("Movement of baseline activities over time")
    xlim([strio_incs(1), strio_incs(end)])
    ylim([fsi_incs(1), fsi_incs(end)])
    set(gcf,'renderer','painters');

end

function [] = plot_space_diamond(space,x,y,diamond_size)
    
    xedges = diamond_size*[0 -1 0; 0 1 0; 0 -1 0; 0 1 0];
    yedges = diamond_size*[0 0 1; 0 0 1; 0 0 -1; 0 0 -1];

    for i = 1:4
        if space(i) == 1
            fill_col = 'k';
        else
            fill_col = 'w';
        end
        fill(x + xedges(i,:), y + yedges(i,:), fill_col)
    end

end
