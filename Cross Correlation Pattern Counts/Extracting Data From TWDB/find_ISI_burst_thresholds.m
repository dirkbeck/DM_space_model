function thresholds = find_ISI_burst_thresholds(spikes, smooth_factor, min_ISIs, debug, fig_dir)
% FIND_ISI_BURST_THRESHOLDS returns the ISI (interspike interval) threshold
% for a neuron. Consecutive spikes with ISIs below the ISI threshold can be
% considered as 'burst' events.
%
% Inputs are:
%  SPIKES         - cell array with the spike times of the nth trial in the
%                 nth entry
%  SMOOTH_FACTOR  - the amount by which we should smooth the set of neuron
%                 ISIs during a trial. This helps make clean the data, but
%                 should not be set to a high value, so as to not corrupt
%                 the data.
%  MIN_ISIS       - the minimum number of ISIs that exist in the spikes
%                 array. In order for a threshold to be found, there must
%                 be some minimal amount of data. Typically, there should
%                 be at least 15 data points.
%  DEBUG          - if true, will make a debug plot visualizing the
%                 distribution of ISIs found, along with the threshold ISI
%                 found. If false, does not make a plot
%  FIG_DIR        - the directory in which the figure should be saved, if
%                 it is created.
%
% Outputs are:
%  THRESHOLDS     - a 1 by 2 matrix containing the value of the threshold
%                 ISI found. The two values of the matrix are the same; the
%                 shape of the matrix is what it is for historical reasons.

    thresholds = [];
    % Get ISIs and smooth
    ISIs = cell2mat(cellfun(@(x) smooth(diff(x),smooth_factor),spikes,'uni',false));
    
    % No thresholds if there isn't enough data.
    if length(ISIs) < min_ISIs
        thresholds(1) = NaN;
        thresholds(2) = NaN;
    else
        % Only look at short ISIs
        max_ISI = 0.25; % seconds
        ISIs = ISIs(ISIs < max_ISI);
        
        % Calculate 35th percentile as thresholds
        percentile = 35;
        thresholds = prctile(ISIs, [percentile percentile]);
        
        if debug
            f = figure;
            subplot(2,2,1); h1 = histogram(ISIs,20);   title('ISIs');
            subplot(2,2,2); h2 = histogram(log10(ISIs),20); title('log10 ISIs');
            % Calculate quartiles
            quartiles = prctile(ISIs,percentile);
            log10_quartiles = prctile(log10(ISIs),percentile);
            subplot(2,2,1); line([quartiles;quartiles],[zeros(1,1); ones(1,1)*max(h1.Values)],'Color','black','LineWidth',2);
            subplot(2,2,2); line([log10_quartiles;log10_quartiles],[zeros(1,1); ones(1,1)*max(h2.Values)],'Color','black','LineWidth',2);
            
            saveas(f, [fig_dir 'Distribution of ISIs'], 'fig');
            saveas(f, [fig_dir 'Distribution of ISIs'], 'epsc2');
            saveas(f, [fig_dir 'Distribution of ISIs'], 'jpg');
        end
    end
end