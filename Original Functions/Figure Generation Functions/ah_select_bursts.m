function [selectedBursts] = ah_select_bursts(allBursts, numNeurons, threshold, startTime, endTime, isCombined, isRandom)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - allBursts has three columns:
%   - The first column is the FR of the burst
%   - The second column is the time of middle of the burst
%   - The third column is the index of neuron
% - numNeurons is the number of different neurons the bursts come from
% - threshold is the minimum firing rate threshold of the burst
% - startTime is the start time of the range we want to plot
% - endTime is the end time of the range we want to plot
% - isCombined specifies whether combining bursts from all neurons
% - isRandom specifies whether to random the rows of the plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

selectedBursts = [];
for i=1:length(allBursts)
    if allBursts(i,1)<threshold
        continue
    end
    if allBursts(i,2)<startTime || allBursts(i,2)>endTime
        continue
    end
    selectedBursts(end+1,:) = allBursts(i,:);
end

if isCombined
    [X, I] = sort(selectedBursts(:,2)); %% sort the bursts by time
    FR = selectedBursts(I(:,1),1);
    long = selectedBursts(I(:,1),4);
    selectedBursts = [FR X X long];
    for i=1:length(selectedBursts)
        selectedBursts(i,3) = mod(i-1,numNeurons)+1;
    end
end

if isRandom
    order = randperm(numNeurons);
    for i=1:length(selectedBursts)
        selectedBursts(i,3) = order(selectedBursts(i,3));
    end
end