clear; close all
addpath(fileparts(pwd))
rng('default')

% global params
n_tstep = 20;
in_space_threshold = 1;
plotted_max_t = 2;
rebound_threshold = 5; % larger leads to more time between rebounds
rebound_magnitude = 3;
default_strio_D1_weight = 1;
default_strio_D2_weight = 1;
max_DA_binding = 3;
tau = .1;

%% 1. examples of system activity over time


step_signal = [.5*ones(1,10) zeros(1,10)]; % negative indicates + value along dimension
alternating_signal = [-1*ones(1,10) 1*ones(1,10)];
input_signals = {step_signal,alternating_signal};

for in = 1:length(input_signals)

    input_signal1 = input_signals{in};
    tsteps = linspace(0,plotted_max_t,n_tstep);
    
    [~,~,sSPN_D1,sSPN_D2,DA,mSPN_D1,mSPN_D2,rebound_ts] = ...
        system_sim(input_signal1,n_tstep,rebound_threshold,...
        rebound_magnitude,in_space_threshold,default_strio_D1_weight, ...
        default_strio_D2_weight,max_DA_binding,tau);
    
    plotter(tsteps,rebound_ts,n_tstep,sSPN_D1,sSPN_D2,mSPN_D1,mSPN_D2,DA,1)

end

%% example of space switching at two levels of strio D1 and two levels of strio D2

n_ctx = 10;
n_tstep_space_switching = 100;
sigma = sprandsym(4,1,[2 2 .5 0]);
input_signal1 = mvnrnd([2 0 0 0],sigma,n_tstep_space_switching);
input_signal2 = -mvnrnd([2 0 0 0],sigma,n_tstep_space_switching);

strio_D1_weights = [1 .25];
strio_D2_weights = [1 .25];

for i=1:length(strio_D1_weights)
    for j=1:4 % dimensions
        in_space_D1_dims{i}(j,:) = ...
            system_sim(input_signal1(:,j),n_tstep_space_switching,...
            rebound_threshold,rebound_magnitude,in_space_threshold,...
            strio_D1_weights(i),default_strio_D2_weight,max_DA_binding,tau);
    end
end
for i=1:length(strio_D2_weights)
    for j=1:4 % dimensions
        [~,d2dims] = ...
            system_sim(input_signal1(:,j),n_tstep_space_switching,...
            rebound_threshold,rebound_magnitude,in_space_threshold,...
            default_strio_D1_weight,strio_D2_weights(i),max_DA_binding,tau);
        in_space_D2_dims{i}(j,:) = d2dims;
    end
end

cmap = [1 1 1; .5 .5 .5; 1 0 0; 0 1 0];
d1_titles = ["more dsSPN","less dsSPN"];
d2_titles = ["more isSPN","less isSPN"];

figure; tiledlayout(2,1)
for i=1:length(in_space_D1_dims)
    nexttile
    imagesc(linspace(0,5,n_tstep_space_switching),1:4,in_space_D1_dims{i}.*[3 2 1 1]')
    xlabel("time (s)")
    ylabel("dimensions used in direct pathway space")
    title(d1_titles(i))
    colormap(cmap)
    clim([0 3])
    set(gcf,'Renderer','painters')
end

figure; tiledlayout(2,1)
for i=1:length(in_space_D2_dims)
    nexttile
    imagesc(linspace(0,5,n_tstep_space_switching),1:4,in_space_D2_dims{i}.*[3 2 1 1]')
    xlabel("time (s)")
    ylabel("dimensions used in indirect pathway space")
    title(d2_titles(i))
    colormap(cmap)
    clim([0 3])
    set(gcf,'Renderer','painters')
end

%% effect of D1/D2 weight on strio D1 and D2

% used the cortex data from above

strio_D1_weights = linspace(0,1,10);
strio_D2_weights = linspace(0,1,10);

input_signals = {input_signal1,input_signal2};
titles = ["Reward","Absent reward"];

for sig = 1:2
    input_signal = input_signals{sig};
    
    for i=1:length(strio_D1_weights)
        [dim_in_D1_space,dim_in_D2_space] = ...
            system_sim(input_signal(:,1),n_tstep_space_switching,rebound_threshold,...
            rebound_magnitude,in_space_threshold,strio_D1_weights(i),...
            strio_D2_weights(i),max_DA_binding,tau);
        dims_in_D1_space(i) = mean(dim_in_D1_space);
        dims_in_D2_space(i) = mean(dim_in_D2_space);
    end

    figure; hold on
    plot(strio_D1_weights,dims_in_D1_space)
    plot(strio_D2_weights,dims_in_D2_space)
    hold off
    xlabel("sSPN activity (arb. u.)")
    ylabel("prob. dimension in space");
    ylim([0 1])
    legend(["direct pathway","indirect pathway"])
    title(titles(sig))
end

%% prediction errors - examples

tsteps = linspace(0,plotted_max_t,n_tstep);
PEs = [3 -3];

for i=1:length(PEs)
    input_signal1 = [1*ones(1,10) (1+PEs(i))*ones(1,10)];
    [~,~,sSPN_D1,sSPN_D2,DA,mSPN_D1,mSPN_D2,rebound_ts] = ...
            system_sim(input_signal1,n_tstep,rebound_threshold,...
            rebound_magnitude,in_space_threshold,default_strio_D1_weight, ...
            default_strio_D2_weight,max_DA_binding,tau);
    plotter(tsteps,rebound_ts,n_tstep,sSPN_D1,sSPN_D2,mSPN_D1,mSPN_D2,DA,1)
end


%% prediction error incremented (similar to Bloem et al. 2022)

PEs = linspace(-1,1,20);

[delta_sSPN_D1, delta_sSPN_D2, delta_mSPN_D1, delta_mSPN_D2] = ...
    deal(zeros(1,length(PEs)));
for i=1:length(PEs)
    input_signal1 = [ones(1,10) (1+PEs(i))*ones(1,10)];
    [~,~,sSPN_D1,sSPN_D2,DA,mSPN_D1,mSPN_D2] = ...
            system_sim(input_signal1,n_tstep,rebound_threshold,...
            rebound_magnitude,in_space_threshold,default_strio_D1_weight, ...
            default_strio_D2_weight,max_DA_binding,tau);
    delta_sSPN_D1(i) = sSPN_D1(1,end) - sSPN_D1(1,10);
    delta_sSPN_D2(i) = sSPN_D2(1,end) - sSPN_D2(1,10);
    delta_mSPN_D1(i) = mSPN_D1(1,end) - mSPN_D1(1,10);
    delta_mSPN_D2(i) = mSPN_D2(1,end) - mSPN_D2(1,10);
    delta_mSPN_D2(i) = mSPN_D2(1,end) - mSPN_D2(1,10);
    delta_DA_pop1(i) = DA{1}(1,end) - DA{1}(1,10);
    delta_DA_pop2(i) = DA{2}(1,end) - DA{2}(1,10);
end

figure('Position', [500 500 350 250]); hold on
plot(PEs,delta_sSPN_D1)
plot(PEs,delta_sSPN_D2)
plot(PEs,delta_mSPN_D1)
plot(PEs,delta_mSPN_D2)
plot(PEs,delta_DA_pop1)
plot(PEs,delta_DA_pop2)
hold off
xlabel("prediction error")
ylabel("change in sSPN activity")
legend(["sSPN D1","sSPN D2","mSPN D1", "mSPN D2","DA ensemble 1","DA ensemble 2"])

%% functions

function [dim_in_D1_space,dim_in_D2_space,sSPN_D1,sSPN_D2,DA,...
    mSPN_D1,mSPN_D2,rebound_ts] = ...
    system_sim(input_signal,n_tstep,rebound_threshold,...
    rebound_magnitude,in_space_threshold,strio_D1_weight,...
    strio_D2_weight,max_DA_binding,tau)
    
    % simulates D1 and D2 sSPN and mSPN for one dimension

    [sSPN_D1,sSPN_D2,DA_D1,DA_D2,mSPN_D1,mSPN_D2] = ...
        deal(zeros(1,n_tstep));
    DA = {DA_D1,DA_D2};
    rebound_ts = {[],[]}; % D1,D2
    rebound_counter = [0 0];
    for t=2:n_tstep
        DA{1}(t) = tau*DA{1}(t-1)-strio_D1_weight*sSPN_D1(:,t-1); % DA at synapse of D1
        DA{2}(t) = tau*DA{2}(t-1)-strio_D2_weight*sSPN_D2(:,t-1); % DA at synapse of D2
        for i=1:2 % D1, D2
            % Evans et al. rebound
            if rebound_counter(i) <= -rebound_threshold && DA{i}(t-1) > 0
                DA{i}(t) = DA{i}(t) + rebound_magnitude; % extra DA spike
                rebound_counter(i) = 0; % reset the counter
                rebound_ts{i}(end+1) = t; % record when it happened
            end
            % dopamine binds for 3 tsteps
            % set a floor (0) and a ceiling (3) for DA binding
            DA_binding{i}(t) = min(max(mean(DA{i}(max(1,t-2):t),2),0),...
                max_DA_binding);
            rebound_counter(i) = rebound_counter(i) + DA{i}(t);
        end
    
    
        sSPN_D1(t) = tau*sSPN_D1(t-1) - input_signal(t) - DA_binding{1}(t);
        sSPN_D2(t) = tau*sSPN_D1(t-1) + input_signal(t) + DA_binding{2}(t);
        mSPN_D1(t) = tau*sSPN_D1(t-1) + input_signal(t) + DA_binding{1}(t);
        mSPN_D2(t) = tau*sSPN_D1(t-1) - input_signal(t) - DA_binding{2}(t);
        
    end

    dim_in_D1_space = DA{1} > in_space_threshold;
    dim_in_D2_space = DA{2} > in_space_threshold;

end

function [] = plotter(tsteps,rebound_ts,n_tstep,sSPN_D1,sSPN_D2,....
    mSPN_D1,mSPN_D2,DA,transition_time)

    SPNs = {{sSPN_D1,mSPN_D1},{sSPN_D2,mSPN_D2}};

    ttls = ["D1","D2"];
    ylm = [-10 10];
    is_rebound = false;

    figure('Position', [500 500 350 250]);
    tiledlayout(2,1,'TileSpacing','none')    
    for i=1:2 % D1, D2
    
        rebound_start = tsteps(rebound_ts{i});
        rebound_end = tsteps(min(rebound_ts{i}+3,n_tstep));
        leg = strings(0);
        
        nexttile; hold on
        plot(tsteps,SPNs{i}{1},'Color','b')
        plot(tsteps,SPNs{i}{2},'Color','r')
        plot(tsteps,DA{i},'Color','c')
        xline(transition_time,'--')
        for k=1:length(rebound_start)
            fill([rebound_start(k) rebound_end(k) rebound_end(k) rebound_start(k)], ...
                [ylm(1) ylm(1) ylm(2) ylm(2)],[.9 .9 .9])
            is_rebound = true;
        end
        hold off
        xlim([0 tsteps(end)])
        xlabel("time (s)")
        ylabel("activity")
        title(ttls(i))
        ylim(ylm)
    end

    hL = legend(["sSPN","mSPN","SNc DA"]);
    hL.Layout.Tile = 'east';

end