%% This script generates visualizations of the distribution of time delays
%  between pairs of neurons. It demonstrates a pair that is correlated,
%  and a pair that is not correlated.

time_delay_bins = 0:.5/20:.5;

% First, plot an example of a not correlated pair
db = 1;
pair_num = 21;
f = figure;
[N,centers] = hist(phasic_time_delays{db}{pair_num}(phasic_time_delays{db}{pair_num} ~=0 & phasic_time_delays{db}{pair_num} < 0.5),time_delay_bins);
bar(centers,N); line([0 .5], [mean(N)+std(N) mean(N)+std(N)],'Color','black');

fig_dir = [ROOT_DIR 'Algorithm Visualizations/' comparison_type '/'];
if ~exist(fig_dir,'dir')
    mkdir(fig_dir)
end
saveas(f, [fig_dir 'Time Delay Distribution of Uncorrelated Pair'], 'fig');
saveas(f, [fig_dir 'Time Delay Distribution of Uncorrelated Pair'], 'jpg');
saveas(f, [fig_dir 'Time Delay Distribution of Uncorrelated Pair'], 'epsc2');

% Next, plot an example of a correlated pair
db = 2;
pair_num = 13;
f = figure;
[N,centers] = hist(phasic_time_delays{db}{pair_num}(phasic_time_delays{db}{pair_num} ~=0 & phasic_time_delays{db}{pair_num} < 0.5),time_delay_bins);
bar(centers,N); line([0 .5], [mean(N)+std(N) mean(N)+std(N)],'Color','black');

% fig_dir = [ROOT_DIR 'Algorithm Visualizations/' comparison_type '/'];
% if ~exist(fig_dir,'dir')
%     mkdir(fig_dir)
% end
% saveas(f, [fig_dir 'Time Delay Distribution of Coorrelated Pair'], 'fig');
% saveas(f, [fig_dir 'Time Delay Distribution of Correlated Pair'], 'jpg');
% saveas(f, [fig_dir 'Time Delay Distribution of Correlated Pair'], 'epsc2');