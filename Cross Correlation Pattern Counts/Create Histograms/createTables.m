%database- tells us which database we are working with
%msORmmORSS- indicates whether this will be matrix-striosome-matrix-matrix, or striosome-striosome
    %1 - matrix-striosome
    %2 - matrix-matrix
    %3 - striosome-striosome
%nameOfFolder-is the directory in which everything will be stored
%pairedOrNot- indicates whether the code should be looking for paired or unpaired neurons
    %1 - paired
    %0 -not paired
%taskTypes - a list of all the task types in the current database
%concentrations - a list of all the concentrations 
%controlStressOrStress2 tells you which database you are in 
    %1 indicates control
    %2 indicates stress
    %3 indicates stress2
%randomizedSubsetOrFull- an int which represents whether or not to use the full found pairs, or a randomized subset of pairs
    %1 - randomized subset of pairs
    %0 - full set of pairs
function [] = createTables(database,msORmmORss,nameOfFolder,pairedOrNot,taskTypes,concentrations,controlStressOrStress2,randomizedSubsetOrFull)


    function [pairs] = MatrixStriosome(mat_ids,strio_ids,pOrNot,currentDataBase)
%pairs is the 2 column n row array where the first column is striosome indexes, and the second is matrix indexes
%mat_ids - 1 column n-row matrix where each item contains the location of matrix neuron in the database
%strio_ids - 1 column by n-row matrix where each item contains the location of strio neuron
%pOrNot - indicates whether or not you are looking for paired/unpaired striosome matrix
    %1=paired
        %in this case you will store matrix-striosome pairs where the ratID and sessionID are the same
    %2=unpaired
        %in this case you will store matrix-striosome pairs where ratID is the same and sessionId isn't the same
%currentDatabase -the database where you will look up the matrix and striosome neuron
%if you are looking for paired matrix-neurons then then for each matrix neuron
    %you will look at all striosome neurons to see if their sessionID and ratID are the same
%if you are looking for unpaired matrix-neurons, then for each matrix neuron
   %you will look at a random 10% of striosome neurons to see if the ratIDs are the same and the sessionIDs are not 
        matrix_indexes = [];
        striosome_indexes = [];
        pairs = [];
        for matrix_counter =1: length(mat_ids)
            matrix_index = mat_ids(matrix_counter);
            matrix_index = str2double(matrix_index);
            currentData=currentDataBase(matrix_index);
            session = currentData.sessionID;
            rat = currentData.ratID;
            if pOrNot==0
                secondList = randperm(length(strio_ids),round(length(strio_ids)*0.10));
            elseif pOrNot==1
                secondList = strio_ids;
            end
%             display(secondList)
            for striosome_counter = secondList
                if pOrNot==0
                    striosome_index = strio_ids(striosome_counter);
                    striosome_index = str2double(striosome_index);
                elseif pOrNot==1
                    striosome_index = str2double(striosome_counter);
                end
                
                striosome_data = currentDataBase(striosome_index);
                striosome_session = striosome_data.sessionID;
                striosome_rat = striosome_data.ratID;
                if pOrNot==1

                    if strcmp(striosome_rat,rat) && strcmp(striosome_session,session) %&& strcmp(tetrodeN,striosome_tetrode)
                        pairs = [pairs;[striosome_index,matrix_index]];
                    end
                elseif pOrNot==0
                    if strcmp(striosome_rat,rat) && ~strcmp(striosome_session,session) %&& strcmp(tetrodeN,striosome_tetrode)
                        pairs = [pairs;[striosome_index,matrix_index]];
                    end
                end

            end
        end
        
    end
    function [pairs] = matrixMatrixORStriosomeStriosome(mat_ids,strio_ids,pOrNot,msOrmmORSS,database,rSOF)
        %mat_ids - a vector of ints, where each int represents a matrix in the database
        %strio_ids - a vector of ints, where each int represents a striosome in the database
        %pOrNot - int which indicates whether you are looking for pairs which have the same ratID and sessionID
            %0 -indicates you are looking for pairs which do not have the same ratId and sessionID
            %1 -indicates you are looking for pairs which do have the same ratID and sessionID
        %msOrmmORSS - indicates whether you are looking for striosome-striosome or matrix-matrix
            %2 indicates you are looking for matrix-matrix pairs
            %3 indicates you are looking for striosome-striosome pairs
        %database - the database you are looking neurons up in (can be contro,stress,or stress2 database)
        %this function is a slighly modified version of the matrixStriosome() on line 19 and works the same way
        %but instead of looking for pairs between matrix and striosome this only looks for pairs between striosomes and striosomes and matrix and matrix
%         display(msOrmmORSS)
        if msOrmmORSS==2
            neuron_ids = mat_ids;
        elseif msOrmmORSS==3
            neuron_ids=strio_ids;
        end
        neuron_neuron_pairs =[];
        for neuron1_counter =1:length(neuron_ids)
            neuron1_index=neuron_ids(neuron1_counter);
            neuron1_index = str2double(neuron1_index);
            currentData = database(neuron1_index);
            session = currentData.sessionID;
            rat = currentData.ratID;
            secondList = neuron_ids;

            for neuron2_counter = secondList                  
                neuron2_index=str2double(neuron2_counter);

                neuron2_data = database(neuron2_index);
                neuron2_session = neuron2_data.sessionID;
                neuron2_rat = neuron2_data.ratID;
                if pOrNot==1
                    if strcmp(neuron2_rat,rat) && strcmp(neuron2_session,session)
                        if neuron1_index~=neuron2_index
                            neuron_neuron_pairs = [neuron_neuron_pairs;[neuron1_index,neuron2_index]];
                        end
                    end
                elseif pOrNot==0
                    if strcmp(neuron2_rat,rat) && ~strcmp(neuron2_session,session)
                        if neuron1_index~=neuron2_index
                            neuron_neuron_pairs = [neuron_neuron_pairs;[neuron1_index,neuron2_index]];
                        end
                    end
                end
            end
        end
        pairs = neuron_neuron_pairs;
        if rSOF
            randomizedIndexes = randperm(height(pairs),round(length(pairs)*0.10));
            pairs = pairs(randomizedIndexes,:);
        end
        display(pairs)
    end
    function[matrix_ids,striosomes_ids,newDir] = makeNewDirectory(taskType,concentration,contStSt2,database)
        %if task type is EQR look up without concentration 
        %if task type is CB and the database is stress, look up without Concetration
        %in all other cases look up with just concentrations and task types
        if strcmp(taskType,'EQR') 
            newDir = "Line Task Type EQR Concentration NA";
            striosomes_ids = twdb_lookup(database, 'index', 'key', 'tetrodeType', 'dms', ...
                'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 3, 5, ...
                'grade', 'final_michael_grade', 0, 5, 'key','neuron_type',"MSN",...
                'key','taskType',taskType);
            matrix_ids = twdb_lookup(database, 'index', 'key', 'tetrodeType', 'dms', ...
                'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 0, 0, ...
                'grade', 'final_michael_grade', 0, 5, 'key', 'neuron_type', 'MSN',...
                'key','taskType',taskType);
            display(striosomes_ids)
        elseif strcmp(taskType,'CB') && contStSt2==2 
            newDir = strcat("Line Task Type CB Concentration NA");
            striosomes_ids = twdb_lookup(database, 'index', 'key', 'tetrodeType', 'dms', ...
                'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 3, 5, ...
                'grade', 'final_michael_grade', 0, 5, 'key','neuron_type',"MSN",...
                'key','taskType',taskType);
            matrix_ids = twdb_lookup(database, 'index', 'key', 'tetrodeType', 'dms', ...
                'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 0, 0, ...
                'grade', 'final_michael_grade', 0, 5, 'key', 'neuron_type', 'MSN',...
                'key','taskType',taskType);
        else
%             display(taskType)
%             display(concentration)
            newDir = strcat("Line ","Task Type ",taskType," Concentration ",string(concentration));
            striosomes_ids = twdb_lookup(database, 'index', 'key', 'tetrodeType', 'dms', ...
                'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 3, 5, ...
                'grade', 'final_michael_grade', 0, 5, 'key','neuron_type',"MSN",...
                'key','taskType',taskType,...
                'key','conc',concentration);
            matrix_ids = twdb_lookup(database, 'index', 'key', 'tetrodeType', 'dms', ...
                'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 0, 1, ...
                'grade', 'final_michael_grade', 0, 5, 'key', 'neuron_type', 'MSN',...
                'key','taskType',taskType,...
                'key','conc',concentration);
        end
    end
    

    %make the directory where you will store everything
    mkdir(nameOfFolder)
    %get the current directory and move into the directory where data can be extracted from the database
    homeDIR = cd('Extracting Data From TWDB');
    extractingData = cd(homeDIR);
    %navigate into the directory where everything will be stored
    cd(nameOfFolder)
    
    %loop through all task types and concentrations so we can find pairs/unpaired neurons for each type
    for currentTaskType=1:height(taskTypes)
        for currentConcentration=1:length(concentrations)
            %move into the extracting data directory
            dirWhereEverythingIsStored =cd(extractingData);
            %make the directory according to specific naming conventions and lookup desired neurons
            [matrix_ids,striosome_ids,newDir]=makeNewDirectory(string(taskTypes(currentTaskType)),...
                concentrations(currentConcentration),...
                controlStressOrStress2,database);


            cd(dirWhereEverythingIsStored)
            mkdir(newDir)
            cd(newDir)
            %call different functions depending on whether you are looking for mat-strio/mat-mat/strio-strio
            if msORmmORss==1
                pairs = MatrixStriosome(matrix_ids,striosome_ids,pairedOrNot,database);
            elseif msORmmORss ==2 || msORmmORss==3
                pairs = matrixMatrixORStriosomeStriosome(matrix_ids,striosome_ids,pairedOrNot,msORmmORss,database,randomizedSubsetOrFull);
            end
            currentIndex=1;
            disp(strcat("Task Type: ",string(taskTypes(currentTaskType))," ",...
            "Concentration: ",string(concentrations(currentConcentration)), ...
            "Has The following Number of Pairs: ",string(height(pairs))));
            while currentIndex <= height(pairs)
                figure

                %if msORMMORss==1 neuron1 is a striosome and neuron2 is a matrix
                %if msORmmORss==2 neuron 1 & 2 are both matrix
                %if msORmmORss==3 neuron 1 & 2 are both striosome
                neuron1Spikes=database(pairs(currentIndex,1)).trial_spikes;
                neuron2Spikes=database(pairs(currentIndex,2)).trial_spikes;
                cd(homeDIR)
                [given_fig,gof,significance,slope]=general_plot_dynamics(neuron1Spikes,neuron2Spikes,msORmmORss);
                cd(dirWhereEverythingIsStored)
                cd(newDir)
                thename = strcat("T T ", string(taskTypes(currentTaskType)), ...
                " Conc ",string(concentrations(currentConcentration)), ...
                " Pair Row ",string(currentIndex), ...
                " RSq ", string(gof),...
                " Sig ", string(significance), ...
                '.fig');
                subtitle(thename)
                   try
                       mkdir("Positive Slope")
                       mkdir("Negative Slope")
                       if slope>0
                           cd("Positive Slope");
                           saveas(given_fig,thename)
                           disp(strcat("Succeeded In Analyzing Pair: ", string(currentIndex),"/",string(height(pairs))));
                       elseif slope<0
                           cd("Negative Slope");
                           saveas(given_fig,thename)
                           disp(strcat("Succeeded In Analyzing Pair: ", string(currentIndex,"/",string(height(pairs)))));
                       elseif significance ==100
                           disp(strcat("Failed in Analyzing Pair: ",string(currentIndex),"/",string(height(pairs))));
                       end
                   catch
                      if slope>0
                           cd("Positive Slope");
                           saveas(given_fig,thename)
                           disp(strcat("Succeeded In Analyzing Pair: ", string(currentIndex),"/",string(height(pairs))));
                       elseif slope<0
%                            cd("Negative Slope");
                           saveas(given_fig,thename)
                           disp(strcat("Succeeded In Analyzing Pair: ", string(currentIndex),"/",string(height(pairs))));
                       elseif significance ==100
                           disp(strcat("Failed in Analyzing Pair: ",string(currentIndex),"/",string(height(pairs))));
                      end
                    
                   end
                   cd("../")
                   currentIndex = currentIndex+1;
                   close(given_fig)
                   
                   
            end
            cd(dirWhereEverythingIsStored)
            disp(strcat("Finished ",string(taskTypes(currentTaskType)),...
                " ",string(concentrations(currentConcentration)),...
                ". It had ", string(height(pairs)), " Pairs."))
            if strcmp(string(taskTypes(currentTaskType)),"EQR")
                break
            end
            if strcmp(string(taskTypes(currentTaskType)),"CB") && controlStressOrStress2==2
                break
            end
        end
    end
    cd(homeDIR)
    countingEverything(nameOfFolder,0.2,0.05)
end