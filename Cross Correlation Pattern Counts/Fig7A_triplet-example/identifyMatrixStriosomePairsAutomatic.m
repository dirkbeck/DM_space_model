workingDIR = cd('C:\Users\ldd77\Downloads\Cell Figures and Data\Functions\TWDB Functions\Extracting Data From TWDB'); %change this to relative path

extractingData = cd(workingDIR); %get path of directory with necessary codes and put it in extractingData %move back into working directory
currentDataBase = twdb_control;

main_directory_name = "control"; %create the name of a directory, the name should represent which database the file will reflect 
mkdir(main_directory_name); %create a directory for the database specified in main_directory_name
cd(main_directory_name); %move into the specified directory

for currentConcentration=1:height(uniqueConcentrations)
    for currentTaskType=1:height(uniqueTaskType)
        newDir = strcat("Line ","Task Type ",string(uniqueTaskType(currentTaskType))," Concentration ",string(uniqueConcentrations(currentConcentration))); %create a dir with a name related to to the current task type and concentration
        mkdir(newDir) %make a dir with the given name
        cd(extractingData) %move into the directory which have the codes that let you extract data from the database 
%     
%         striosomes_ids = twdb_lookup(currentDataBase, 'index', 'key', 'tetrodeType', 'dms', ...
%             'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 3, 5, ...
%             'grade', 'final_michael_grade', 0, 5, 'key','neuron_type',"MSN",...
%             'key','taskType',uniqueTaskType{currentTaskType},...
%             'key','conc',uniqueConcentrations(currentConcentration));

        striosomes_ids = twdb_lookup(currentDataBase, 'index', 'key', 'tetrodeType', 'dms', ... %get striosomes from the database, only looking at task type
            'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 3, 5, ...
            'grade', 'final_michael_grade', 0, 5, 'key','neuron_type',"MSN",...
            'key','taskType',uniqueTaskType{currentTaskType});       
        
%         matrix_ids = twdb_lookup(currentDataBase, 'index', 'key', 'tetrodeType', 'dms', ...
%             'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 0, 1, ...
%             'grade', 'final_michael_grade', 0, 5, 'key', 'neuron_type', 'MSN',...
%             'key','taskType',uniqueTaskType{currentTaskType},...
%             'key','conc',uniqueConcentrations(currentConcentration));

        matrix_ids = twdb_lookup(currentDataBase, 'index', 'key', 'tetrodeType', 'dms', ... %get matrix from the database, only looking at task type 
            'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 0, 1, ...
            'grade', 'final_michael_grade', 0, 5, 'key', 'neuron_type', 'MSN',...
            'key','taskType',uniqueTaskType{currentTaskType});


        display(matrix_ids);
        display(striosomes_ids)
        matrix_indexes = [];
        striosome_indexes = [];
        for matrix_counter =1: length(matrix_ids) %cycle through all matrix ids returned by twdb_lookup
            matrix_index = matrix_ids(matrix_counter); %get the current matrix neuron's position in the database
            matrix_index = str2double(matrix_index); %convert to a double as by default twdb_lookup will return a string


            currentData=currentDataBase(matrix_index); %get the row in the database which has data on the matrix neuron
            session = currentData.sessionID; %get the sessionID from the current row, this sessionID is a date
            rat = currentData.ratID; %get the name of the rat of the current row 
            tetrodeN = currentData.tetrodeN; %get the tetrode number from the current row

            
            for striosome_counter = 1: length(striosomes_ids) %cycle through all striosome ids returned by twdb_lookup 
                striosome_index = striosomes_ids(striosome_counter);
                striosome_index = str2double(striosome_index);
                striosome_data = currentDataBase(striosome_index);
                striosome_session = striosome_data.sessionID;
                striosome_rat = striosome_data.ratID;
                striosome_tetrode=striosome_data.tetrodeN;
                if strcmp(striosome_rat,rat) && strcmp(striosome_session,session) %&& strcmp(tetrodeN,striosome_tetrode) %check to make sure the striosome and matrix belong to the same rat and have the same id
                    matrix_indexes = [matrix_indexes;matrix_index]; %record the matrix index
                    striosome_indexes = [striosome_indexes;striosome_index]; %record the striosome index
                end
            end
        end
        striosome_matrix_pairs = [striosome_indexes,matrix_indexes]; %record the pair 
        cd(workingDIR) %move back into og directory 
    %     display(strcat("The following task type: ",string(uniqueTaskType{currentTaskType})))
    %     display(strcat("Has this many pairs: ",string(height(matrix_indexes))))
        %now I have strisome_matrix_pairs
        %now I need to modify plot_dynamics code to do what I want
        currentIndex=1;
        striosome_bin_time = 1; 
        while currentIndex <= height(striosome_matrix_pairs) %cycle through all the found pairs 
            try
               figure %create a figure to plot things on later
               spikes_strio=currentDataBase(striosome_matrix_pairs(currentIndex,1)).trial_spikes; %get the spikes of the current strio
               spikes_matrix=currentDataBase(striosome_matrix_pairs(currentIndex,2)).trial_spikes; %get the spikes of the current matrix neuron

               [given_fig,gof,significance,slope] = matrix_strio_plot_dynamics(spikes_strio,spikes_matrix,striosome_bin_time); %creates a figure of cross correlation between strio and matrix
               currentDir =cd(newDir);
               thename = strcat("T T ", string(uniqueTaskType(currentTaskType)), ...
                   " Conc ",string(uniqueConcentrations(currentConcentration)), ...
                   " Pair Row ",string(currentIndex), ...
                   " RSq ", string(gof),...
                   " Sig ", string(significance), ...
                   '.fig');
    %            thename = strcat(pwd,thename);
               subtitle(thename)
%                display(thename)
                   try
                       mkdir("Positive Slope")
                       mkdir("Negative Slope")
                       if slope>0
                           cd("Positive Slope");
                           saveas(given_fig,thename)
                       elseif slope<0
                           cd("Negative Slope");
                           saveas(given_fig,thename)
                       end
                   catch
                      if slope>0
                           cd("Positive Slope");
                           saveas(given_fig,thename)
                       elseif slope<0
                           cd("Negative Slope");
                           saveas(given_fig,thename)
                      end
                    
                   end 
%                pause(20)
                   currentIndex=currentIndex+1; 
                   close(given_fig)
                   cd(currentDir)
            catch
                close all
                currentIndex=currentIndex+1;
            end

    
        
        end
    end
end




