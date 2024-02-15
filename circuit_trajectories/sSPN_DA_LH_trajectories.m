clear; close all
rng(10)
addpath(fileparts(pwd))

%% plot net advantage on strio, DA, LH grid

n_inc = 10;
spaces_plotted = [0 0 0 0; 1 0 0 0; 1 1 0 0; 1 1 1 0; 1 1 1 1];
space_advantage_coefs = 5*randn(16,1);
spaces = dec2bin(0:16-1)' - '0';
strio_incs = linspace(0,2,n_inc);
strio0 = 1;
FSI = 1;
FSI_c = .1;
GPi = 1;
GPi0 = 1;
LH_incs = linspace(0,2,n_inc);
LH0 = 1;
RMTg = 1;
RMTg0 = 1;
DA_incs = linspace(0,2,n_inc);
DA_a = 1;
DA_b = 1;
baseline_FSI = 1;
baseline_strio = 1;
baseline_GPi = 1;
baseline_LH = 1;
baseline_RMTg = 1;
baseline_DA = 1;

net_advantage = zeros(n_inc,n_inc,n_inc);
for i=1:n_inc
    for j=1:n_inc
        for k=1:n_inc
            advantage = calculate_circuit_configuration_advantage(...
                space_advantage_coefs,spaces',strio_incs(i),FSI,GPi,...
                LH_incs(j),RMTg,DA_incs(k));
            cost = calculate_circuit_configuration_cost(...
                FSI,strio_incs(i),GPi,LH_incs(j),RMTg,DA_incs(k),...
                baseline_FSI, baseline_strio,baseline_GPi, baseline_LH,...
                baseline_RMTg, baseline_DA);
            net_advantage(i,j,k) = advantage - cost;
        end
    end
end

sail_plot(strio_incs,DA_incs,LH_incs,net_advantage)

%% plot trajectories

[dx,dy,dz] = ...
    circuit_configuration_trajectory(strio_incs,DA_incs,LH_incs,...
    4,1,1,space_advantage_coefs,ones(4,1),n_inc);

n_streamline_inc = 5;

% for labeling trajectories
epsilon = .5;
minpts = ceil(n_streamline_inc^3/50);
k = 3;

[strio_grid,da_grid,lh_grid] = meshgrid(strio_incs(2:end-1),...
    DA_incs(2:end-1),LH_incs(2:end-1));

trajectory_sinks_plot(strio_grid,da_grid,lh_grid,dx,dy,dz,...
    n_streamline_inc,epsilon,minpts,k,"")

%% functions

function [] = sail_plot(strio_incs,da_incs,lh_incs,...
    net_advantages)
    
    [strio_grid,da_grid,lh_grid] = meshgrid(strio_incs,da_incs,lh_incs);
    
    % for isosurface
    slices = linspace(min(net_advantages,[],'all'),...
        max(net_advantages,[],'all'),5);
    
    figure; hold on
    for i=1:length(slices)
        isosurface(strio_grid,da_grid,lh_grid,net_advantages,slices(i))
    end
    isosurface(strio_grid,da_grid,lh_grid,net_advantages,slices(i))
    hold off
    colormap jet
    colorbar
    xlabel("sSPN activity (arb. u.)")
    ylabel("DA of SNc activity (arb. u.)")
    zlabel("LHb activity (arb. u.)")
    view(3)
    set(gcf,'renderer','Painters')
    clim([-1 1])

end

function [] = trajectory_sinks_plot(strio_grid,da_grid,lh_grid,dx,dy,dz,...
    n_trajectory_inc,epsilon,minpts,k,ttl)
    
    [strio_trajectory_grid, da_trajectory_grid, lh_trajectory_grid] = ...
        meshgrid(linspace(min(strio_grid,[],'all'),max(strio_grid,[],'all'),n_trajectory_inc), ...
        linspace(min(da_grid,[],'all'),max(da_grid,[],'all'),n_trajectory_inc),...
        linspace(min(lh_grid,[],'all'),max(lh_grid,[],'all'),n_trajectory_inc));
    
    % ---------------trajectory lines in 3D -------------------------
    
    cols = [colororder; rand(n_trajectory_inc^3 - height(colororder),3)];
    
    starting_pts = [strio_trajectory_grid(:),da_trajectory_grid(:),lh_trajectory_grid(:)];
    
    [classes, end_pts, verts] = ...
        find_trajectory_sink_by_region(...
        strio_grid,da_grid,lh_grid,...
        dx,dy,dz,starting_pts,epsilon,minpts,k);
    classes_grid = reshape(classes,n_trajectory_inc,n_trajectory_inc,n_trajectory_inc);
    
    unique_classes = unique(classes);
    
    figure; hold on
    for i=1:length(unique_classes)
        scatter3(end_pts(classes==unique_classes(i),1),...
            end_pts(classes==unique_classes(i),2),...
            end_pts(classes==unique_classes(i),3),[],cols(i,:),'filled')
    end
    lineobj = streamline(verts);
    for i=1:length(verts)
        lineobj(i).Color = cols(classes(i),:);
    end
    hold off
    xlim([min(strio_grid,[],"all"),max(strio_grid,[],"all")])
    ylim([min(da_grid,[],"all"),max(da_grid,[],"all")])
    zlim([min(lh_grid,[],"all"),max(lh_grid,[],"all")])
    view(3)
    set(gcf,'renderer','Painters')
    xlabel('striosome')
    ylabel('DA')
    zlabel('LH')
    title(ttl)
    
    
    % ---------- 2D slices plotted in 3D --------
    
    
    middle_trajectory_index = ceil(n_trajectory_inc/2);
    n_incs = size(dx,1);
    grads = {dx,dy,dz};
    axis_labels = ["sSPN activity (arb. u.)","DA of SNc activity (arb. u.)", ...
        "LHb activity (arb. u.)"];
    grid_indxs = {1:n_incs,1:n_incs,1:n_incs};
    trajectory_indxs = {1:n_trajectory_inc,1:n_trajectory_inc,1:n_trajectory_inc};
    
    grids = {{strio_grid(:,:,1), da_grid(:,:,1)},...
        {strio_grid(:,:,1), squeeze(lh_grid(1,:,:))'},...
        {da_grid(:,:,1)', squeeze(lh_grid(1,:,:))'}};
    trajgrids = {{strio_trajectory_grid(:,:,1), da_trajectory_grid(:,:,1)},...
        {strio_trajectory_grid(:,:,1), squeeze(lh_trajectory_grid(1,:,:))'},...
        {da_trajectory_grid(:,:,1)', squeeze(lh_trajectory_grid(1,:,:))'}};
    
    figure
    t = tiledlayout(1,3);
    for i=1:3
        nt = nexttile; hold on
    
        grad_indxs = [1,2,3];
        grad_indxs(4-i) = [];
        grads_copy = grads(grad_indxs);
        axis_labels_copy = axis_labels(grad_indxs);
        x_axis_grad = grads_copy{1};
        y_axis_grad = grads_copy{2};
    
        grid_indxs_copy = grid_indxs;
        grid_indxs_copy{4-i} = middle_trajectory_index;
        
        trajectory_indxs_copy = trajectory_indxs;
        trajectory_indxs_copy{4-i} = middle_trajectory_index;
    
        x_axis_slice = squeeze(x_axis_grad(grid_indxs_copy{1},...
            grid_indxs_copy{2},grid_indxs_copy{3}));
        y_axis_slice = squeeze(y_axis_grad(grid_indxs_copy{1},...
            grid_indxs_copy{2},grid_indxs_copy{3}));
        hght = -invgradient(x_axis_slice,y_axis_slice);
        sliced_classes_grid = squeeze(classes_grid(trajectory_indxs_copy{1},...
            trajectory_indxs_copy{2},trajectory_indxs_copy{3}));
        color_code = zeros(size(strio_grid,1));
        for j=1:size(strio_grid,1)
            for k=1:size(strio_grid,1)
                closeness = sqrt((grids{i}{1}(j,k)-trajgrids{i}{1}(:,:,1)).^2 + ...
                    (grids{i}{2}(j,k)-trajgrids{i}{2}(:,:,1)).^2);
                [~,indx] = min(closeness,[],'all');
                color_code(j,k) = sliced_classes_grid(indx); 
            end
        end
        surf(hght,color_code)
        shading interp
        l = streamslice(x_axis_slice,y_axis_slice);
        set(l,'Color','k');
        for j=1:length(l)
            height_j = interp2(hght,l(j).XData, l(j).YData);
            l(j).ZData = height_j;
        end
        hold off
        xlabel(axis_labels_copy(1))
        ylabel(axis_labels_copy(2))
        zticks('')
        view(3)
        set(gcf,'renderer','Painters')
    end
    
    set(gcf,'renderer','Painters')
    title(t,ttl)
    colormap(cols(1:unique_classes(end),:))
    

end



function [classes, end_pts, verts] = ...
    find_trajectory_sink_by_region(...
    strio_grid,da_grid,lh_grid,dx,dy,dz,starting_pts,epsilon,minpts,k)
    % classify staring point by where the trajectory ends
    
    % epsilon, minpts are parameters for DBSCAN of on-page trajectories, kmeans
    % is for kmeans of off-page trajectories
    
    verts = stream3(strio_grid,da_grid,lh_grid,dx,dy,dz,...
        starting_pts(:,1),starting_pts(:,2),starting_pts(:,3));
    
    end_pts = nan(length(verts),3);
    for i=1:length(verts)
        if ~isempty(verts{i})
            end_pts(i,:) = verts{i}(end,:);
        end
    end
    
    % separate lines that ended on the page vs off
    off_page = end_pts(:,1) - strio_grid(1,1,1) < epsilon | ...
        end_pts(:,2) - da_grid(1,1,1) < epsilon | ...
        end_pts(:,3) - lh_grid(1,1,1) < epsilon | ...
        strio_grid(1,end,end) - end_pts(:,1) < epsilon | ...
        da_grid(end,1,end) - end_pts(:,2) < epsilon | ...
        lh_grid(end,end,end) - end_pts(:,3) < epsilon;
    
    if ~isempty(end_pts(~off_page,:))
        on_page_classes = dbscan(end_pts(~off_page,:),epsilon,minpts);
        maxval = max(on_page_classes);
    else
        on_page_classes = [];
        maxval = 0;
    end
    if any(on_page_classes==-1)
        on_page_classes(on_page_classes==-1) = length(unique(on_page_classes));
    end
    off_page_classes = kmeans(end_pts(off_page,:),k) + maxval;
    
    classes = zeros(height(end_pts),1);
    classes(~off_page) = on_page_classes;
    classes(off_page) = off_page_classes;


end