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

[strio_grid,da_grid,lh_grid] = meshgrid(strio_incs,DA_incs,LH_incs);
    
% for isosurface
slices = linspace(min(net_advantage,[],'all'),...
    max(net_advantage,[],'all'),5);

figure; hold on
for i=1:length(slices)
    isosurface(strio_grid,da_grid,lh_grid,net_advantage,slices(i))
end
isosurface(strio_grid,da_grid,lh_grid,net_advantage,slices(i))
hold off
colormap jet
colorbar
xlabel("sSPN activity (arb. u.)")
ylabel("DA of SNc activity (arb. u.)")
zlabel("LHb activity (arb. u.)")
view(3)
set(gcf,'renderer','Painters')
clim([-1 1])

%% plot trajectories

[dx,dy,dz] = ...
    circuit_configuration_trajectory(strio_incs,DA_incs,LH_incs,...
    4,1,1,space_advantage_coefs,ones(4,1),n_inc);

n_trajectory_inc = 5;

[strio_grid,da_grid,lh_grid] = meshgrid(strio_incs(2:end-1),...
    DA_incs(2:end-1),LH_incs(2:end-1));

[strio_trajectory_grid, da_trajectory_grid, lh_trajectory_grid] = ...
        meshgrid(linspace(min(strio_grid,[],'all'),max(strio_grid,[],'all'),n_trajectory_inc), ...
        linspace(min(da_grid,[],'all'),max(da_grid,[],'all'),n_trajectory_inc),...
        linspace(min(lh_grid,[],'all'),max(lh_grid,[],'all'),n_trajectory_inc));
    
starting_pts = [strio_trajectory_grid(:),da_trajectory_grid(:),lh_trajectory_grid(:)];

verts = stream3(strio_grid,da_grid,lh_grid,dx,dy,dz,...
    starting_pts(:,1),starting_pts(:,2),starting_pts(:,3));


figure; hold on
for i=1:length(verts)
    in_space_prob = zeros(1,height(verts{i}));
    for j=1:height(verts{i})
        % find prob. dimension in space at that activity
        % change sSPN, DA, LHb, keep other circuit elements constant
        in_space_prob(j) = ...
            algorithmic_model(verts{i}(j,1),1,0.5,1,verts{i}(j,3),...
            0.5,1,verts{i}(j,2));
    end
    if height(verts{i})>1
        scatter3(verts{i}(end,1),verts{i}(end,2),verts{i}(end,3),[],...
            in_space_prob(end),'filled')
    end
    patch([verts{i}(:,1)' nan],[verts{i}(:,2)' nan],[verts{i}(:,3)' nan],...
        [in_space_prob 0],'FaceColor','none','EdgeColor','interp')
end
xlim([min(strio_grid,[],"all"),max(strio_grid,[],"all")])
ylim([min(da_grid,[],"all"),max(da_grid,[],"all")])
zlim([min(lh_grid,[],"all"),max(lh_grid,[],"all")])
view(3)
set(gcf,'renderer','Painters')
xlabel('striosome')
ylabel('DA')
zlabel('LHb')
c = colorbar;
caxis([0 0.5])
grid on
title(c,"Prob. dimension in space")
