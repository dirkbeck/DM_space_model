
clear; close all


model_names = ["experimental summary","SV difference model","conflict model",...
    "PE model","space model"];


%% Cell 2015


task_names = categorical(["CC","CBC","NCB","BB"]);
experimental = [3.5 0 2.5 3];
value_model = [-.5 0 .5 1]; % difference in value mixture - choc
conflict_model = [1 -1 .9 1]; % high score = low conflict
PE_model = [-1 0 .5 1]; % difference in expected value and observed when entering maze
% rew space, rew + cost space, rew space, rew space
space_model = [1 -1 1 1];
cell2017 = [3.5 2 2.5 3];
axis_tick_labs = {'--','-','+','++'};

dat = {experimental,value_model,conflict_model,PE_model,space_model,cell2017};

for i=1:length(dat)
    heatmapdat{i} = nan(length(task_names));
    for j=1:length(task_names)
        heatmapdat{i}(j,j) = dat{i}(j);
    end
end

cmap = [1 1 1; parula(256)];
caxes = {[-.5 2.5],[-1.1 1.1],[-1.1 1.1],[-1.1 1.1],[-1.1 1.1],[-.5 2.5]};
model_names_ = [model_names, "Cell 2017"];
colormap(cmap)
tiledlayout(1,length(dat))
for i=1:length(dat)
    nexttile;
    imagesc(1:4,1:4,flipud(heatmapdat{i}));
    title(model_names_(i))
    xlabel("value, right option")
    ylabel("value, left option")
    xticks(1:4)
    yticks(1:4)
    xticklabels(axis_tick_labs)
    yticklabels(fliplr(axis_tick_labs))
    colorbar
    clim(caxes{i});
    axis square
end

%% Cell 2020


tasks_2020 = ["learned (young)","less learned (old)","unlearned"];
experimental = [2.1 -1.1; 2.1 .5; .6 .5]; % columns are rew task, cost task; rows groups
value_model = [1 -.5; .75 -.25; .3 .25];
conflict_model = [0.2 0.1; 0.2 0.1; 0.2 0.1];
PE_model = [0.2 0.1; 0.2 0.1; 0.2 0.];
% not rew space, cost space; not rew space, not cost space; reward space, not cost space
space_model = [1 -.5; 1 .5; .5 .5]; 
HD = [.4 .4; nan nan; nan nan];

dat = {experimental,value_model,conflict_model,PE_model,space_model,HD};
yaxes = {[-1.5 2.5],[-1 1],[-1 1],[-1 1],[-1 1],[-1.5 2.5]};
other_titles = ["model learned","less learned","not learned"];
titles = {tasks_2020,other_titles,other_titles,other_titles,other_titles,["HD",nan,nan]};
model_names_ = [model_names nan];

x = 0:.01:12;
curve = normpdf(x-6);

figure; tiledlayout(3,length(dat));
for i=1:length(dat)
    for j=1:length(dat{i})
        nexttile(length(dat)*(j-1)+i);
        hold on
        plot(x,dat{i}(j,1)*curve/max(curve))
        plot(x,dat{i}(j,2)*curve/max(curve))
        title([model_names_(i), titles{i}(j)])
        xline([3 9])
        xticks(0)
        xlim([x(1),x(end)])
        xlabel("time (arb. u.)")
        ylim(yaxes{i})
        ylabel("sSPN activity (arb. u.)")
        hold off
    end
end
legend(["reward trial","cost trial"],'Location','eastoutside')

%% Bloem et al 2022

% top row reward/cost encoding neurons, bottom row no reward/cost encoding neurons;
% columns are begin and end of line; cells are 1) reward, 2) puff
experimental = {[-.1 .6; .2 -.1],[0 .4; .3 -.1]};
value_model = {[1 1; 0 0],[1 1; 0 0]};
conflict_model = {[0.01 0.01; 0 0],[0.01 0.01; 0 0]};
PE_model = {[0 1; 1 0]; [0 1; 1 0]};
space_model = {[0 1; 1 0]; [0 1; 1 0]}; % signal changes from projection 
% onto neurons encdo

dat = {experimental,value_model,conflict_model,PE_model,space_model};
cols = {[0 1 0; .5 .5 .5],[1 0 0; .5 .5 .5]};
group_names = ["reward trials","cost trials"];

figure; tiledlayout(2,length(dat))
for i=1:round(length(dat))
    for j=1:2 % reward trial, cost trial
        nexttile(length(dat)*(j-1)+i); hold on
        for k=1:2
            plot([-1 1],dat{i}{j}(k,:),'color',cols{j}(k,:))
        end
        hold off
        xlabel("prediction error (arb. u.)")
        ylabel("sSPN activity (arb. u.)")
%         legend(["other sSPN","dim. encoding sSPN"])
        title(model_names(i), group_names(j))
        ylim([0 1])
    end
end


%% Xiao et al.

% cells: before learning, after. rows: reward trial, cost trial
% columns: Tshz1+ neuron spike at cue, at outcome. 
experimental = {[.5 1; .5 3],[.5 .5; 1.5 3]};
value_model = {[0.1 0.1; 0.1 1],[0.1 0.1; 0.1 1]};
conflict_model = {[0.1 0.1; 0.1 0.1],[0.1 0.1; 0.1 0.1]};
PE_model = {[0.1 0.1; .2 1], [ 0.1 0.1; 1 0]};
space_model = {[0.1 0.1; .5 1],[.1 .1; .5 1]};
dat = {experimental,value_model,conflict_model,PE_model,space_model};

t = 0:.01:8;
cue_spike = zeros(1,length(t));
cue_spike(201:400) = (cue_spike(201:400) + lognpdf(0:.01:1.99,-1,1))/max(lognpdf(0:.01:1.99,-1,1));
outcome_spike = zeros(1,length(t));
outcome_spike(401:600) = (outcome_spike(401:600) + lognpdf(0:.01:1.99,-1,1))/max(lognpdf(0:.01:1.99,-1,1));

group_names = ["beginning learning", "after learning"];

figure; tiledlayout(2,length(dat))
for i=1:length(dat)
    for j=1:2 % before, after learning
        nexttile(length(dat)*(j-1)+i); hold on
        % cost-responding
        plot(t,dat{i}{j}(1,1)*cue_spike + dat{i}{j}(1,2)*outcome_spike,'green')
        % cost-not-responding
        plot(t,dat{i}{j}(2,1)*cue_spike + dat{i}{j}(2,2)*outcome_spike,'red')
        xline(2,'--k')
        xline(4,'-k')
        hold off
        xlabel("time (arb. u.)")
        ylabel("sSPN activity")
        title(model_names(i), group_names(j))
        if i~=1
            ylim([-.2 1.2])
        end
        xlim([t(1) t(end)])
    end
end
legend(["reward","punishment","cue","outcome"])

%% Weglage et al. 2021

% rows: sSPN, D1, D2
% columns: task phases

% taken from Figure2G, right panel
% data taken from the 150ms after phase onset
experimental = [2 1 0; 15 16 16; 5 4 5; 4 3 4; 1 1 1];
value_model = [1 0 0 0 0]';
conflict_model = zeros(1,5)';
PE_model = [.3 0 0 0 0]';
space_model = [.2 .7 .05 .05 .05]';
dat = {experimental,value_model,conflict_model,PE_model,space_model};
legs = {["sSPN","","D1","","D2"],"sSPN","sSPN","sSPN","sSPN"};
ylims = {[0 20],[0 1],[0 1],[0 1],[0 1]};

cols = colororder;

figure
tiledlayout(1,length(dat))
for i=1:length(dat)
    nexttile; hold on
    for j=1:width(dat{i})
        plot(0:4,dat{i}(:,j),'Color',cols(j,:))
        scatter(0:4,dat{i}(:,j),20,'filled','MarkerFaceColor',cols(j,:))
    end
    hold off
    xlabel("task phase")
    xticks(0:5)
    xticklabels(["reward","moving","choice","moving","delay"])
    ylabel('prop. neurons excited')
    title(model_names(i))
    legend(legs{i})
    ylim(ylims{i})
end
