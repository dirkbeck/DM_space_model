function plot_raster(...
    plot_num, spikes_swn, spikes_msnstrio, spikes_msnmatrix, bin_time, swn_fr)

swn_raster_dat = {};
msnstrio_raster_dat = {};
msnmatrix_raster_dat = {};
for spike_idx = 1:length(spikes_swn)    
    % Get strio counts
    trial_spikes_swn = cell2mat(spikes_swn(spike_idx));
    [swn_n, swn_edges] = histcounts(trial_spikes_swn, floor(40/bin_time));
    
    fr_bins = [];
    for swn_fr_val=swn_fr
        fr_bins = [fr_bins find(swn_n/bin_time > swn_fr_val - 0.01 & swn_n/bin_time < swn_fr_val + 0.01)]; 
    end
    trial_spikes_bins_swn = discretize(trial_spikes_swn, swn_edges);
        
    trial_spikes_msnstrio = cell2mat(spikes_msnstrio(spike_idx));
    trial_spikes_bins_msnstrio = discretize(trial_spikes_msnstrio, swn_edges);

    trial_spikes_msnmatrix = cell2mat(spikes_msnmatrix(spike_idx));
    trial_spikes_bins_msnmatrix = discretize(trial_spikes_msnmatrix, swn_edges);
    
    for fr_bin=fr_bins
        bin_start_edge = swn_edges(fr_bin);
        
        swn_idxs = trial_spikes_bins_swn == fr_bin;
        msnstrio_idxs = trial_spikes_bins_msnstrio == fr_bin;
        msnmatrix_idxs = trial_spikes_bins_msnmatrix == fr_bin;
        
        swn_raster_dat{end+1} = trial_spikes_swn(swn_idxs) - bin_start_edge;
        msnstrio_raster_dat{end+1} = trial_spikes_msnstrio(msnstrio_idxs) - bin_start_edge;
        msnmatrix_raster_dat{end+1} = trial_spikes_msnmatrix(msnmatrix_idxs) - bin_start_edge; 
    end
end

l = length(swn_raster_dat) + 1;
subplot(4, 3, 3 + plot_num);
plot_raster_(swn_raster_dat);
ylim([0 l]);
xlim([0 1]);
title(sprintf('SWN (fr = [%i %i %i])', swn_fr));
ylabel('trials');
xlabel('time');
subplot(4, 3, 2 * 3 + plot_num)
plot_raster_(msnstrio_raster_dat);
ylim([0 l]);
xlim([0 1]);
title(sprintf('MSN strio (fr = [%i %i %i])', swn_fr));
ylabel('trials');
xlabel('time');
subplot(4, 3, 3 * 3 + plot_num)
plot_raster_(msnmatrix_raster_dat);
ylim([0 l]);
xlim([0 1]);
title(sprintf('MSN matrix (fr = [%i %i %i])', swn_fr));
ylabel('trials');
xlabel('time');
end

function plot_raster_(dat)
hold on;
n = length(dat);
for ii=1:n  
    y = n - ii + 1;
    scatter(dat{ii}, y * ones(1,length(dat{ii})), 5, 'k', 'filled');
end
end

