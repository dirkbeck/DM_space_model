clear; close all
rng('default')

n_features = 2;
n_pcs = 2;
n_obs = 100;
noise_coef = 0.1;
dim_prob = .2; % how many dimensions in space, on average?

% create some random data
X = randn(n_obs,n_features);

% create some simulated data

% hidden rules map X to SPN activity. These are PCs in the space model,
% similar to Beta in a linear regression
pcs = randn(n_features,n_pcs);
spaces = rand(n_obs,n_pcs)>dim_prob; 
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