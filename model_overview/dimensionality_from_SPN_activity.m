clear; close all
rng('default')
addpath(fileparts(pwd))

%% first, link striosome activity to possible spaces

n_features = 2;
n_pcs = 2;
n_obs = 100;
noise_coef = 0.5;
dim_prob = .5; % how many dimensions in space, on average?

% create some random data
X = randn(n_obs,n_features);

% create some simulated data

% hidden rules map X to SPN activity. These are PCs in the space model,
% similar to Beta in a linear regression
pcs = randn(n_features,n_pcs);
spaces = rand(n_obs,n_pcs)>(1-dim_prob);
ground_truth_y = sum(X*pcs.*spaces,2);
y = ground_truth_y+noise_coef*randn(n_obs,1); % SPN activity
[unique_spaces,~,space_labels] = unique(spaces,'rows'); % labels indicate different spaces

[x1,x2]=ndgrid(-2:1:2,-2:1:2);
titles = ["non-D (slope\cong0)","1st dim. in space\newlinebut not " + ...
    "2nd dim.","2nd dim. in space\newlinebut not 1st dim.",...
    "2D space\newline(slope = 1st dim. slope + \newline2nd dim. slope)"];
cols = colororder;
mdls = {};
figure; t = tiledlayout(2,2);
for i=1:length(unique(space_labels))
    nexttile; hold on
    mdl = fitlm(X(space_labels==i,:),y(space_labels==i));
    mdls{i} = mdl;
    scatter3(X(space_labels==i,1),X(space_labels==i,2), ...
        y(space_labels==i),[],cols(i,:),'filled')
    Z = mdl.Coefficients{1,1} + mdl.Coefficients{2,1}*x1 + ...
        mdl.Coefficients{3,1}*x2;
    surf(x1,x2,Z,'FaceColor',cols(i,:));
    view(3)
    hold off
    xlabel("feature 1 (e.g. temperature)")
    ylabel("feature 2 (e.g. music volume)")
    zlim([-5 5])
    title(titles(i))
end
zlabel("sSPN activity")
legend("simulated observation","linear regression fit")
set(gcf,'Renderer','painters')

figure; hold on
for i=1:length(unique(space_labels))
    scatter3(X(space_labels==i,1),X(space_labels==i,2), ...
            y(space_labels==i),[],cols(i,:),'filled')
end
hold off
xlabel("feature 1 (e.g. temperature)")
ylabel("feature 2 (e.g. music volume)")
zlabel("sSPN activity")
zlim([-5 5])
legend(["DM cluster 1","DM cluster 2","DM cluster 3","DM cluster 4"])
view(3)
set(gcf,'Renderer','painters')

%% next, link spaces to choice

w_1_estimate = [mdls{2}.Coefficients{2,1},mdls{2}.Coefficients{3,1}];
w_2_estimate = [mdls{3}.Coefficients{2,1},mdls{3}.Coefficients{3,1}];
w_estimate = [w_1_estimate' w_2_estimate'];
X_ = X*w_estimate;

actions = zeros(n_obs,1);
actions(space_labels==1) = randi(2,sum(space_labels==1),1);
actions(space_labels==2) = round(1./(1+exp(-ground_truth_y(space_labels==2)+randn)))+1;
actions(space_labels==3) = round(1./(1+exp(-ground_truth_y(space_labels==3)+randn)))+1;
actions(space_labels==4) = round(1./(1+exp(-ground_truth_y(space_labels==4)+randn)))+1;

titles = (["non-D","2nd dim. in space","1st dim. in space","2D space"]);

for i=1:4 % space labels

    action_values = zeros([5,5,2]);

    optionsxy = linspace(min(X_(space_labels==i,:),[],'all'),...
        max(X_(space_labels==i,:),[],'all'),5);
    [optionsx, optionsy] = meshgrid(optionsxy,optionsxy);
    
    if sum(space_labels==i) > 0
        mdl_i = mnrfit(X_(space_labels==i,:),...
            double(actions(space_labels==i)));
        for j = 1:5 % 5 incs in the plotted grid
            for k = 1:5 % 5 incs in the plotted grid
                action_values(j,k,1) = 1/(1+exp(-(...
                        mdl_i(1) + ...
                        mdl_i(2) * optionsx(j,k) + ...
                        mdl_i(3) * optionsy(j,k))));
                action_values(j,k,2) = 1 - action_values(j,k,1);
            end
        end
    end
    
    cmap = actioncmap();
    symbols = ["x","d","o","*","v"];
    figure; hold on
    decision_making_map_plot(cmap,action_values,optionsxy,titles(i))
    xlabel("dim. 1")
    ylabel("dim. 2")
    for j = 1:2
        scatter(X_(space_labels==i & actions==j,2),...
            X_(space_labels==i & actions==j,1),200,...
            'k',symbols(j),'LineWidth',3);
    end
    hold off

end

