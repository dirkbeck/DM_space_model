clear; close all
rng('default')

n_tstep = 35;
n_ctx = 10000;
n_SPN_ensemble = 4;
n_SPN_per_ensemble = 25;
n_SPN = n_SPN_ensemble*n_SPN_per_ensemble;
n_SPNsim = 100;
n_eng_comps = 2;
ctx_diseng_ews = .1;
SPN_var_coef = .1;

% 1. cortex
% determinant is the product of the eigenvalues
% the eigenvalues must sum to the trace (i.e. the # of neurons)
ctx_engaged_ews = ((n_ctx - (n_ctx-n_eng_comps)*ctx_diseng_ews) ...
    ./ n_eng_comps);
cortex_norm_det = (ctx_engaged_ews .^ n_eng_comps .* ...
    ctx_diseng_ews .^ (n_ctx - n_eng_comps)) .^ (1/n_ctx);


% 2. strio and mSPN

[strio_norm_dets,mSPN_norm_dets] = deal(zeros(length(n_eng_comps),n_SPNsim));
for i=1:length(n_eng_comps)
    n_eng_comp = n_eng_comps(i);
    SPN_ews = repelem([ctx_engaged_ews(i),ctx_diseng_ews],...
        n_SPN_per_ensemble*[n_eng_comp,n_SPN_ensemble-n_eng_comp]);
    for s=1:n_SPNsim % multiple sims for a smooth plot
        strio = zeros(n_SPN,n_tstep);
        mSPN = zeros(n_SPN,n_tstep);
        % signal is distributed based on the engaged dimensions
        strio(1:n_eng_comps*n_SPN_per_ensemble,:) = 1;
        mSPN(1:n_eng_comps*n_SPN_per_ensemble,:) = 1;
        % variance is distributed based on eigenvalues
        strio = strio + SPN_var_coef*SPN_ews'.*randn(n_SPN,n_tstep);
        mSPN = mSPN + SPN_var_coef*SPN_ews'.*randn(n_SPN,n_tstep).*mSPN;
        % find determinant of the neurons over time
        strio_norm_dets(i,s) = det(corrcoef(strio))^(1/n_SPN);
        mSPN_norm_dets(i,s) = det(corrcoef(mSPN))^(1/n_SPN);
    end
end
% average across the simulations
strio_norm_det = mean(strio_norm_dets,2);
mSPN_norm_det = mean(mSPN_norm_dets,2);

%% plotting

% cortex, strio, mSPN data
dimensionalities = [n_ctx.*ones(length(n_eng_comps),1),...
    n_SPN.*ones(length(n_eng_comps),1),n_eng_comps'.*n_SPN_per_ensemble]; 
norm_dets = [cortex_norm_det',strio_norm_det,mSPN_norm_det];

figure; hold on
for i=1:length(n_eng_comps)
    plot(log([1000 10 1]),1-norm_dets(i,:),'o-')
end
hold off
xlabel("dimensionality (log scale)")
ylabel("theoretical synchrony")
xticks(log([1 10 1000]))
xticklabels(["sSPN (~.1% cortex)","mSPN (~1% cortex)","cortex"])
% legend(["1D state","2D state"])
