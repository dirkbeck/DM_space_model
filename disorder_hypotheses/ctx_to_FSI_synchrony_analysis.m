
% match to Atanu's results: 
% 
% look at pairs of combinations of PFC-PL and FSI

clear; close all
rng('default')

%% Mathematical relationship between weight, synchrony, and FSI/ctx


% to find covariance, slope, and intercept:
%
% cov(fsi,ctx1) = connection weight*(var(ctx1) + sum(cov(ctx1,connected ctx2),cov(ctx,connected ctx3),...));
% and
% correlation = cov(fsi,ctx)/sqrt(var(ctx1)*(var(ctx1)+2*cov(fsi,ctx1) + ...
% 2cov(fsi,ctx2) + ... + sum(cov matrix of fsi and ctx)))
%
% slope = cov(fsi,ctx1)/var(fsi)
%

n_connection_incs = 1:10; % assume the same between all neurons
connection_w_incs = 1:3;
ctx_var = 1; % assume for all neurons
ctx_cov = .1;
mean_ctx = 5;

for i=1:length(n_connection_incs)
    for j=1:length(connection_w_incs)
        c = n_connection_incs(i);
        w = connection_w_incs(j);
        ctx_fsi_r2(i) = ((ctx_var+(c-1)*ctx_cov)/(c*ctx_var))^.5;
        slope(i,j) = 1/(w*c);
    end
end

figure
plot(n_connection_incs,slope)
xlabel("n ctx -> fsi connections")
ylabel("Theoretical a")
xlim([n_connection_incs(1) n_connection_incs(end)])

l = legend("low","medium","high");
title(l,"connection weight")

figure
plot(n_connection_incs,ctx_fsi_r2)
xlabel("n ctx -> fsi connections")
ylabel("Theoretical r^2")
xlim([n_connection_incs(1) n_connection_incs(end)])

%% show some simulations with change in synchrony and connectedness

n_ctx = 100;
n_sim = 10; % number of points on the plots

W_ctx_fsis = rand(n_ctx,1);
n_neurons_connected_per_FSI = [10 2];

titles = ["Control","fewer ctx->fsi connections"];

for i=1:2
    for j=1:n_sim
        % make the first cortex neuron connected to the FSI. Arbitrarily pick
        % several others to be connected
        W_ctx_fsi = [1 ismember(2:n_ctx,...
            randsample(2:n_ctx,n_neurons_connected_per_FSI(i)-1,false))]' ...
            .* W_ctx_fsis;
        ctx = randn(1,n_ctx);
        % record the activity of the connected pair
        ctx1(i,j) = ctx(1);
        fsi(i,j) = ctx * W_ctx_fsi;
    end
end

figure
tiledlayout(2,1)
for i=1:2
    nexttile
    hold on
    scatter(ctx1(i,:),fsi(i,:))
    mdl = fitlm(ctx1(i,:),fsi(i,:));
    p = plot(mdl);
    delete(p([1 3 4]));
    hold off
    xlabel("cortex activity (arb. u.)")
    ylabel("FSI activity (arb. u.)")
    title(["cortex/FSI pair across simulated trials, " titles(i)])
end