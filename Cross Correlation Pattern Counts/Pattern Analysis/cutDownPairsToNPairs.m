function [modified_pairs] = cutDownPairsToNPairs(n,all_pairs)
modified_pairs = {all_pairs{1}(1:n,:),all_pairs{2}(1:n,:),all_pairs{3}(1:n,:)};
end