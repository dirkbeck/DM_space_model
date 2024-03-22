clear; close all
rng('default')
addpath(fileparts(pwd))

%% first, link striosome activity to possible spaces

n_features = 2;
n_pcs = 2;
n_obs = 100;
noise_coef = 0.1;
dim_prob = .8; % how many dimensions in space, on average?

% create some random data
X = randn(n_obs,n_features);

% create some simulated data

% hidden rules map X to SPN activity. These are PCs in the space model,
% similar to Beta in a linear regression
pcs = randn(n_features,n_pcs);
spaces = rand(n_obs,n_pcs)>(1-dim_prob); 
y = sum(X*pcs.*spaces,2)+noise_coef*randn(n_obs,1); % SPN activity
[unique_spaces,~,space_labels] = unique(spaces,'rows'); % labels indicate different spaces

[x1,x2]=ndgrid(-2:1:2,-2:1:2);
titles = ["non-D (slope\cong0)","1st dim. in space\newlinebut not " + ...
    "2nd dim.","2nd dim. in space\newlinebut not 1st dim.",...
    "2D space\newline(slope = 1st dim. slope + \newline2nd dim. slope)"];
cols = colororder;
figure; t = tiledlayout(2,2);
for i=1:length(unique(space_labels))
    nexttile; hold on
    mdl = fitlm(X(space_labels==i,:),y(space_labels==i));
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


optionsxy = linspace(0,1,5);
[optionsx, optionsy] = meshgrid(optionsxy,optionsxy);
actions_0D = randi(3,5)-1;
actions_1stdim = [2 2 2 2 0; 2 2 0 2 2; 0 0 0 0 0; 1 0 1 0 1; 1 1 0 1 1];
actions_2nddim = [2 0 0 0 1; 2 0 0 1 1; 2 2 0 0 1; 2 0 0 0 1; 2 0 0 1 1];
actions_2D = [0 2 2 2 2; 1 0 2 2 2; 1 0 0 0 2; 1 1 1 0 0; 1 1 1 1 1];

actions_list = {actions_0D,actions_1stdim,actions_2nddim,actions_2D};
titles = (["non-D","1st dim. in space","2nd dim. in space","2D space"]);

for act=1:length(actions_list)

    actions = actions_list{act};

    optionsx_vec = optionsx(:); optionsy_vec = optionsy(:); ...
        actions_vec = actions(:);
    
    unique_actions = unique(actions);
    unique_actions = unique_actions(unique_actions~=0); % remove "no action"
    n_actions = length(unique_actions);
    action_values = zeros([size(actions),n_actions]);
    for i = 1:n_actions
        action_i = unique_actions(i);
        mdl_i = mnrfit([optionsx_vec,optionsy_vec],...
            1-double(actions_vec==action_i)+1);
        for j = 1:size(actions,1)
            for k = 1:size(actions,2)
                action_values(j,k,i) = 1/(1+exp(-(...
                    mdl_i(1) + ...
                    mdl_i(2) * optionsx(j,k) + ...
                    mdl_i(3) * optionsy(j,k))));
            end
        end
    end
    action_values = action_values/2; % divided by 2 so that max sum is 1
    
    cmap = actioncmap();
    symbols = ["x","d","o","*","v"];
    figure; hold on
    decision_making_map_plot(cmap,action_values,optionsxy,titles(act))
    xlabel("dim. 1")
    ylabel("dim. 2")
    for i = 1:n_actions
        scatter(optionsy(actions_vec==unique_actions(i)),...
            optionsx(actions_vec==unique_actions(i)),200,...
            cmap(i+1,:),symbols(i),'LineWidth',3);
    end
    % add decision boundary for the 1D+ cases
    if act>1
        for i=1:size(action_values,3)
            for j=1:size(action_values,3)
                if i > j
                    contour(optionsxy,optionsxy,squeeze(action_values(:,:,i))'-...
                        squeeze(action_values(:,:,j))',[0 0],'k','LineWidth',5)
                end
            end
        end
    end
    hold off

end

