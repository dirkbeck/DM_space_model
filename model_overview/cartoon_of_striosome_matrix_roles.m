clear; close all
addpath(fileparts(pwd))

n_grid_incs = 3; % number of increments to plot along each dimension
n_actions = 4;

incs = linspace(0,1,n_grid_incs+1);
[cost,reward,hunger] = meshgrid(incs,incs,incs);

% example subjective values in 3D state space for the 4 actions
example_signal(:,:,:,1) = 5*reward - 2*cost - hunger; % approach
example_signal(:,:,:,2) = - 5*reward + 2*cost; % avoid
example_signal(:,:,:,3) = hunger; % freeze
example_signal(:,:,:,4) = -reward - cost - hunger; % wander
example_signal = min(max(example_signal,0),.5);

% take slices for 2D and 1D
values_3D = example_signal;
values_2D = squeeze(mean(values_3D,3));
values_1D = squeeze(mean(values_2D,2));


%% plot cartoons

cmap = actioncmap();
[incsx,incsxy,incsxyz] = deal(linspace(-1,1,n_grid_incs+1));


% striosome

figure; tiledlayout(3,1);

nexttile
decision_making_map_3D_plot(cmap,zeros(n_grid_incs+1,n_grid_incs+1,n_grid_incs+1,4),...
    incsxyz,"3D")
nexttile
decision_making_map_plot(cmap,zeros(n_grid_incs+1,n_grid_incs+1,4),...
    incsxyz,"2D")
nexttile
decision_making_map_1D_plot(cmap,zeros(n_grid_incs+1,4),incsxyz,"1D")

% matrix

figure; tiledlayout(3,1);

nexttile
decision_making_map_3D_plot(cmap,values_3D,incsxyz,"3D")
nexttile
decision_making_map_plot(cmap,values_2D,incsxyz,"2D")
nexttile
decision_making_map_1D_plot(cmap,values_1D,incsxyz,"1D")
axis normal



%% functions

function [] = decision_making_map_1D_plot(cmap,values,incsx,ttle)
% plots 2D psychometric function color maps
    
    % parameters
    decision_making_grid_size = size(values,2);

    hold on
    for xi=1:decision_making_grid_size-1
        value_ = squeeze(values(xi,:));
        value = [1-sum(value_), value_]';
        color = sum(value .* cmap(1:size(values,2)+1,:),1);
        fill([incsx(xi) incsx(xi) incsx(xi+1) incsx(xi+1)],...
             [0 1 1 0], ...
             color, 'LineStyle','none');
    end
    
    xlabel('reward')
    xticks('')
    yticks('')
    set(gcf,'renderer','Painters')
    axis square

    title(ttle)

end


function [] = decision_making_map_3D_plot(cmap,values,incsxyz,ttle)

% plots psychometric function color maps on 3 input axes

    % parameters
    decision_making_grid_size = size(values,2);

    % for cube connections
    idx = ...
        [4 8 5 1 4; 1 5 6 2 1; 2 6 7 3 2; 3 7 8 4 3; 5 8 7 6 5; 1 4 3 2 1]';

    hold on
    for xi=1:decision_making_grid_size-1
        for yi=1:decision_making_grid_size-1
            for zi=1:decision_making_grid_size-1
                value_ = squeeze(values(xi,yi,zi,:));
                value = [1-sum(value_); value_];
                color = sum(value .* cmap(1:size(values,4)+1,:),1);
                   
                coord = [...
                    incsxyz(xi) incsxyz(yi) incsxyz(zi);
                    incsxyz(xi+1) incsxyz(yi) incsxyz(zi);
                    incsxyz(xi+1) incsxyz(yi+1) incsxyz(zi);
                    incsxyz(xi) incsxyz(yi+1) incsxyz(zi);
                    incsxyz(xi) incsxyz(yi) incsxyz(zi+1);
                    incsxyz(xi+1) incsxyz(yi) incsxyz(zi+1);
                    incsxyz(xi+1) incsxyz(yi+1) incsxyz(zi+1);
                    incsxyz(xi) incsxyz(yi+1) incsxyz(zi+1)];
    
                xc = coord(:,1);
                yc = coord(:,2);
                zc = coord(:,3);
                patch(xc(idx), yc(idx), zc(idx), color);

            end
        end
    end
    
    xlabel('reward')
    ylabel('cost')
    zlabel('hunger')
    xticks('')
    yticks('')
    zticks('')
    set(gcf,'renderer','Painters')
    axis square
    view(3)

    title(ttle)

end