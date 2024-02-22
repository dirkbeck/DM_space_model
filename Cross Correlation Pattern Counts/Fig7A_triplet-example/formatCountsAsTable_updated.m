taskAndConcentration = keys(total_Figures_Count).';
taskAndConcentration = string(taskAndConcentration);

totalFigures = cell2mat(values(total_Figures_Count).');

total_negative_figures_count = cell2mat(values(total_negative_figures).');
negative_percentage = total_negative_figures_count ./ totalFigures;

total_positive_figures_count = cell2mat(values(total_positive_figures).');
positive_percentage = total_positive_figures_count ./ totalFigures;

percentage_of_all_figs_where_positive_both_threshold_met = cell2mat(values(positive_relationship_met_r_squared_and_signficance).') ./ totalFigures;
percentage_of_all_figs_where_negative_both_threshold_met = cell2mat(values(negative_relationship_met_r_squared_and_signficance).') ./ totalFigures;

percentage_of_positive_figs_where_positive_both_threshold_met = cell2mat(values(positive_relationship_met_r_squared_and_signficance).') ./ total_positive_figures_count;
percentage_of_negative_figs_where_negative_both_threshold_met = cell2mat(values(negative_relationship_met_r_squared_and_signficance).') ./ total_negative_figures_count;

percentage_of_all_figs_where_positive_only_r_square_met = cell2mat(values(positive_relationship_met_r_squared).') ./ totalFigures ;
percentage_of_all_figs_where_negative_only_r_square_met = cell2mat(values(negative_relationship_met_r_squared).') ./ totalFigures;

percentage_of_positive_figs_where_positive_only_r_square_met = cell2mat(values(positive_relationship_met_r_squared).') ./ total_positive_figures_count ;
percentage_of_negative_figs_where_negative_only_r_square_met = cell2mat(values(negative_relationship_met_r_squared).') ./ total_negative_figures_count;

percentage_of_all_figs_where_positive_only_significance_met = cell2mat(values(positive_relationship_met_signifance).') ./ totalFigures; 
percentage_of_all_figs_where_negative_only_significance_met = cell2mat(values(negative_relationship_met_signifance).') ./ totalFigures ; 

percentage_of_positive_figs_where_only_significance_met = cell2mat(values(positive_relationship_met_signifance).') ./ total_positive_figures_count ; 
percentage_of_negative_figs_where_only_significance_met = cell2mat(values(negative_relationship_met_signifance).') ./ total_negative_figures_count; 
% order=[2;1; 3; 4; 5; 7; 8; 6; 9; 18; 11; 12; 13; 10; 14; 15; 16; 17]; %control group order
% order = [1;2;11;3;4;5;6;7;8;9;10]; %stress order
% order = [1;2;3;4;7;5;6]; %stress 2 order
tableOfNegative = table(taskAndConcentration, ...
    totalFigures, ...
    negative_percentage,...
    percentage_of_all_figs_where_negative_both_threshold_met,...
    percentage_of_negative_figs_where_negative_both_threshold_met,...
    percentage_of_all_figs_where_negative_only_r_square_met,...
    percentage_of_negative_figs_where_negative_only_r_square_met,...
    percentage_of_all_figs_where_negative_only_significance_met,...
    percentage_of_negative_figs_where_only_significance_met);
% display(tableOfNegative)


tableOfPositive = table(taskAndConcentration, ...
    totalFigures, ...
    positive_percentage,...
    percentage_of_all_figs_where_positive_both_threshold_met,...
    percentage_of_positive_figs_where_positive_both_threshold_met,...
    percentage_of_all_figs_where_positive_only_r_square_met,...
    percentage_of_positive_figs_where_positive_only_r_square_met,...
    percentage_of_all_figs_where_positive_only_significance_met,...
    percentage_of_positive_figs_where_only_significance_met);
% display(tableOfPositive)


%% create bar graphs

for i=3:width(tableOfNegative)
    all_task_types = tableOfNegative{:,1}.';
    currentCol = tableOfNegative{:,i};
    currentTitle = tableOfNegative.Properties.VariableNames{i};
    currentTitle = strrep(currentTitle,"_","\_");
%     disp(currentCol)
%     disp(currentTitle)

    figure;
    hold on;
    bar(categorical(all_task_types),currentCol.')
    title(currentTitle);
    subtitle("Created by formatCountsAsTable\_updated.m")
    ylabel("Percentage")
end

% tableOfNegative = tableOfPositive;

for i=3:width(tableOfPositive)
    all_task_types = tableOfPositive{:,1}.';
    currentCol = tableOfPositive{:,i};
    currentTitle = tableOfPositive.Properties.VariableNames{i};
    currentTitle = strrep(currentTitle,"_","\_");
%     disp(currentCol)
%     disp(currentTitle)

    figure;
    hold on;
    bar(categorical(all_task_types),currentCol.')
    title(currentTitle);
    subtitle("Created by formatCountsAsTable\_updated.m")
    ylabel("Percentage")
end


%% format 
theFileNAmeNonsense = split(myFolder,"\");
disp(theFileNAmeNonsense{end})

disp("negative")
disp(table(keys(total_Figures_Count).',...
    cell2mat(values(total_Figures_Count).'),...
    cell2mat(values(negative_relationship_met_r_squared_and_signficance).') ./ cell2mat(values(total_Figures_Count).'), ...
    'VariableNames',{'TT and Conc','Total Figure Count', '% of all figures that met both'}))

disp("positive")
disp(table(keys(total_Figures_Count).',...
    cell2mat(values(total_Figures_Count).'),...
    cell2mat(values(positive_relationship_met_r_squared_and_signficance).') ./ cell2mat(values(total_Figures_Count).'), ...
    'VariableNames',{'TT and Conc','Total Figure Count', '% of all figures that met both'}))

