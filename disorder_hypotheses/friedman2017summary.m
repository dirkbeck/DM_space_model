clear; close all


% Cell 2020

tasks_2020 = ["young learned","old learned","unlearned","Huntington's"];
delta_activity = [3.1,1.6,.2,0];

figure; hold on
scatter(delta_activity,delta_activity,'k','filled')
plot(delta_activity,delta_activity,'k')
text(delta_activity,delta_activity,tasks_2020)
hold off
xlabel("Modeled difference in # components, cost trial - reward trial")
ylabel("difference in mean striosome activity, cost trial - reward trial")
xticks(0)
title("Cell 2020 summary")




% Cell 2015

tasks_2015 = ["reward only / two reward / cost and benefit nonconflict", ...
    "cost and benefit conflict"];
activity = [3.2 0];
modeled_n_components = max(activity) - activity;

figure; hold on
scatter(modeled_n_components,activity,'k','filled')
plot(modeled_n_components,activity,'k')
text(modeled_n_components,activity,tasks_2015)
hold off
xlabel("Modeled # components")
ylabel("mean striosome activity")
xticks(0)
title("Cell 2015 summary")




% Cell 2017

tasks_2017 = ["stress cost and benefit conflict", ...
    "control cost and benefit conflict"];
activity = [2.9 0];
modeled_n_components = max(activity) - activity;

figure; hold on
scatter(modeled_n_components,activity,'k','filled')
plot(modeled_n_components,activity,'k')
text(modeled_n_components,activity,tasks_2017)
hold off
xlabel("Modeled # components")
ylabel("mean striosome activity")
xticks(0)
title("Cell 2017 summary")

