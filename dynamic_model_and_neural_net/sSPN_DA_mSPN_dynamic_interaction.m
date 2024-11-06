clear; close all
addpath(fileparts(pwd))
rng('default')

% global params
n_tstep = 5001;
in_space_threshold = 1;
tau = 1;
z_da = 0;
w_SNc_dsSPN = 5;
w_SNc_isSPN = 5;
w_SNc_dmSPN = 5;
w_SNc_imSPN = 5;
stp_constant = -.01;
compartment_addition = [0 0 0 0];

%% example of space switching when each compartment is stimulated

t = linspace(0,20*pi,n_tstep);
input_signal1 = [2 1 0 0] + [sin(t)' cos(t)' sin(2*t)' cos(2*t)'];
addition_incs = linspace(-1,1,100);

for i=1:length(addition_incs)
    for j=1:4 % dimensions
        [dim_in_D1_space,dim_in_D2_space] = ...
            system_sim(input_signal1(:,j),n_tstep,in_space_threshold, ...
            z_da,w_SNc_dsSPN,w_SNc_isSPN,...
            w_SNc_dmSPN,w_SNc_imSPN,tau,stp_constant, ...
            [addition_incs(i),addition_incs(i),0,0]);
        dims_in_D1_space(i,j) = mean(dim_in_D1_space);
        dims_in_D2_space(i,j) = mean(dim_in_D2_space);
    end
end

cmap = [1 1 1; 1 .5 0; 0 0 1; 1 0 0; 0 1 0];
titles = ["high sSPN","high mSPN","control"];

figure; hold on
plot(addition_incs,4*mean(dims_in_D1_space,2))
plot(addition_incs,4*mean(dims_in_D2_space,2))
hold off
xlabel("sSPN activity (arb. u.)")
ylabel("av. dec.-space dimensionality");
ylim([0 4])
legend(["direct pathway","indirect pathway"])

%% effect of dopamine on decision-space

% used the cortex data from above

z_das = linspace(-1,1,100);

for i=1:length(z_das)
    for j=1:4
        % sSPN
        [dim_in_D1_space,dim_in_D2_space] = ...
            system_sim(input_signal1(:,j),n_tstep,in_space_threshold, ...
            z_das(i),w_SNc_dsSPN,w_SNc_isSPN,...
            w_SNc_dmSPN,w_SNc_imSPN,tau,stp_constant,compartment_addition);
        dims_in_D1_space(i,j) = mean(dim_in_D1_space);
        dims_in_D2_space(i,j) = mean(dim_in_D2_space);
    end
end

figure; hold on
plot(z_das,4*mean(dims_in_D1_space,2))
plot(z_das,4*mean(dims_in_D2_space,2))
hold off
xlabel("daSNC activity (arb. u.)")
ylabel("av. dec.-space dimensionality");
ylim([0 4])
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
            w_SNc_dmSPN,w_SNc_imSPN,tau,stp_constant,compartment_addition);
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
            w_SNc_dmSPN,w_SNc_imSPN,tau,stp_constant,compartment_addition);
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

input_signal = 10*[ones(1,(n_tstep-1)*1/4-100) zeros(1,(n_tstep-1)*3/4+100); ...
                zeros(1,(n_tstep-1)/4) ones(1,(n_tstep-1)*1/4-100) zeros(1,(n_tstep-1)*2/4+100); ...
                zeros(1,(n_tstep-1)/2) ones(1,(n_tstep-1)*1/4-100) zeros(1,(n_tstep-1)/4+100); ...
                zeros(1,(n_tstep-1)*3/4),ones(1,(n_tstep-1)/4)]';
stp_constants = [0 -.1];

for i=1:length(stp_constants)
    for j=1:4 % dimensions
        dims_in_space{i}(j,:) = ...
            system_sim(input_signal(:,j),n_tstep,in_space_threshold, ...
            z_da,w_SNc_dsSPN,w_SNc_isSPN,...
            w_SNc_dmSPN,w_SNc_imSPN,tau,stp_constants(i),compartment_addition);
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
    w_SNc_isSPN,w_SNc_dmSPN, w_SNc_imSPN,tau,stp_constant,compartment_addition)
    
    t=linspace(0,5,n_tstep);
    del_t = t(2)-t(1);

    [s_d,s_i,m_d,m_i,w_dsSPN_SNc,y_d,y_i] = deal(zeros(n_tstep,1));
    s_d(1) = 0;
    s_i(1) = 0;
    m_d(1) = 0;
    m_i(1) = 0;
    w_dsSPN_SNc(1) = -1; % inhibitory connection
    w_isSPN_SNc = ones(1,n_tstep); % double inhibitory though GPe
    
    for i=2:n_tstep
        
        y_d(i) = 1/(1+exp(-w_dsSPN_SNc(i-1)*s_d(i-1)-z_da));
        y_i(i) = 1/(1+exp(-w_isSPN_SNc(i-1)*s_i(i-1)-z_da));
        dsd_dt = -s_d(i-1) - input_signal(i-1) + compartment_addition(1) - w_SNc_dsSPN*(y_d(i) - 1/2);
        dsi_dt = -s_i(i-1) - input_signal(i-1) + compartment_addition(2) + w_SNc_isSPN*(y_i(i) - 1/2);
        dmd_dt = -m_d(i-1) + input_signal(i-1) + compartment_addition(3) + w_SNc_dmSPN*(y_d(i) - 1/2);
        dmi_dt = -m_i(i-1) + input_signal(i-1) + compartment_addition(4) - w_SNc_imSPN*(y_i(i) - 1/2);
        dw_dsSPN_SNc_dt = stp_constant * s_d(i-1);
        
        s_d(i) = s_d(i-1) + tau*dsd_dt*del_t;
        s_i(i) = s_i(i-1) + tau*dsi_dt*del_t;
        m_d(i) = m_d(i-1) + tau*dmd_dt*del_t;
        m_i(i) = m_i(i-1) + tau*dmi_dt*del_t;
        w_dsSPN_SNc(i) = w_dsSPN_SNc(i-1) + dw_dsSPN_SNc_dt*del_t;

    end

    dim_in_D1_space = m_d > in_space_threshold;
    dim_in_D2_space = m_i > in_space_threshold;

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
