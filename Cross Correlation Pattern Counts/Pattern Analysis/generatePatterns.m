%% load databases
[dbs,twdbs] = loadData;

%% find neuron ids
[cb_pls_ids, cb_plNotS_ids, cb_strio_ids, cb_matrix_ids, ...
    cb_swn_ids, cb_swn_not_hfn_ids, cb_hfn_ids] ...
    = find_neuron_ids(twdbs, 'CB', [-Inf,-Inf,-Inf,-Inf,1]);
cd("..\Pattern Analysis")
[~,sessionDir_neurons] = findAllSessions(twdbs,dbs);
% cd("..\Pattern Analysis")

%% Get Pairs
% display(cb_strio_ids)
% theStrioIdsAsCell = twdb_lookup(twdbs{1}, 'index', 'key', 'tetrodeType', 'dms', ...
%     'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 3, 5, ...
%     'grade', 'final_michael_grade', 0, 5, 'key','neuron_type',"MSN",...
%     'key','taskType','TR');
% 
% cb_strio_ids = {cell2mat(theStrioIdsAsCell),0,0};
% 
% theMatrixIdsAsCell = twdb_lookup(twdbs{1}, 'index', 'key', 'tetrodeType', 'dms', ...
%     'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 0, 0, ...
%     'grade', 'final_michael_grade', 0, 5, 'key', 'neuron_type', 'MSN',...
%     'key','taskType','TR');
% cb_matrix_ids = {cell2mat(theMatrixIdsAsCell),0,0};
% display(cb_strio_ids)
cd("C:\Users\ldd77\OneDrive\Desktop\Striosome-Matrix-Analysis\Pattern Analysis")

disp(cb_matrix_ids{1})
disp(cb_strio_ids{1})
[neuron_1_ids,neuron_2_ids] = findSpecifiedNeuronsInDatabases(dbs,sessionDir_neurons,cb_matrix_ids,cb_strio_ids);
all_matrix_strio_pairs = getPairs(dbs,neuron_1_ids,neuron_2_ids,sessionDir_neurons);
all_matrix_strio_pairs = cutDownPairsToNPairs(80,all_matrix_strio_pairs);
all_matrix_strio_pairs = remove_neurons_connected_to_themselves(all_matrix_strio_pairs);
nlags=1;

%% The important part
% I still need to keep track of Patterns,
%but now I need to specify where each count is goooooooing
%it can only be a short trial or a long trial
%where short is anything less than or equal to 2.49329
%and long is anything less than or equal to 4.46383 but still greater than the short trial
%these numbers are hardcoded into plotBins.m and can be changed if the need ever arises
%the variable shortOrLong tells us which this is 
    %shortOrLong=0 : short Trial
    %shortOrLong=1: long trial
    %shortOrLong=2: this is an edge case which indicates that the trial was unusually long, likely due to artifact 
%the variable pairedOrUnpaired tells us whether or not granger causality detected the pairs to be connected or not
    %pairedOrUnpaired =1: paired
    %pairedOrUnpaired =0: unpaired


eeC = {0,0,0};
eiC = {0,0,0};
ieC = {0,0,0};
iiC = {0,0,0};
%the structure of the following variables is as follows
%TrialCounter(databaseNumber)(Pattern You are Counting)
    %databaseNumber = 1 - control
    %databaseNumber = 2 - stress
    %databaseNumber = 3 - stress 2
    %Pattern You Are Counting = 1: striosome excited, matrix excited
    %Pattern You Are Counting = 1: striosome excited, matrix inhibited
    %Pattern You Are Counting = 1: striosome inhibited, matrix excited
    %Pattern You Are Counting = 1: striosome inhibited, matrix inhibited

pairedLongTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};
pairedShortTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};
pairedWeirdlyLongTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};

unpairedLongTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};
unpairedShortTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};
unpairedWeirdlyLongTrialCounter = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};

%first number represents short count
%second number reresents longCount
%each cell array represents a database
pairedShortAndLongCount = {{0,0},{0,0},{0,0}};
unpairedShortAndLongCount = {{0,0},{0,0},{0,0}};


for currentDB=1:length(twdbs)
    currentDatabasePairs = all_matrix_strio_pairs{currentDB};
    currentDatabase = twdbs{currentDB};
    for currentPair=1:height(currentDatabasePairs)
        cd("..\Pattern Analysis")
        [result,pairedLongTrialCounterCurrent,pairedShortTrialCounterCurrent,pairedWeirdlyLongTrialCounterCurrent,...
    unpairedLongTrialCounterCurrent,unpairedShortTrialCounterCurrent,unpairedWeirdlyLongTrialCounterCurrent,...
    shortOrLong,pairedOrUnpaired,unpairedCountCurr,pairedCountCurr]  = runGrangerCausality(currentPair,currentDatabase,currentDatabasePairs,nlags,currentDB,dbs);
        % UPDATE THE TOTAL COUNTS
        pairedLongTrialCounter{currentDB}{1} = pairedLongTrialCounter{currentDB}{1} + pairedLongTrialCounterCurrent{currentDB}{1};
        pairedLongTrialCounter{currentDB}{2} = pairedLongTrialCounter{currentDB}{2} + pairedLongTrialCounterCurrent{currentDB}{2};
        pairedLongTrialCounter{currentDB}{3} = pairedLongTrialCounter{currentDB}{3} + pairedLongTrialCounterCurrent{currentDB}{3};
        pairedLongTrialCounter{currentDB}{4} = pairedLongTrialCounter{currentDB}{4} + pairedLongTrialCounterCurrent{currentDB}{4};
        pairedLongTrialCounter{currentDB}{5} = pairedLongTrialCounter{currentDB}{5} + pairedLongTrialCounterCurrent{currentDB}{5};


        pairedShortTrialCounter{currentDB}{1} = pairedShortTrialCounter{currentDB}{1} + pairedShortTrialCounterCurrent{currentDB}{1};
        pairedShortTrialCounter{currentDB}{2} = pairedShortTrialCounter{currentDB}{2} + pairedShortTrialCounterCurrent{currentDB}{2};
        pairedShortTrialCounter{currentDB}{3} = pairedShortTrialCounter{currentDB}{3} + pairedShortTrialCounterCurrent{currentDB}{3};
        pairedShortTrialCounter{currentDB}{4} = pairedShortTrialCounter{currentDB}{4} + pairedShortTrialCounterCurrent{currentDB}{4};
        pairedShortTrialCounter{currentDB}{5} = pairedShortTrialCounter{currentDB}{5} + pairedShortTrialCounterCurrent{currentDB}{5};

        pairedWeirdlyLongTrialCounter{currentDB}{1} = pairedWeirdlyLongTrialCounter{currentDB}{1} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{1};
        pairedWeirdlyLongTrialCounter{currentDB}{2} = pairedWeirdlyLongTrialCounter{currentDB}{2} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{2};
        pairedWeirdlyLongTrialCounter{currentDB}{3} = pairedWeirdlyLongTrialCounter{currentDB}{3} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{3};
        pairedWeirdlyLongTrialCounter{currentDB}{4} = pairedWeirdlyLongTrialCounter{currentDB}{4} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{4};
        pairedWeirdlyLongTrialCounter{currentDB}{5} = pairedWeirdlyLongTrialCounter{currentDB}{5} + pairedWeirdlyLongTrialCounterCurrent{currentDB}{5};

%         disp(unpairedLongTrialCounter{currentDB}{1})
%         disp(unpairedLongTrialCounterCurrent{currentDB}{1})
        unpairedLongTrialCounter{currentDB}{1} = unpairedLongTrialCounter{currentDB}{1} + unpairedLongTrialCounterCurrent{currentDB}{1};
        unpairedLongTrialCounter{currentDB}{2} = unpairedLongTrialCounter{currentDB}{2} + unpairedLongTrialCounterCurrent{currentDB}{2};
        unpairedLongTrialCounter{currentDB}{3} = unpairedLongTrialCounter{currentDB}{3} + unpairedLongTrialCounterCurrent{currentDB}{3};
        unpairedLongTrialCounter{currentDB}{4} = unpairedLongTrialCounter{currentDB}{4} + unpairedLongTrialCounterCurrent{currentDB}{4};
        unpairedLongTrialCounter{currentDB}{5} = unpairedLongTrialCounter{currentDB}{5} + unpairedLongTrialCounterCurrent{currentDB}{5};

        unpairedShortTrialCounter{currentDB}{1} = unpairedShortTrialCounter{currentDB}{1} + unpairedShortTrialCounterCurrent{currentDB}{1};
        unpairedShortTrialCounter{currentDB}{2} = unpairedShortTrialCounter{currentDB}{2} + unpairedShortTrialCounterCurrent{currentDB}{2};
        unpairedShortTrialCounter{currentDB}{3} = unpairedShortTrialCounter{currentDB}{3} + unpairedShortTrialCounterCurrent{currentDB}{3};
        unpairedShortTrialCounter{currentDB}{4} = unpairedShortTrialCounter{currentDB}{4} + unpairedShortTrialCounterCurrent{currentDB}{4};    
        unpairedShortTrialCounter{currentDB}{5} = unpairedShortTrialCounter{currentDB}{5} + unpairedShortTrialCounterCurrent{currentDB}{5};    

        unpairedWeirdlyLongTrialCounter{currentDB}{1} = unpairedWeirdlyLongTrialCounter{currentDB}{1} + unpairedWeirdlyLongTrialCounterCurrent{currentDB}{1};
        unpairedWeirdlyLongTrialCounter{currentDB}{2} = unpairedWeirdlyLongTrialCounter{currentDB}{2} + unpairedWeirdlyLongTrialCounterCurrent{currentDB}{2};
        unpairedWeirdlyLongTrialCounter{currentDB}{3} = unpairedWeirdlyLongTrialCounter{currentDB}{3} + unpairedWeirdlyLongTrialCounterCurrent{currentDB}{3};
        unpairedWeirdlyLongTrialCounter{currentDB}{4} = unpairedWeirdlyLongTrialCounter{currentDB}{4} + unpairedWeirdlyLongTrialCounterCurrent{currentDB}{4};
        unpairedWeirdlyLongTrialCounter{currentDB}{5} = unpairedWeirdlyLongTrialCounter{currentDB}{5} + unpairedWeirdlyLongTrialCounterCurrent{currentDB}{5};
        
        pairedShortAndLongCount{currentDB}{1} = pairedShortAndLongCount{currentDB}{1} + pairedCountCurr{currentDB}{1};
        pairedShortAndLongCount{currentDB}{2} = pairedShortAndLongCount{currentDB}{2} + pairedCountCurr{currentDB}{2};
        
        unpairedShortAndLongCount{currentDB}{1} = unpairedShortAndLongCount{currentDB}{1} + unpairedCountCurr{currentDB}{1};
        unpairedShortAndLongCount{currentDB}{2} = unpairedShortAndLongCount{currentDB}{2} + unpairedCountCurr{currentDB}{2};
%         close all
        if  result== 1
            break
        end
        
    end
    if result==1
        break
    end
end

%% Create Figures

% % pairedLongTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
% % pairedShortTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
% % pairedWeirdlyLongTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
% % 
% % unpairedLongTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
% % unpairedShortTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
% % unpairedWeirdlyLongTrialCounter = {{0,0,0,0},{0,0,0,0},{0,0,0,0}};
% 
% categories = {'Strio Excited, Matrix Excited';'';'Strio Excited Matrix Inhibited';'';'Strio Inhibited, Matrix Excited';'';'Strio Inhibited, Matrix Inhibited';'';'No Pattern Detected'};
% 
% figure
% hold on
% lcounts = [pairedLongTrialCounter{1}{1},unpairedLongTrialCounter{1}{1};...
%     pairedLongTrialCounter{1}{2},unpairedLongTrialCounter{1}{2};...
%     pairedLongTrialCounter{1}{3},unpairedLongTrialCounter{1}{3};...
%     pairedLongTrialCounter{1}{4},unpairedLongTrialCounter{1}{4};...
%     pairedLongTrialCounter{1}{5},unpairedLongTrialCounter{1}{5}];
% disp(lcounts)
% lcountsCol1Normalized = lcounts(:,1) ./ pairedShortAndLongCount{1}{2};
% lcountsCol2Normalized = lcounts(:,2) ./ unpairedShortAndLongCount{1}{2};
% lcounts = [lcountsCol1Normalized,lcountsCol2Normalized]; 
% disp(lcounts)
% longTrialNormalizationFactor = shortAndLongCount{1}{2};
% disp(longTrialNormalizationFactor)
% bar(lcounts)
% xticklabels(categories)
% title("Control Database Pattern Counts Long Trials, paired by Granger Causality")
% legend("Paired","Unpaired")
% ylim([0,4])
% hold off
% 
% figure
% hold on
% scounts = [pairedShortTrialCounter{1}{1},unpairedShortTrialCounter{1}{1};...
%     pairedShortTrialCounter{1}{2},unpairedShortTrialCounter{1}{2};...
%     pairedShortTrialCounter{1}{3},unpairedShortTrialCounter{1}{3};...
%     pairedShortTrialCounter{1}{4},unpairedShortTrialCounter{1}{4};...
%     pairedShortTrialCounter{1}{5},unpairedShortTrialCounter{1}{5}];
% scountsCol1Normalized = scounts(:,1) ./ pairedShortAndLongCount{1}{1};
% scountsCol2Normalized = scounts(:,2) ./ unpairedShortAndLongCount{1}{1};
% scounts = [scountsCol1Normalized,scountsCol2Normalized]; 
% bar(scounts)
% xticklabels(categories)
% title("Control Database Pattern Counts Short Trials, paired by Granger Causality")
% legend("Paired","Unpaired")
% text(0.5,pairedShortTrialCounter{1}{1},"Paired")
% ylim([0,4])
% hold off
% 
% 
% 
% % figure
% % hold on
% % WLcounts =[pairedWeirdlyLongTrialCounter{1}{1},unpairedWeirdlyLongTrialCounter{1}{1};...
% %     pairedWeirdlyLongTrialCounter{1}{2},unpairedWeirdlyLongTrialCounter{1}{2};...
% %     pairedWeirdlyLongTrialCounter{1}{3},unpairedWeirdlyLongTrialCounter{1}{3};...
% %     pairedWeirdlyLongTrialCounter{1}{4},unpairedWeirdlyLongTrialCounter{1}{4}];
% % bar(WLcounts)
% % xticklabels(categories)
% % title("Control Database Pattern Counts Weirdly Long Trials, paired by Granger Causality")
% % legend("Paired","Unpaired")
% % hold off
% 
% 
