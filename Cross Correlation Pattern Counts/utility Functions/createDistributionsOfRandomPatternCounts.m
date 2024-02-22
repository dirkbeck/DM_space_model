load("..\Pattern Analysis\Random\LongRandomExcitedExcited.mat")
load("..\Pattern Analysis\Random\LongRandomExcitedInhibited.mat")
load("..\Pattern Analysis\Random\LongRandomInhibitedExcited.mat")
load("..\Pattern Analysis\Random\LongRandomInhibitedInhibited.mat")
load("..\Pattern Analysis\Random\ShortRandomExcitedExcited.mat")
load("..\Pattern Analysis\Random\ShortRandomExcitedInhibited.mat")
load("..\Pattern Analysis\Random\ShortRandomInhibitedExcited.mat")
load("..\Pattern Analysis\Random\ShortRandomInhibitedInhibited.mat")

stddvPlts = [-3,-2,-1,1,2,3];
standardDeviations = [];
%standardDeviations will be an 8 row by 6 col array
%each row will be for one of the random pattern counts for each pattern count in the order it appears above
%each dataset above has 6 standard deviations
%3 below the mean
%3 above the mean
%the array can be inter

%           |-3*stddvs|-2*stddvs|-3*stddvs|1*stddvs|2*stddvs|3*stddvs
%Long EE
%Long EI
%Long IE
%Long II
%short EE
%short EI
%short IE
%Short II


figure
hist(allLongExcitedExcited,100)
title("Long Excited Excited")
subtitle("Created by createDistributionsOfRandomPatternCounts.m")
xlabel("Pattern Count")
ylabel("Frequency")
meanOfData = mean(allLongExcitedExcited);
xline(meanOfData,'--m')
s = std(allLongExcitedExcited);
currentStdDvs = []; 
for i=1:length(stddvPlts)
    xline(meanOfData - (s*stddvPlts(i)),'--r',string(meanOfData - (s*stddvPlts(i))   ))
    currentStdDvs = [meanOfData - (s*stddvPlts(i)),currentStdDvs];
end
standardDeviations = [standardDeviations;currentStdDvs];


figure
hist(allLongExcitedInhibited,100)
title("Long Excited Inhibited")
subtitle("Created by createDistributionsOfRandomPatternCounts.m")
xlabel("Pattern Count")
ylabel("Frequency")
meanOfData = mean(allLongExcitedInhibited);
xline(meanOfData,'--m')
s = std(allLongExcitedInhibited);
currentStdDvs = []; 
for i=1:length(stddvPlts)
    xline(meanOfData - (s*stddvPlts(i)),'--r',string(meanOfData - (s*stddvPlts(i))   ))
    currentStdDvs = [meanOfData - (s*stddvPlts(i)),currentStdDvs];
end
standardDeviations = [standardDeviations;currentStdDvs];

figure
hist(allLongInhibitedExcited,100)
title("Long Inhibited Excited")
subtitle("Created by createDistributionsOfRandomPatternCounts.m")
xlabel("Pattern Count")
ylabel("Frequency")
meanOfData = mean(allLongInhibitedExcited);
xline(meanOfData,'--m')
s = std(allLongInhibitedExcited);
currentStdDvs = []; 
for i=1:length(stddvPlts)
    xline(meanOfData - (s*stddvPlts(i)),'--r',string(meanOfData - (s*stddvPlts(i))   ))
    currentStdDvs = [meanOfData - (s*stddvPlts(i)),currentStdDvs];
end
standardDeviations = [standardDeviations;currentStdDvs];


figure
hist(allLongInhibitedInhibited,100)
title("Long Inhibited Inhibited")
subtitle("Created by createDistributionsOfRandomPatternCounts.m")
xlabel("Pattern Count")
ylabel("Frequency")
meanOfData = mean(allLongInhibitedInhibited);
xline(meanOfData,'--m')
s = std(allLongInhibitedInhibited);
currentStdDvs = []; 
for i=1:length(stddvPlts)
    xline(meanOfData - (s*stddvPlts(i)),'--r',string(meanOfData - (s*stddvPlts(i))   ))
    currentStdDvs = [meanOfData - (s*stddvPlts(i)),currentStdDvs];
end
standardDeviations = [standardDeviations;currentStdDvs];

figure
hist(allShortExcitedExcited,100)
title("Short Excited Excited")
subtitle("Created by createDistributionsOfRandomPatternCounts.m")
xlabel("Pattern Count")
ylabel("Frequency")
meanOfData = mean(allShortExcitedExcited);
xline(meanOfData,'--m')
s = std(allShortExcitedExcited);
currentStdDvs = []; 
for i=1:length(stddvPlts)
    xline(meanOfData - (s*stddvPlts(i)),'--r',string(meanOfData - (s*stddvPlts(i))   ))
    currentStdDvs = [meanOfData - (s*stddvPlts(i)),currentStdDvs];
end
standardDeviations = [standardDeviations;currentStdDvs];

figure
hist(allShortExcitedInhibited,100)
title("Short Excited Inhibited")
subtitle("Created by createDistributionsOfRandomPatternCounts.m")
xlabel("Pattern Count")
ylabel("Frequency")
meanOfData = mean(allShortExcitedInhibited);
xline(meanOfData,'--m')
s = std(allShortExcitedInhibited);
currentStdDvs = []; 
for i=1:length(stddvPlts)
    xline(meanOfData - (s*stddvPlts(i)),'--r',string(meanOfData - (s*stddvPlts(i))   ))
    currentStdDvs = [meanOfData - (s*stddvPlts(i)),currentStdDvs];
end
standardDeviations = [standardDeviations;currentStdDvs];

figure
hist(allShortInhibitedExcited,100)
title("Short Inhibited Excited")
subtitle("Created by createDistributionsOfRandomPatternCounts.m")
xlabel("Pattern Count")
ylabel("Frequency")
meanOfData = mean(allShortInhibitedExcited);
xline(meanOfData,'--m')
s = std(allShortInhibitedExcited);
currentStdDvs = []; 
for i=1:length(stddvPlts)
    xline(meanOfData - (s*stddvPlts(i)),'--r',string(meanOfData - (s*stddvPlts(i))   ))
    currentStdDvs = [meanOfData - (s*stddvPlts(i)),currentStdDvs];
end
standardDeviations = [standardDeviations;currentStdDvs];

figure
hist(allShortInhibitedInhibited,100)
title("Short Inhibited Inhibited")
subtitle("Created by createDistributionsOfRandomPatternCounts.m")
xlabel("Pattern Count")
ylabel("Frequency")
meanOfData = mean(allShortInhibitedInhibited);
xline(meanOfData,'--m')
s = std(allShortInhibitedInhibited);
currentStdDvs = []; 
for i=1:length(stddvPlts)
    xline(meanOfData - (s*stddvPlts(i)),'--r',string(meanOfData - (s*stddvPlts(i))   ))
    currentStdDvs = [meanOfData - (s*stddvPlts(i)),currentStdDvs];
end
standardDeviations = [standardDeviations;currentStdDvs];

disp(standardDeviations);