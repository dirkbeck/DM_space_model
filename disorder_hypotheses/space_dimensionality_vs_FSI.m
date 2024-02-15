clear; close all
addpath(fileparts(pwd))

altered_fsi_rng = linspace(0,5,100);

for i=1:100
    component_probs(:,i) = algorithmic_model(1,altered_fsi_rng(i),.1,1,0,0,5,1);
end

plot(linspace(0,1,100),component_probs')
xlabel("FSI activity")
ylabel("prob. dimension in space")
