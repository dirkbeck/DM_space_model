clear; close all
rng('default')

% For simulations
n_connections_incs = 2:10;
n_sim = 1000;
n_ctxs = [20 100 1000];
nSPN = 10;
first2ews = [1 .1];

for ctx_i=1:length(n_ctxs)
    n_ctx = n_ctxs(ctx_i);
    dprime{ctx_i} = zeros(n_sim,length(n_connections_incs));
    ews = [first2ews zeros(1,n_ctx-2)];
    full_ctx_sigma = sprandsym(n_ctx,1,ews); % randomly create a covariance matrix
    [true_ctx_evs,~] = eigs(full_ctx_sigma);
    full_ctx_signal = true_ctx_evs(:,1);
    true_SPN_signal = 1;

    for sim_i = 1:n_sim
        % perform analysis on a single dimension, see how similar an average neuron
        % is to the signal after transmission through sparse weights
        activities = zeros(nSPN,6);
        for i=1:length(n_connections_incs)
            n_connections = n_connections_incs(i);
            for j=1:nSPN
                connections = randsample(n_ctx,n_connections)';
                partial_sigma = full_ctx_sigma(connections,connections);
                partial_signal = full_ctx_signal(connections);
                [W,~] = eigs(partial_sigma);
                % test signal to align so that increasing cortex leads to
                % increasing SPN
        
                SPN_signal = partial_signal'*W;
                activities(j,1:min(length(SPN_signal),6)) = abs(SPN_signal);
            end
            dprime{ctx_i}(sim_i,i) = abs(mean(activities(:,1))-mean(activities(:,2)))/...
                mean(std(activities(:,1),activities(:,2)));
        end
    end
end

figure; hold on
for ctx_i=1:length(n_ctxs)
    plot(n_connections_incs,mean(dprime{ctx_i}),'.-')
end
xlabel("n ctx->sSPN connections")
ylabel("sensitivity index between sSPN dimensions")
legend(["2x dim. reduction","10x dim. rediction","100x dim. reduction"])