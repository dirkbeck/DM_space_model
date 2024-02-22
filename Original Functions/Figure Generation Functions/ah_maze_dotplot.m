function ah_maze_dotplot(X,fig_marker,plotting_parameters)
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
% dotplot(X, fig_marker, plotting_parameters) plots with specified
% parameters: 
%
%
% The data points in X are drawn as small boxes, according to the following
% rules:
%   -Each box must be centered at its true x-value (no binning).
%   -The boxes are plotted in sequence from the minimum x-value to the max.
%   -No two boxes may overlap.
%   -If a box overlaps one that has already been plotted, then the box is 
%    shifted up by one box-height at a time until there is no overlap.

if nargin==2 %if plotting parameters not specified, set to defaults
    red_min = 100;
    green_max = 20;
    w = .02;
    len = 3;
    turn = .3;
else
    green_max = plotting_parameters(1);
    red_min = plotting_parameters(2);
    w = plotting_parameters(3);
    len = plotting_parameters(4);
    turn = plotting_parameters(5);
end

n = length(X);                          %-Sort the data, etc.
FRs = X(:,1);
X = sort(X(:,2))*len;
minX = X(1);
maxX = X(n);


Y = ones(n,1);                          %-Initialize y-levels for all boxes.
VX = zeros(4,n);                        %-Matrix VX holds x-coords of vertices.
VY = zeros(4,n);                        % Matrix VY holds y-coords of vertices.
                                        % Each VX/VY column pair defines the
                                        % vertices of one box.

                                        %-Set up the vertices of the box for
                                        % the first point.
VX(:,1) = [X(1)-w X(1)+w X(1)+w X(1)-w]';
VY(:,1) = [Y(1)-w Y(1)-w Y(1)+w Y(1)+w]';

                                        %-Figure out the y-levels for boxes 2
 for i = 2:n                            % through n.

                                        %-Check to see if left edge of dot i 
                                        % overlaps right edge of a previous dot 
                                        % on the same y-level.
    comparators = Y(1:i-1)==Y(i);
    if sum(comparators)>0 && X(i)-w < max(X(comparators)+w)
        overlaps = true;
    else
        overlaps = false;
    end
    
    while overlaps == true              %-While overlap still exists, shift up.
        Y(i) = Y(i)+1;
        comparators = Y(1:i-1)==Y(i);   %-Check for remaining overlaps
        if sum(comparators)>0 && X(i)-w < max(X(comparators)+w)
            overlaps = true;
        else
            overlaps = false;
        end
    end
end

maxY = max(Y);
numDivisions = maxY*floor(1/(2*w*maxY));
numPerDivision = numDivisions/maxY;
for i = 1:maxY
    p = (randperm(numDivisions)-1/2)/numDivisions;
    Ys = reshape(p,maxY,numPerDivision);
end

%TODO: conversion of (X,Y,width) to splotch on maze?
boxwidth = 1.5*w;
for i = 1:n
    r = randi([1, numPerDivision]);
    Y(i) = Ys(Y(i),r);
   
    VX(:,i) = [X(i)-boxwidth X(i)+boxwidth X(i)+boxwidth X(i)-boxwidth]';
    VY(:,i) = [Y(i)-boxwidth Y(i)-boxwidth Y(i)+boxwidth Y(i)+boxwidth]';
end


if fig_marker                           %-Create the figure if necessary, then
    figure;                             % plot all of the boxes.
end
hold all;
patch([0 0 len len], [0 1 1 0], [0 .5 1]);
for i = 1:n
    patch_color_scale = (FRs(i) - green_max)/(red_min - green_max);
    patch_color_scale = max(min(patch_color_scale,1),0);
    patch_color = [1, 1-patch_color_scale, 0];
    patch(VX(:,i), VY(:,i), patch_color, 'EdgeColor', 'none')
end
line([0 0], [0 1], 'LineWidth', 2, 'Color', 'Black')
line([turn*len turn*len], [0 1], 'LineWidth', 2, 'Color', 'Black')
line([len len], [0 1], 'LineWidth', 2, 'Color', 'Black')
xlim([0-.1 len+.1]);
ylim([0 1]);
                                        %-Change plot attrib (if plot into new axis).
set(gca,'YTick',[], ...
        'YColor','w', ...
        'XTick', [0 turn*len len], ...
        'XTickLabel',{'Click', 'Turn', 'Lick'}, ...
        'DataAspectRatio',[1 1 1], ...
        'TickDir','out')

