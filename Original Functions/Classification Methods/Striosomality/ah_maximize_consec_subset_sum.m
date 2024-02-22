function idxs = ah_maximize_consec_subset_sum(set)
%AH_MAXIMIZE_CONSEC_SUBSET_SUM finds the maximum consecutive subset sum in
%an array. Algorithm taken from Wikipedia. 
idxs = [0 0];
begin_temp = 1;
max_ending_here = 0;
max_so_far = 0;
for iter = 1:length(set)
    if max_ending_here + set(iter) < 0
        max_ending_here = 0;
        begin_temp = iter+1;
    else
        max_ending_here = max_ending_here + set(iter);
    end
    if max_ending_here >= max_so_far
        max_so_far  = max_ending_here;
        idxs = [begin_temp, iter];
    end
end
if idxs(1) > idxs(2)
    idxs = [0 0];
end
end