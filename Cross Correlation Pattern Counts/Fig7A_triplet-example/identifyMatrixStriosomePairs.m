
workingDIR = cd('C:\Users\ldd77\Downloads\Cell Figures and Data\Functions\TWDB Functions\Extracting Data From TWDB');
extractingData = cd(workingDIR);

for currentConcentration=1:height(uniqueConcentrations)
    for currentTaskType=1:height(uniqueTaskType)
        newDir = strcat("Line ","Task Type ",string(uniqueTaskType(currentTaskType))," Concentration ",string(uniqueConcentrations(currentConcentration)));
        mkdir(newDir)
        cd(extractingData)
    
        striosomes_ids = twdb_lookup(twdb_control, 'index', 'key', 'tetrodeType', 'dms', ...
            'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 3, 5, ...
            'grade', 'final_michael_grade', 0, 5, 'key','neuron_type',"MSN",...
            'key','taskType',uniqueTaskType{currentTaskType},...
            'key','conc',uniqueConcentrations(currentConcentration));
        display(striosomes_ids)
        
        matrix_ids = twdb_lookup(twdb_control, 'index', 'key', 'tetrodeType', 'dms', ...
            'grade', 'removable', 0, 0, 'grade', 'striosomality2_type', 0, 0, ...
            'grade', 'final_michael_grade', 0, 5, 'key', 'neuron_type', 'MSN',...
            'key','taskType',uniqueTaskType{currentTaskType},...
            'key','conc',uniqueConcentrations(currentConcentration));
        display(matrix_ids);
        matrix_indexes = [];
        striosome_indexes = [];
        for matrix_counter =1: length(matrix_ids)
            matrix_index = matrix_ids(matrix_counter);
            matrix_index = str2double(matrix_index);
            currentData=twdb_control(matrix_index);
            session = currentData.sessionID;
            rat = currentData.ratID;
            tetrodeN = currentData.tetrodeN;
            for striosome_counter = 1: length(striosomes_ids)
                striosome_index = striosomes_ids(striosome_counter);
                striosome_index = str2double(striosome_index);
                striosome_data = twdb_control(striosome_index);
                striosome_session = striosome_data.sessionID;
                striosome_rat = striosome_data.ratID;
                striosome_tetrode=striosome_data.tetrodeN;
                if strcmp(striosome_rat,rat) && strcmp(striosome_session,session) %&& strcmp(tetrodeN,striosome_tetrode)
                    matrix_indexes = [matrix_indexes;matrix_index];
                    striosome_indexes = [striosome_indexes;striosome_index];
                end
            end
        end
        striosome_matrix_pairs = [striosome_indexes,matrix_indexes];
        cd(workingDIR)
    %     display(strcat("The following task type: ",string(uniqueTaskType{currentTaskType})))
    %     display(strcat("Has this many pairs: ",string(height(matrix_indexes))))
        %now I have strisome_matrix_pairs
        %now I need to modify plot_dynamics code to do what I want
        currentIndex=1;
        striosome_bin_time = 1;
        while currentIndex <= height(striosome_matrix_pairs)
            try
               figure 
               spikes_strio=twdb_control(striosome_matrix_pairs(currentIndex,1)).trial_spikes;
               spikes_matrix=twdb_control(striosome_matrix_pairs(currentIndex,2)).trial_spikes;

               [given_fig,gof,significance,slope] = matrix_strio_plot_dynamics(spikes_strio,spikes_matrix,striosome_bin_time);
               currentDir =cd(newDir);
               thename = strcat("Task Type ",string(uniqueTaskType(currentTaskType))," Concentration ",string(uniqueConcentrations(currentConcentration))," Pair Position ",string(currentIndex),'.fig');
    %            thename = strcat(pwd,thename);
               subtitle(thename)
%                display(thename)
                   try
                       mkdir("Positive Slope")
                       mkdir("Negative Slope")
                       if slope>0
                           cd("Positive Slope");
                           saveas(given_fig,thename)
                           currentIndex=currentIndex+1;
                       elseif slope<0
                           cd("Negative Slope");
                           goodOrNot=input("Is this Graph Good?");
                           if goodOrNot==1
                                saveas(given_fig,thename);
                                currentIndex=currentIndex+1;
                                striosome_bin_time=1;
                           elseif goodOrNot==0
                               striosome_bin_time=input("Enter Bin Time For striosome.\n");
                           end
                       end
                   catch
                      if slope>0
                           cd("Positive Slope");
                           saveas(given_fig,thename)
                           currentIndex=currentIndex+1;
                       elseif slope<0
                           cd("Negative Slope");
                           goodOrNot=input("Is this Graph Good?");
                           if goodOrNot==1
                                saveas(given_fig,thename);
                                currentIndex=currentIndex+1;
                                striosome_bin_time=1;
                           elseif goodOrNot==0

                               striosome_bin_time=input("Enter Bin Time For striosome.\n");
                           end
                      end
                    
                   end 
%                pause(20)
                   close(given_fig)
                   cd(currentDir)
            catch
                close all
                currentIndex=currentIndex+1;
            end

    
        
        end
    end
end






