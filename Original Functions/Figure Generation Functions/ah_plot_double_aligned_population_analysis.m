function ah_plot_double_aligned_population_analysis(plotting_bins, evt_times_distribution, timeOfBins, numTrials, event_columns, extra_event_locs, smoothing_coeff, fig_marker, color)
%AH_PLOT_DOUBLE_ALIGNED_POPULATION_ANALYSIS plots a double aligned
%population analysis figure; no actual work save the plotting is actually
%done in this function. Takes inputs directly from either of the binning
%functions:
%Inputs:
% PLOTTING_BINS - output of either binning function. These are the bins
%   that we wish to plot.
% EVT_TIMES_DISTRIBUTION - also output of binning function. One entry for
%   each event that we have in ses_evt_timings (see binning functions).
%   Chances are, we only care about a couple of the events in here; others
%   tend to be rather buggy. 
% TIMEoFbINS - also output of binning function. Array of same size as
%   plotting_bins that contains the time of the center of each bin (since
%   bins are not all same time width, it's the average time). 
% EVENT_COLUMNS - indices of first align event and second align event in
%   evt_times_distribution.
% EXTRA_EVENTS - one entry for each extra event we wish to mark, giving
%   either the location of the event in our transformed coordinates for the
%   bins (on a scale of 0 to 1) or the index of the entry in
%   evt_times_distribution where we wish to search. 
% FIG_MARKER - marker that tells function whether or not it should generate
%   a new figure or write onto an existing figure
% COLOR - the desired color of the error bars. If unspecified, initialized
% as red ([1 0 0])
if ~exist('color', 'var')
    color = [1 0 0];
end

if fig_marker
    figure;                         %generate figure
end
hold all;                           %hold all graphics objects onto figure
numBins = length(timeOfBins);       %number of bins
binWidth = timeOfBins(2) - timeOfBins(1);   %width of bins
startTime = timeOfBins(1) - binWidth/2;     %time of beginning of first bin
endTime = timeOfBins(end) + binWidth/2;     %time of end of last bin
max_bin = max(plotting_bins(:,1));               %maximum bin
min_bin = min(min(plotting_bins(:,1)),0);        %minimum bin, or 0 if the minimum bin is greater than 0.
first_align_evt = event_columns(1);    %column in evt_times_distribution of first align event
first_align_evt_time = mean(evt_times_distribution{first_align_evt});  %average time of first align event
second_align_evt = event_columns(2);   %column in evt_times_distribution of second align event
second_align_evt_time = mean(evt_times_distribution{second_align_evt}); %average time of second align event
line([first_align_evt_time, first_align_evt_time], [min_bin max_bin], 'Color', 'Black', 'LineWidth', 2)     %line at first align event time
line([second_align_evt_time, second_align_evt_time], [min_bin max_bin], 'Color', 'Black', 'LineWidth', 2)   %line at second align event time
for evt_idx = 1:length(extra_event_locs)
    if ~mod(extra_event_locs(evt_idx),1)    %if given the entry index in evt_times_distribution, this will be an integer
        event_time = mean(evt_times_distribution{extra_event_locs(evt_idx)});   %time of event
    else                                %otherwise, we are given the location on a scale of 0 to 1 of the event
        event_loc = extra_event_locs(evt_idx);  %location of event
        event_time = startTime + event_loc*(endTime - startTime);   %time of event
    end
    line([event_time event_time], [min_bin max_bin], 'Color', 'Black', 'LineWidth', 2)  %line of time of event
end

stError_bins = (plotting_bins(:,2)-plotting_bins(:,1).^2).^(1/2)/sqrt(numTrials);   %standard error of plotting bins
upperBound_bins = smooth(plotting_bins(:,1) + stError_bins,smoothing_coeff);        %bins of upper bound of plot
lowerBound_bins = smooth(plotting_bins(:,1) - stError_bins,smoothing_coeff);        %bins of lower bound of plot
plot_bins = smooth(plotting_bins(:,1),smoothing_coeff);                             %smooth plotting bins
timeOfBins = timeOfBins + binWidth*(smoothing_coeff-1)/2;                           %shift bin times for smoothing filter art-effect
patch_handle = patch([timeOfBins, timeOfBins(numBins:-1:1)], [lowerBound_bins; upperBound_bins(numBins:-1:1)]', ...
    color, 'EdgeColor', 'none', 'FaceAlpha', 1);                            %shade region between error bounds
plot(timeOfBins, plot_bins, 'LineWidth', 1.5, 'Color', [0 0 0])             %plot plotting bins
uistack(patch_handle,'bottom')


end
