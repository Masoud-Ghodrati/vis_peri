function [Results, position_Tick] = calcualte_Periphery_dPrime(data_Path)
%  This function takes the data_Paths as input, which is the path that raw
%  data of experiment has been stroed, the output of the function is the
%  accuracy of subjects in the experiemnt

dir_Cat_Level = dir(data_Path); % The directory of 3 categorization level, there should be all in Dataset folder
dir_Cat_Level = dir_Cat_Level(3:end);
%% Data formating
for iCategory_Level = 1 : length(dir_Cat_Level)
    
    current_Category = dir([data_Path '\' dir_Cat_Level(iCategory_Level).name]);
    current_Category = current_Category(3:end);
    
    for iExperimnet_InCategory = 1 : length(current_Category)
        
        this_Experiment = dir([data_Path '\' dir_Cat_Level(iCategory_Level).name '\' current_Category(iExperimnet_InCategory).name]);
        this_Experiment = this_Experiment(3:end);
        
        This_Experiment_Result.CatLevelName = dir_Cat_Level(iCategory_Level).name;
        This_Experiment_Result.TaskName = current_Category(iExperimnet_InCategory).name;
        
        This_Experiment_Result.PerformanceAll = [];
        This_Experiment_Result.PerformanceClass_1 = [];
        This_Experiment_Result.PerformanceClass_1_Name = [];
        This_Experiment_Result.PerformanceClass_2 = [];
        This_Experiment_Result.PerformanceClass_2_Name = [];
        
        for iSubject = 1 : length(this_Experiment)
            
            this_Subject = dir([data_Path '\' dir_Cat_Level(iCategory_Level).name '\',...
                current_Category(iExperimnet_InCategory).name '\' this_Experiment(iSubject).name]);
            this_Subject = this_Subject(3);
            
            this_Subject_Data = readtable([data_Path '\' dir_Cat_Level(iCategory_Level).name '\',...
                current_Category(iExperimnet_InCategory).name '\' this_Experiment(iSubject).name '\'  this_Subject.name]);
            
            stimulus_Position_Array = this_Subject_Data(:,4).Variables;
            subjetc_Response_Array = this_Subject_Data(:,11).Variables;
            task_Label_Array = this_Subject_Data(:,3).Variables;
            unique_Task = unique(this_Subject_Data(:,3).Variables);
            if length(unique_Task{1})>=2 || length(unique_Task{2})>=2
                if ~(length(unique_Task{1})==1 && length(unique_Task{2})==2)
                    task_Temp{1} = unique_Task{2};
                    task_Temp{2} = unique_Task{1};
                    unique_Task = task_Temp;
                end
            end
            [~, idx_Class1] = ismember( task_Label_Array, unique_Task{1} );
            [~, idx_Class2] = ismember( task_Label_Array, unique_Task{2} );
            this_subject_dPrime = []; this_subject_Hitt = []; this_subject_FalseAlarm = [];
            fprintf([',   Task 1: ' unique_Task{1} ' , Task 2: ' unique_Task{2} '\n'])
            
            
            for iPosition = 1 : length(unique(stimulus_Position_Array)) % loop over positions
                
                
                this_subject_Hitt(iPosition) = mean(subjetc_Response_Array(stimulus_Position_Array==iPosition & idx_Class1));
                this_Hitt_NumTrial = length(subjetc_Response_Array(stimulus_Position_Array==iPosition & idx_Class1));
                fprintf([',   Trials: ' num2str(length(subjetc_Response_Array(stimulus_Position_Array==iPosition & idx_Class1)))])
                
                this_subject_FalseAlarm(iPosition) = 1-mean(subjetc_Response_Array(stimulus_Position_Array==iPosition & idx_Class2));
                this_FalseAlarm_NumTrial =  length(subjetc_Response_Array(stimulus_Position_Array==iPosition & idx_Class2));
                fprintf([', Trials: ' num2str(length(subjetc_Response_Array(stimulus_Position_Array==iPosition & idx_Class2)))])
                
                fprintf([',    FL: ' num2str(this_subject_FalseAlarm(iPosition)) ' Hitt:'  num2str(this_subject_Hitt(iPosition))])
                this_subject_dPrime(:, iPosition) = dprime_simple(this_subject_Hitt(iPosition),this_subject_FalseAlarm(iPosition), this_Hitt_NumTrial, this_FalseAlarm_NumTrial);
                fprintf('\n')
                
            end
            if isnan(this_subject_dPrime)
                error('Accuracy should not be nan')
            end
            
            This_Experiment_Result.PerformanceAll(iSubject, :) = this_subject_dPrime(1, :);
            This_Experiment_Result.PerformanceClass_1(iSubject, :) = this_subject_Hitt;
            This_Experiment_Result.PerformanceClass_1_Name = unique_Task{1};
            This_Experiment_Result.PerformanceClass_2(iSubject, :) = this_subject_FalseAlarm;
            This_Experiment_Result.PerformanceClass_2_Name = unique_Task{2};
            
        end
        
        
        Results{iCategory_Level}{iExperimnet_InCategory} = This_Experiment_Result;
        
    end
    
    
end

position_Tick = round(unique(this_Subject_Data(:,5).Variables))';