[~,twdbs] = loadData;

% Create the Control, Stress1, and Stress 2 Strio-Matrix Pattern Counts 
sortedTableOfSkews = createSkewnessBarChart(100,twdbs,"control"); 
create a skewness table for control database on task type level

allFilesToLoad = ["..\Pattern Analysis\allMaps\Maps By Task Type\AllControlMapsByTaskType.mat",...
    "..\Pattern Analysis\allMaps\Maps By Task Type\AllStress 1MapsByTaskType.mat",...
    "..\Pattern Analysis\allMaps\Maps By Task Type\AllStress 2MapsByTaskType.mat"];
location of pattern count data

create control pattern count line graphs
createLinearPatternCountGraphsByTaskType(1,allFilesToLoad,sortedTableOfSkews,"control")

%create stress1 pattern count line graphs
createLinearPatternCountGraphsByTaskType(1,allFilesToLoad,sortedTableOfSkews,"stress")

%create stress2 pattern count line graphs
createLinearPatternCountGraphsByTaskType(1,allFilesToLoad,sortedTableOfSkews,"stress2")