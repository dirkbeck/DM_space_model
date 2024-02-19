function [pairedLongTrialCounter,pairedShortTrialCounter,pairedWeirdlyLongTrialCounter,...
    unpairedLongTrialCounter,unpairedShortTrialCounter,unpairedWeirdlyLongTrialCounter,...
    unpairedShortAndLongCount,pairedShortAndLongCount,array_of_firsts] = plotBins_modified_to_plot(neuron_1_spikes,neuron_2_spikes,neuron_1_evt_timings,neuron_2_evt_timings,~,currentDB,currentPair,neuron_1_index,neuron_2_index,pairedOrUnpaired)
%     function [] = createHistogram(all_neuron_1_times,strio_mean,strio_std,all_neuron_2_times,matrix_mean,matrix_std)
%         stdDvns = [-1,1,-2,2,-3,3];
%         figure
%         histogram(log10(all_neuron_1_times),100)
%         xline(strio_mean,"--r","Mean(Log10(Strio Spikes))")
%         hold on
%         for currentStandardDeviation =1:6
%             xline((strio_std * stdDvns(currentStandardDeviation)) + strio_mean,...
%                 '--k',...
%                 strcat(string(abs(stdDvns(currentStandardDeviation))),"Std. Deviations Away",string((strio_std * stdDvns(currentStandardDeviation)) + strio_mean)))
%         end
%         title("Striosome Spikes")
%         hold off
% 
%         figure
%         hold on
%         histogram(log10(all_neuron_2_times),100)
%         xline(matrix_mean,"--r","Mean(Log10(Matrix Spikes))")
% 
%         for i =1:6
%             xline((matrix_std * stdDvns(i)) + matrix_mean,...
%                 '--k',...
%                 strcat(string(abs(stdDvns(i))),"Std. Deviations Away",string((matrix_std * stdDvns(i)) + matrix_mean)))
%         end
%         title("Matrix Spikes")
%         hold off
%     end
%     function [neur_1_excit_thres,...
%     neur_1_inhib_thres,...
%     neur_2_excit_thres,...
%     neur_2_inhib_thres] = findThresholds(neuron_1_spikes,neuron_2_spikes)
%         all_neuron_1_times = [];
%         all_neuron_2_times = [];
%         for currTrial=1:length(neuron_1_spikes)
%             current_neuron_1_spikes = neuron_1_spikes(currTrial);
%             current_neuron_1_spikes = current_neuron_1_spikes{1};
%             all_neuron_1_times = [all_neuron_1_times;current_neuron_1_spikes];
% 
%             current_neuron_2_spikes = neuron_2_spikes(currTrial);
%             current_neuron_2_spikes = current_neuron_2_spikes{1};
%             all_neuron_2_times = [all_neuron_2_times;current_neuron_2_spikes];
%         end
%         all_neuron_1_times= diff(all_neuron_1_times);
%         all_neuron_1_times(all_neuron_1_times<0) = [];
%         strio_mean = mean(log10(all_neuron_1_times));
%         strio_std = std(log10(all_neuron_1_times));
%         
%         all_neuron_2_times =diff(all_neuron_2_times);
%         all_neuron_2_times(all_neuron_2_times<0) = [];
%         % display((all_neuron_2_times))
%         matrix_mean = mean(log10(all_neuron_2_times));
%         matrix_std = std(log10(all_neuron_2_times));
% 
%         neur_1_excit_thres = (strio_std *0.4) + strio_mean;
%         neur_1_inhib_thres = (strio_std *-0.5) + strio_mean;
%         neur_2_excit_thres = (matrix_std*2)+matrix_mean;
%         neur_2_inhib_thres = (matrix_std * -1) + matrix_mean;
%         
% %         createHistogram(all_neuron_1_times,strio_mean,strio_std,all_neuron_2_times,matrix_mean,matrix_std);
% 
%     end
% [neur_1_excit_thres,...
%     neur_1_inhib_thres,...
%     neur_2_excit_thres,...
%     neur_2_inhib_thres] = findThresholds(neuron_1_spikes,neuron_2_spikes);
    function [eeCounter,eiCounter,ieCounter,iiCounter,nCounter,array_of_firsts] = countPatterns(strioXB,strioTimings,strioAbovThresh,strioBelowThreshold,matXB,matTimings,matrixAbovThresh,matrixBelowThreshold,...
            longBaselineLowerBound,longBaselineUpperBound,immediateBaselineUpperBound,earlyDecisionBinUpperBound,lateDecisionUpperBound,remainingBinUpperBound)
%% Understanding the inhibition threshold
        %start by taking log10(mean(dist(spikeTimes)))
        %Remember that dist(spikeTimings) is an array where each number represents spike_time(N+1) - spike_time(N)
        %if dist(i) is increasing we consider this inhibition
        %so we set the inhibition threshold as log10(mean(dist(spikeTimings))) +5%
        %excitement is the opposite of this
        %as dist(i) is decreasing we consider this excitement
        %so we set the excitement threshold as log10(mean(dis(spikeTimings))) -5%
        %anything > inibititionThreshold = inhbition
        %anything < excitementThreshold = excitement
        %although this might sound strange it is correct to say that anything less than the excitement threshold is excitement
        %it is also correct to say that anything above the inhibitionThreshold is inhibition

        %visual representation
        %_______________log10(mean(dist(spikeTimes)))+ (0.05 *log10(mean(dist(spikeTimes))))______________________________Inhibition Threshold
        %_______________log10(mean(dist(spikeTimes)))______________________________________________________________________
        %_______________log10(mean(dist(spikeTimes))) - (0.05 * log10(mean(dist(spikeTimes))))______________________________ Excitement Threshold


        eeCounter = 0;
        eiCounter = 0;
        ieCounter = 0;
        iiCounter = 0;
        nCounter = 0;
        array_of_firsts = [];
        foundFirstWindowWherePatternsStart = false;
        %xb is recorded time
        %yb is log10(diff(distance))
        

        %Let's assume the following 4 patterns exist
        %____Strio____|_Matrix________
        %Not Firing   |  Not Firing
        %Not Firing   |  Firing
        %Firing       |  Not Firing
        %Firing       |  Firing

        %Let's also assume that we have the following bins
        %_____NAME______________|____Interval_____________
        %Long Baseline Bin      |-15 Seconds to -3 seconds
        %Immediate Baseline Bin | -3 to 0 seconds
        %Early Decision Bin     | 0 to 2 seconds
        %Late Decision Bin      | Greater Than 2 seconds but less than licking time



        [strioLongBaselineRange,...
            strioImmediateBaselineRange,...
            strioEarlyDecisionRange,...
            strioLateDecisionRange,...
            strioFinalBinRange] = categorizeXBIntoBins(longBaselineLowerBound,...
            longBaselineUpperBound,...
            immediateBaselineUpperBound,...
            earlyDecisionBinUpperBound,...
            lateDecisionUpperBound,...
            remainingBinUpperBound,...
            strioXB);

        allStrioBins = {strioLongBaselineRange,strioImmediateBaselineRange,strioEarlyDecisionRange,strioLateDecisionRange,strioFinalBinRange};
        
        [matLongBaselineRange,matImmediateBaselineRange,matEarlyDecisionRange,matLateDecisionRange,matFinalBinRange] = categorizeXBIntoBins(longBaselineLowerBound,...
            longBaselineUpperBound,...
            immediateBaselineUpperBound,...
            earlyDecisionBinUpperBound,...
            lateDecisionUpperBound,...
            remainingBinUpperBound,...
            matXB);

        allMatBins = {matLongBaselineRange,matImmediateBaselineRange,matEarlyDecisionRange,matLateDecisionRange,matFinalBinRange};
        allBinNames = ["Long Baseline","Immediate Baseline","Early Decision","Late Decision","Remaining Bin"];

        [teststrioxb,teststrioyb] = stairs(strioTimings(1:end-1),smoothdata(log10(diff(strioTimings)),"includenan"));
        [testmatxb,testmatyb] = stairs(matTimings(1:end-1),smoothdata(log10(diff(matTimings)),"includenan"));
        
        %strio and mat AbovThresh is a logical array that tells you whether or not the value in yb is greater than the inhibition threshold +5%
        %strio and mat BelowThreshold is a logical array that tells you whether or not the value in yb is less than the inhibition threshold -5%

        testStrioInhibLine = teststrioyb;
        %any item in testStrioInhbitionLine which is not above the inhibition threshold becomes NaN
        testStrioInhibLine(~strioAbovThresh) = NaN;
        %Nan indicates excitment when in the testStrioInhibitionLine

        testStrioExcitLine = teststrioyb;
        %any item in testStrioExcitementLine which is not below the excitement threshold becomes NaN
        testStrioExcitLine(~strioBelowThreshold) = NaN;
        %NAN indicates inhibition when in the testStrioExcitementLine

        

        testMatInhibLine = testmatyb;
        %any item in testMatrixInhbitionLine which is not above the inhibition threshold becomes NaN
        testMatInhibLine(~matrixAbovThresh) = NaN;
        %Nan indicates excitment when in the testMatInhibitionLine

        testMatExcitLine = testmatyb;
        %any item in testMatrixExcitementLine which is not below the excitement threshold becomes NaN
        testMatExcitLine(~matrixBelowThreshold) = NaN;
        %NAN indicates inhibition when in the testMatExcitementLine




        
        for currentBin=1:length(allStrioBins)

            [~,~,matInhibitionSlice,~] = excitationOrInhibition(testmatxb,allMatBins{currentBin},testMatInhibLine);
            %any values that are not NaN in the inhibition slice are inhibition
            [~,~,strioInhibitionSlice,~,strio_inh_min] = excitationOrInhibition(teststrioxb,allStrioBins{currentBin},testStrioInhibLine);

            [~,~,matExcitementSlice,~] = excitationOrInhibition(testmatxb,allMatBins{currentBin},testMatExcitLine);
            [~,~,strioExcitementSlice,~,strio_exc_min] = excitationOrInhibition(teststrioxb,allStrioBins{currentBin},testStrioExcitLine);

%             disp("Strio E and I")
%             disp([size(strioExcitementSlice),size(strioInhibitionSlice)])
%             disp("Matrix E and I")
%             disp([size(matExcitementSlice),size(matInhibitionSlice)])


            lengthOfStrioSlice = length(strioInhibitionSlice);
            lengthOfMatSlice = length(matInhibitionSlice);

            if sum(~isnan(strioInhibitionSlice)) / lengthOfStrioSlice > sum(~isnan(strioExcitementSlice)) / lengthOfStrioSlice && abs((sum(~isnan(strioInhibitionSlice)) / lengthOfStrioSlice) - (sum(~isnan(strioExcitementSlice)) / lengthOfStrioSlice)) > 0.1
                strioStatus = "inhibited";
                if ~foundFirstWindowWherePatternsStart
                    foundFirstWindowWherePatternsStart = true;
                    array_of_firsts = [array_of_firsts;strio_inh_min];
                end

            elseif sum(~isnan(strioInhibitionSlice)) / lengthOfStrioSlice < sum(~isnan(strioExcitementSlice)) / lengthOfStrioSlice && abs((sum(~isnan(strioInhibitionSlice)) / lengthOfStrioSlice) - (sum(~isnan(strioExcitementSlice)) / lengthOfStrioSlice)) > 0.1
                strioStatus = "excited";
                if ~foundFirstWindowWherePatternsStart
                    foundFirstWindowWherePatternsStart = true;
                    disp("strioInhibitionSlice")
                    disp(strioInhibitionSlice)
                    disp(strioInhibitionSlice(find(~isnan(strioInhibitionSlice), 1, 'first')))
                    array_of_firsts = [array_of_firsts;strio_inh_min];
                    
                end
            else
                strioStatus = "neither";
            end


            if sum(~isnan(matInhibitionSlice)) / lengthOfMatSlice > sum(~isnan(matExcitementSlice)) / lengthOfMatSlice && abs((sum(~isnan(matInhibitionSlice)) / lengthOfMatSlice) - (sum(~isnan(matExcitementSlice)) / lengthOfMatSlice)) > 0.1
                matStatus = "inhibited";
            elseif sum(~isnan(matInhibitionSlice)) / lengthOfMatSlice < sum(~isnan(matExcitementSlice)) / lengthOfMatSlice && abs((sum(~isnan(matInhibitionSlice)) / lengthOfMatSlice) - (sum(~isnan(matExcitementSlice)) / lengthOfMatSlice)) > 0.1
                matStatus = "excited";
            else
                matStatus = "neither";
            end

            if strcmpi("excited",strioStatus) && strcmpi("excited",matStatus)
                eeCounter = eeCounter+1;           
%                 disp(strcat(allBinNames(currentBin),": Striosome Excited, Matrix Excited"))
            elseif strcmpi("excited",strioStatus) && strcmpi("inhibited",matStatus)
                eiCounter = eiCounter+1;       
%                 disp(strcat(allBinNames(currentBin),": Striosome Excited, Matrix Inhibited"))
            elseif strcmpi("inhibited",strioStatus) && strcmpi("excited",matStatus)
                ieCounter = ieCounter+1;
%                 disp(strcat(allBinNames(currentBin),": Striosome Inhibited, Matrix Excited"))
            elseif strcmpi("inhibited",strioStatus) && strcmpi("inhibited",matStatus)
%                 disp(strcat(allBinNames(currentBin),": Striosome Inhibited, Matrix Inhibited"))
                iiCounter = iiCounter+1;
            else
                nCounter = nCounter+1;
            end


            
        end


    end
    function [longBaselineRange,immediateBaselineRange,earlyDecisionRange,lateDecisionRange,finalBinRange] = categorizeXBIntoBins(longBaselineLowerBound,longBaselineUpperBound,immediateBaselineUpperBound,earlyDecisionBinUpperBound,lateDecisionUpperBound,...
            remainingBinUpperBound,XB)
        longBaselineRange = (XB >=longBaselineLowerBound & XB < longBaselineUpperBound);
        immediateBaselineRange = (XB >= longBaselineUpperBound & XB < immediateBaselineUpperBound) ;
        earlyDecisionRange = (XB >= immediateBaselineUpperBound & XB < earlyDecisionBinUpperBound);
        lateDecisionRange = (XB >= earlyDecisionBinUpperBound & XB < lateDecisionUpperBound);
        finalBinRange = (XB >= lateDecisionUpperBound & XB <= remainingBinUpperBound);
    end
    function [minIndex,maxIndex,inhibitionSlice,copyOfXB,min] = excitationOrInhibition(XB,condition,inhibitionLine)
        copyOfXB = XB;
        copyOfXB(~logical(condition)) = NaN;
        copyOfXB = copyOfXB(~isnan(copyOfXB));
        if isempty(copyOfXB)
            minIndex=0;
            maxIndex=0;
            inhibitionSlice = [];
            min = nan;
        else
            [min,max] = bounds(copyOfXB);
            minIndex = find(min==XB,1);
            maxIndex = find(max==XB,2);
            if length(maxIndex)>1
                maxIndex = maxIndex(2);
            end            
            inhibitionSlice = inhibitionLine(minIndex:maxIndex);
        end
    end

array_of_firsts = [];

pairedLongTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};
pairedShortTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};
pairedWeirdlyLongTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};

unpairedLongTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};
unpairedShortTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};
unpairedWeirdlyLongTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};

pairedShortAndLongCount = {{0,0},{0,0},{0,0}};
unpairedShortAndLongCount = {{0,0},{0,0},{0,0}};
for currentTrial=1:length(neuron_1_spikes) 
    eeCounter = 0;%Strio excitement Matrix Excitement
    eiCounter = 0;%Strio excitement Matrix Inhibition
    ieCounter = 0;%Strio inhibition Matrix Excitement
    iiCounter = 0;%Strio Inhibition Matrix Inhibition
    nCounter = 0; 

    longBaselineLowerBound = -15;
    longBaselineUpperBound = -3;
    immediateBaselineUpperBound = 0;
    earlyDecisionBinUpperBound = 2.4922;
    neuron_1_lateDecisionUpperBound = neuron_1_evt_timings(currentTrial,4); %late decision is anything greater than 2 but before licking
    neuron_1_lateDecisionUpperBound = 4.4556;
    neuron_2_lateDecisionUpperBound = neuron_2_evt_timings(currentTrial,4); %late decision is anything greater than 2 but before licking
    remainingBin = 20;

    neuron_1_spikes_spike_i = neuron_1_spikes(currentTrial);
    neuron_1_spikes_spike_i = neuron_1_spikes_spike_i{1};
    all_neuron_1_spikes = neuron_1_spikes_spike_i;

    neuron_2_spikes_spike_i = neuron_2_spikes(currentTrial);
    neuron_2_spikes_spike_i = neuron_2_spikes_spike_i{1};
    all_neuron_2_spikes = neuron_2_spikes_spike_i;

    %% check whether the currentTrial is Long Or Short

    shortTrial = 2.49329;
    longTrial = 4.46383;
    neuron_1_current_trial_length = neuron_1_evt_timings(currentTrial,6); 
    neuron_2_current_trial_length = neuron_2_evt_timings(currentTrial,6);

    if neuron_1_current_trial_length ==0 || neuron_2_current_trial_length == 0
        continue;
    else
        if pairedOrUnpaired == 0
            if neuron_1_current_trial_length <= shortTrial
                shortOrLong = 0;
                unpairedShortAndLongCount{currentDB}{1} = unpairedShortAndLongCount{currentDB}{1} +1;
            elseif neuron_1_current_trial_length > shortTrial && neuron_1_current_trial_length <= longTrial
                shortOrLong = 1;
                unpairedShortAndLongCount{currentDB}{2} = unpairedShortAndLongCount{currentDB}{2} +1;
            elseif neuron_1_current_trial_length > longTrial
                shortOrLong = 2;

            end
        else
            if neuron_1_current_trial_length <= shortTrial
                shortOrLong = 0;
                pairedShortAndLongCount{currentDB}{1} = pairedShortAndLongCount{currentDB}{1} +1;
            elseif neuron_1_current_trial_length > shortTrial && neuron_1_current_trial_length <= longTrial
                shortOrLong = 1;
                pairedShortAndLongCount{currentDB}{2} = pairedShortAndLongCount{currentDB}{2} +1;
            elseif neuron_1_current_trial_length > longTrial
                shortOrLong = 2;

            end
        end


    end


    
   figure
    %% Plot the Spikes
    subplot(3,1,1)
    line([neuron_1_spikes_spike_i,neuron_1_spikes_spike_i]',repmat([1-.4;1-.1],[1,length(neuron_1_spikes_spike_i)]),'Color','black');
%     these spikes are plotted form 0.6-0.9, so these are on top 

    line([neuron_2_spikes_spike_i,neuron_2_spikes_spike_i]',repmat([1-.9; 1-.6],[1,length(neuron_2_spikes_spike_i)]),'Color','black');
%      these spikes are plotted from 0.1-0.4, so these are on bottom
    
    title("Striosome (top) and Matrix (bottom) Bursts")
    xlim([-20 20])


    % Plot the Bins
   patch([longBaselineUpperBound,longBaselineLowerBound,longBaselineLowerBound,longBaselineUpperBound], [0.1,0.1,0.95,0.95],...
    'yellow', 'FaceColor', 'blue', 'EdgeColor', 'none', 'LineWidth',1,'FaceAlpha',.3);
    text(mean([longBaselineLowerBound,longBaselineUpperBound]),1,"Long Base.")

    patch([longBaselineLowerBound,immediateBaselineUpperBound,immediateBaselineUpperBound,longBaselineLowerBound], [0.1,0.1,0.95,0.95],...
       'yellow', 'FaceColor', "#7E2F8E", 'EdgeColor', 'none', 'LineWidth',1,'FaceAlpha',.3);
    text(longBaselineUpperBound,1,"Imm. Base.")

    patch([immediateBaselineUpperBound,earlyDecisionBinUpperBound,earlyDecisionBinUpperBound,immediateBaselineUpperBound], [0.1,0.1,0.95,0.95],...
       'yellow', 'FaceColor', 'yellow', 'EdgeColor', 'none', 'LineWidth',1,'FaceAlpha',.3);
    text(immediateBaselineUpperBound,1,"Early Dec.")

    patch([neuron_1_lateDecisionUpperBound,earlyDecisionBinUpperBound,earlyDecisionBinUpperBound,neuron_1_lateDecisionUpperBound], [0.6,0.6,0.95,0.95],...
       'yellow', 'FaceColor', 'cyan', 'EdgeColor', 'none', 'LineWidth',1,'FaceAlpha',.3);
    patch([neuron_1_lateDecisionUpperBound,earlyDecisionBinUpperBound,earlyDecisionBinUpperBound,neuron_1_lateDecisionUpperBound], [0.1,0.1,0.45,0.45],...
       'yellow', 'FaceColor', 'cyan', 'EdgeColor', 'none', 'LineWidth',1,'FaceAlpha',.3);
    text(earlyDecisionBinUpperBound,1,"Late Dec.")

    patch([remainingBin, neuron_1_lateDecisionUpperBound,neuron_1_lateDecisionUpperBound,remainingBin], [0.1,0.1,0.95,0.95],...
       'yellow', 'FaceColor', "#D95319", 'EdgeColor', 'none', 'LineWidth',1,'FaceAlpha',.3);

    text(mean([remainingBin,neuron_2_lateDecisionUpperBound]),1,'Remaining Bin')
%% Plot the Striosome Step Plot
   title("Striosomes On Top, Matrix on Bottom")
    neuron_1_ISI_threshold = [mean(diff(all_neuron_1_spikes)), mean(diff(all_neuron_1_spikes))];
 
   subplot(3,1,2)
    hold on

    if isempty(all_neuron_1_spikes) || isempty(log10(diff(all_neuron_1_spikes)))
        close(gcf)
        continue
    end
    stairs(all_neuron_1_spikes(1:end-1),log10(diff(all_neuron_1_spikes)),'LineWidth',1,'Color','red');

    [strioxb,strioyb] = stairs(all_neuron_1_spikes(1:end-1),log10(diff(all_neuron_1_spikes)));
    strioAboveThreshold = (strioyb >= log10(neuron_1_ISI_threshold(1)) + (0.05 * log10(neuron_1_ISI_threshold(1))));
    strioBelowThreshold = (strioyb <= log10(neuron_1_ISI_threshold(1)) - (0.05 * log10(neuron_1_ISI_threshold(1))));

    strioInhibitionLine = strioyb;
    strioInhibitionLine(~strioAboveThreshold) = NaN;
    plot(strioxb,strioInhibitionLine,'b','LineWidth',2);
    hold on
    line([-20 20], log10(neuron_1_ISI_threshold),'LineWidth',2,'Color','black');
    xlabel('Time (s)'); ylabel('log ISI (s)');
    title("Striosome Neuron Inhibition (Blue) and Excitation (Red)")
    xlim([-20 20])

    % plot the Matrix Step-Plot
    subplot(3,1,3)
    hold on
    neuron_2_ISI_threshold = [mean(diff(all_neuron_2_spikes)), mean(diff(all_neuron_2_spikes))];
    if isempty(all_neuron_2_spikes) || isempty(log10(diff(all_neuron_2_spikes)))
        close(gcf)
        continue
    end
    stairs(all_neuron_2_spikes(1:end-1),log10(diff(all_neuron_2_spikes)),'LineWidth',1,'Color','red');
    
    [xb,yb] = stairs(all_neuron_2_spikes(1:end-1),log10(diff(all_neuron_2_spikes)));
    matrixAboveThreshold = (yb >= log10(neuron_2_ISI_threshold(1)) + (0.05 * log10(neuron_2_ISI_threshold(1))));
    matBelowThreshold = (yb <= log10(neuron_2_ISI_threshold(1)) - (0.05 * log10(neuron_2_ISI_threshold(1))));

    matrixInhibitionLine = yb;
    matrixInhibitionLine(~matrixAboveThreshold) = NaN;
    plot(xb,matrixInhibitionLine,'b','LineWidth',2);
    line([-20 20], log10(neuron_2_ISI_threshold),'LineWidth',2,'Color','black');
    xlabel('Time (s)'); ylabel('log ISI (s)');
    title("Matrix Neuron Excitation(Red) and Inhibition(Blue)")
    xlim([-20 20])

    sgtitle(strcat("Striosomes Neurons Affecting Matrix Neuron Database: Control Pair: ",string(currentPair),...
       " Striosome Index:",string(neuron_1_index), ...
       " Matrix Index: ",string(neuron_2_index),...
       " Current Trial: ",string(currentTrial)))
    hold off;

%     disp(strcat("Trial Number: ",string(currentTrial)))
    [eeCounterNew,eiCounterNew,ieCounterNew,iiCounterNew,nCounterNew,array_of_firsts_new] = countPatterns(strioxb,all_neuron_1_spikes,strioAboveThreshold,strioBelowThreshold,xb,all_neuron_2_spikes,matrixAboveThreshold,matBelowThreshold,...
        longBaselineLowerBound,longBaselineUpperBound,immediateBaselineUpperBound,earlyDecisionBinUpperBound,neuron_1_lateDecisionUpperBound,remainingBin);

%     [eeCounterNew,eiCounterNew,ieCounterNew,iiCounterNew] = countPatterns2(strioInhibitionLine,matrixInhibitionLine);

    %% Update Pattern Counters With Newly Counted Patterns
    eeCounter = eeCounterNew+eeCounter;
    eiCounter = eiCounter+eiCounterNew;
    ieCounter = ieCounter+ieCounterNew;
    iiCounter = iiCounter+iiCounterNew;
    nCounter = nCounter + nCounterNew;
    array_of_firsts = [array_of_firsts,array_of_firsts_new];


% pairedLongTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
% pairedShortTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
% pairedWeirdlyLongTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
% 
% unpairedLongTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
% unpairedShortTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
% unpairedWeirdlyLongTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};


    if shortOrLong == 0
        if pairedOrUnpaired == 1
            pairedShortTrialCounter{currentDB}{1} = pairedShortTrialCounter{currentDB}{1} + eeCounter;
            pairedShortTrialCounter{currentDB}{2} = pairedShortTrialCounter{currentDB}{2} + eiCounter;
            pairedShortTrialCounter{currentDB}{3} = pairedShortTrialCounter{currentDB}{3} + ieCounter;
            pairedShortTrialCounter{currentDB}{4} = pairedShortTrialCounter{currentDB}{4} + iiCounter;
            pairedShortTrialCounter{currentDB}{5} = pairedShortTrialCounter{currentDB}{5} + nCounter;
        elseif pairedOrUnpaired == 0
            unpairedShortTrialCounter{currentDB}{1} = unpairedShortTrialCounter{currentDB}{1} + eeCounter;
            unpairedShortTrialCounter{currentDB}{2} = unpairedShortTrialCounter{currentDB}{2} + eiCounter;
            unpairedShortTrialCounter{currentDB}{3} = unpairedShortTrialCounter{currentDB}{3} + ieCounter;
            unpairedShortTrialCounter{currentDB}{4} = unpairedShortTrialCounter{currentDB}{4} + iiCounter;
            unpairedShortTrialCounter{currentDB}{5} = unpairedShortTrialCounter{currentDB}{5} + nCounter;
        end
    elseif shortOrLong == 1
        if pairedOrUnpaired == 1
            pairedLongTrialCounter{currentDB}{1} = pairedShortTrialCounter{currentDB}{1} + eeCounter;
            pairedLongTrialCounter{currentDB}{2} = pairedShortTrialCounter{currentDB}{2} + eiCounter;
            pairedLongTrialCounter{currentDB}{3} = pairedShortTrialCounter{currentDB}{3} + ieCounter;
            pairedLongTrialCounter{currentDB}{4} = pairedShortTrialCounter{currentDB}{4} + iiCounter;
            pairedLongTrialCounter{currentDB}{5} = pairedShortTrialCounter{currentDB}{5} + nCounter;
        elseif pairedOrUnpaired == 0
%             disp(unpairedLongTrialCounter{currentDB}{1})
            %             disp(eeCounter)
            unpairedLongTrialCounter{currentDB}{1} = unpairedShortTrialCounter{currentDB}{1} + eeCounter;
            unpairedLongTrialCounter{currentDB}{2} = unpairedShortTrialCounter{currentDB}{2} + eiCounter;
            unpairedLongTrialCounter{currentDB}{3} = unpairedShortTrialCounter{currentDB}{3} + ieCounter;
            unpairedLongTrialCounter{currentDB}{4} = unpairedShortTrialCounter{currentDB}{4} + iiCounter;
            unpairedLongTrialCounter{currentDB}{5} = unpairedShortTrialCounter{currentDB}{5} + nCounter;
        end
    elseif shortOrLong == 2
        if pairedOrUnpaired == 1
            pairedWeirdlyLongTrialCounter{currentDB}{1} = pairedShortTrialCounter{currentDB}{1} + eeCounter;
            pairedWeirdlyLongTrialCounter{currentDB}{2} = pairedShortTrialCounter{currentDB}{2} + eiCounter;
            pairedWeirdlyLongTrialCounter{currentDB}{3} = pairedShortTrialCounter{currentDB}{3} + ieCounter;
            pairedWeirdlyLongTrialCounter{currentDB}{4} = pairedShortTrialCounter{currentDB}{4} + iiCounter;
            pairedWeirdlyLongTrialCounter{currentDB}{5} = pairedShortTrialCounter{currentDB}{5} + nCounter;
        elseif pairedOrUnpaired == 0
            unpairedWeirdlyLongTrialCounter{currentDB}{1} = unpairedShortTrialCounter{currentDB}{1} + eeCounter;
            unpairedWeirdlyLongTrialCounter{currentDB}{2} = unpairedShortTrialCounter{currentDB}{2} + eiCounter;
            unpairedWeirdlyLongTrialCounter{currentDB}{3} = unpairedShortTrialCounter{currentDB}{3} + ieCounter;
            unpairedWeirdlyLongTrialCounter{currentDB}{4} = unpairedShortTrialCounter{currentDB}{4} + iiCounter;
            unpairedWeirdlyLongTrialCounter{currentDB}{5} = unpairedShortTrialCounter{currentDB}{5} + nCounter;
        end
    end


%     close all
end
%% Print The Results of Counted Patterns
% disp("_________________________________________________________________________________")
% disp(strcat("Total Counts for Pair Number: ",string(currentPair)," In Control Database"))
% disp(strcat("Striosome Excited, Matrix Excited: ",string(eeCounter)))
% disp(strcat("Striosome Excited, Matrix Inhibited: ",string(eiCounter)))
% disp(strcat("Striosome Inhibited, Matrix Excited: ",string(ieCounter)))
% disp(strcat("Striosome Inhibited, Matrix Inhibited: ",string(iiCounter)))

end