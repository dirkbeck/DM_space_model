%this file dynamically creates 10 folders of unpaired striosome-striosome neurons
%it focuses on the Cost Benefit task type 
%and the concentrations of 15 and 30

%MODIFY THIS VARIABLE
%to point towards the actual location of twdbs on your local machine
twdbs_dir = ['C:\Users\ldd77' filesep 'Downloads' filesep 'twdbs.mat'];
twdbs = load(twdbs_dir);

uniqueTaskType={'CB'};
uniqueConcentrations = [15,30];
for i=1:10
    createTables(currentDatabase,3,strcat("Unpaired Striosome Striosome Control",string(i)),0,uniqueTaskType,uniqueConcentrations,1,1)
end

%The histograms are created by reading all of the excel files created in the last step and storing all of the percentages found there
%it is expected that these excel files all contain tables where at least 1 column is named "NegativeThresholdMeetingPercentage"
%NegativeThresholdMeetingPercentage should be a column of the percentage of total figures which meet the
%r-squared and significance threshold (r squared =0.2, significance =0.05) for each concentration and task type
%please see an example table below.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% taskAndConcentration	                totalFigures	totalNegativePercentage	    NegativeThresholdMeetingPercentage
% Line Task Type CB Concentration 15	30	            0.333333333	                0.133333333
% Line Task Type CB Concentration 30	2	            0.5	                        0.5
% Line Task Type CB Concentration 5	    3	            0   	                    0
% Line Task Type CB Concentration 70	344	            0.183139535	                0.081395349
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%please note that the titles variable must be changed if you want to use a different task type or if the title order in
%your excel files are different
allFiles = dir("*.xlsx");
currentConcentrationPercentages = [];

%read the excel files with the percentage data
for i=1:length(allFiles)
    currentTable = readtable(allFiles(i).name);
    currentConcentrationPercentages = [currentConcentrationPercentages,currentTable.NegativeThresholdMeetingPercentage];
end

%CHANGE THIS VARIABLE
%it should be changed to match the titles of the excel files in the current directory
titles = {'CB Concentration 15',...
'CB Concentration 30',...
'CB Concentration 5',...
'CB Concentration 70'};

%these data points come from Paired Striosome Striosome Control.xlsx
pairedStriosomeStriosomeControl = [0.161764706,0.111111111,0,0.074944072];

%create the plots
for i=1:length(titles)
    unpairedStriosomeStriosomeControl =currentConcentrationPercentages(i,:);
    figure
    hold on;
    stdDvn = std(unpairedStriosomeStriosomeControl);
    mn= mean(unpairedStriosomeStriosomeControl);
    histogram(unpairedStriosomeStriosomeControl,100);
    histogram(pairedStriosomeStriosomeControl(i),100);
    
    grid on;

    %plot the mean 
    xline(mn,'--g',{strcat('Unpaired Mean',string(mn))});
    
    standardDeviationColorList = {'r','b','m'};
    counter=1;
    %plot the standard deviations (1,2,3)
    for j=[-1,1,-2,2,-3,3]
        if j<0
            counter =j*-1 ;
        else
            counter = j;
        end
        color=char(standardDeviationColorList(counter));
        xline(mn-stdDvn *j,strcat('--',color),{strcat(string(counter),' Standard Deviation(s)',string(mn-stdDvn*j))});
    end
    legend('Unpaired','Paired','','','','','','','');
    title(strcat("Paired & Unpaired SS Control ",titles(i)))
    xlim([mn-stdDvn*3,mn-stdDvn*-3])
    hold off
end