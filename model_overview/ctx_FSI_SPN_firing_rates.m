clear; close all
rng('default')

n_tstep = 100;
n_ctx = 10;
n_SPN = 3;
t = linspace(0,2*pi,n_tstep);

% create a cortex signal -- make it very rank 1
ctx_ews = [1 .5 repelem(.1,n_ctx-2)];
Sigma = sprandsym(n_ctx,1,ctx_ews); % randomly create a covariance matrix
[ev,~] = eigs(Sigma);
ctx = (sin(t).*ev(:,1) + cos(t).*ev(:,2) + sin(2*t).*ev(:,3))' + ...
    .2*mvnrnd(zeros(1,n_ctx),Sigma,n_tstep);
ctx = ctx .* [repelem(.2,n_tstep/4),repelem(1,n_tstep/2),...
    repelem(.2,n_tstep/4)]';

% after FSI scaling
FSI_a = 1;
FSI_b = 0.1;
FSI = ctx ./ (FSI_b + FSI_a*vecnorm(ctx,2,2));

% SPN
SPN = FSI*ev;
SPN = SPN(:,1:n_SPN);

figure
tiledlayout(3,1)
nexttile
plot(linspace(0,1,n_tstep),ctx,'k','HandleVisibility','off')
ylabel("cortex neuron activity (arb. u.)")
nexttile
plot(linspace(0,1,n_tstep),FSI,'k','HandleVisibility','off')
ylabel("activity after FSI scaling (arb. u.)")
nexttile
plot(linspace(0,1,n_tstep),SPN)
xlabel("time (arb. u.)")
ylabel("SPN activity (arb. u.)")
legend(["dimension 1 (e.g. reward)","dimension 2 (e.g. cost)",...
    "dimension 3 (e.g. hunger)"])
