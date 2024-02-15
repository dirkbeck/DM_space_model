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
    1*mvnrnd(zeros(1,n_ctx),Sigma,n_tstep);

SPN = ctx*ev;
sSPN = SPN(:,1:n_SPN);
mSPN = SPN(:,1:n_SPN);
mSPN(:,2:n_SPN) = 0; % reduce activity for out-of-space

figure
tiledlayout(2,1)
nexttile
plot(linspace(0,1,n_tstep),sSPN)
ylabel("sSPN activity (arb. u.)")
nexttile
plot(linspace(0,1,n_tstep),mSPN)
xlabel("time (arb. u.)")
ylabel("mSPN activity (arb. u.)")
legend(["dimension 1 (e.g. reward)","dimension 2 (e.g. cost)",...
    "dimension 3 (e.g. hunger)"])
