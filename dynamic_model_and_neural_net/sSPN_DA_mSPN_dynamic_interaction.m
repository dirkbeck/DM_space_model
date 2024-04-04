clear; close all
addpath(fileparts(pwd))
rng('default')

% global params
n_tstep = 5001;
in_space_threshold = .75;
tau = 1;
z_da = 0;
w_SNc_dsSPN = 5;
w_SNc_isSPN = 5;
w_SNc_dmSPN = 5;
w_SNc_imSPN = 5;
stp_constant = .01;

%% example of space switching at two levels of dopamine

t = linspace(0,20*pi,n_tstep);
input_signal1 = [2 1 -2 -2] + [sin(t)' cos(t)' sin(2*t)' cos(2*t)'];
w_SNc_dsSPNs = [10 0];
w_SNc_isSPNs = [10 0];

for i=1:2
    for j=1:4 % dimensions
        [in_space_D1_dims{i}(j,:),in_space_D2_dims{i}(j,:)] = ...
            system_sim(input_signal1(:,j),n_tstep,in_space_threshold, ...
            z_da,w_SNc_dsSPNs(i),w_SNc_isSPNs(i),...
            w_SNc_dmSPN,w_SNc_imSPN,tau,stp_constant);
    end
end

cmap = [1 1 1; 1 .5 0; 0 0 1; 1 0 0; 0 1 0];
titles = ["more dopamine","less dopamine"];

figure; tiledlayout(2,1)
for i=1:length(in_space_D1_dims)
    nexttile
    imagesc(linspace(0,5,n_tstep),1:4,in_space_D1_dims{i}.*[4 3 2 1]')
    xlabel("time (s)")
    ylabel("dimensions used in direct pathway space")
    title(titles(i))
    colormap(cmap)
    clim([0 4])
    set(gcf,'Renderer','painters')
    yticklabels('')
end

figure; tiledlayout(2,1)
for i=1:length(in_space_D2_dims)
    nexttile
    imagesc(linspace(0,5,n_tstep),1:4,in_space_D2_dims{i}.*[4 3 2 1]')
    xlabel("time (s)")
    ylabel("dimensions used in indirect pathway space")
    title(titles(i))
    colormap(cmap)
    clim([0 4])
    set(gcf,'Renderer','painters')
    yticklabels('')
end

input_plot(input_signal1,cmap)

%% effect of D1/D2 weight on strio D1 and D2

% used the cortex data from above

w_SNc_SPNs = linspace(0,10,100);

for i=1:length(w_SNc_SPNs)
    for j=1:4
        % sSPN
        [dim_in_D1_space,dim_in_D2_space] = ...
            system_sim(input_signal1(:,j),n_tstep,in_space_threshold, ...
            z_da,w_SNc_SPNs(i),w_SNc_SPNs(i),...
            w_SNc_dmSPN,w_SNc_imSPN,tau,stp_constant);
        dims_in_D1_space(i,j) = mean(dim_in_D1_space);
        dims_in_D2_space(i,j) = mean(dim_in_D2_space);

        % mSPN
        [~,~,~,~,m_d,m_i] = ...
            system_sim(input_signal1(:,j),n_tstep,in_space_threshold, ...
            z_da,w_SNc_dsSPN,w_SNc_isSPN,...
            w_SNc_SPNs(i),w_SNc_SPNs(i),tau,stp_constant);

        m_ds(j,:) = m_d;
        m_is(j,:) = m_i;
    end
    % assume that all in-space dimensions equally affect AV
    D1_AVs = 1./(1+exp(-m_ds(1,:)));
    D2_AVs = 1./(1+exp(-m_is(4,:)));
    D1_space_dimensionality(i) = sum(dims_in_D1_space(i,:));
    D2_space_dimensionality(i) = sum(dims_in_D2_space(i,:));
    D1_AV(i) = mean(D1_AVs);
    D2_AV(i) = mean(D2_AVs);
end

% Striosome space
figure; hold on
plot(w_SNc_SPNs,D1_space_dimensionality)
plot(w_SNc_SPNs,D2_space_dimensionality)
hold off
xlabel("daSNC->sSPN weight (arb. u.)")
ylabel("av. DM-space dimensionality");
ylim([0 2])
legend(["direct pathway","indirect pathway"])

% Matrix subjective value
figure; hold on
plot(w_SNc_SPNs,D1_AV)
plot(w_SNc_SPNs,D2_AV)
hold off
xlabel("daSNC->mSPN weight (arb. u.)")
ylabel("av. action value");
legend(["direct pathway","indirect pathway"])

%% examples of system response


positive_prediction_error = [10*ones(1,(n_tstep-1)/2),20*ones(1,(n_tstep-1)/2+1)];
negative_prediction_error = [10*ones(1,(n_tstep-1)/2),0*ones(1,(n_tstep-1)/2+1)];
ramping = .5*ones(1,n_tstep);
input_signals = {positive_prediction_error,negative_prediction_error,ramping};
maxys = [20 20 1];

for in = 1:length(input_signals)
    input_signal = input_signals{in};
    tsteps = linspace(0,5,n_tstep);
    [dim_in_D1_space,dim_in_D2_space,s_d,s_i,m_d,m_i] = ...
            system_sim(input_signal,n_tstep,in_space_threshold, ...
            z_da,w_SNc_dsSPN,w_SNc_isSPN,...
            w_SNc_dmSPN,w_SNc_imSPN,tau,stp_constant);
    figure; hold on
    plot(linspace(0,5,n_tstep),s_d)
    plot(linspace(0,5,n_tstep),s_i)
    plot(linspace(0,5,n_tstep),m_d)
    plot(linspace(0,5,n_tstep),m_i)
    hold off
    xlabel("time (s)")
    ylabel("activity (arb. u.)")
    legend(["dsSPN","isSPN","dmSPN","imSPN"]);

    input_plot(input_signal',cmap)
    ylim([0 maxys(in)])

end

%% prediction error incremented (similar to Bloem et al. 2022)

PEs = linspace(-1,1,21);

[delta_sSPN_D1, delta_sSPN_D2, delta_mSPN_D1, delta_mSPN_D2] = ...
    deal(zeros(1,length(PEs)));
for i=1:length(PEs)
    input_signal = 10*[ones(1,(n_tstep-1)/2),ones(1,(n_tstep-1)/2+1)+PEs(i)];
    [dim_in_D1_space,dim_in_D2_space,s_d,s_i,m_d,m_i] = ...
            system_sim(input_signal,n_tstep,in_space_threshold, ...
            z_da,w_SNc_dsSPN,w_SNc_isSPN,...
            w_SNc_dmSPN,w_SNc_imSPN,tau,stp_constant);
    delta_sSPN_D1(i) = s_d((n_tstep-1)/2) - s_d(end);
    delta_sSPN_D2(i) = s_i((n_tstep-1)/2) - s_i(end);
    delta_mSPN_D1(i) = m_d((n_tstep-1)/2) - m_d(end);
    delta_mSPN_D2(i) = m_i((n_tstep-1)/2) - m_i(end);
end

figure; hold on
plot(PEs,delta_sSPN_D1)
plot(PEs,delta_sSPN_D2)
plot(PEs,delta_mSPN_D1)
plot(PEs,delta_mSPN_D2)
hold off
xlabel("prediction error")
ylabel("change in sSPN activity")
legend(["sSPN D1","sSPN D2","mSPN D1", "mSPN D2"])
 

%% Examples of with vs. without rebound

input_signal = 10*[ones(1,(n_tstep-1)*1/4) zeros(1,(n_tstep-1)*3/4); ...
                zeros(1,(n_tstep-1)/4) ones(1,(n_tstep-1)*1/4) zeros(1,(n_tstep-1)*2/4); ...
                zeros(1,(n_tstep-1)/2) ones(1,(n_tstep-1)*1/4) zeros(1,(n_tstep-1)/4); ...
                zeros(1,(n_tstep-1)*3/4),ones(1,(n_tstep-1)/4)]';
stp_constants = [0 .1];

for i=1:length(stp_constants)
    for j=1:4 % dimensions
        dims_in_space{i}(j,:) = ...
            system_sim(input_signal(:,j),n_tstep,in_space_threshold, ...
            z_da,w_SNc_dsSPN,w_SNc_isSPN,...
            w_SNc_dmSPN,w_SNc_imSPN,tau,stp_constants(i));
    end
end

titles = ["no rebound","rebound"];

figure; tiledlayout(2,1)
for i=1:length(dims_in_space)
    nexttile
    imagesc(linspace(0,5,n_tstep),1:4,dims_in_space{i}.*[4 3 2 1]')
    xlabel("time (s)")
    ylabel("dimensions used in direct pathway space")
    title(titles(i))
    colormap(cmap)
    clim([0 4])
    set(gcf,'Renderer','painters')
    yticklabels('')
end

input_plot(input_signal,cmap)

%% functions

function [dim_in_D1_space,dim_in_D2_space,s_d,s_i,m_d,m_i,w_dsSPN_SNc,w_isSPN_SNc] = ...
    system_sim(input_signal,n_tstep,in_space_threshold,z_da,w_SNc_dsSPN, ...
    w_SNc_isSPN,w_SNc_dmSPN, w_SNc_imSPN,tau,stp_constant)
    
    t=linspace(0,5,n_tstep);
    del_t = t(2)-t(1);

    [s_d,s_i,m_d,m_i,w_dsSPN_SNc,w_isSPN_SNc,y_d,y_i] = deal(zeros(n_tstep,1));
    s_d(1) = 0;
    s_i(1) = 0;
    m_d(1) = 0;
    m_i(1) = 0;
    w_dsSPN_SNc(1) = 1;
    w_isSPN_SNc(1) = 1;
    
    for i=2:n_tstep
        
        y_d(i) = 1/(1+exp(w_dsSPN_SNc(i-1)*s_d(i-1)-z_da));
        y_i(i) = 1/(1+exp(w_isSPN_SNc(i-1)*s_i(i-1)-z_da));
        loop_back(i) = -w_SNc_dsSPN*(y_d(i) - 1/2);
        dsd_dt = -s_d(i-1) - input_signal(i-1) - w_SNc_dsSPN*(y_d(i) - 1/2);
        dsi_dt = -s_i(i-1) + input_signal(i-1) + w_SNc_isSPN*(y_i(i) - 1/2);
        dmd_dt = -m_d(i-1) + input_signal(i-1) + w_SNc_dmSPN*(y_d(i) - 1/2);
        dmi_dt = -m_i(i-1) - input_signal(i-1) - w_SNc_imSPN*(y_i(i) - 1/2);
        dw_dsSPN_SNc_dt = stp_constant * s_d(i-1);
        dw_isSPN_SNc_dt = stp_constant * s_i(i-1);
        
        s_d(i) = s_d(i-1) + tau*dsd_dt*del_t;
        s_i(i) = s_i(i-1) + tau*dsi_dt*del_t;
        m_d(i) = m_d(i-1) + tau*dmd_dt*del_t;
        m_i(i) = m_i(i-1) + tau*dmi_dt*del_t;
        w_dsSPN_SNc(i) = w_dsSPN_SNc(i-1) + dw_dsSPN_SNc_dt*del_t;
        w_isSPN_SNc(i) = w_isSPN_SNc(i-1) + dw_isSPN_SNc_dt*del_t;

    end

    dim_in_D1_space = y_d > in_space_threshold;
    dim_in_D2_space = y_i > in_space_threshold;

end

function [] = input_plot(input_signal,cmap)
    figure; hold on
    for i=1:width(input_signal)
        plot(linspace(0,5,length(input_signal)),input_signal(:,i),...
            'Color',cmap(6-i,:));
    end
    hold off
    xlabel("time (s)")
    ylabel("system input")
end
