clear; close all

GPi_dim_combination_rules = .2*[1 1 1 1];

ttls = ["lesioned LHb","stimulated LHb","control"];
LH_additions = [-5 5 .5];


%% two examples

for i=1:3

sSPN = -[1 0 -3 -3];
GPi = sSPN-sum(GPi_dim_combination_rules.*sSPN);
LH = GPi+LH_additions(i)+.5;
RMTg = LH+.5;
DA = RMTg-1;

dat = [in_spaceness(sSPN)' in_spaceness(GPi)' in_spaceness(LH)' ...
    in_spaceness(RMTg)' in_spaceness(DA)'];

green_cols = [linspace(1,0,100)' linspace(1,1,100)' linspace(1,0,100)'];
red_cols = [linspace(1,1,100)' linspace(1,0,100)' linspace(1,0,100)'];
black_cols = [linspace(1,0,100)' linspace(1,0,100)' linspace(1,0,100)'];

figure
t = tiledlayout(4,1,'TileSpacing','none');
t1 = nexttile;
imagesc(1:5,1,dat(1,:));
colormap(t1,green_cols)
xticks('')
yticks('')
ylabel("dim. 1 (e.g. reward)")
clim([0 1])
t2 = nexttile;
imagesc(1:5,2,dat(2,:));
colormap(t2,red_cols)
xticks('')
yticks('')
ylabel("dim. 2 (e.g. cost)")
clim([0 1])
t3 = nexttile;
imagesc(1:5,3,dat(3,:));
colormap(t3,black_cols)
xticks('')
yticks(1:4)
ylabel("dim. 3")
clim([0 1])
yticks('')
t4 = nexttile;
imagesc(1:5,4,dat(4,:));
colormap(t4,black_cols)
xticks(1:5)
ylabel("dim. 4")
yticks('')
clim([0 1])
xticklabels(["sSPN","GPi","LHb","RMTg","DA of SNc (final space)"])
title(t,ttls(i))
colorbar

end

%% now incremented across ranges
n_inc = 100;
incs = linspace(0,1,n_inc);
for i=1:n_inc
    GPi_dims(i,:) = in_spaceness(sSPN-...
        sum(incs(i)*GPi_dim_combination_rules.*sSPN));
    LH_dims(i,:) = in_spaceness(GPi+incs(i)+.5);
    RMTg_dims(i,:) = in_spaceness(LH+incs(i)+.5);
end

figure; hold on
plot(incs,4*GPi_dims(:,2))
plot(incs,4*LH_dims(:,2))
plot(incs,4*RMTg_dims(:,2))
hold off
legend(["GPi","LH","RMTg"])
xlabel("activity (arb. u.)")
ylabel("av. dec.-dims used")
ylim([0 4])

%% functions

function prob_in_space = in_spaceness(signal)
    prob_in_space = 1./(1+exp(signal-1));
end