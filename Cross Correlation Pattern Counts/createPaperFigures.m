%% ensure all necessary paths on on the drive
addpath(genpath(pwd));
%% load the data into the enviornment
[dbs,twdbs] = loadData(['C:\Users\ldd77' filesep 'Downloads' filesep 'twdbs.mat']); %make sure to edit the passed file path so that it points to your database
%% load the bootstapped random pattern counts into the environmnet to create standard deviation lines on plot
load("ShortRandomExcitedExcited.mat")
load("ShortRandomExcitedInhibited.mat")
load("ShortRandomInhibitedExcited.mat")
load("ShortRandomInhibitedInhibited.mat")
array_of_random_distributions = {allShortExcitedExcited,allShortExcitedInhibited,allShortInhibitedExcited,allShortInhibitedInhibited};
%% calculate some means and std
standardDeviationsLinesLocations= nan(4,3);
for i=1:length(array_of_random_distributions)
    mean_of_task = mean(array_of_random_distributions{i});
    which_std_dvts = [1,2,3];
    standardDeviationsLinesLocations(i,:) = mean_of_task + (std(array_of_random_distributions{i}) * which_std_dvts );
    
    %yline(standardDeviationsLinesLocations,'--','Color','red')
end
%% Fig 3e
clc;
fig_creation_dir =cd(fullfile(".","Pattern Analysis/"));
binSize = 100;
beginning_to_end_indexes = [1 1.5];     %[1 1.5] is for control database
                                        %[2 2.5] is for stress1 database
                                        %[3 3.5] is for stress2 database
createSkewnessBarChart;
cd(fullfile('.','allMaps','Maps By Task Type'));
createLinearPatternCountGraphsByTaskType;
cd(fig_creation_dir);
%% Extended Figure 3b
fig_creation_dir = cd(fullfile(".","Pattern Analysis"));
binsize = 1;
createHistogramsByTaskTypeOrConcentration;
cd(fig_creation_dir);
%% Extended Figure 3c
clc;
close all;
fig_creation_dir = cd(fullfile(".","Neural Network"));
weiner_process_illustration;
cd(fig_creation_dir);
%% Extended Figure 3d
clc;
fig_creation_dir =cd(fullfile(".","Pattern Analysis/"));
binSize = 100;
beginning_to_end_indexes = [1 1.5];     %[1 1.5] is for control database
                                        %[2 2.5] is for stress1 database
                                        %[3 3.5] is for stress2 database
createSkewnessBarChart;
cd(fig_creation_dir);
%% Extended Figure 3e & Extended Figure 3f
% WARNING!! This creates a lot of figures and runs for a very long time, so please be aware of that
fig_creation_dir = cd(fullfile(".","Fig7A_triplet-example/"));
updated_cross_correlation_split_with_filter;
cd(fig_creation_dir);
%% Extended Figure 3g
%WARNING, you must run the code for 3e and 3f as this plot counts the figures created in that step 
fig_creation_dir = cd(fullfile(".","Fig7A_triplet-example"));
countingEverything_updated_dont_split_by_pos_neg;
cd(fig_creation_dir);
%% Extended Figure 3h & Extended Figure 3i & Extended Figure 3j
%WARNING: this code will run for a very long time and produce many figures, but does not save them all because it is too many to save
%if you want to view and pause the figures please navigate to: ".\Pattern Analysis\plotBins_modified_to_plot.m" and insert a break point on the lines that have close(gcf)
fig_creation_dir = cd(fullfile(".","Pattern Analysis"));
generate_patterns_by_concentrations_to_get_examples;
cd(fig_creation_dir);
%% Extended Figure 3k & Extended Figure 3l & Extended Figure 3m & Extended Figure 3n (lines 117-145)
fig_creation_dir = cd(fullfile(".","Pattern Analysis","allMaps","Maps By Task Type"));
create_bar_charts_from_current_maps;
cd(fig_creation_dir);
%% Extended Figure 4a & Extended Figure 4b & Extended Figure 4c
clc;
fig_creation_dir = cd(fullfile(".","Pattern Analysis/"));
createCDFsforAllTaskTypes;
cd(fig_creation_dir);
%% Extended Figure 4d 
fig_creation_dir = cd(fullfile(".","Pattern Analysis/"));
createSkewnessBarChartOfTRAndCBAcrossControlAndStress2;
cd(fig_creation_dir);
%% Extended Figure 4e & Extended Figure 4f & Extended Figure 4g & Extended Figure 4h
fig_creation_dir = cd(fullfile(".","Pattern Analysis","allMaps","Maps By Task Type"));
create_bar_charts_from_current_maps;
cd(fig_creation_dir);

%% Extended Figure 4i
fig_creation_dir = cd();
cd(fig_creation_dir);
clc;
fig_creation_dir =cd(fullfile(".","Pattern Analysis/"));
binSize = 100;
beginning_to_end_indexes = [1 1.5];     %[1 1.5] is for control database
                                        %[2 2.5] is for stress1 database
                                        %[3 3.5] is for stress2 database
createSkewnessBarChart;
beginning_to_end_indexes = [2 2.5];
cd(fullfile('.','allMaps','Maps By Task Type'));
createLinearPatternCountGraphsByTaskType;
ylim([0,1.2])
cd(fig_creation_dir);
