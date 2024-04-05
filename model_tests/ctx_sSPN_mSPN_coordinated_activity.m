clear; close all
rng('default')

n_tstep = 100;
n_ctx = 5;
n_SPN = 3;
t = linspace(0,2*pi,n_tstep);

% create a cortex signal
evs = [2 1 .5 .2 .1*ones(1,n_ctx-4)];
input_signal = [sin(t/2)*evs(1); sin(3*t)*evs(2); cos(5*t)*evs(3); ...
    cos(2*t+1)*evs(4); sin(t+1)*evs(5)];

titles = ["mSPN, 1D DM-space","mSPN, 2D DM-space"];

figure
tiledlayout(3,1)
nexttile; hold on
plot(linspace(0,1,n_tstep),input_signal)
plot(linspace(0,1,n_tstep),sum(input_signal),'LineWidth',10,'Color','k')
hold off
title("mSPN")
ylim([-1 4])
for i=[1 2]
    ylabel("sSPN activity (arb. u.)")
    nexttile; hold on
    plot(linspace(0,1,n_tstep),input_signal(1:i,:))
    plot(linspace(0,1,n_tstep),sum(input_signal(1:i,:),1),'LineWidth',10,'Color','k')
    hold off
    title(titles(i))
    ylim([-1 4])
end
xlabel("time (arb. u.)")
ylabel("mSPN activity (arb. u.)")
legend(["dimension 1 (e.g. reward)","dimension 2 (e.g. cost)",...
    "dimension 3 (e.g. hunger)", "total activity"])

% correlation
figure
plot(0:4,[0 cumsum(evs(1:4))/sum(evs)],'-o');
xlabel("DM-space dimensionality")
ylabel("correlation, sSPN and msSPN activities")
ylim([0 1])