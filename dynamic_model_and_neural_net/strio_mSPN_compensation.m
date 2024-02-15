 
clear; close all
addpath(fileparts(pwd))
cmap = actioncmap();
rng('default')

SV_b_param = 0; % documented in the first row of B
spaces = {[],1,[1 1]};
grid_size = 4; % # of plotted increments
noises = [.5 10];

% subjective value profile params
incsxy = linspace(-1,1,grid_size);
B = [-3 -3 -3 -3; 10 -10 0 0; -10 10 0 0];

% weiner process model params
n_sim = 100; 
max_ts = [1 2 5];
max_t = 2; % for incremented analysis
threshold = 1.5;
tstep = .1;


noise_titles = ["Low cortical noise","high cortical noise"];
D1_vs_D2_titles = ["non-D space","1D space","2D space"];
time_titles = ["1s","2s","5s"];

for noise_inc = 1:2 % low, then high noise
    for t_inc = 1:length(max_ts)

        % examples of low noise vs high noise and low D1 vs high D1
        
        for D1vsD2_inc=1:length(spaces) % low, then high D1 (1st 1D state, low SV; 2nd 2D state, high SV)
            action_rates_ = ...
                DMsim(B,grid_size,n_sim,incsxy,spaces{D1vsD2_inc}, ...
                noises(noise_inc),max_ts(t_inc),threshold,tstep,SV_b_param);
            action_rates{D1vsD2_inc}=action_rates_;
        end
    
        % plots
        x = incsxy; y=incsxy;
        [y1,x1]=meshgrid(y,x);
        figure
        t = tiledlayout(1,length(spaces));
        for D1vsD2_inc=1:length(spaces)
            nexttile; hold on 
            for j=1:4
                z=action_rates{D1vsD2_inc}(:,:,j);
                h(j)=CREATESTACKEDMULTIBAR3d(x1, y1, squeeze(z), ...
                    zeros(size(z)), 1, cmap(j+1,:));
            end
            hold off
            xlabel("reward (arb. u.)")
            ylabel("cost (arb. u.)")
            zlabel("prop. action")
            title(D1_vs_D2_titles(D1vsD2_inc))
            view(3)
            zlim([0 1])
            set(gcf,"Renderer",'painters')
        end
        title(t,[noise_titles(noise_inc), time_titles(t_inc)])
    
    end

    % analysis across a spectrum of # dimensions

    n_dim_incs = 0:4;
    B_incd = [B; randn(2,4)];
    
    accuracy = deal(zeros(length(n_dim_incs),1));
    
    for i=1:length(n_dim_incs)
    
        n_dim = n_dim_incs(i);
        space = ones(1,n_dim);
    
        action_rates_ = ...
                DMsim(B_incd,grid_size,n_sim,incsxy,space,...
                noises(noise_inc),max_t,threshold,tstep,SV_b_param);

        % form some metrics to plot
        frequency(i) = mean(action_rates_,'all'); 

        correct_approach_grid = tril(ones(grid_size),-1);
        incorrect_approach_grid = triu(ones(grid_size),1);
        correct_avoid_grid = incorrect_approach_grid;
        incorrect_avoid_grid = correct_avoid_grid;
        TP = sum(action_rates_(:,:,1).*correct_approach_grid,'all');
        FP = sum(action_rates_(:,:,1).*incorrect_approach_grid,'all');
        TN = sum(action_rates_(:,:,2).*correct_avoid_grid,'all');
        FN = sum(action_rates_(:,:,2).*incorrect_avoid_grid,'all');
        sensitivity(i) = TP/(TP+FN);
        specificity(i) = TN/(TN+FP);
        if isnan(sensitivity(i))
            sensitivity(i) = 0;
        end
        if isnan(specificity(i))
            specificity(i) = 1;
        end
        
    end

    figure; hold on
    plot(n_dim_incs,frequency)
    plot(n_dim_incs,sensitivity)
    plot(n_dim_incs,specificity)
    hold off
    ylabel('score')
    xlabel("space dimensionality")
    title("High reward, mid. cost choices")
    legend(["rate of choice in first 2s", ...
        "rate of turning right when SV(right) > SV(left)", ...
        "rate of avoiding turning right when SV(right) < SV(left)"])
    title(noise_titles(noise_inc))
    ylim([0 1])

end

%% functions

function action_rates = ...
    DMsim(B,grid_size,n_sim,incsxy,space,noise,max_t,threshold, ...
    tstep,SV_b_param)
    
    action_rates = zeros(grid_size,grid_size,4);
    t_dats = zeros(grid_size,grid_size,n_sim);
    x_axis = [ones(length(space)>0), zeros(1,length(space)-1)];
    y_axis = [zeros(length(space)>0), ones(length(space)>1), zeros(1,length(space)-2)];
    if ~isempty(x_axis)
        x_axis(1) = 1;
    end
    if length(y_axis) > 1
        y_axis(2) = 1;
    end
    B = B(1:1+length(space),:);

    action_values = rundecisionsimgrid(space,4,x_axis,y_axis,B,incsxy);  

    for i=1:grid_size
        for j=1:grid_size
            [t_to_decision_dat, actions_taken] = weiner_process_model(...
                squeeze(action_values(i,j,:))',noise,max_t,threshold,tstep, ...
                n_sim,SV_b_param);
            action1 = sum((actions_taken == 1) .* (t_to_decision_dat ~= max_t));
            action2 = sum((actions_taken == 2) .* (t_to_decision_dat ~= max_t));
            action3 = sum((actions_taken == 3) .* (t_to_decision_dat ~= max_t));
            action4 = sum((actions_taken == 4) .* (t_to_decision_dat ~= max_t));
            action_rates(i,j,:) = [action1 action2 action3 action4] / n_sim;
            t_to_decision_dat(t_to_decision_dat == max_t) = nan;
            t_dats(i,j,:) = t_to_decision_dat;
            
        end
    end

end

