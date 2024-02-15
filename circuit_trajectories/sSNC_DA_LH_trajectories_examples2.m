
clear; close all


n_interp_inc = 15;

% large # = benefit falls off more quickly if you're far from a state
distance_to_pt_multiplier = 1; 
% importance of returning back to a central stable point
gravity_multiplier = 1;
circuit_preference_pt = [1 1 1]; % strio,da,lh
ews = [5 5 1 1]';

unique_states = dec2bin(0:2^4-1)-'0';

strio_incs = linspace(0,3,n_interp_inc);
da_incs = linspace(0,3,n_interp_inc);
lh_incs = linspace(0,3,n_interp_inc);

[strio_grid,da_grid,lh_grid] = meshgrid(strio_incs(2:end-1),...
    da_incs(2:end-1),lh_incs(2:end-1));

% high-D space
state_values_weights = [zeros(1,15) 1];
[dx,dy,dz] = circuit_configuration_trajectory(...
    strio_incs,da_incs,lh_incs,n_space_component,distance_to_pt_multiplier,...
    gravity_multiplier,state_values_weights,ews,n_interp_inc);


%% 2D streamlines down midpoint of 3rd dimension and in 3D (Fig 6)

n_streamlines = 4;
streamline_cols = colororder;
starting_pts = rand(3,n_streamlines) .* ...
    [max(strio_grid,[],'all')-min(strio_grid,[],'all')+min(strio_grid,[],'all');
    max(da_grid,[],'all')-min(da_grid,[],'all')+min(da_grid,[],'all');
    max(lh_grid,[],'all')-min(lh_grid,[],'all')+min(lh_grid,[],'all')];
xstreamslice = {mean(strio_grid,"all"),[],[]};
ystreamslice = {[],mean(da_grid,"all"),[]};
zstreamslice = {[],[],mean(lh_grid,"all")};
views = [90 0 0; 0 0 90];

f=figure;

% slices
t = tiledlayout(1,4);
for i=3:-1:1
    ax(i) = nexttile; hold on
    streamslice(strio_grid,da_grid,lh_grid,dx,dy,dz,xstreamslice{i},ystreamslice{i},zstreamslice{i})
    lineobj = streamline(strio_grid,da_grid,lh_grid,dx,dy,dz,...
        starting_pts(1,:),starting_pts(2,:),starting_pts(3,:));
    for j=1:length(lineobj)
        lineobj(j).Color = streamline_cols(j,:);
        lineobj(j).LineWidth = 3;
        scatter3(lineobj(j).XData(1),lineobj(j).YData(1),lineobj(j).ZData(1), ...
           50, streamline_cols(j,:),'filled')
        scatter3(lineobj(j).XData(end),lineobj(j).YData(end),lineobj(j).ZData(end), ...
           50, streamline_cols(j,:))
    end
    hold off
    xlabel("sSPN activity (arb. u.)")
    ylabel("DA of SNc activity (arb. u.)")
    zlabel("LHb activity (arb. u.)")
    view(ax(i),views(1,i),views(2,i))
    xlim([min(strio_grid,[],"all"), max(strio_grid,[],"all")])
    ylim([min(da_grid,[],"all"), max(da_grid,[],"all")])
    zlim([min(lh_grid,[],"all"), max(lh_grid,[],"all")])
end

% in 3D
nexttile; hold on
streamslice(strio_grid,da_grid,lh_grid,dx,dy,dz,...
    max(strio_grid,[],"all"), max(lh_grid,[],"all"), min(da_grid,[],"all"));
lineobj = streamline(strio_grid,da_grid,lh_grid,dx,dy,dz,...
        starting_pts(1,:),starting_pts(2,:),starting_pts(3,:));
for j=1:length(lineobj)
    lineobj(j).Color = streamline_cols(j,:);
    lineobj(j).LineWidth = 3;
    scatter3(lineobj(j).XData(1),lineobj(j).YData(1),lineobj(j).ZData(1), ...
       50, streamline_cols(j,:),'filled')
    scatter3(lineobj(j).XData(end),lineobj(j).YData(end),lineobj(j).ZData(end), ...
       50, streamline_cols(j,:))
end
box on;
view(3);
xlim([min(strio_grid,[],"all"), max(strio_grid,[],"all")])
ylim([min(da_grid,[],"all"), max(da_grid,[],"all")])
zlim([min(lh_grid,[],"all"), max(lh_grid,[],"all")])
xlabel("sSPN activity (arb. u.)")
ylabel("DA of SNc activity (arb. u.)")
zlabel("LHb activity (arb. u.)")
set(gcf,'Renderer','painters')