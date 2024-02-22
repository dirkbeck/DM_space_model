
c = newline;
for i=1:length(ss_ret{1}{1})
    display(strcat("Connectivity: ",string(strio_strio_connectivities{1}{1}(i))));
    disp("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    display(strcat("Sum Square Error: ",string(ss_ret{1}{1}{i}.rss_adj)," | Less Than 0.3 is cause for concern",c));
    display(strcat("Consistency Test: ",string(ss_ret{1}{1}{i}.cons)," | Less that 80% is cause for concern",c));
    display(strcat("Durbin-Watson Test: ",string(ss_ret{1}{1}{i}.waut)," | Less than 0.05 or 0.01 is cause for concern.",c));
    disp("________________________________________________________________");
end