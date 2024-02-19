%% This script generates a figure that explains how the cascade plot is generated.
%  Essentially, the algorithm associates time windows with colors. If,
%  during a time window, many neurons are active, that time period is
%  associated with a deep shade of red. For time windows with
%  less activity, the associated color is less red.

f = figure;
%  Each neuron has a 'brick' corresponding to the time that they are the
%  most active. The first subplot plots the locations of these 'bricks' for
%  make believe neurons. The brick times are stored in the variable
%  'brick_centers'.
subplot(3,1,[1 2]);

% The bricks have a duration in seconds.
brick_duration = .25;

% Bricks can occur in high concentration.
high_concentration_start = 7+.5;
high_concentration_end = 11-.5;
brick_centers = unifrnd(high_concentration_start,high_concentration_end,10,1); 
brick_centers = [brick_centers; high_concentration_start; high_concentration_end];

% Bricks can occur in medium concentration.
mid_concentration_start = 5;
mid_concentration_end = 13;
brick_centers = [brick_centers; mid_concentration_start; mid_concentration_end];

% Bricks can occur in very low concentrations.
not_window_start = 1;
not_window_end = 19;
brick_centers = [brick_centers; 1; 16; 0.5; 19];

% Plot bricks
brick_centers = sort(brick_centers);
brick_centers = brick_centers(randperm(length(brick_centers)));
brick_ys = [];
for brick_idx = 1:length(brick_centers)
    brick_center = brick_centers(brick_idx);
    brick_start = brick_center-brick_duration;
    brick_end = brick_center+brick_duration;
    patch([brick_start, brick_end, brick_end, brick_start],...
            [2*brick_idx, 2*brick_idx, 2*brick_idx+1, 2*brick_idx+1], 'black');
    brick_ys = [brick_ys; brick_center, 2*brick_idx];
end

% Make lines showing window of highest activity
height = 2*length(brick_centers)+4;
line([high_concentration_start high_concentration_start], [-1, height],...
                'Color','black','LineWidth',2,'LineStyle','--');
line([high_concentration_end high_concentration_end], [-1, height],...
                'Color','black','LineWidth',2,'LineStyle','--');

brick_centers = sort(brick_centers);
% Red (most active) time window
red_window_start = brick_centers(find(brick_centers>high_concentration_start,1));
red_window_end = brick_centers(find(brick_centers<high_concentration_end,1,'last'));
line([red_window_start, red_window_start], [brick_ys(brick_ys(:,1) == red_window_start,2), -1],...
        'Color','red','LineWidth',2);
arrow([red_window_start, -1], [red_window_end, -1], 'Color', 'red');
line([red_window_end, red_window_end], [brick_ys(brick_ys(:,1) == red_window_end,2), -1],...
        'Color','red','LineWidth',2,'LineStyle','--');
    
% Yellow (medium activity) time window
line([mid_concentration_start, mid_concentration_start], [brick_ys(brick_ys(:,1) == mid_concentration_start,2), -2],...
        'Color','yellow','LineWidth',2);
arrow([mid_concentration_start, -2], [mid_concentration_end, -2], 'Color', 'yellow');
line([mid_concentration_end, mid_concentration_end], [brick_ys(brick_ys(:,1) == mid_concentration_end,2), -2],...
        'Color','yellow','LineWidth',2,'LineStyle','--');

% 'White' (least activity) time window
line([not_window_start, not_window_start], [brick_ys(brick_ys(:,1) == not_window_start,2), -3],...
        'Color',rgb('gray'),'LineWidth',2);
arrow([not_window_start, -3], [not_window_end, -3], 'Color', rgb('gray'));
line([not_window_end, not_window_end], [brick_ys(brick_ys(:,1) == not_window_end,2), -3],...
        'Color',rgb('gray'),'LineWidth',2,'LineStyle','--');
ylim([-1-4, height+1]);

% In a second subplot, show the colors (red, yellow, 'white') associated
% with the time windows identified above.
subplot(3,1,3);
small_y = .4; big_y = .6;
patch([not_window_start, not_window_end, not_window_end, not_window_start], ...
    [small_y, small_y, big_y, big_y], rgb('gray'),'EdgeColor','none');
patch([mid_concentration_start, mid_concentration_end, mid_concentration_end, mid_concentration_start], ...
    [small_y, small_y, big_y, big_y], 'yellow','EdgeColor','none');
patch([red_window_start, red_window_end, red_window_end, red_window_start], ...
    [small_y, small_y, big_y, big_y], 'red','EdgeColor','none');
xlim([0 20]); ylim([0 1]);

% Save the figure
fig_dir = [ROOT_DIR 'Algorithm Visualizations/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveas(f,[fig_dir 'Entropy Windows'], 'fig');
saveas(f,[fig_dir 'Entropy Windows'], 'epsc2');
saveas(f,[fig_dir 'Entropy Windows'], 'jpg');