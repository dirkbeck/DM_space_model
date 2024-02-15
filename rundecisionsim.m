function [probs] = rundecisionsim(state, input, x_axis, y_axis, B)

% Which actions are taken at a given state with a given input?

% x_axis, y_axis: how do the inputs translate to the first two PCs?
% B: matrix rules

% turn the input reward and cost combination into PCs
proj = [input(1) input(2)]*[x_axis; y_axis];
% remove the rules not included in the state
B_state = B.*[1 state]';
% calculate probability assigned to each action
logodds = B(1,:) + proj*B_state(2:end,:);
ratios = [exp(logodds) 1]; % all ratios are compared to "no action" 1
probs = ratios(1:end-1)/sum(ratios);

end