clear; close all

t = 0:.1:pi;
x = linspace(0,1,length(t)+20); % arb time units

reward_signal1 = .8*[zeros(1,10) sin(t) zeros(1,10)];
reward_signal2 = .1*[zeros(1,10) sin(t) zeros(1,10)];
cost_signal1 = -.5*[zeros(1,10) sin(t) zeros(1,10)];
cost_signal2 = -1*[zeros(1,10) sin(t) zeros(1,10)];

GPi_signal1 = -(reward_signal1 + cost_signal1);
GPi_signal2 = -(reward_signal2 + cost_signal2);

figure
tiledlayout(2,2)

nexttile; hold on
plot(x,reward_signal1)
plot(x,cost_signal1)
hold off
legend(["reward","cost"])
title("sSPN signal 1")
xlabel("time (arb. u.)")
ylabel("activity (arb. u.)")
ylim([-1 1])

nexttile
plot(x,GPi_signal1)
title("GPi response 1")
xlabel("time (arb. u.)")
ylabel("activity (arb. u.)")
ylim([-1 1])

nexttile; hold on
plot(x,reward_signal2)
plot(x,cost_signal2)
hold off
legend(["reward","cost"])
title("sSPN signal 2")
xlabel("time (arb. u.)")
ylabel("activity (arb. u.)")
ylim([-1 1])

nexttile
plot(x,GPi_signal2)
title("GPi response 2")
xlabel("time (arb. u.)")
ylabel("activity (arb. u.)")
ylim([-1 1])

