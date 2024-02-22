%% colormap for the different actions

function cmap = actioncmap()

% same as in decision_making_boundaries.m
cmap = [1 1 1; % white (no action)
    0.4660 0.6740 0.1880; % green (approach)
    0.6350 0.0780 0.1840; % red (avoid)
    0.9290 0.6940 0.1250; % orange (other action)
    0.4940, 0.1840, 0.5560]; % purple; (other action)

end