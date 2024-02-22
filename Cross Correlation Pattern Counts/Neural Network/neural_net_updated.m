clear; close all

%% params

% number of nuerons
n_SPN_ensembles = 4; % number of eigenvectors mSPN uses
n_strio_per_ensemble = 4; % for each dSPN and iSPN
n_mSPN_per_ensemble = 10;
n_FSI = 3;
n_PFCPL = 20;
n_other_ctx = 100;
sparsity_ctx_strio = .5; % on scale of 0 (no connection) to 1 (all connected)
sparsity_ctx_mSPN = .5; % on scale of 0 (no connection) to 1 (all connected)
sparsity_ctx_FSI = .5;
sparsity_FSI_strio = .5;
sparsity_FSI_mSPN = .5;
FSI_denom_addition = 1; % to avoid /0s for SPN activity

ctx_FSI_weight = .5; % average weight among connected pairs
ctx_strio_weight = .1;
ctx_mSPN_weight = 1;
FSI_strio_weight = -.5;
FSI_mSPN_weight = -.5;

n_tstep = 5; % size of training data
ctx_ews = [2 .5 .2 .1 zeros(1,n_other_ctx-4)];
%the first eigen value is for the first eigen vector
%reward is always the first element
%for cb 2 1 000000 ...
%for tr 2 000000...
%for EQR 0 1 000...
%for Rev CB 2 1 0000...
%there should be 2 eigen value per principal component,modify the line above 
%there are 2 principal components in general
%Reward and cost
%the cost benefit task will have both reward and cost
%TR task will have only the reward dimension
%EQR task will have only the cost dimension
%rev CB will have the cost and reward dimensions 

exc_thresholds = [.25,.25]; % threshold +/- baseline to count a pattern: strio,mSPN
inh_thresholds = [-2,-2]; % strio,mSPN
baseline_strio_activity = -0.1; % baseline to measure change in SPN from
baseline_mSPN_activity = -1;
da_a_param = -2; % for DA activation function
da_b_param = 1;

ctx_train_dat = create_ctx(n_tstep,ctx_ews,n_other_ctx);

% emphasize certain principal components depending on task
[ev,~] = eig(cov(ctx_train_dat)); 
%ev is a matrix whose columns are the corresponding right eigenvectors, so that cov(ctx_train_data)*ev = ev*~ 
 
ctxs = {ctx_train_dat + ev(:,1)', ctx_train_dat + sum(ev(:,1:n_SPN_ensembles),2)'};
%for each task, add the relevant eigen vector columns (columns with something actually in them  
PFC_PLs = {randn(1,n_PFCPL); randn(1,n_PFCPL) + 0.25; randn(1,n_PFCPL) + 0.35; randn(1,n_PFCPL) + 1}; 
% high PFC-PL for complex task
%so I'm making the assumption that I will need 4 values in the PFC_PL tasks
%one each for REV CB, EQR, TR, and CB
%REV CB should be the easiest task
%EQR should be second easiest
%TR should be slightly more difficult than EQR, but approximately the same
%CB should be hardest task 
%I THINK that this will simulate 1 brain going through 4 different tasks 
%and by simulating 1 brain running through 4 different tasks, we can see how the difficulty is directly affecting things
titles = ["REV CB (Simple Task)","EQR (Simple Task)","TR (Simple Task)","CB (Difficult Task)"];

%% main

for pfcpl_i = 1:4

other_ctx = ctxs{pfcpl_i};
PFC_PL = PFC_PLs{pfcpl_i};

W_otherctx_FSI = get_random_weights(...,
    ctx_FSI_weight,n_other_ctx,n_FSI,sparsity_ctx_FSI);
W_PFCPL_FSI = get_random_weights(...,
    ctx_FSI_weight,n_PFCPL,n_FSI,sparsity_ctx_FSI);

W_FSI_strio = zeros(n_FSI,n_strio_per_ensemble,n_SPN_ensembles);
W_FSI_mSPN = zeros(n_FSI,n_mSPN_per_ensemble,n_SPN_ensembles);
W_otherctx_strio = zeros(n_other_ctx,n_strio_per_ensemble,n_SPN_ensembles);
W_otherctx_mSPN = zeros(n_other_ctx,n_mSPN_per_ensemble,n_SPN_ensembles);
W_PFCPL_strio = zeros(n_PFCPL,n_strio_per_ensemble,n_SPN_ensembles);

for i=1:n_SPN_ensembles
    W_FSI_strio(:,:,i) = get_random_weights(...,
        FSI_strio_weight,n_FSI,n_strio_per_ensemble,sparsity_FSI_strio);
    W_FSI_mSPN(:,:,i) = get_random_weights(...,
        FSI_mSPN_weight,n_FSI,n_mSPN_per_ensemble,sparsity_FSI_mSPN);
    W_otherctx_strio(:,:,i) = get_random_weights(...,
        ctx_strio_weight,n_other_ctx,n_strio_per_ensemble,sparsity_ctx_strio);
    W_otherctx_mSPN(:,:,i) = get_random_weights(...,
        ctx_mSPN_weight,n_other_ctx,n_mSPN_per_ensemble,sparsity_ctx_mSPN);
    W_PFCPL_strio(:,:,i) = get_random_weights(...,
        ctx_strio_weight,n_PFCPL,n_strio_per_ensemble,sparsity_ctx_strio);
end

[strio_activity, mSPN_activity] = sum_SPN_activity(...,
    n_SPN_ensembles,W_otherctx_FSI,W_PFCPL_FSI,W_FSI_strio,W_FSI_mSPN, ...
    W_otherctx_mSPN,W_otherctx_strio,W_PFCPL_strio,FSI_denom_addition,...
    other_ctx,PFC_PL);

SPN_activities = {strio_activity,mSPN_activity};

SPN_activities{1} = SPN_activities{1} - baseline_strio_activity;
SPN_activities{2} = SPN_activities{2} - baseline_mSPN_activity;
    
[da_activity, strio_ensemble_mean_activities] = ...
    calc_DA_activation(SPN_activities,da_a_param, da_b_param);
    
sSPN_sSPN_patterns = pattern_counter(SPN_activities{1}, SPN_activities{1}, ...
    [exc_thresholds(1), exc_thresholds(1)],[inh_thresholds(1),inh_thresholds(1)]);
sSPN_mSPN_patterns = pattern_counter(SPN_activities{1}, SPN_activities{2}, ...  %these are the patterns which I actually want to record each time I run these 
    [exc_thresholds(1), exc_thresholds(2)],[inh_thresholds(1),inh_thresholds(2)]);
mSPN_mSPN_patterns = pattern_counter(SPN_activities{2}, SPN_activities{2}, ...
    [exc_thresholds(2), exc_thresholds(2)],[inh_thresholds(2),inh_thresholds(2)]);

% plotter(SPN_activities,strio_ensemble_mean_activities,...
%     da_a_param,da_b_param,da_activity,sSPN_sSPN_patterns,...
%     sSPN_mSPN_patterns,mSPN_mSPN_patterns,titles(pfcpl_i))

end


% match to Atanu's results: change the activity of one cortex neuron,
% then one FSI neuron. How do striosome and FSI neurons respond?

n_sim = 10;
% record the maximum connection indices, similar to how most connected
% neurons in experimental recordings are isolated
W_FSI_strio_1stensemble = W_FSI_strio(:,:,1); % look at the 1st ensemble for this
W_PFCPL_strio_1stensemble = W_PFCPL_strio(:,:,1);
Ws = {W_PFCPL_FSI,W_FSI_strio_1stensemble,W_PFCPL_strio_1stensemble};
for i=1:length(Ws)
    W = Ws{i};
    [~, indx] = max(Ws{i},[],'all');
    [max_from_indxs(i),max_to_indxs(i)] = ind2sub(size(W),indx);
end

[pfcpl_p2f,fsi_p2f,fsi_f2s,strio_f2s,pfcpl_p2s,strio_p2s] = deal(zeros(1,n_sim));
for i=1:n_sim
    otherctx_i = randn(1,n_other_ctx);
    pfcpl_i = randn(1,n_PFCPL);
    [strio_i, ~, fsi_i] = sum_SPN_activity(...,
        n_SPN_ensembles,W_otherctx_FSI,W_PFCPL_FSI,W_FSI_strio,W_FSI_mSPN, ...
        W_otherctx_mSPN,W_otherctx_strio,W_PFCPL_strio,FSI_denom_addition,...
        otherctx_i,pfcpl_i);
    % PFC-PL to FSI plot
    pfcpl_p2f(i) = pfcpl_i(max_from_indxs(1)); 
    fsi_p2f(i) = fsi_i(max_to_indxs(1));
    % FSI to dSPN
    fsi_f2s(i) = fsi_i(max_from_indxs(2));
    strio_f2s(i) = strio_i(max_to_indxs(2));
    % PFC-PL to strio
    pfcpl_p2s(i) = pfcpl_i(max_from_indxs(3));
    strio_p2s(i) = strio_i(max_to_indxs(3));
end

% sort in ascending order by the "from" for plotting
[pfcpl_p2f, indx] = sort(pfcpl_p2f);
fsi_p2f = fsi_p2f(indx);
[fsi_f2s, indx] = sort(fsi_f2s);
strio_f2s = strio_f2s(indx);
[pfcpl_p2s, indx] = sort(pfcpl_p2s);
strio_p2s = strio_p2s(indx);

% figure
% scatter(pfcpl_p2f,fsi_p2f)
% xlabel("PFC-PL")
% ylabel("FSI")
% title("Modeled PFCPL-FSI pairs")
% 
% figure
% scatter(fsi_f2s,strio_f2s)
% xlabel("FSI")
% ylabel("strio")
% title("Modeled FSI-strio pairs")
% 
% figure
% scatter(pfcpl_p2s,strio_p2s)
% xlabel("PFC-PL")
% ylabel("strio")
% title("modeled PFCPL-strio pairs")

%% functions

function ctx = create_ctx(n_tstep,ctx_ews,n_ctx)
    % each cortex neuron has different but somewhat similar data
    Sigma = sprandsym(n_ctx,1,ctx_ews); % randomly create a covariance SPN
    ctx = mvnrnd(zeros(n_ctx,1),Sigma,n_tstep); % randomly create cortex data
end


function W = get_learned_weights(weight,inpt,n_output,sparsity,n_output_ensembles,...
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

    % multiply by 2 so that "weight" is the average weight
    W = 2 * weight * W;

end

function W = get_random_weights(weight,n_input,n_output,sparsity)

    % multiply by 2 so that "weight" is the average weight
    W = 2 * weight * sprand(n_input,n_output,sparsity);

end


function [strio_activity, mSPN_activity, FSI_activity] = sum_SPN_activity(...,
    n_SPN_ensembles,W_otherctx_FSI,W_PFCPL_FSI,W_FSI_strio,W_FSI_mSPN, ...
    W_otherctx_mSPN,W_otherctx_strio,W_PFCPL_strio,FSI_denom_addition,...
    other_ctx,PFC_PL)
    
    % for each SPN ensemble
    % input cortex activity during a decision, 
    % find differences in population activity between the neurons

    for i=1:n_SPN_ensembles
        % get the values through the ctx -> FSI -> SPN subcircuit
        FSI_activity = other_ctx*W_otherctx_FSI + PFC_PL*W_PFCPL_FSI;
        FSI_pathway_mSPN = FSI_activity * W_FSI_mSPN(:,:,i);
        FSI_pathway_strio = FSI_activity * W_FSI_strio(:,:,i);
        % add or subtract a small constant to avoid division errors
        signs_mSPN = sign(FSI_pathway_mSPN);
        signs_mSPN(signs_mSPN == 0) = 1;
        FSI_pathway_with_denomaddition_mSPN = FSI_pathway_mSPN + ...
            FSI_denom_addition*signs_mSPN;
        signs_strio = sign(FSI_pathway_strio);
        signs_strio(signs_strio == 0) = 1;
        FSI_pathway_with_denomaddition_strio = FSI_pathway_strio + ...
            FSI_denom_addition*signs_strio;
        % direct cortex -> SPN connection is divided by cortex -> FSI
        % -> SPN connection
        mSPN_activity(:,i) = sum(other_ctx*W_otherctx_mSPN(:,:,i) ./ ...
            FSI_pathway_with_denomaddition_mSPN);
        strio_activity(:,i) = sum(...
            (other_ctx*W_otherctx_strio(:,:,i) + PFC_PL*W_PFCPL_strio(:,:,i)) ./ ...
            FSI_pathway_with_denomaddition_strio);
    end

end


function [da_activity, strio_ensemble_mean_activities] = ...
    calc_DA_activation(SPN_activities, da_a_param, da_b_param)

    n_ensembles = width(SPN_activities{1});

    strio_ensemble_mean_activities = zeros(n_ensembles,1);
    for i=1:width(SPN_activities{1})
        strio_ensemble_mean_activities(i) = mean(SPN_activities{1}(:,i),1,"includenan");
    end

    da_activity = 1./(1+exp(da_a_param*strio_ensemble_mean_activities+da_b_param));

end


function patterns = pattern_counter(SPN_pop1,SPN_pop2,...
    exc_thresholds,inh_thresholds)
    %the top things that are different between the groups that we are showing 
    n_exc_patterns_pop1 = sum(SPN_pop1 > exc_thresholds(1),'all');
    n_exc_patterns_pop2 = sum(SPN_pop2 > exc_thresholds(2),'all');
    n_inh_patterns_pop1 = sum(SPN_pop1 < inh_thresholds(1),'all');
    n_inh_patterns_pop2 = sum(SPN_pop2 < inh_thresholds(2),'all');
    patterns = [n_exc_patterns_pop1*n_exc_patterns_pop2, ...
        n_exc_patterns_pop1*n_inh_patterns_pop2, ...
        n_inh_patterns_pop1*n_exc_patterns_pop2, ...
        n_inh_patterns_pop1*n_inh_patterns_pop2];

end


function [] = plotter(SPN_activities,...
    strio_ensemble_mean_activities,da_a_param,da_b_param,da_activity, ...
    sSPN_sSPN_patterns,sSPN_mSPN_patterns,mSPN_mSPN_patterns,ttl)

    syms x
    n_ensembles = width(SPN_activities{1});

    figure
    t = tiledlayout(3,n_ensembles+2);
    title(t,ttl);

    nexttile([1 n_ensembles])
    hold on
    bar(mean(SPN_activities{1},1,'omitnan'),'k')
    bar(SPN_activities{1}','k')
    yline(mean(SPN_activities{1},'all','omitnan'),'--k')
    hold off
    xlabel("ensemble #")
    ylabel("relative activity")
    title("Activity of striosome ensembles")
    subtitle("black = ensemble mean, \newline" + ...
        "dashed line = global mean");

    nexttile
    bar(sSPN_sSPN_patterns)
    ylabel("# patterns")
    xticklabels(["exc -> exc", "exc -> inh", "inh -> exc", "inh -> inh"])
    title("Counts of excitatory & inhibitory sSPN patterns")

    nexttile
    bar(sum(SPN_activities{1} ~= 0))
    ylabel("# engaged sSPN neurons")
    title("sSPN ensemble size")

    for i=1:n_ensembles
        nexttile; hold on
        fplot(1/(1+exp(da_a_param*x + da_b_param)),'k')
        scatter(strio_ensemble_mean_activities(i), ...
            1/(1+exp(da_a_param*strio_ensemble_mean_activities(i) + da_b_param)),'k','filled')
        xline(strio_ensemble_mean_activities(i),'--k')
        hold off
        xlabel("strio activity")
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
    bar(mean(SPN_activities{2},1,'omitnan'),'k')
    bar(SPN_activities{2}','k')
    yline(mean(SPN_activities{2},'all','omitnan'),'--k')
    xlabel("ensemble #")
    ylabel("relative activity")
    title("Activity of mSPN ensembles")
    subtitle("black = ensemble mean, \newline" + ...
        "dashed line = global mean");

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
