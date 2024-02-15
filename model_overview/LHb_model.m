clear; close all

% show that firing rates resemble predicion erorr in LHb, RMTg, and DA of
% SNc

DA_a = 5;
DA_b = -1;

cost_incs = linspace(0,1,100);
reward_incs = linspace(0,1,100);

% 1) aversive stimulus
sSPN = .5; % value in reward dimension
LH = cost_incs;
RMTg = .8*cost_incs;
DA = 1./(1 + exp(DA_a*-sSPN + LH + RMTg - DA_b));

figure; tiledlayout(1,2)

t1 = nexttile; hold on
plot(cost_incs,LH)
plot(cost_incs,RMTg)
plot(cost_incs,DA)
hold off
xlabel("cost level")
ylabel("activity")
legend(["LHb","RMTg","reward dimension DA of SNc"])
title(t1,"cost + reward")

% 2) unexpected reward
LH = -reward_incs;
RMTg = -.8*reward_incs;
DA = 1./(1 + exp(DA_a*(-reward_incs) + LH + RMTg - DA_b));

t2 = nexttile; hold on
plot(reward_incs,LH)
plot(reward_incs,RMTg)
plot(reward_incs,DA)
hold off
xlabel("reward level")
ylabel("activity")
legend(["LHb","RMTg","reward dimension DA of SNc"])
title(t2,"unexpected reward")
