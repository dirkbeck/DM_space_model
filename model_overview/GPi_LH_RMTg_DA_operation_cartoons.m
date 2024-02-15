clear; close all
syms x
rng('default')

rew = randn(1,2);
cost = -rew;
other1 = randn(1,2);
other2 = randn(1,2);

lims = [min([rew,cost,other1,other2]), max([rew,cost,other1,other2])];

% sSPN
figure; hold on
plot([0 rew(1)], [0 rew(2)],'g')
plot([0 cost(1)], [0 cost(2)],'r')
plot([0 other1(1)], [0 other1(2)],'k')
plot([0 other2(1)], [0 other2(2)],'k')
hold off
xlim(lims)
ylim(lims)
axis off

% GPi
comb = sum([rew;cost;other1;other2]);
figure; hold on
plot([0 rew(1)], [0 rew(2)],'--g')
plot([0 cost(1)], [0 cost(2)],'--r')
plot([0 other1(1)], [0 other1(2)],'--k')
plot([0 other2(1)], [0 other2(2)],'--k')
plot([0 comb(1)], [0 comb(2)],'k')
hold off
xlim(lims)
ylim(lims)
axis off

% LH
figure; hold on
plot([0 comb(1)], [0 comb(2)],'--k')
plot(.6*[0 comb(1)], .6*[0 comb(2)],'k')
hold off
xlim(lims)
ylim(lims)
axis off

% RMTg
figure; hold on
plot(.6*[0 comb(1)], .6*[0 comb(2)],'--k')
plot(.3*[0 comb(1)], .3*[0 comb(2)],'k')
hold off
xlim(lims)
ylim(lims)
axis off

% DA
figure
fplot(1/(1+exp(3*x)),'k')
axis off