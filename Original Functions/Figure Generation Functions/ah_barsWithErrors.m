function ah_barsWithErrors(means, stds, labels, colors, fig_marker)

numGroups = size(means,1);
numItems = size(means,2);
halfBarWidth = .3/numItems;
barCenters = -.3+halfBarWidth:2*halfBarWidth:.3-halfBarWidth;
stdXvals = [-.66*halfBarWidth, -.66*halfBarWidth, .66*halfBarWidth, .66*halfBarWidth, .01, .01, ...
    .66*halfBarWidth, .66*halfBarWidth, -.66*halfBarWidth, -.66*halfBarWidth, -.01, -.01];

if fig_marker
    figure; 
end
hold all;

for group_idx = 1:numGroups
    for item_idx = 1:numItems
        M = means(group_idx,item_idx);
        S = stds(group_idx,item_idx);
        stdYvals = [M-S+.01, M-S-.01, M-S-.01, M-S+.01, M-S+.01, M+S-.01, ...
            M+S-.01, M+S+.01, M+S+.01, M+S-.01, M+S-.01, M-S+.01];
        patch(group_idx+barCenters(item_idx)+halfBarWidth*[-1 -1 1 1], [0 M M 0], colors{item_idx})
        patch(group_idx+barCenters(item_idx)+stdXvals, stdYvals, [0 0 0])
    end
end

set(gca, 'XTick', [1:numGroups])
set(gca, 'XTickLabel', labels)

end

