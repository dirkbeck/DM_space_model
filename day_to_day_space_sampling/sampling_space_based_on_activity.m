clear; close all
rng('default')
addpath(fileparts(pwd))

% plot the ranges of circuit configurations that are best for achieving
% different spaces (i.e. have the highest advantage)
% comorbidity is related to the overlap in configurations that produce
% different spaces

n_interp_inc = 10;
spaces = dec2bin(0:16-1)' - '0';

max_activity = 5;
[strio_incs,lh_incs,da_incs] = deal(linspace(0,max_activity,n_interp_inc));
[baseline_strio, baseline_LH, baseline_DA] = deal(max_activity/2);

% find the the advantages by space

for j=1:16
    individual_space_advantage_coefs = zeros(16,1);
    % for this loop, only this space is valued
    individual_space_advantage_coefs(j) = 1; 
    advantages{j} = ...
        get_advantage_and_cost_grids(strio_incs,lh_incs,da_incs,...
        individual_space_advantage_coefs,baseline_strio,baseline_LH,baseline_DA);
end

plotter(advantages,strio_incs,lh_incs,da_incs)

%% functions

function [advantages,costs,net_advantages] = ...
    get_advantage_and_cost_grids(strio_incs,lh_incs,da_incs,...
    space_advantage_coefs,baseline_strio,baseline_LH,baseline_DA)
    
    [net_advantages,costs,advantages] = ...
        deal(zeros(length(strio_incs),length(lh_incs),length(da_incs)));
    spaces = (dec2bin(0:2^4-1)' - '0')';

    for i=1:length(strio_incs)
        for j=1:length(lh_incs)
            for k=1:length(da_incs)
    
                strio = strio_incs(i);
                lh = lh_incs(j);
                da = da_incs(k);
                    
                advantage = calculate_circuit_configuration_advantage(...
                    space_advantage_coefs,spaces,strio,1,1,lh,.5,da);
                cost = calculate_circuit_configuration_cost(1,strio,1,lh,...
                    .75,da,1,baseline_strio,1,baseline_LH,.75, baseline_DA);
                net_advantages(i,j) = advantage - cost;
        
                advantages(i,j,k) = advantage;
                costs(i,j,k) = cost;

            end
        end
    end

end


function [] = plotter(advantages,strio_incs,...
    lh_incs,da_incs)
    
    sampled_points_per_space = 10;

    unique_complexities_indx = [1 2 4 9 16];

    for i=1:5
        advantages_i = advantages{unique_complexities_indx(i)};

        % choose some arbitrary points and use them based on their
        % probability
        strio_indxs{i} = datasample(1:length(strio_incs),sampled_points_per_space);
        lh_indxs{i} = datasample(1:length(lh_incs),sampled_points_per_space);
        da_indxs{i} = datasample(1:length(da_incs),sampled_points_per_space);

        for j=1:sampled_points_per_space
            example_advantage_i(j) = advantages_i(strio_indxs{i}(j),lh_indxs{i}(j),da_indxs{i}(j));
            if example_advantage_i(j) > rand
                % remove point if it doesn't appear probabilistically
                strio_indxs{i}(j) = nan;
                lh_indxs{i}(j) = nan;
                da_indxs{i}(j) = nan;
            end
        end
        example_advantage{i} = example_advantage_i;
    end

    % bubble plot
    figure; tiledlayout(1,2)
    nexttile
    hold on
    for i=1:5
        scatter3(strio_indxs{i},lh_indxs{i},da_indxs{i},300*example_advantage{i},'filled')
    end
    hold off
    xlabel("sSPN activity (arb. u.)")
    ylabel("LHb activity (arb. u.)")
    zlabel("DA of SNc activity (arb. u.)")
    title("Circuit configurations where spaces with " + ...
        "different # components are acheived");
    subtitle("size = probability achieved at that configuration")
    view(3)
    legend(["space not formed","1D space","2D","3D","4D"])
    set(gcf,'renderer','painters');

    % for legend
    nexttile
    scatter3([1 1],[1 1],1:2,300*[.1 .5],'filled')
    title("probability in space = .1,1")

    % edges plot
    cols = colororder;
    figure; hold on
    for i=1:5
        P = rmmissing([strio_indxs{i}' lh_indxs{i}' da_indxs{i}']);
        k = boundary(P);
        trisurf(k,P(:,1),P(:,2),P(:,3),'Facecolor',cols(i,:))
    end
    hold off
    xlabel("striosome activity")
    ylabel("lh activity")
    zlabel("da activity")
    title("Boundary around the configurations that produced spaces")
    view(3)
    legend(["space not formed","1D space","2D","3D","4D"])
    set(gcf,'renderer','painters');

end
