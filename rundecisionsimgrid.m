function action_values = ...
    rundecisionsimgrid(state,n_actions,x_axis,y_axis,B,incsxy)

% forms a grid_size by grid_size matrix that can be used in a
% decision-making map or psychometric functions

if iscell(incsxy)
    incsx = incsxy{1};
    incsy = incsxy{2};
else
    incsx = incsxy;
    incsy = incsxy;
end
decision_making_grid_size = length(incsx);

action_values = zeros(decision_making_grid_size,decision_making_grid_size,n_actions);
for xi=1:decision_making_grid_size
    for yi=1:decision_making_grid_size
        input = [incsx(xi) incsy(yi)];
        action_values(xi,yi,:) = rundecisionsim(state,input,x_axis,y_axis,B);
    end
end


end