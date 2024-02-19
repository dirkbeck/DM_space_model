function [all_strio_strio_pairs] = remove_neurons_connected_to_themselves(all_strio_strio_pairs)
condition = all_strio_strio_pairs{1}(:,1) == all_strio_strio_pairs{1}(:,2);
all_strio_strio_pairs{1}(condition,:) = [];

condition = all_strio_strio_pairs{2}(:,1) == all_strio_strio_pairs{2}(:,2);
all_strio_strio_pairs{2}(condition,:) = [];

condition = all_strio_strio_pairs{3}(:,1) == all_strio_strio_pairs{3}(:,2);
all_strio_strio_pairs{3}(condition,:) = [];
end