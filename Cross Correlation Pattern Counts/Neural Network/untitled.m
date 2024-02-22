% You'll change around:
%   # of neurons (anatomy),
%   sparsity (anatomy/physiology),
%   denom addition (fitting, within reason),
%   weights (fitting, within reason),
%   ctx ews (to match Atanu's calculated eigenvalues),
%   thresholds (fitting, within reason),
%   and thresholds (whatever you want)

%SPN neurons learn the eigenvectors of the cortex
%the state is which principal components used
%SPN neurons

clear; close all

%% params

% number of nuerons
n_SPN_ensembles = 4; % number of eigenvectors matrix SPN uses
n_SPN = 10; % for each dSPN and iSPN
n_FSI = 3;
n_ctx = 100;


sparsity_ctx_SPN = .1; % on scale of 0 (no connection) to 1 (all connected)
sparsity_ctx_FSI = .05;
sparsity_FSI_SPN = .2;


FSI_denom_addition = 1; % to avoid /0s for SPN activity


ctx_FSI_weight = .1; % average weight among connected pairs
ctx_SPN_weight = .5;
FSI_SPN_weight = -.5;


n_tstep = 5; % size of training data
ctx_ews = [2 .5 .2 .1 zeros(1,n_ctx-4)]; %measures synchrony
disp("ctx_ews")
disp(ctx_ews)

exc_thresholds = [1,1]; % threshold +/- baseline to count a pattern: strio,matrix


inh_thresholds = [-1,-1]; % strio,matrix


baseline_SPN_activity = -1; % baseline to measure change in SPN from


da_a_param = -2; % for DA activation function


da_b_param = 1;

ctx_train_dat = create_ctx(n_tstep,ctx_ews,n_ctx); %either use real cortex data or create fake data based on the real data

% emphasize certain principal components depending on task
[ev,~] = eig(cov(ctx_train_dat));
ctxs = {ctx_train_dat + ev(:,1)', ctx_train_dat + sum(ev(:,1:n_SPN_ensembles),2)'};
disp("ctxs")
disp(ctxs)
titles = ["Simple task","Difficult task"];

%% main

for ctx_i_all = 1:1.5%2

    ctx = ctxs{ctx_i_all};

    W_ctx_dSPN = 2*ctx_SPN_weight * get_weights(ctx_train_dat,...
        n_SPN,sparsity_ctx_SPN,n_SPN_ensembles,"Hebbian");
    disp("W_ctx_dSPN")
    disp(W_ctx_dSPN)

    W_ctx_iSPN = 2*ctx_SPN_weight * get_weights(ctx_train_dat,...
        n_SPN,sparsity_ctx_SPN,n_SPN_ensembles,"anti-Hebbian");

    W_ctx_FSI = 2*ctx_FSI_weight * sprand(n_ctx,n_FSI,sparsity_ctx_FSI);

    [W_FSI_dSPN,W_FSI_iSPN] = deal(zeros(n_FSI,n_SPN,n_SPN_ensembles));

    for i=1:n_SPN_ensembles
        W_FSI_dSPN(:,:,i) = 2*FSI_SPN_weight * sprand(n_FSI,n_SPN,sparsity_FSI_SPN);
        W_FSI_iSPN(:,:,i) = 2*FSI_SPN_weight * sprand(n_FSI,n_SPN,sparsity_FSI_SPN);
    end

    SPN_activity = sum_SPN_activity(n_SPN,n_SPN_ensembles,ctx,W_ctx_dSPN,...
        W_ctx_iSPN,W_ctx_FSI,W_FSI_dSPN,W_FSI_iSPN,FSI_denom_addition);

    % mathematically, ctx -> strio can converge to either exc or inh SPN
    % let them lead to inhibition in striosome, excitation in matrix
    [strio_activity, matrix_activity] = deal(SPN_activity);
    if mean(SPN_activity{1},"all","omitnan") > 0
        strio_activity{1} = -SPN_activity{1};
        matrix_activity{1} = SPN_activity{1};
    else
        strio_activity{1} = SPN_activity{1};
        matrix_activity{1} = -SPN_activity{1};
    end

    SPN_activities = {strio_activity,matrix_activity};


    for act = 1:2 % strio and matrix
        SPN_activity = SPN_activities{act};
        for i=1:2
            SPN_activity{i} = SPN_activity{i} - baseline_SPN_activity;
        end
    end

    [dSPN_iSPN_diffs, da_activity] = calc_DA_activation(SPN_activity, ...
        da_a_param, da_b_param);

    sSPN_sSPN_patterns = pattern_counter(SPN_activities{1}, SPN_activities{1}, ...
        [exc_thresholds(1), exc_thresholds(1)],[inh_thresholds(1),inh_thresholds(1)]);
    sSPN_mSPN_patterns = pattern_counter(SPN_activities{1}, SPN_activities{2}, ...
        [exc_thresholds(1), exc_thresholds(2)],[inh_thresholds(1),inh_thresholds(2)]);
    mSPN_mSPN_patterns = pattern_counter(SPN_activities{2}, SPN_activities{2}, ...
        [exc_thresholds(2), exc_thresholds(2)],[inh_thresholds(2),inh_thresholds(2)]);

    plotter(SPN_activities,dSPN_iSPN_diffs,...
        da_a_param,da_b_param,da_activity,sSPN_sSPN_patterns,...
        sSPN_mSPN_patterns,mSPN_mSPN_patterns,titles(ctx_i_all))

end


% match to Atanu's results: change the activity of one cortex neuron,
% then one FSI neuron. How do striosome and FSI neurons respond?

n_sim = 10;
% record the maximum connection indices, similar to how most connected
% neurons in experimental recordings are isolated
W_FSI_dSPN = W_FSI_dSPN(:,:,1); % look at the first dSPN ensemble
W_ctx_dSPN = W_ctx_dSPN(:,:,1); % look at the first dSPN ensemble
Ws = {W_ctx_FSI,W_FSI_dSPN,W_ctx_dSPN};
for i=1:length(Ws)
    W = Ws{i};
    [~, indx] = max(Ws{i},[],'all');
    [max_from_indxs(i),max_to_indxs(i)] = ind2sub(size(W),indx);
end

[ctx_c2f,fsi_c2f,fsi_f2s,dSPN_f2s,ctx_c2s,dSPN_c2s] = deal(zeros(1,n_sim));
for i=1:n_sim
    ctx_i_all = randn(1,n_ctx);
    fsi_i_all = ctx_i_all * W_ctx_FSI;
    dSPN_i_all = ctx_i_all * W_ctx_dSPN + fsi_i_all * W_FSI_dSPN;
    % cortex to FSI
    ctx_c2f(i) = ctx_i_all(max_from_indxs(1));
    fsi_c2f(i) = fsi_i_all(max_to_indxs(1));
    % FSI to dSPN
    fsi_f2s(i) = fsi_i_all(max_from_indxs(2));
    dSPN_f2s(i) = dSPN_i_all(max_to_indxs(2));
    % cortex to dSPN
    ctx_c2s(i) = ctx_i_all(max_from_indxs(3));
    dSPN_c2s(i) = dSPN_i_all(max_to_indxs(3));
end

% sort in ascending order by the "from" for plotting
[ctx_c2f, indx] = sort(ctx_c2f);
fsi_c2f = fsi_c2f(indx);
[fsi_f2s, indx] = sort(fsi_f2s);
dSPN_f2s = dSPN_f2s(indx);
[ctx_c2s, indx] = sort(ctx_c2s);
dSPN_c2s = dSPN_c2s(indx);

figure
scatter(ctx_c2f,fsi_c2f)
xlabel("cortex")
ylabel("FSI")
title("Modeled cortex-FSI pairs")

figure
scatter(dSPN_f2s,dSPN_f2s)
xlabel("FSI")
ylabel("dSPN")
title("Modeled FSI-dSPN pairs")

figure
scatter(ctx_c2s,dSPN_c2s)
xlabel("cortex")
ylabel("dSPN")
title("modeled cortex-dSPN pairs")

%% functions

function ctx = create_ctx(n_tstep,ctx_ews,n_ctx)
% each cortex neuron has different but somewhat similar data
Sigma = sprandsym(n_ctx,1,ctx_ews); % randomly create a covariance SPN
ctx = mvnrnd(zeros(n_ctx,1),Sigma,n_tstep); % randomly create cortex data
end


function W = get_weights(inpt,n_output,sparsity,n_output_ensembles,...
    learning_type)

n_input = width(inpt);

% randomly generate connections
connected_neurons = reshape(randsample(2,n_input*n_output,true,...
    [1-sparsity,sparsity]),n_input,n_output)-1;

W = zeros(n_input,n_output,n_output_ensembles);

for i=1:n_output
    connected_indx = find(connected_neurons(:,i));
    if learning_type == "Hebbian"
        [weights,~] = eig(cov(inpt(:,connected_indx)));
    elseif learning_type == "anti-Hebbian"
        weights = null(inpt(:,connected_indx));
    else
        error("Incorrect learning type")
    end
    % connect to as many ensembles as there is data
    if ~isempty(weights)
        W(connected_indx,i,1:min(end,width(weights))) = ...
            weights(:,1:min(end,n_output_ensembles));
    end
end

end


function SPN_activity = sum_SPN_activity(n_SPN,n_SPN_ensembles,ctx,W_ctx_dSPN,...
    W_ctx_iSPN,W_ctx_FSI,W_FSI_dSPN,W_FSI_iSPN,FSI_denom_addition)

% for each SPN ensemble
% input cortex activity during a decision,
% find differences in population activity between the neurons

SPN_activity = ...
    {zeros(n_SPN,n_SPN_ensembles),zeros(n_SPN,n_SPN_ensembles)};
W_ctx_SPN = {W_ctx_dSPN,W_ctx_iSPN};
W_FSI_SPN = {W_FSI_dSPN,W_FSI_iSPN};

for i=1:2 % dSPN and iSPN
    for j=1:n_SPN_ensembles
        FSI_pathway = ctx*W_ctx_FSI*W_FSI_SPN{i}(:,:,j);
        % add or subtract a small constant to avoid division errors
        signs = sign(FSI_pathway);
        signs(signs == 0) = 1;
        FSI_pathway_with_denomaddition = FSI_pathway + ...
            FSI_denom_addition*signs;
        % direct cortex -> SPN connection is divided by cortex -> FSI
        % -> SPN connection
        SPN_activity{i}(:,j) = sum(ctx*W_ctx_SPN{i}(:,:,j) ./ ...
            FSI_pathway_with_denomaddition);
    end
end

end


function [dSPN_iSPN_diffs,da_activity] = calc_DA_activation(SPN_activity, da_a_param, da_b_param)

n_ensembles = width(SPN_activity{1});

dSPN_iSPN_diffs = zeros(n_ensembles,1);
for i=1:width(SPN_activity{1})
    dSPN_iSPN_diffs(i) = mean(SPN_activity{1}(:,i),1,"includenan") - ...
        mean(SPN_activity{2}(:,i),1,"includenan");
end

da_activity = 1./(1+exp(da_a_param*dSPN_iSPN_diffs+da_b_param));

end


function patterns = pattern_counter(SPN_activity_pop1,SPN_activity_pop2,...
    exc_thresholds,inh_thresholds)

% look at both dSPN and iSPN
all_SPN_pop1 = [SPN_activity_pop1{1}; SPN_activity_pop1{2}];
all_SPN_pop2 = [SPN_activity_pop2{1}; SPN_activity_pop2{2}];

n_exc_patterns_pop1 = sum(all_SPN_pop1 > exc_thresholds(1),'all');
n_exc_patterns_pop2 = sum(all_SPN_pop2 > exc_thresholds(2),'all');
n_inh_patterns_pop1 = sum(all_SPN_pop1 < inh_thresholds(1),'all');
n_inh_patterns_pop2 = sum(all_SPN_pop2 < inh_thresholds(2),'all');
patterns = [n_exc_patterns_pop1*n_exc_patterns_pop2, ...
    n_exc_patterns_pop1*n_inh_patterns_pop2, ...
    n_inh_patterns_pop1*n_exc_patterns_pop2, ...
    n_inh_patterns_pop1*n_inh_patterns_pop2];

end


function [] = plotter(SPN_activities,...
    dSPN_iSPN_diffs,da_a_param,da_b_param,da_activity, ...
    sSPN_sSPN_patterns,sSPN_mSPN_patterns,mSPN_mSPN_patterns,ttl)

    syms x
    n_ensembles = width(SPN_activities{1}{1});

    all_sSPN = [SPN_activities{1}{1}; SPN_activities{1}{2}];
    all_mSPN = [SPN_activities{2}{1}; SPN_activities{2}{2}];

    figure
    t = tiledlayout(3,n_ensembles+2);
    title(t,ttl);

    nexttile([1 n_ensembles])
    hold on
    bar(mean(all_sSPN,1,'omitnan'),'k')
    b = bar(all_sSPN');
    % dSPN, iSPN colors
    cols = [repelem("g",height(all_sSPN)/2),repelem("m",height(all_sSPN)/2)];
    for i=1:length(b)
        b(i).FaceColor = cols(i);
    end
    yline(mean(all_sSPN,'all','omitnan'),'--k')
    hold off
    xlabel("ensemble #")
    ylabel("relative activity")
    title("Activity of striosome ensembles")
    subtitle("colors = individual striosome activity, \newline" + ...
        "black = ensemble mean, \newline" + ...
        "dashed line = global mean, \newline" + ...
        "green = dSPN, purple = iSPN");

    nexttile
    bar(sSPN_sSPN_patterns)
    ylabel("# patterns")
    xticklabels(["exc -> exc", "exc -> inh", "inh -> exc", "inh -> inh"])
    title("Counts of excitatory & inhibitory sSPN patterns")

    nexttile
    bar(sum(all_sSPN ~= 0))
    ylabel("# engaged sSPN neurons")
    title("sSPN ensemble size")

    for i=1:n_ensembles
        nexttile; hold on
        fplot(1/(1+exp(da_a_param*x + da_b_param)),'k')
        scatter(dSPN_iSPN_diffs(i), ...
            1/(1+exp(da_a_param*dSPN_iSPN_diffs(i) + da_b_param)),'k','filled')
        xline(dSPN_iSPN_diffs(i),'--k')
        hold off
        xlabel("sdSPN - siSPN activity")
        ylabel("DA relative activity")
        title(strcat("ensemble ",num2str(i)))
    end

    nexttile([1 2])
    bar(da_activity)
    ylim([0 1])
    xlabel("ensemble #")
    ylabel("DA relative activity")
    hold off
    xlabel("ensemble #")
    ylabel("relative activity")
    title("Activity of DA ensembles")

    nexttile([1 n_ensembles])
    hold on
    bar(mean(all_mSPN,1,'omitnan'),'k')
    b = bar(all_mSPN');
    % dSPN, iSPN colors
    cols = [repelem("g",height(all_mSPN)/2),repelem("m",height(all_mSPN)/2)];
    for i=1:length(b)
        b(i).FaceColor = cols(i);
    end
    yline(mean(all_mSPN,'all','omitnan'),'--k')
    xlabel("ensemble #")
    ylabel("relative activity")
    title("Activity of mSPN ensembles")
    subtitle("colors = individual mSPN activity, \newline" + ...
        "black = ensemble mean, \newline" + ...
        "dashed line = global mean, \newline" + ...
        "green = dSPN, purple = iSPN");

    nexttile
    bar(sSPN_mSPN_patterns)
    xticklabels(["exc -> exc", "exc -> inh", "inh -> exc", "inh -> inh"])
    ylabel("# patterns")
    title("sSPN-mSPN ensembles")

    nexttile
    bar(mSPN_mSPN_patterns)
    xticklabels(["exc -> exc", "exc -> inh", "inh -> exc", "inh -> inh"])
    ylabel("# patterns")
    title("mSPN-mSPN ensembles")

end