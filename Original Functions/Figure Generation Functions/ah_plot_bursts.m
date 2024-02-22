function ah_plot_bursts(selectedBursts, plotting_parameters)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function plots the selected bursts in a box.
% - plotting_parameters has 11 parameters
%   - The 1st one is the minimum value in color scale
%   - The 2nd one is the maximum value in color scale
%   - The 3rd one is the width of the plot box
%   - The 4th one is the length of the plot box
%   - The 5th one is the number of rows in the plot
%   - The 6th one is the size of each dot
%   - The 7th one is the start time of the range we want to plot
%   - The 8th one is the end time of the range we want to plot
%   - The 9th one is the turn time
%   - The 10th one is the start time of short baseline we want to show
%   - The 11th one is the end time of short baseline we want to show
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

green_max = plotting_parameters(1);
red_min = plotting_parameters(2);
w = plotting_parameters(3);
len = plotting_parameters(4);
depth = plotting_parameters(5);
box_scale = plotting_parameters(6);
startTime = plotting_parameters(7);
endTime = plotting_parameters(8);
turnTime = plotting_parameters(9);
startBaseline = plotting_parameters(10);
endBaseline = plotting_parameters(11);
click = (-startTime)/(endTime-startTime);
turn = (turnTime-startTime)/(endTime-startTime);
lick = (1-startTime)/(endTime-startTime);
left = (startBaseline-startTime)/(endTime-startTime);
right = (endBaseline-startTime)/(endTime-startTime);
boxwidth = w*box_scale;

for i=1:length(selectedBursts)
    if selectedBursts(i,3) < depth
        x = len*(selectedBursts(i,2)-startTime)/(endTime-startTime);
        y = w*selectedBursts(i,3);
        long = selectedBursts(i,4)/2;
        VX(:,i) = [x-boxwidth*long x+boxwidth*long x+boxwidth*long x-boxwidth*long]';
        VY(:,i) = [y-boxwidth y-boxwidth y+boxwidth y+boxwidth]';
    end
end

figure;
hold all;
patch([0 0 len len], [0 w*depth w*depth 0], [0 .5 1]);
for i=1:length(selectedBursts)
    if selectedBursts(i,3) < depth
        patch_color_scale = (selectedBursts(i,1)-green_max)/(red_min-green_max);
        patch_color_scale = max(min(patch_color_scale,1),0);
        patch_color = [1, 1-patch_color_scale, 0];
        patch(VX(:,i), VY(:,i), patch_color, 'EdgeColor', 'none')
    end
end
line([0 0], [0 w*depth], 'LineWidth', 2, 'Color', 'Black')
line([click*len click*len], [0 w*depth], 'LineWidth', 2, 'Color', 'Black')
line([turn*len turn*len], [0 w*depth], 'LineWidth', 2, 'Color', 'Black')
line([lick*len lick*len], [0 w*depth], 'LineWidth', 2, 'Color', 'Black')
line([len len], [0 w*depth], 'LineWidth', 2, 'Color', 'Black')
patch([0 left*len left*len 0], [0 0 w*depth w*depth], 'k', 'EdgeColor', 'none')
patch([right*len click*len click*len right*len], [0 0 w*depth w*depth], 'k', 'EdgeColor', 'none')

xlim([0-.1 len+.1]);
ylim([0 w*depth]);
set(gca,'YTick',[], ...
    'YColor','w', ...
    'XTick', [click*len turn*len lick*len], ...
    'XTickLabel',{'Click', 'Turn', 'Lick'}, ...
    'DataAspectRatio',[1 1 1], ...
    'TickDir','out')