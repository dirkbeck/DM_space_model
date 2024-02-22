% Specify the folder where the files live.
% myFolder = "C:\Users\ldd77\OneDrive\Desktop\Friedman-Hueske-2020\Fig7A_triplet-example\Automated";
myFolder = ".\Stress Lines";
% myFolder = "C:\Users\ldd77\OneDrive\Desktop\Friedman-Hueske-2020\Fig7A_triplet-example\Stress 2 Lines";

myFolder = "C:\Users\ldd77\OneDrive\Desktop\Striosome-Matrix-Analysis\Fig7A_triplet-example\Control";
rsquaredThreshold = 0.2;
significanceThreshold = 0.05; 

satisfactoryRsquaredCount = containers.Map('KeyType','char','ValueType','any');
satisfactorySignificance = containers.Map('KeyType','char','ValueType','any');
totalFiguresCount = containers.Map('KeyType','char','ValueType','any');
totalNegativeFiguresCount = containers.Map('KeyType','char','ValueType','any');
totalPositiveFiguresCount = containers.Map('KeyType','char','ValueType','any');
totalPositiveRSquaredSatisfactory = containers.Map('KeyType','char','ValueType','any');
totalPositiveSignificance =containers.Map('KeyType','char','ValueType','any');



% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '**/*.fig'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
for a=1: length(theFiles)
    baseFileName = theFiles(a).name;
    fullFileName = fullfile(theFiles(a).folder, baseFileName);
    splitFileName = split(fullFileName,'\');
    satisfactoryRsquaredCount(string(splitFileName(9)))= 0;
    satisfactorySignificance(string(splitFileName(9)))= 0;
    totalFiguresCount(string(splitFileName(9))) = 0;
    totalNegativeFiguresCount(string(splitFileName(9))) =0 ;
    totalPositiveFiguresCount(string(splitFileName(9))) = 0;
    totalPositiveRSquaredSatisfactory(string(splitFileName(9))) = 0;
    totalPositiveSignificance(string(splitFileName(9))) =0;
end
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
    splitFileName = split(fullFileName,'\');
%     display(splitFileName)
    fprintf(1, 'Now reading %s\n', fullFileName);
    currentTitle = string(splitFileName(11));
    currentTitle = split(currentTitle," ");
    rsquared = currentTitle(7);
    rsquared = str2double(rsquared);
    significance = currentTitle(9);
    significance = strrep(significance,".fig","");
    significance = str2double(significance);
%     display(currentTitle)
%     disp(rsquared)
%     disp(significance)
    if strcmp(string(splitFileName(10)),"Negative Slope")
        totalFiguresCount(string(splitFileName(9))) = totalFiguresCount(string(splitFileName(9)))+1;
        totalNegativeFiguresCount(string(splitFileName(9))) = totalNegativeFiguresCount(string(splitFileName(9)))+1;
        if significance <= significanceThreshold
            if rsquared >=rsquaredThreshold
                satisfactoryRsquaredCount((string(splitFileName(9)))) = satisfactoryRsquaredCount((string(splitFileName(9)))) +1;
                satisfactorySignificance((string(splitFileName(9)) )) = satisfactorySignificance((string(splitFileName(9)) ))+1;
            end
        end
        
    else
        totalFiguresCount(string(splitFileName(9))) = totalFiguresCount(string(splitFileName(9)))+1;
        totalPositiveFiguresCount(string(splitFileName(9))) = totalPositiveFiguresCount(string(splitFileName(9)))+1;
        if rsquared >= rsquaredThreshold
            if significance<=significanceThreshold
                totalPositiveRSquaredSatisfactory(string(splitFileName(9))) = totalPositiveRSquaredSatisfactory(string(splitFileName(9)))+1;
                totalPositiveSignificance(string(splitFileName(9))) =totalPositiveSignificance(string(splitFileName(9))) +1;
            end
        end

    end
   
end