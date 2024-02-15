clear; close all
rng('default')
addpath(fileparts(pwd))

%% dimensions of striosome D1, striosome D2, DA

% cortex -> strio D1 encode pro-action dimensions to include in space
% cortex -> strio D2 encode anti-action dimensions to include in space

n_ctx = 50;
n_neurons_per_dimension = 10000;
n_ctx_SPN_connections = 4;
n_dims = min(4,n_ctx_SPN_connections);
ctx_ews = [2 2 .5 .2 zeros(1,n_ctx-4)];
Sigma = sprandsym(n_ctx,1,ctx_ews); % randomly create a covariance matrix
[evs,~] = eigs(Sigma);

% signal from cortex; set to occur along PC dimensinos
ctxs = {evs(:,1)', randn(1,n_ctx)};

% matches above, for plotting
ctx_titles = ["Reward signal", "Noise signal"]; 
dimensions_in_space = {[1 0 0 0],[0 0 0 0]};
dimensions_not_in_space = {[0 1 1 1],[1 1 1 1]};

[W_ctx_dSPN,W_ctx_iSPN,W_FSI_dSPN,W_FSI_iSPN] = ...
    deal(zeros(n_ctx,n_dims,n_neurons_per_dimension));
for i=1:n_neurons_per_dimension % SPNs in each dimension
    % a few cortex neurons are connected to this SPN
    connected_ctx_dSPN_neurons = randsample(n_ctx,n_ctx_SPN_connections);
    connected_ctx_iSPN_neurons = randsample(n_ctx,n_ctx_SPN_connections);
    % find the connections from the cortex neurons to this SPN
    small_Sigma_dSPN = Sigma(connected_ctx_dSPN_neurons,connected_ctx_dSPN_neurons);
    small_Sigma_iSPN = Sigma(connected_ctx_iSPN_neurons,connected_ctx_iSPN_neurons);
    [evs_dSPN,~] = eigs(small_Sigma_dSPN);
    [evs_iSPN,~] = eigs(small_Sigma_iSPN);
    W_ctx_dSPN(connected_ctx_dSPN_neurons,:,i) = evs_dSPN;
    W_ctx_iSPN(connected_ctx_iSPN_neurons,:,i) = -evs_iSPN;
    W_FSI_dSPN(connected_ctx_dSPN_neurons,:,i) = ...
        ones(n_ctx_SPN_connections,n_dims);
    W_FSI_iSPN(connected_ctx_iSPN_neurons,:,i) = ...
        ones(n_ctx_SPN_connections,n_dims);
end


% calculate striatal neurons from cortex
[sdSPN,siSPN] = deal(cell(n_ctx,1));
for i=1:length(ctxs) % the different modeled tasks
    for j=1:n_dims % the dimensions
        sdSPN{i}(j,:) = ctxs{i} * squeeze(W_ctx_dSPN(:,j,:)) / ...
            norm(ctxs{i}*squeeze(W_FSI_dSPN(:,j,:)));
        siSPN{i}(j,:) = ctxs{i} * squeeze(W_ctx_iSPN(:,j,:)) / ...
            norm(ctxs{i}*squeeze(W_FSI_iSPN(:,j,:)));
    end
end


activity_min = min([cell2mat(sdSPN(:)), cell2mat(siSPN(:))],[],'all'); 
activity_max = max([cell2mat(sdSPN(:)), cell2mat(siSPN(:))],[],'all');

%% plots of the individual neurons for different types of noise

global_legend_txt = "red = dims used in direct pathway; " + ...
    "cyan = D2 dims used in indirect pathway, black = dimensions not used";

figure
t = tiledlayout(2, length(ctxs));
title(t,global_legend_txt);
for i=1:length(ctxs)

    dims_in_space_cols{i} = zeros(length(dimensions_in_space{i}),3);
    dims_not_in_space_cols{i} = zeros(length(dimensions_not_in_space{i}),3);
    dims_in_space_cols{i}(dimensions_in_space{i}==1,:) = ...
        repmat([1 0 0],sum(dimensions_in_space{i}==1),1);
    dims_not_in_space_cols{i}(dimensions_not_in_space{i}==1,:) = ...
        repmat([0 1 1],sum(dimensions_not_in_space{i}==1),1);
    
    nexttile(i); hold on
    boxplot(sdSPN{i}',"Colors",dims_in_space_cols{i},'Boxstyle','filled','Outliersize',1,'Symbol','.')
    hold off
    title([ctx_titles(i)," dSPN"]);
    xlabel("dimension")
    ylabel("sSPN activity (arb. u.)")
    ylim([activity_min activity_max])

    nexttile(i+length(ctxs)); hold on
    boxplot(siSPN{i}',"Colors",dims_not_in_space_cols{i},'Boxstyle','filled','Outliersize',1,'Symbol','.')
    title([ctx_titles(i)," iSPN"]);
    xlabel("dimension")
    ylabel("sSPN activity (arb. u.)")
    ylim([activity_min activity_max])

end
set(gcf,'renderer','painters')

for i=1:length(ctxs)
    dsSPN_dat(i,:) = sum(sdSPN{i}');
    isSPN_dat(i,:) = sum(siSPN{i}');
end
activity_min = min([dsSPN_dat,isSPN_dat],[],'all');
activity_max = max([dsSPN_dat,isSPN_dat],[],'all');

figure
t = tiledlayout(2,length(ctxs));
for i=1:length(ctxs)
    nexttile(i);
    b = bar(sum(sdSPN{i}'));
    b.FaceColor = 'flat';
    b.CData = dims_in_space_cols{i};
    title([ctx_titles(i)," dSPN"])
    ylim([activity_min,activity_max])
    xticks(1:4)
    xlabel("dimension")
    ylabel("sum sSPN activity (arb. u.)")

    nexttile(i+length(ctxs));
    b = bar(sum(siSPN{i}'));
    b.FaceColor = 'flat';
    b.CData = dims_not_in_space_cols{i};
    title([ctx_titles(i)," iSPN"])
    ylim([activity_min,activity_max])
    xticks(1:4)
    xlabel("dimension")
    ylabel("activity (arb. u.)")
end


%% plots of DA activation for each dimension, corresponding to the previous plots

da_a_param = 1;
da_b_param_D1 = -5;
da_b_param_D2 = 5;
da_b_params = {da_b_param_D1,da_b_param_D2};

syms xvar
sSPNs = {sdSPN,siSPN};
dims_space = {dimensions_in_space,dimensions_not_in_space};
dims_space_cols = ["r","c"];
d1d2title = ["D1","D2"];
for d1d2indx=1:2 % D1, D2
    figure
    t = tiledlayout(2,length(ctxs));
    title(t,d1d2title(d1d2indx),global_legend_txt)
    for i=1:length(ctx_titles)
    
        da_input = sum(sSPNs{d1d2indx}{i},2,'omitnan');
        da_output = 1./(1+exp(da_a_param*(da_input - da_b_params{d1d2indx})));
    
        nexttile(i)
        hold on
        fplot(1/(1+exp(da_a_param*(xvar-da_b_params{d1d2indx}))),'k',...
            [activity_min, activity_max])
        for j=find(dims_space{d1d2indx}{i})
            scatter(da_input(j), da_output(j),dims_space_cols{d1d2indx},'filled')
        end
        for j=find(~dims_space{d1d2indx}{i})
            scatter(da_input(j), da_output(j),'k','filled')
        end
        xline(da_input,'--k')
        hold off
        xlabel("sum sSPN activity (arb. u.)")
        ylabel("DA of SNc activity (arb. u.)")
        title(["DA activation, ",ctx_titles(i)])
        
        nexttile(i+length(ctxs))
        hold on
        for j=find(dims_space{d1d2indx}{i})
            bar(j, da_output(j),dims_space_cols(d1d2indx),'EdgeColor','none')
        end
        for j=find(~dims_space{d1d2indx}{i})
            bar(j, da_output(j),'k','EdgeColor','none')
        end
        hold off
        ylim([0 1])
        xticks(1:4)
        xlabel("dimension")
        ylabel("DA of SNc activity (arb. u.)")
        hold off
        xlabel("dimension")
        ylabel("DA of SNc activity (arb. u.)")
        title(["Activity of DA dimensions ",ctx_titles(i)])

    end
end
set(gcf,'renderer','painters')



%% raster plot of some example neurons

n_example_ctx = 30;
n_example_sSPN_per_dimension = 4;
baseline_tsteps = 10;
decision_tsteps = 10;
example_ctx_ids = randsample(n_ctx,n_example_ctx);
% use 4 neurons per dimensions x 2 (d1 vs d2) x 2 dimensions
example_SPN_ids = randsample(n_neurons_per_dimension,n_example_sSPN_per_dimension);

ctx_baseline = mvnrnd(zeros(1,n_example_ctx),...
    5*Sigma(example_ctx_ids,example_ctx_ids),baseline_tsteps);
ctx_decision = mvnrnd(zeros(1,n_example_ctx),...
    Sigma(example_ctx_ids,example_ctx_ids),decision_tsteps) + ...
    5*evs(example_ctx_ids,1)';

for i=1:2 % neurons from two dimensions shown
    dsSPN_baseline{i} = ctx_baseline*squeeze(W_ctx_dSPN(...
        example_ctx_ids,i,example_SPN_ids));
    isSPN_baseline{i} = ctx_baseline*squeeze(W_ctx_iSPN(...
        example_ctx_ids,i,example_SPN_ids));
    dsSPN_decision{i} = ctx_decision*...
        squeeze(W_ctx_dSPN(example_ctx_ids,i,example_SPN_ids));
    isSPN_decision{i} = ctx_decision*...
        squeeze(W_ctx_iSPN(example_ctx_ids,i,example_SPN_ids));
end

ctx = [ctx_baseline; ctx_decision];
SPN = [[dsSPN_baseline{1}, isSPN_baseline{1}, dsSPN_baseline{2}, ...
    isSPN_baseline{2}]; [dsSPN_decision{1}, isSPN_decision{1}, ...
    dsSPN_decision{2}, isSPN_decision{2}]];

raster_color_plot(ctx,baseline_tsteps,decision_tsteps)
raster_color_plot(SPN,baseline_tsteps,decision_tsteps)

function raster_color_plot(dat,baseline_tsteps,decision_tsteps)
    figure
    hold on
    imshow(dat');
    xline(baseline_tsteps + .5,'LineWidth',2)
    xline(baseline_tsteps + decision_tsteps + .5,'LineWidth',2)
    hold off
    xlabel("time (s)")
    ylabel("neuron")
    xticks([baseline_tsteps, ...
        baseline_tsteps + decision_tsteps + .5])
    xticklabels(["decision period begins", "state is set"])
    colorbar
    colormap parula
    clim([-1 1])
end
