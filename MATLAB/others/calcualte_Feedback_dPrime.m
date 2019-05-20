function [Results, position_Tick] = calcualte_Feedback_dPrime(data_Path)
%  This function takes the data_Paths as input, which is the path that raw
%  data of experiment has been stroed, the output of the function is the
%  accuracy (d') of subjects in the experiemnt

dir_Category_Level = dir(data_Path); % The directory of 3 categorization level, there should be all in Dataset folder
dir_Category_Level = dir_Category_Level(3:end);
%% Data formating
for iCategory_Level = 1 : length(dir_Category_Level)
    
    current_Category = dir([data_Path '\' dir_Category_Level(iCategory_Level).name]);
    current_Category = current_Category(3:end);
    
    This_Experiment_Result.TaskName = dir_Category_Level(iCategory_Level).name;
    This_Experiment_Result.PerformanceAll = [];
    This_Experiment_Result.PerformanceClass_1 = [];
    This_Experiment_Result.PerformanceClass_1_Name = [];
    This_Experiment_Result.PerformanceClass_2 = [];
    This_Experiment_Result.PerformanceClass_2_Name = [];
    
    for iSubject = 1 : length(current_Category)
        
        this_Subject = dir([data_Path '\' dir_Category_Level(iCategory_Level).name '\',...
            current_Category(iSubject).name]);
        this_Subject = this_Subject(3);
        
        this_Subject_Data = readtable([data_Path '\' dir_Category_Level(iCategory_Level).name '\',...
            current_Category(iSubject).name '\'  this_Subject.name]);
        
        stimulus_Position_Array = this_Subject_Data(:,4).Variables;
        unique_Position = unique(stimulus_Position_Array)';
        subjetc_Response_Array = this_Subject_Data(:,12).Variables;
        task_Label_Array = this_Subject_Data(:,3).Variables;
        unique_Task = unique(this_Subject_Data(:,3).Variables);
        if length(unique_Task{1})>=2 || length(unique_Task{2})>=2
            if ~(length(unique_Task{1})==1 && length(unique_Task{2})==2)
                task_Temp{1} = unique_Task{2};
                task_Temp{2} = unique_Task{1};
                unique_Task = task_Temp;
            end
        end
        sOA_Array = this_Subject_Data(:,11).Variables;
        unique_sOA = unique(sOA_Array)';
        
        [~, idx_Class1] = ismember( task_Label_Array, unique_Task{1} );
        [~, idx_Class2] = ismember( task_Label_Array, unique_Task{2} );
        
        fprintf([',   Task 1: ' unique_Task{1} ' , Task 2: ' unique_Task{2} '\n'])
        
        for isOA = 1 : length(unique_sOA)
            this_subject_dPrime = []; this_subject_Hit = []; this_subject_FalseAlarm = [];
            for iPosition = 1 : length(unique_Position)% positions
                
                this_subject_Hit(iPosition) = mean(subjetc_Response_Array(stimulus_Position_Array==unique_Position(iPosition) & idx_Class1 & sOA_Array==unique_sOA(isOA)));
                this_Hit_NumTrial = length(subjetc_Response_Array(stimulus_Position_Array==unique_Position(iPosition) & idx_Class1 & sOA_Array==unique_sOA(isOA)));
                fprintf([',   Trials: ' num2str(this_Hit_NumTrial)])
                
                this_subject_FalseAlarm(iPosition) = 1-mean(subjetc_Response_Array(stimulus_Position_Array==unique_Position(iPosition) & idx_Class2 & sOA_Array==unique_sOA(isOA)));
                this_FalseAlarm_NumTrial =  length(subjetc_Response_Array(stimulus_Position_Array==unique_Position(iPosition) & idx_Class2 & sOA_Array==unique_sOA(isOA)));
                fprintf([', Trials: ' num2str(this_FalseAlarm_NumTrial)])
                
                fprintf([',    FL: ' num2str(this_subject_FalseAlarm(iPosition)) ' Hit:'  num2str(this_subject_Hit(iPosition))])
                this_subject_dPrime(:, iPosition) = dprime_simple(this_subject_Hit(iPosition),this_subject_FalseAlarm(iPosition), this_Hit_NumTrial, this_FalseAlarm_NumTrial);
                fprintf('\n')
                
            end
            
            if isnan(this_subject_dPrime)
                error('this_subject_dPrime should not be nan,  there should be something wrong with the code')
            end
            
            This_Experiment_Result.PerformanceAll(iSubject, :, isOA) = this_subject_dPrime(1, :);
            
            This_Experiment_Result.PerformanceClass_1(iSubject, :, isOA) = this_subject_Hit;
            This_Experiment_Result.PerformanceClass_1_Name = unique_Task{1};
            
            This_Experiment_Result.PerformanceClass_2(iSubject, :, isOA) = this_subject_FalseAlarm;
            This_Experiment_Result.PerformanceClass_2_Name = unique_Task{2};
            
        end
        
    end
    
    Results{iCategory_Level} = This_Experiment_Result;
    
end

position_Tick = round(unique(this_Subject_Data(:,5).Variables))';
