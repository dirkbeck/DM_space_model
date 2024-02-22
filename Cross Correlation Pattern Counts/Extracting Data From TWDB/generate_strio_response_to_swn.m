%% The script generates figures that show the response of striosomes to
%  SWN bursts.

all_ids = {cb_plNotS_ids,cb_pls_ids,cb_strio_ids,cb_matrix_ids,cb_hfn_ids,cb_swn_ids};
%% First, find all possible pairs of striosomes and SWNs
hfn_strio_pairs = cell(1,length(dbs));
to_plot = false;
comparison_type = 'SWNs to Striosomes';
for db = 1:length(dbs)
    hfn_strio_pairs{db} = pair_counting(twdbs{db},all_ids{6}{db},all_ids{3}{db}, to_plot);
end

%% Find time delays
min_ISIs_per_neuron = 15;
min_time = -2.5; max_time = 3;
method_hfn = 'Tim';
method_strio = 'Tim';
debug_thresholds = false;

min_delay = .004; max_delay = 1.5;
normalization = 'zscore';
debug_delays = false;
inhib_times = cell(1,length(dbs));
phasic_FR_pairs = cell(1,length(dbs));
tonic_FR_pairs = cell(1,length(dbs));
min_num_inhib_times = 10;

f1 = figure;
f2 = figure;

for db = 1:length(dbs)
    inhib_times{db} = cell(1,size(hfn_strio_pairs{db},1));
    phasic_FR_pairs{db} = cell(1,size(hfn_strio_pairs{db},1));
    tonic_FR_pairs{db} = cell(1,size(hfn_strio_pairs{db},1));
    skipped_pairs = [];
    
    for pair_num = 1:size(hfn_strio_pairs{db},1)
        disp([db pair_num pair_num/size(hfn_strio_pairs{db},1)]);
        % Get pair ids
        hfn_id = hfn_strio_pairs{db}(pair_num,1);
        strio_id = hfn_strio_pairs{db}(pair_num,2);
        
        % Get pair spikes and ah bursts
        hfn_spikes = twdbs{db}(hfn_id).trial_spikes;    hfn_ah_bursts = twdbs{db}(hfn_id).trial_bursts;
        strio_spikes = twdbs{db}(strio_id).trial_spikes;strio_ah_bursts = twdbs{db}(strio_id).trial_bursts;
        
        % Find bursts
        smooth_factor = 3; % For finding thresholds
        hfn_bursts = find_phasic_periods(hfn_spikes, smooth_factor, min_ISIs_per_neuron, min_time, max_time, hfn_ah_bursts, method_hfn, debug_thresholds);
        strio_bursts = find_phasic_periods(strio_spikes, smooth_factor, min_ISIs_per_neuron, min_time, max_time, strio_ah_bursts, method_strio, debug_thresholds);

        if ~iscell(hfn_bursts)
            skipped_pairs = [skipped_pairs, pair_num];
            continue
        end
        
        [inhib_times{db}{pair_num}, phasic_FR_pairs{db}{pair_num}, tonic_FR_pairs{db}{pair_num}] = find_phasic_time_delays_inhib(hfn_spikes, strio_spikes, hfn_bursts, strio_bursts, ...
                                                min_delay, max_delay, min_time, max_time, normalization, debug_delays);
                                            
    end
    disp(length(skipped_pairs));
    skipped_pairs = unique([skipped_pairs, find(cellfun(@(x) length(x) < min_num_inhib_times,inhib_times{db}))]);
    disp(length(skipped_pairs));
    phasic_FR_pairs{db}(skipped_pairs) = [];
    tonic_FR_pairs{db}(skipped_pairs) = [];
    inhib_times{db}(skipped_pairs) = [];
    hfn_strio_pairs{db}(skipped_pairs,:) = [];
end

%% Determine if burst activity of SWNs significantly influence the activity of striosomes
sig_inhib_pair_nums = cell(1,length(dbs));
for db = 1:length(dbs)
    for pair_num = 1:size(hfn_strio_pairs{db},1)
        [~,p]=ttest2(phasic_FR_pairs{db}{pair_num}(:,2), tonic_FR_pairs{db}{pair_num}(:,2));
                
        if p < .05
            sig_inhib_pair_nums{db} = [sig_inhib_pair_nums{db}, pair_num];
        end
    end
end

f = figure;
[~,p] = chi2test(length(sig_inhib_pair_nums{1}),size(hfn_strio_pairs{1},1),...
                length(sig_inhib_pair_nums{2}),size(hfn_strio_pairs{2},1),...
                length(sig_inhib_pair_nums{3}),size(hfn_strio_pairs{3},1));
bar(arrayfun(@(x) length(sig_inhib_pair_nums{x})/size(hfn_strio_pairs{x},1), 1:length(dbs)));
strs = {'Control', 'Stress', 'Stress2'};
set(gca, 'XTickLabel',strs, 'XTick',1:numel(strs));
xlabel('Experimental Group'); ylabel('Proportion of Inhibited Pairs');
title(['Chi Square Test p = ' num2str(p)]);
text(1-.2, length(sig_inhib_pair_nums{1})/size(hfn_strio_pairs{1},1)+.05,[num2str(length(sig_inhib_pair_nums{1})) '/' num2str(size(hfn_strio_pairs{1},1))]);
text(2-.2, length(sig_inhib_pair_nums{2})/size(hfn_strio_pairs{2},1)+.05,[num2str(length(sig_inhib_pair_nums{2})) '/' num2str(size(hfn_strio_pairs{2},1))]);
text(3-.2, length(sig_inhib_pair_nums{3})/size(hfn_strio_pairs{3},1)+.05,[num2str(length(sig_inhib_pair_nums{3})) '/' num2str(size(hfn_strio_pairs{3},1))]);
ylim([0 max(arrayfun(@(x) length(sig_inhib_pair_nums{x})/size(hfn_strio_pairs{x},1), 1:length(dbs)))+.1])

fig_dir = [ROOT_DIR 'Correlation Using Phasic Activity/' comparison_type '/'];
if ~exist(fig_dir,'dir')
    mkdir(fig_dir);
end
saveas(f, [fig_dir 'Proportion of Inhibited Pairs'], 'fig');
saveas(f, [fig_dir 'Proportion of Inhibited Pairs'], 'epsc2');
saveas(f, [fig_dir 'Proportion of Inhibited Pairs'], 'jpg');

%% Firing rate of SWN to firing rate of striosome comparison for significant pairs (population analysis)
all_tonic_FR_pairs = cell(1,length(dbs));
all_inhib_times = cell(1,length(dbs));
for db = 1:length(dbs)
    for pair_num = sig_inhib_pair_nums{db}
        all_tonic_FR_pairs{db} = [all_tonic_FR_pairs{db}; tonic_FR_pairs{db}{pair_num}];
        all_inhib_times{db} = [all_inhib_times{db}; phasic_FR_pairs{db}{pair_num}];
    end
end

% HFN FR bins for graphs
f = figure;
all_tonic_hfn_FRs = (cell2mat(cellfun(@(x) x(:,1)',all_tonic_FR_pairs,'uni',false)));
tonic_hfn_FR_bins = prctile(all_tonic_hfn_FRs(all_tonic_hfn_FRs<25), 0:25:100);
all_phasic_hfn_FRs = (cell2mat(cellfun(@(x) x(:,1)',all_inhib_times,'uni',false)));
phasic_hfn_FR_bins = prctile(all_phasic_hfn_FRs(all_phasic_hfn_FRs<100), 0:20:100);
min_per_bin = 15;
subplot_idxs = [1,3,4];
for db = 1:length(dbs)
    subplot(2,2,subplot_idxs(db));
    tonic_hfn_FRs = (all_tonic_FR_pairs{db}(:,1));
    tonic_strio_FRs = all_tonic_FR_pairs{db}(:,2);
    phasic_hfn_FRs = (all_inhib_times{db}(:,1));
    phasic_strio_FRs = all_inhib_times{db}(:,2);
    
    [~,~,tonic_strio_FR_bins] = histcounts(tonic_hfn_FRs,tonic_hfn_FR_bins);
    tonic_strio_FR_means = [];
    for bin_num = 1:max(tonic_strio_FR_bins)
        if sum (tonic_strio_FR_bins == bin_num) >= min_per_bin
            tonic_strio_FR_means = [tonic_strio_FR_means, mean(tonic_strio_FRs(tonic_strio_FR_bins == bin_num))];
        else
            tonic_strio_FR_means = [tonic_strio_FR_means, NaN];
        end
    end
    
    [~,~,phasic_strio_FR_bins] = histcounts(phasic_hfn_FRs,phasic_hfn_FR_bins);
    phasic_strio_FR_means = [];
    for bin_num = 1:max(phasic_strio_FR_bins)
        if sum(phasic_strio_FR_bins == bin_num) >= min_per_bin
            phasic_strio_FR_means = [phasic_strio_FR_means, mean(phasic_strio_FRs(phasic_strio_FR_bins == bin_num))];
        else
            phasic_strio_FR_means = [phasic_strio_FR_means, NaN];
        end
    end
    
    hold on;
    tonic_hfn_FR_bin_centers = (tonic_hfn_FR_bins(1:end-1) + tonic_hfn_FR_bins(2:end)) / 2;
    tonic_hfn_FR_bin_centers = tonic_hfn_FR_bin_centers(~isnan(tonic_strio_FR_means));
    tonic_strio_FR_means = tonic_strio_FR_means(~isnan(tonic_strio_FR_means));
    p1 = plot(tonic_hfn_FR_bin_centers,tonic_strio_FR_means);
    scatter(tonic_hfn_FR_bin_centers,tonic_strio_FR_means,5,'blue');
    
    phasic_hfn_FR_bin_centers = (phasic_hfn_FR_bins(1:end-1) + phasic_hfn_FR_bins(2:end)) / 2;
    phasic_hfn_FR_bin_centers = phasic_hfn_FR_bin_centers(~isnan(phasic_strio_FR_means));
    phasic_strio_FR_means = phasic_strio_FR_means(~isnan(phasic_strio_FR_means));
    p2 = plot(phasic_hfn_FR_bin_centers,phasic_strio_FR_means);
    scatter(phasic_hfn_FR_bin_centers,phasic_strio_FR_means,5,'red');
    hold off;
    xlabel('SWN FR'); ylabel([comparison_type ' Firing Rate']);
    ylim([-2 1]);
    legend([p1,p2],'Tonic','Phasic');
    title(dbs{db});
end

fig_dir = [ROOT_DIR 'Correlation Using Phasic Activity/' comparison_type '/'];
if ~exist(fig_dir,'dir')
    mkdir(fig_dir);
end
saveas(f, [fig_dir 'Strength to Strength Comparison'], 'fig');
saveas(f, [fig_dir 'Strength to Strength Comparison'], 'epsc2');
saveas(f, [fig_dir 'Strength to Strength Comparison'], 'jpg');