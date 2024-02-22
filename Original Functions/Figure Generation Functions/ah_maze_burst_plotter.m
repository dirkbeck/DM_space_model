function ah_maze_burst_plotter(X,fig_marker,plotting_parameters)
% FUNCTION TO DRAW A DOTPLOT IN A MAZE.
%
% Disclaimer: draws heavily from a dotplot function that I downloaded in 
% June, 2013. Don't know the author; point is, not all of the code in here
% is strictly mine originally.
%
% dotplot(X,fig_marker,Ys) produces a dotplot of data in matrix X in a new 
% figure. X needs to be n x 2, with one column containing firing rate, and
% one column containing the location of bursts. Fig_marker determines 
% whether or not a new figure is created. Uses default plotting parameters
% (see below)
% dotplot(X, fig_marker, plotting_parameters) produces a dotplot of data in
% matrix X in a new figure. X needs to be n x 2, with one column containing
% firing rate, and one column containing the location of bursts. Fig_marker
% determines whether or not a new figure is created. Plots with specified
% parameters as follows:
%
%
% The data points in X are drawn as small boxes, according to the following
% rules:
%   -Each box must be centered at its true x-value (no binning).
%   -The boxes are plotted in sequence from the minimum x-value to the max.
%   -Boxes are plotted in the spot that overlaps the least with any
%       previous boxes.


green_max = plotting_parameters(1);
red_min = plotting_parameters(2);
w = plotting_parameters(3);
len = plotting_parameters(4);
depth = plotting_parameters(5);
box_scale = plotting_parameters(6);
turn = plotting_parameters(7);
boxwidth = w*box_scale;

n = size(X,1);                          %-Sort the data, etc.
FRs = X(:,1);
X = sort(X(:,2))*len;

order = randperm(depth);                %-Generate random ordering of rows
%TODO: check that order is balanced; if not, try again until balanced. 
rightEndpoint = zeros(depth);           %-Initialize array storing right endpoint in each row

Y = ones(n,1);                          %-Initialize y-levels for all boxes.
VX = zeros(4,n);                        %-Matrix VX holds x-coords of vertices.
VY = zeros(4,n);                        % Matrix VY holds y-coords of vertices.
                                        % Each VX/VY column pair defines the
                                        % vertices of one box.


                                        %-Figure out the y-levels for boxes 1
 for i = 1:n                            % through n.
                                        
    leftmostEndpoint = len;             %-Find row with leftmost rightmost
    bestRow = 0;                        %-box that is earliest in the
    for j = 1:depth                     %-random order.
        if rightEndpoint(order(j)) < leftmostEndpoint
            leftmostEndpoint = rightEndpoint(order(j));
            bestRow = order(j);
        end
    end
    
    Y(i) = w*(bestRow-1/2);             %Y-location of box. Update the right endpoint
    rightEndpoint(bestRow) = X(i);
    
    VX(:,i) = [X(i)-boxwidth X(i)+boxwidth X(i)+boxwidth X(i)-boxwidth]';
    VY(:,i) = [Y(i)-boxwidth Y(i)-boxwidth Y(i)+boxwidth Y(i)+boxwidth]';
end


if fig_marker                           %-Create the figure if necessary, then
    figure;                             % plot all of the boxes.
end
hold all;
patch([0 0 len len], [0 w*depth w*depth 0], [0 .5 1]);
for i = 1:n
    patch_color_scale = (FRs(i) - green_max)/(red_min - green_max);
    patch_color_scale = max(min(patch_color_scale,1),0);
    patch_color = [1, 1-patch_color_scale, 0];
    patch(VX(:,i), VY(:,i), patch_color, 'EdgeColor', 'none')
end
line([0 0], [0 w*depth], 'LineWidth', 2, 'Color', 'Black')
line([turn*len turn*len], [0 w*depth], 'LineWidth', 2, 'Color', 'Black')
line([len len], [0 w*depth], 'LineWidth', 2, 'Color', 'Black')
xlim([0-.1 len+.1]);
ylim([0 w*depth]);
                                        %-Change plot attrib (if plot into new axis).
set(gca,'YTick',[], ...
        'YColor','w', ...
        'XTick', [0 turn*len len], ...
        'XTickLabel',{'Click', 'Turn', 'Lick'}, ...
        'DataAspectRatio',[1 1 1], ...
        'TickDir','out')

