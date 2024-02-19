load("LongRandomExcitedExcited.mat")
load("LongRandomExcitedInhibited.mat")
load("LongRandomInhibitedExcited.mat")
load("LongRandomInhibitedInhibited.mat")
load("ShortRandomExcitedExcited.mat")
load("ShortRandomExcitedInhibited.mat")
load("ShortRandomInhibitedExcited.mat")
load("ShortRandomInhibitedInhibited.mat")

stddvPlts = [-3,-2,-1,1,2,3];

figure
hist(allLongExcitedExcited,100)
title("Long Excited Excited")
xlabel("Pattern Count")
ylabel("Frequency")
meanOfData = mean(allLongExcitedExcited);
xline(meanOfData,'--m')
s = std(allLongExcitedExcited);
for i=1:length(stddvPlts)
    xline(meanOfData - (s*stddvPlts(i)),'--r',string(meanOfData - (s*stddvPlts(i))   ))
end

figure
hist(allLongExcitedInhibited,100)
title("Long Excited Inhibited")
xlabel("Pattern Count")
ylabel("Frequency")
meanOfData = mean(allLongExcitedInhibited);
xline(meanOfData,'--m')
s = std(allLongExcitedInhibited);
for i=1:length(stddvPlts)
    xline(meanOfData - (s*stddvPlts(i)),'--r',string(meanOfData - (s*stddvPlts(i))   ))
end

figure
hist(allLongInhibitedExcited,100)
title("Long Inhibited Excited")
xlabel("Pattern Count")
ylabel("Frequency")
meanOfData = mean(allLongInhibitedExcited);
xline(meanOfData,'--m')
s = std(allLongInhibitedExcited);
for i=1:length(stddvPlts)
    xline(meanOfData - (s*stddvPlts(i)),'--r',string(meanOfData - (s*stddvPlts(i))   ))
end

figure
hist(allLongInhibitedInhibited,100)
title("Long Inhibited Inhibited")
xlabel("Pattern Count")
ylabel("Frequency")
meanOfData = mean(allLongInhibitedInhibited);
xline(meanOfData,'--m')
s = std(allLongInhibitedInhibited);
for i=1:length(stddvPlts)
    xline(meanOfData - (s*stddvPlts(i)),'--r',string(meanOfData - (s*stddvPlts(i))   ))
end

figure
hist(allShortExcitedExcited,100)
title("Short Excited Excited")
xlabel("Pattern Count")
ylabel("Frequency")
meanOfData = mean(allShortExcitedExcited);
xline(meanOfData,'--m')
s = std(allShortExcitedExcited);
for i=1:length(stddvPlts)
    xline(meanOfData - (s*stddvPlts(i)),'--r',string(meanOfData - (s*stddvPlts(i))   ))
end

figure
hist(allShortExcitedInhibited,100)
title("Short Excited Inhibited")
xlabel("Pattern Count")
ylabel("Frequency")
meanOfData = mean(allShortExcitedInhibited);
xline(meanOfData,'--m')
s = std(allShortExcitedInhibited);
for i=1:length(stddvPlts)
    xline(meanOfData - (s*stddvPlts(i)),'--r',string(meanOfData - (s*stddvPlts(i))   ))
end

figure
hist(allShortInhibitedExcited,100)
title("Short Inhibited Excited")
xlabel("Pattern Count")
ylabel("Frequency")
meanOfData = mean(allShortInhibitedExcited);
xline(meanOfData,'--m')
s = std(allShortInhibitedExcited);
for i=1:length(stddvPlts)
    xline(meanOfData - (s*stddvPlts(i)),'--r',string(meanOfData - (s*stddvPlts(i))   ))
end

figure
hist(allShortInhibitedInhibited,100)
title("Short Inhibited Inhibited")
xlabel("Pattern Count")
ylabel("Frequency")
meanOfData = mean(allShortInhibitedInhibited);
xline(meanOfData,'--m')
s = std(allShortInhibitedInhibited);
for i=1:length(stddvPlts)
    xline(meanOfData - (s*stddvPlts(i)),'--r',string(meanOfData - (s*stddvPlts(i))   ))
end