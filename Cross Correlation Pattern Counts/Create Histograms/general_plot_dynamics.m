function [fig_handle,goodnessOfFit, significance,slope] =general_plot_dynamics(spikes_neuron_1, spikes_neuron_2, ...
    msORmmORss)
allPossibleGoodnessOfFit = [0 0 0 0 0];
%alter bin size from 1-5 and record all the rsquared for each fit
for i=1:5
    all_matrix1_counts = [];
    all_matrix2_counts = [];
    %the for loop should repeat only to match the smallest matrix size
    %below I determine which spikes matrix is smallest
    if length(spikes_neuron_1) > length(spikes_neuron_2)
        smallest = length(spikes_neuron_2);
    elseif length(spikes_neuron_1) < length(spikes_neuron_2)
        smallest = length(spikes_neuron_1);
    elseif length(spikes_neuron_1)== length(spikes_neuron_2)
        smallest = length(spikes_neuron_2);
    end
    for spike_idx = 1: smallest
    % Get matrix & striosome counts
        %get the number of spikes in each bin, and the edges of each bin
        %for striosome neurons
        [striosome_N, striosome_edges] =    histcounts(cell2mat(spikes_neuron_1(spike_idx)), i);
        %get the number of spikes in each bin for matrix neurons
        %we use the same number of edges that were found in the striosome
        %histcounts call
%         display(spike_idx)
        msnmatrix_N =                       histcounts(cell2mat(spikes_neuron_2(spike_idx)), striosome_edges);
        %store the spike counts in some arrays
        %also divide their value by the striosome bin time
        all_matrix1_counts = [all_matrix1_counts striosome_N/i];
        all_matrix2_counts = [all_matrix2_counts msnmatrix_N/i];
    end



    %get the average spike value of the matrix neurons for each value of the
    %striosome neurons
    [xmean_matrix, ynew_matrix] = y_mean(all_matrix1_counts, all_matrix2_counts);
    if height(xmean_matrix) <3
        slope = 0;
        significance=100;
        goodnessOfFit = -500;
        fig_handle = gcf;
        disp("There was not enough data to fit")
        continue
    end

    % Start Fitting to linear line and get rsquare error
    fitType = fittype('a*x+b', 'independent', 'x', 'dependent', 'y');
    opts = fitoptions( 'Method', 'NonlinearLeastSquares');
    opts.Display = 'Off';

    [fitobj_matrix, gof_matrix] = fit(xmean_matrix, ynew_matrix, fitType);
    
    slope=fitobj_matrix.a; 
    
    %find the significance between x and y
    [~,significance] = corrcoef([xmean_matrix, ynew_matrix]);
    
    significance = significance(1,2);
    allPossibleGoodnessOfFit(i) = gof_matrix.rsquare;

end
[~,I] = max(allPossibleGoodnessOfFit);
all_matrix1_counts = [];
all_matrix2_counts = [];
if length(spikes_neuron_1) > length(spikes_neuron_2)
    smallest = length(spikes_neuron_2);
elseif length(spikes_neuron_1) < length(spikes_neuron_2)
    smallest = length(spikes_neuron_1);
elseif length(spikes_neuron_1)== length(spikes_neuron_2)
    smallest = length(spikes_neuron_2);
end
for spike_idx = 1: smallest
% Get matrix & striosome counts
    %get the number of spikes in each bin, and the edges of each bin
    %for striosome neurons
    [striosome_N, striosome_edges] =    histcounts(cell2mat(spikes_neuron_1(spike_idx)), I);
    %get the number of spikes in each bin for matrix neurons
    %we use the same number of edges that were found in the striosome
    %histcounts call
    msnmatrix_N =                       histcounts(cell2mat(spikes_neuron_2(spike_idx)), striosome_edges);
    %store the spike counts in some arrays
    %also divide their value by the striosome bin time
    all_matrix1_counts = [all_matrix1_counts striosome_N/I];
    all_matrix2_counts = [all_matrix2_counts msnmatrix_N/I];
end


%get the average spike value of the matrix neurons for each value of the
%striosome neurons
[xmean_matrix, ynew_matrix] = y_mean(all_matrix1_counts, all_matrix2_counts);

% check to make sure there's actually enough data to fit
if height(xmean_matrix) <3
    slope = 0;
    significance=100;
    goodnessOfFit = -500;
    fig_handle = gcf;
    disp("There was not enough data to fit")
    return
end


% Start Fitting to linear line and get rsquare error
fitType = fittype('a*x+b', 'independent', 'x', 'dependent', 'y');
opts = fitoptions( 'Method', 'NonlinearLeastSquares');
opts.Display = 'Off';

[fitobj_matrix, gof_matrix] = fit(xmean_matrix, ynew_matrix, fitType);

slope=fitobj_matrix.a; 

%find the significance between x and y
% display(xmean_matrix.')
% display(ynew_matrix.')
[~,significance] = corrcoef([xmean_matrix, ynew_matrix]);
% display(strcat("Significance",string(significance)))
significance = significance(1,2);
% display(strcat("Significance",string(significance)))
allPossibleGoodnessOfFit(i) = gof_matrix.rsquare;    

hold on;
plot(fitobj_matrix, xmean_matrix, ynew_matrix, 'o');
if msORmmORss==1
    ylabel('SWN Firing Rate (Hz) - matrix');
    xlabel('SWN Firing Rate (Hz) - striosome');
    title(sprintf('bin Matrix=%.2f, bin Matrix=%.2f, R^2 =%.3f, Significance=%.3f', ...
    I, I, gof_matrix.rsquare,significance));
elseif msORmmORss==2
    ylabel('SWN Firing Rate (Hz) - matrix');
    xlabel('SWN Firing Rate (Hz) - matrix');
    title(sprintf('bin Strio=%.2f, bin Matrix=%.2f, R^2 =%.3f, Significance=%.3f', ...
    I, I, gof_matrix.rsquare,significance));
elseif msORmmORss==3
    ylabel('SWN Firing Rate (Hz) - striosome');
    xlabel('SWN Firing Rate (Hz) - striosome');
    title(sprintf('bin Strio=%.2f, bin Strio=%.2f, R^2 =%.3f, Significance=%.3f', ...
    I, I, gof_matrix.rsquare,significance));
end

b = gca; legend(b,'off');
fig_handle = gcf;

goodnessOfFit=gof_matrix.rsquare;


end