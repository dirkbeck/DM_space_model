function [riskiness,safety,high_action,low_action,exploit,explore] = ...
    calculate_decision_making_ingredient_values(action_values,...
    decision_making_grid_size)

% what are the values for 6 different "decision making ingredient" axes of
% behavior?

% 1. riskiness. What is valued more when there is high cost, high reward:
% approach or avoid? Higher approach is considered more risk.
riskiness_grid = action_values(round(decision_making_grid_size/2)+1:end, ...
    round(decision_making_grid_size/2)+1:end, :);
riskiness = sum(riskiness_grid(:,:,1) - riskiness_grid(:,:,2),'all') / ...
     (decision_making_grid_size/2)^2;

% 2. safety. Similarly, what is valued more when there is low cost, low 
% reward? Higher avoid is considered more safe.
safety_grid = action_values(1:round(decision_making_grid_size/2), ...
    1:round(decision_making_grid_size/2), :);
safety = sum(safety_grid(:,:,2) - safety_grid(:,:,1),'all') / ...
     (decision_making_grid_size/2)^2;

% 3. High action. What proportion of the grid has >.5 action?
high_action = sum(sum(action_values,3)>.5,'all') / ...
    decision_making_grid_size^2;

% 4. Low action. What proportion of the grid has <.1 action?
low_action = sum(sum(action_values,3)<.2,'all') / ...
    decision_making_grid_size^2;

% 5. Exploit. What proportion of the grid has >.5 gini coefs?
gini_coefs = zeros(decision_making_grid_size);
for i=1:decision_making_grid_size
    for j=1:decision_making_grid_size
        action_values_ij = squeeze(action_values(i,j,:));
        gini_coefs(i,j) = sum(abs(action_values_ij-action_values_ij'),"all")/...
            (2*4^2*mean(action_values_ij));
    end
end
exploit = sum(gini_coefs>.5,'all') /decision_making_grid_size^2;

% 6. Explore. What proportion of the grid has <.25 gini coefs?
explore = sum(gini_coefs<.25,'all') /decision_making_grid_size^2;


end