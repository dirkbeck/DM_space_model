function ah_plot_split_maze(right_plotting_bins, left_plotting_bins, fig_marker, figure_params)
%AH_PLOT_SPLIT_MAZE takes in three sets of plotting bins and 11 paramters
%relevant to the figure being created and plots a maze figure with the
%middle split. Inputs are:
% MIDDLE_PLOTTING_BINS - bins that get plotted in the middle (stem) of the
%   T-maze.
% RIGHT_PLOTTING_BINS - bins that get plotted on the right wing of the maze
% LEFT_PLOTTING_BINS - bins that get plotting on the left wing of the maze
% FIGURE_PARAMS - 11 parameters required to plot the maze; 9 are relevant
%   to the figure itself, and 2 rely on the binning function (it will be
%   misleading if those two are not consistent):
%   - extended_height - the height of the stem of the extended figure
%   - maze_height - the height of the stem of the actual T-maze
%   - maze_width - the width of the maze
%   - maze_length - the length of the arms of the actual T-maze
%   - extended_length - the length of the arms of the extended figure
%   - exp_param - the parameter that decides the exponent of the scaling of
%       colors
%   - coloring_type - marker that tells us whther our coloring
%       are percentile based or absolute (1 means absolute, 0 percentile)
%   - low_color - the percentile of the value that we set as the lowest
%       color
%   - high_color - the percentile of the value that we set as the highest
%       color
%   - firstAlignEventLoc - this needs to be consistent with the binning
%       function or the figure will mislead. Location on 0 to 1 scale of
%       first alignment event
%   - secondAlignEventLoc - this needs to be consistent with the binning
%       function or the figure will mislead. Location on 0 to 1 scale of
%       second alignment event
%   If not specified, intialized to: 
%   [43, 22, 8, 33, 54, 1.5, 0, .3, .9, .3, .6]
if ~exist('figure_params', 'var')
    figure_params = [43, 22, 8, 33, 54, 1.5, 0, .3, .9, .3, .6];
end

%% Setup
if fig_marker
    figure;                         %generate figure
end
hold all;                           %hold all graphics objects onto figure

extended_height = figure_params(1);         %height of the stem of the extended figure
maze_height = figure_params(2);             %height of the stem of the actual T-maze
maze_width = figure_params(3);              %width of the maze
maze_arm_length = figure_params(4);             %length of the arms of the actual T-maze
extended_length = figure_params(5);         %length of the arms of the extended figure
exp_param = figure_params(6);               %parameter that decides the exponent of the scaling of colors
coloring_type = figure_params(7);           %marker of coloring type (absolute or percentile based)
low_color = figure_params(8);               %percentile of the value that we set as the lowest color
high_color = figure_params(9);              %percentile of the value that we set as the highest color
firstAlignEventLoc = figure_params(10);      %location on 0 to 1 scale of first alignment event
secondAlignEventLoc = figure_params(11);    %location on 0 to 1 scale of second alignment event
numBins = size(right_plotting_bins,1);      %number of bins

total_maze_length = maze_height + maze_width + maze_arm_length; %full length of actual T-maze

premaze_length = firstAlignEventLoc;                    %length, on 0 to 1 scale, of extended part before maze
postmaze_length = 1 - secondAlignEventLoc;              %length, on 0 to 1 scale, of extended part after maze
maze_length = secondAlignEventLoc - firstAlignEventLoc; %length, on 0 to 1 scale, of actual maze
maze_height_num = round(maze_length*numBins*maze_height/total_maze_length); %number of bins in stem of actual maze
maze_length_num = round(maze_length*numBins*maze_arm_length/total_maze_length); %number of bins in arms of actual maze
maze_middle_num = round(maze_length*numBins - maze_length_num - maze_height_num);  %number of bins in intersection of actual maze

if coloring_type
    lowColorValRight = low_color;
    lowColorValLeft = low_color;
    highColorValRight = high_color;
    highColorValLeft = high_color;
else
    idHighColor = round(numBins*high_color);    %index of the high color percentile
    idLowColor = round(numBins*low_color);      %index of the low color percentile
    tmp = sort(right_plotting_bins);            %temporary variable; sorted right bins
    lowColorValRight = tmp(idLowColor);         %low color value of right bins
    highColorValRight = tmp(idHighColor);       %high color value of right bins
    tmp = sort(left_plotting_bins);             %temporary variable; sorted left bins
    lowColorValLeft = tmp(idLowColor);          %low color value of left bins
    highColorValLeft = tmp(idHighColor);        %high color value of left bins
end

cmap = zeros(201,3);                        %setting up color array; row 1 is blue, row 201 is red, everything else is in between
cmap(101:151,1) = linspace(0,1,51);
cmap(151:201,1) = ones(51,1);
cmap(1:51,2) = linspace(0,1,51);
cmap(51:151,2) = ones(101,1);
cmap(151:201,2) = linspace(1,0,51);
cmap(1:51,3) = ones(51,1);
cmap(51:101,3) = linspace(1,0,51);
%% Stem bins
for i = 1:maze_height_num+premaze_length*numBins
    if i <= premaze_length*numBins
        rectangle_width = (extended_height-maze_height)/(premaze_length*numBins); %width of rectangle we're plotting
        tmp = max(min(right_plotting_bins(i),highColorValRight),lowColorValRight);   %temporary variable; shifting value if above max or below min
        rightColor = round(abs(((tmp-lowColorValRight)/(highColorValRight-lowColorValRight))^(exp_param))*200.999999999+.5); rightColor = max(rightColor,1); rightColor = min(rightColor,201);   %row of color appropriate for value
        tmp = max(min(left_plotting_bins(i),highColorValLeft),lowColorValLeft);    %temporary variable; shifting value if above max or below min
        leftColor = round(abs(((tmp-lowColorValLeft)/(highColorValLeft-lowColorValLeft))^(exp_param))*200.999999999+.5); leftColor = max(leftColor,1); leftColor = min(leftColor,201);        %row of color appropriate for value
        rectangle('Position', [maze_width*.25, (i-1)*rectangle_width, maze_width, rectangle_width], 'FaceColor', cmap(rightColor,:), 'EdgeColor', 'none') %draw bin
        rectangle('Position', [-maze_width*1.25, (i-1)*rectangle_width, maze_width, rectangle_width], 'FaceColor', cmap(leftColor,:), 'EdgeColor', 'none') %draw bin
    else
        rectangle_width = maze_height/maze_height_num;                      %width of rectangle we're plotting
        j = i - premaze_length*numBins + (extended_height-maze_height)/rectangle_width; %helper variable 
        tmp = max(min(right_plotting_bins(i),highColorValRight),lowColorValRight);   %temporary variable; shifting value if above max or below min
        rightColor = round(abs(((tmp-lowColorValRight)/(highColorValRight-lowColorValRight))^(exp_param))*200.999999999+.5); rightColor = max(rightColor,1); rightColor = min(rightColor,201);   %row of color appropriate for value
        tmp = max(min(left_plotting_bins(i),highColorValLeft),lowColorValLeft);    %temporary variable; shifting value if above max or below min
        leftColor = round(abs(((tmp-lowColorValLeft)/(highColorValLeft-lowColorValLeft))^(exp_param))*200.999999999+.5); leftColor = max(leftColor,1); leftColor = min(leftColor,201);        %row of color appropriate for value
        rectangle('Position', [maze_width*.25,(j-1)*rectangle_width,maze_width,rectangle_width], 'FaceColor', cmap(rightColor,:), 'EdgeColor','none') %draw bin
        rectangle('Position', [-maze_width*1.25,(j-1)*rectangle_width,maze_width,rectangle_width], 'FaceColor', cmap(leftColor,:), 'EdgeColor','none') %draw bin
    end
end
%% Arm bins
for i = 1:maze_length_num+postmaze_length*numBins
    if i+maze_height_num+maze_middle_num <= maze_length*numBins
        rectangle_width = maze_arm_length/maze_length_num;                                  %width of rectangle we're plotting
        tmp = max(min(right_plotting_bins(i+maze_height_num+maze_middle_num+premaze_length*numBins),highColorValRight),lowColorValRight);   %temporary variable; shifting value if above max or below min
        rightColor = round(((tmp-lowColorValRight)/(highColorValRight-lowColorValRight))^(exp_param)*200.999999999+.5);                     %row of color appropriate for value
        rightColor = max(rightColor,1); rightColor = min(rightColor,201);
        if imag(rightColor)
            rightColor = 1;
        end
        tmp = max(min(left_plotting_bins(i+maze_height_num+maze_middle_num+premaze_length*numBins),highColorValLeft),lowColorValLeft);      %temporary variable; shifting value if above max or below min
        leftcolor = round(((tmp-lowColorValLeft)/(highColorValLeft-lowColorValLeft))^(exp_param)*200.999999999+.5);                         %row of color appropriate for value
        leftcolor = max(leftcolor,1); leftcolor = min(leftcolor,201);
        if imag(leftcolor)
            leftcolor = 1;
        end
        rectangle('Position', [maze_width*1.25+rectangle_width*(i-1), extended_height, rectangle_width, maze_width], 'FaceColor', cmap(rightColor,:), 'EdgeColor', 'none')     %draw bin
        rectangle('Position', [-maze_width*1.25-rectangle_width*i, extended_height, rectangle_width, maze_width], 'FaceColor', cmap(leftcolor,:), 'EdgeColor', 'none')         %draw bin
    else
        rectangle_width = (extended_length-maze_arm_length)/(postmaze_length*numBins);      %width of rectangle we're plotting
        tmp = max(min(right_plotting_bins(i+maze_height_num+maze_middle_num+premaze_length*numBins),highColorValRight),lowColorValRight);   %temporary variable; shifting value if above max or below min
        rightColor = round(((tmp-lowColorValRight)/(highColorValRight-lowColorValRight))^(exp_param)*200.999999999+.5);                     %row of color appropriate for value
        rightColor = max(rightColor,1); rightColor = min(rightColor,201);
        if imag(rightColor)
            rightColor = 1;
        end
        tmp = max(min(left_plotting_bins(i+maze_height_num+maze_middle_num+premaze_length*numBins),highColorValLeft),lowColorValLeft);      %temporary variable; shifting value if above max or below min
        leftcolor = round(((tmp-lowColorValLeft)/(highColorValLeft-lowColorValLeft))^(exp_param)*200.999999999+.5);                         %row of color appropriate for value
        leftcolor = max(leftcolor,1); leftcolor = min(leftcolor,201);
        if imag(leftcolor)
            leftcolor = 1;
        end
        j = i - maze_length_num;
        rectangle('Position', [maze_width*1.25+maze_arm_length+rectangle_width*(j-1), extended_height, rectangle_width, maze_width], 'FaceColor', cmap(rightColor,:), 'EdgeColor', 'none') %draw bin
        rectangle('Position', [-maze_width*1.25-maze_arm_length-rectangle_width*j, extended_height, rectangle_width, maze_width], 'FaceColor', cmap(leftcolor,:), 'EdgeColor', 'none')     %draw bin
    end
end
%% Center Bins
theta = pi/(2*maze_middle_num)-.000000001;
for i = 1:maze_middle_num
    tmp = max(min(right_plotting_bins(i+maze_height_num+premaze_length*numBins),highColorValRight),lowColorValRight);   %temporary variable; shifting value if above max or below min
    rightColor = round(((tmp-lowColorValRight)/(highColorValRight-lowColorValRight))^(exp_param)*200.999999999+.5);     %row of color appropriate for value
    rightColor = max(rightColor,1); rightColor = min(rightColor,201);
    if imag(rightColor)
        rightColor = 1;
    end
    tmp = max(min(left_plotting_bins(i+maze_height_num+premaze_length*numBins),highColorValLeft),lowColorValLeft);      %temporary variable; shifting value if above max or below min
    leftcolor = round(((tmp-lowColorValLeft)/(highColorValLeft-lowColorValLeft))^(exp_param)*200.999999999+.5);         %row of color appropriate for value
    leftcolor = max(leftcolor,1); leftcolor = min(leftcolor,201);
    if imag(leftcolor)
        leftcolor = 1;
    end
    if i == 25
        1;
    end
    if tan(i*theta) < 1
        patch([maze_width*1.25; maze_width*.25; maze_width*.25], [extended_height; extended_height+tan(i*theta)*maze_width/2; extended_height+tan((i-1)*theta)*maze_width/2], cmap(rightColor,:), 'EdgeColor', 'none')   %draw bin
        patch([-maze_width*1.25; -maze_width*.25; -maze_width*.25], [extended_height; extended_height+tan(i*theta)*maze_width/2; extended_height+tan((i-1)*theta)*maze_width/2], cmap(leftcolor,:), 'EdgeColor', 'none')   %draw bin
    elseif tan((i-1)*theta) < 1
        patch([maze_width*1.25; maze_width*.25; maze_width*.25; maze_width*1.25-maze_width*cot(i*theta)], [extended_height; extended_height+tan((i-1)*theta)*maze_width/2; extended_height+maze_width; extended_height+maze_width], cmap(rightColor,:), 'EdgeColor', 'none')    %draw bin
        patch([-maze_width*1.25; -maze_width*.25; -maze_width*.25; -maze_width*1.25+maze_width*cot(i*theta)], [extended_height; extended_height+tan((i-1)*theta)*maze_width/2; extended_height+maze_width; extended_height+maze_width], cmap(leftcolor,:), 'EdgeColor', 'none')   %draw bin
    else
        patch([maze_width*1.25; maze_width*1.25-maze_width*cot(i*theta); maze_width*1.25-maze_width*cot((i-1)*theta)], [extended_height; extended_height+maze_width; extended_height+maze_width], cmap(rightColor,:), 'EdgeColor', 'none')   %draw bin
        patch([-maze_width*1.25; -maze_width*1.25+maze_width*cot(i*theta); -maze_width*1.25+maze_width*cot((i-1)*theta)], [extended_height; extended_height+maze_width; extended_height+maze_width], cmap(leftcolor,:), 'EdgeColor', 'none') %draw bin
    end
end
%% Legend
cmap_base = 0;
cmap_top = extended_height - maze_width;
cmap_left = extended_length + maze_width/4;
cmap_right = extended_length + maze_width*5/4;
cmap_rect_height = (cmap_top - cmap_base)/201;
for color_idx = 1:201
    patch([cmap_left cmap_right cmap_right cmap_left], cmap_base + cmap_rect_height*[color_idx-1 color_idx-1 color_idx color_idx], cmap(color_idx,:),'EdgeColor','none')
end
line([cmap_left cmap_left], [cmap_base cmap_top], 'LineWidth', 1, 'Color', 'Black')
line([cmap_left cmap_right], [cmap_top cmap_top], 'LineWidth', 1, 'Color', 'Black')
line([cmap_right cmap_right], [cmap_top cmap_base], 'LineWidth', 1, 'Color', 'Black')
line([cmap_right cmap_left], [cmap_base cmap_base], 'LineWidth', 1, 'Color', 'Black')
if coloring_type && exp_param == 1
    text(cmap_left-.1*maze_width,cmap_base,num2str(low_color),'HorizontalAlignment','right', 'VerticalAlignment','bottom')
    text(cmap_left-.1*maze_width,.5*(cmap_base+cmap_top),num2str(.5*(high_color + low_color)),'HorizontalAlignment','right')
    text(cmap_left-.1*maze_width,cmap_top,num2str(high_color),'HorizontalAlignment','right','VerticalAlignment','top')
end
%% Maze Outline
line([-maze_width*1.25 -maze_width*.25], [0 0], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', ':')
line([-maze_width*1.25 -maze_width*1.25], [0 extended_height-maze_height], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', ':')
line([-maze_width*.25 -maze_width*.25], [0 extended_height-maze_height], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', ':')
line([-maze_width*1.25 -maze_width*.25], [extended_height-maze_height extended_height-maze_height], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', '-')
line([-maze_width*1.25 -maze_width*1.25], [extended_height-maze_height extended_height], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', '-')
line([-maze_width*.25 -maze_width*.25], [extended_height-maze_height extended_height+maze_width], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', '-')
line([-maze_width*1.25 -maze_width*1.25-maze_arm_length], [extended_height extended_height], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', '-')
line([-maze_width*.25 -maze_width*1.25-maze_arm_length], [extended_height+maze_width extended_height+maze_width], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', '-')
line([-maze_width*1.25-maze_arm_length -maze_width*1.25-maze_arm_length], [extended_height extended_height+maze_width], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', '-')
line([-maze_width*1.25-maze_arm_length -maze_width*1.25-extended_length], [extended_height extended_height], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', ':')
line([-maze_width*1.25-maze_arm_length -maze_width*1.25-extended_length], [extended_height+maze_width extended_height+maze_width], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', ':')
line([-maze_width*1.25-extended_length -maze_width*1.25-extended_length], [extended_height extended_height+maze_width], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', ':')

line([maze_width*1.25 maze_width*.25], [0 0], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', ':')
line([maze_width*1.25 maze_width*1.25], [0 extended_height-maze_height], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', ':')
line([maze_width*.25 maze_width*.25], [0 extended_height-maze_height], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', ':')
line([maze_width*1.25 maze_width*.25], [extended_height-maze_height extended_height-maze_height], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', '-')
line([maze_width*1.25 maze_width*1.25], [extended_height-maze_height extended_height], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', '-')
line([maze_width*.25 maze_width*.25], [extended_height-maze_height extended_height+maze_width], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', '-')
line([maze_width*1.25 maze_width*1.25+maze_arm_length], [extended_height extended_height], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', '-')
line([maze_width*.25 maze_width*1.25+maze_arm_length], [extended_height+maze_width extended_height+maze_width], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', '-')
line([maze_width*1.25+maze_arm_length maze_width*1.25+maze_arm_length], [extended_height extended_height+maze_width], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', '-')
line([maze_width*1.25+maze_arm_length maze_width*1.25+extended_length], [extended_height extended_height], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', ':')
line([maze_width*1.25+maze_arm_length maze_width*1.25+extended_length], [extended_height+maze_width extended_height+maze_width], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', ':')
line([maze_width*1.25+extended_length maze_width*1.25+extended_length], [extended_height extended_height+maze_width], 'LineWidth', 3, 'Color', 'Black', 'LineStyle', ':')

xlim([-extended_length-2*maze_width, extended_length+2*maze_width])
ylim([-maze_width, extended_height+2*maze_width])
axis equal;
end