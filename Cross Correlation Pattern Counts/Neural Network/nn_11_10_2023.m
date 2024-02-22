clear; %close all

%% params

% number of nuerons
n_SPN_ensembles = 4; % number of eigenvectors mSPN uses
n_strio_per_ensemble = 10; % for each dSPN and iSPN
n_mSPN_per_ensemble = 10;
n_FSI = 3;
n_PFCPL = 20;
n_other_ctx = 20;


sparsity_ctx_strio = .5; % on scale of 0 (no connection) to 1 (all connected)
sparsity_ctx_mSPN = .8; % on scale of 0 (no connection) to 1 (all connected)
sparsity_ctx_FSI = .01;

sparsity_FSI_strio = .6;
sparsity_FSI_mSPN = .7;%seems to affect IE pattern count the most


FSI_denom_addition = 1; % to avoid /0s for SPN activity
ctx_FSI_weight = .6; % average weight among connected pairs


ctx_strio_weight = 1;
ctx_mSPN_weight = .1;

FSI_strio_weight = -.8;
FSI_mSPN_weight = -.9;


n_tstep = 5; % size of training data



ctx_ews = [2 .5 .2 .1 zeros(1,n_other_ctx-4)];%Rev CB: 2 1, TR: 2, EQR: 0 1, CB 2 1
%the cost benefit task will have both reward and cost
%TR task will have only the reward dimension
%EQR task will have only the cost dimension
%rev CB will have the cost and reward dimensions 
%for cost benefit I could add one more value which represent the conflict dimension
%it would only be for cost benefit 

exc_thresholds = [0 0 ]; % threshold +/- baseline to count a pattern: strio,mSPN
inh_thresholds = [0 0 ]; % strio,mSPN

baseline_strio_activity = -0.25; % baseline to measure change in SPN from
baseline_mSPN_activity = -0.25;


da_a_param = -2; % for DA activation function
da_b_param = 1;


          
titles = ["REV CB (Simple Task)","EQR (Simple Task)","TR (Simple Task)","CB (Difficult Task)"];

difficulty_array = [1, 6, 11, 18];

%% main
rev_cb_patterns = [];
eqr_patterns = [];
tr_patterns = [];
cb_patterns = [];
for j=1:100
    ctx_train_dat = create_ctx(n_tstep,ctx_ews,n_other_ctx);

    % emphasize certain principal components depending on task
    [ev,~] = eig(cov(ctx_train_dat));

    ctxs = {ctx_train_dat + sum(ev(:,1:2),2)',... %rev CB will emphasize both reward and cost
        ctx_train_dat + (ev(:,1)'), ... %EQR will emphasize reward dimension
        ctx_train_dat + (ev(:,2)'),... %TR will emphasize cost dimension
        ctx_train_dat + (sum(ev(:,1:n_SPN_ensembles),2)')}; %CB emphasize the cost and reward dimensions 


    PFC_PLs = {randn(1,n_PFCPL) + difficulty_array(1);...
        randn(1,n_PFCPL) + difficulty_array(2);...
        randn(1,n_PFCPL) + difficulty_array(3);...
        randn(1,n_PFCPL) + difficulty_array(4)}; % high PFC-PL for complex task
    %WHAT IS THE POINT OF HAVING MULTIPLE BRAINS VS 1 BRAIN WHICH GIVES VERY GOOD RESULTS?
    %I ASSUME THAT THE GOAL IS THAT REGARDLESS OF THE BRAIN, WE GET THE SAME RESULTS
    %SHOW THAT AS COMPLEXITY INCREASES, SO DO THE NUMBER OF EIGEN VECTORS
    %sHOW THAT AS COMPLEXITY INCREASES, SO DOES THE NUMBER OF PATTERNS
    %TO START FITTING TO ATANU'S STUFF INCREASE THRESHOLDS FOR FSIS
    %ALL pl INPUTS NEEDS TO BE IDENTICAL 
    %FSIS WILL BE VERY SYNCED WITH CORTEX
    %STRIOSOMES WILL NOT LISTEN TO FSI 
    %FROM ATANUS RESEARCH WE SEE THAT STRESS CAUSES LACK OF INHIBITORY INPUT TO THE STRIOSOME
    %AGING CAUSES ANIMALS TO ACCEPT MORE, WHICH IS SIMILAR TO ATANU'S RESEARCH
    %THIS INDICATES THAT STRESS AND AGING ARE SIMILAR
    %LARA IS MAKING MULTIPLE PLOTS TO SHOW THIS 
    %IN BOTH CASES THE ANIMALS ARE IGNORING THE HIGH COST AND PURSUING HIGH REWARD 
    %lara has dreed in her experiments, which excites all striosome
        %animal will choose more
        %animal cannot differentiate between reward and cost
        %animal has a 1 state choice/it cannot create a state
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

        mSPN_activity = zeros(10,4);

       
        if pfcpl_i ==1
            strio_activity = randn(10,4) + 1;
        elseif pfcpl_i ==2 
            strio_activity = randn(10,4) + 1;
            strio_activity(:,1) =strio_activity(:,1) + randn(10,1);
        elseif pfcpl_i == 3
            strio_activity = randn(10,4) + 1;
            strio_activity(:,2) =strio_activity(:,2) + randn(10,1);
        elseif pfcpl_i == 4
            strio_activity = randn(10,4) + 1;
            strio_activity(:,1) = strio_activity(:,1) + randn(10,1);
            strio_activity(:,2) =strio_activity(:,2) + randn(10,1);
        end
        %for rev cb unequal reward, all strio active
        %for EQR 3 high activity ensembles and 1 ensemble low activity (inhibited
        %for TR 3 high activity ensembles and 1 ensemble low activity (inhibited
        %for CB 2 high activity, 2 low actibity 
        %create matrices with the same form as the strio_activity matrix at the same ratios described above
        %make sure all matrices have some variance,
        %if an ensemble is active have a larger variance for those neurons 
        SPN_activities = {strio_activity,mSPN_activity};

        SPN_activities{1} = SPN_activities{1} - baseline_strio_activity;
        SPN_activities{2} = SPN_activities{2} - baseline_mSPN_activity;

        [da_activity, strio_ensemble_mean_activities] = ...
            calc_DA_activation(SPN_activities,da_a_param, da_b_param);

        sSPN_sSPN_patterns = pattern_counter(SPN_activities{1}, SPN_activities{1}, ...
            [exc_thresholds(1), exc_thresholds(1)],[inh_thresholds(1),inh_thresholds(1)]);

        %only one I care about
        sSPN_mSPN_patterns = pattern_counter(SPN_activities{1}, SPN_activities{2}, ...
            [exc_thresholds(1), exc_thresholds(2)],[inh_thresholds(1),inh_thresholds(2)]);

        if pfcpl_i ==1
            rev_cb_patterns = [rev_cb_patterns;sSPN_mSPN_patterns];
        elseif pfcpl_i ==2
            eqr_patterns = [eqr_patterns;sSPN_mSPN_patterns];
        elseif pfcpl_i ==3
            tr_patterns = [tr_patterns;sSPN_mSPN_patterns];
        elseif pfcpl_i ==4
            cb_patterns = [cb_patterns;sSPN_mSPN_patterns];
        end

        mSPN_mSPN_patterns = pattern_counter(SPN_activities{2}, SPN_activities{2}, ...
            [exc_thresholds(2), exc_thresholds(2)],[inh_thresholds(2),inh_thresholds(2)]);

%         plotter(SPN_activities,strio_ensemble_mean_activities,...
%             da_a_param,da_b_param,da_activity,sSPN_sSPN_patterns,...
%             sSPN_mSPN_patterns,mSPN_mSPN_patterns,titles(pfcpl_i))

    end
end

average_rev_cb_patterns = [mean(rev_cb_patterns(:,1)),mean(rev_cb_patterns(:,2)),mean(rev_cb_patterns(:,3)),mean(rev_cb_patterns(:,3))];
average_eqr_patterns = [mean(eqr_patterns(:,1)),mean(eqr_patterns(:,2)),mean(eqr_patterns(:,3)),mean(eqr_patterns(:,4))];
average_tr_patterns =[mean(tr_patterns(:,1)),mean(tr_patterns(:,2)),mean(tr_patterns(:,3)),mean(tr_patterns(:,4))];
average_cb_patterns = [mean(cb_patterns(:,1)),mean(cb_patterns(:,2)),mean(cb_patterns(:,3)),mean(cb_patterns(:,4))];
figure; hold on;

%plot average rev cb pattern counts as bar chart
subplot(2,5,1);
bar(average_rev_cb_patterns)
ylim([0,max([average_rev_cb_patterns;average_eqr_patterns;average_tr_patterns;average_cb_patterns],[],"all") + 50])
title("Average Rev CB Strio Matrix Pattern Counts")

%plot average EQR pattern count as bar chart
subplot(2,5,2);
bar(average_eqr_patterns);
ylim([0,max([average_rev_cb_patterns;average_eqr_patterns;average_tr_patterns;average_cb_patterns],[],"all") + 50])
title("Average EQR Strio Matrix Pattern Counts")

%plot average TR average pattern count as bar chart
subplot(2,5,3);
bar(average_tr_patterns);
ylim([0,max([average_rev_cb_patterns;average_eqr_patterns;average_tr_patterns;average_cb_patterns],[],"all") + 50])
title("Average TR Strio Matrix Pattern Counts")

%plot the CB pattern count as a bar chart
subplot(2,5,4);
bar(average_cb_patterns);
ylim([0,max([average_rev_cb_patterns;average_eqr_patterns;average_tr_patterns;average_cb_patterns],[],"all") + 50])
title("Average CB Strio Matrix Pattern Counts")

%plot the pattern counts as a linear graph
subplot(2,5,6:10); hold on;
array_of_all_patterns = [average_rev_cb_patterns;average_eqr_patterns;average_tr_patterns;average_cb_patterns];
plot(difficulty_array,array_of_all_patterns(:,1).',"-o")
plot(difficulty_array,array_of_all_patterns(:,2).',"-o")
plot(difficulty_array,array_of_all_patterns(:,3).',"-o")
plot(difficulty_array,array_of_all_patterns(:,4).',"-o")
legend("Excited Excited", "Excited Inhibited", "Inhibited Excited", "Inhibited Inhibited")
text(difficulty_array,...
    [max(array_of_all_patterns(1,:)),max(array_of_all_patterns(2,:)),max(array_of_all_patterns(3,:)),max(array_of_all_patterns(4,:))],...
    ["Rev CB", "EQR", "TR", "CB"])
xlabel("Difficulty")
ylabel("Pattern Count")
%excited excited patterns  %excited inhibited patterns  %inhibited excited patterns %inhibited inhibited patterns



hold off;
% match to Atanu's results: change the activity of one cortex neuron,
% then one FSI neuron. How do striosome and FSI neurons respond?

n_sim = 1000;
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
% title("Modeled cortex-FSI pairs")
% 
% figure
% scatter(fsi_f2s,strio_f2s)
% xlabel("FSI")
% ylabel("strio")
% title("Modeled FSI-dSPN pairs")
% 
% figure
% scatter(pfcpl_p2s,strio_p2s)
% xlabel("PFC-PL")
% ylabel("strio")
% title("modeled cortex-dSPN pairs")

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
    bar(mean(SPN_activities{2},1,'omitnan'),'k')
    bar(SPN_activities{2}','k')
    yline(mean(SPN_activities{2},'all','omitnan'),'--k')
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
