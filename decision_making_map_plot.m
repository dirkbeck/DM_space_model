function [] = decision_making_map_plot(cmap,values,incsxy,ttle)
% plots 2D psychometric function color maps

    if iscell(incsxy)
        incsx = incsxy{1};
        incsy = incsxy{2};
    else
        incsx = incsxy;
        incsy = incsxy;
    end
    
    % parameters
    decision_making_grid_size = size(values,2);

    hold on
    for xi=1:decision_making_grid_size-1
        for yi=1:decision_making_grid_size-1
            value_ = squeeze(values(xi,yi,:));
            value = [1-sum(value_); value_];
            color = sum(value .* cmap(1:size(values,3)+1,:),1);
            fill([incsx(xi) incsx(xi) incsx(xi+1) incsx(xi+1)],...
                 [incsy(yi) incsy(yi+1), incsy(yi+1), incsy(yi)], ...
                 color, 'LineStyle','none');
        end
    end
    
    xlabel('vreward')
    ylabel('cost')
    xticks('')
    yticks('')
    set(gcf,'renderer','Painters')
    axis square

    title(ttle)

end