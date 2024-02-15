% calculate the probability of forming states with different complexities
% at different levels of striosomes

% forming a state with a certain # dimensions is calculated as
% the probability of forming each dimension ^ number of dimensions

% for GPi, LH, RMTg, DA excersizes see the similar model in
% GPi_LH_RMTg_DA_model.m

close all; clear
addpath(fileparts(pwd))
rng('default')
col_order = colororder;

%% plot of number of dimensions at different striosome activities

n_inc = 1000;

strio_0 = ones(4,1); % x prior to manipulation
altered_x_rng = linspace(-1,1,n_inc);
sSPN = altered_x_rng + strio_0;
for i=1:n_inc
    p(i) = algorithmic_model(sSPN(i),1,0,1,0,0,10,1);
end

for k=0:4
    probs_states(k+1,:) = nchoosek(4,k).*p.^k.*(1-p).^(4-k);
end

figure
plot(altered_x_rng,probs_states)
xlabel("sSPN activity (arb. u.)")
ylabel("proportion formed")
legend("non-D","1D","2D","3D","4D")
set(gcf,'renderer','painters');

%% 2) experimental effect on decisions of manipulation

% inhibition draws animal from a cost state to 2D integration
% excitation drives the animal into a cost state

% from choice of high conflict option, to choice of high conflict option
excitation_dat = {[5 10 15 20 25 25 30 35 55 60], [20 25 30 35 40 45 50 60 65 70]};
inhibition_dat = {[20 20 20 20 20 20 20 30 70], [0 1 1 1 2 3 4 5 10]};

dat = {excitation_dat{2},inhibition_dat{1},inhibition_dat{2}};
cols = [col_order(1,:);col_order(2,:);col_order(3,:)];

figure; hold on
for i=1:length(dat)
    histogram(dat{i},0:10:100,'FaceColor',cols(i,:))
end
hold off
xlabel("% choosing high cost, high reward")
ylabel("experimental count")
legend(["excitation","control","inhibition"])

%% modeled effect of manipulation

reward = [2 1]; % left, right
cost = [.5 .25]; % left, right

SV_excitation = 0 * reward - 0 * cost; % 0D space
SV_control = 0.5 * reward - 0 * cost; % 1D space
SV_inhibition = 1 * reward - 1 * cost; % 2D space
SVs = {SV_excitation,SV_control,SV_inhibition};

% average choice from model animals that complete nsim trials
n_sim = 20;

% Data from nanimal animals
nanimal = 100;

for i=1:3 % excitation, control, inhibition
    for j=1:nanimal
        [tdat, actions_taken] = weiner_process_model( ...
            SVs{i},1,5,2,.01,n_sim,3);
        dat{i}(j) = mean(actions_taken-1);
    end
end

figure; hold on
for i=1:3
    histogram(dat{i},0:.1:1)
end
hold off
xlabel("modeled % choosing high cost, high reward")
ylabel("sim. count")
legend(["excitation (non-D space)","control (1D space)","inhibition (2D space)"])
