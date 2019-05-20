function [Results, position_Tick] = calcualte_Periphery_Accuracy(data_Path)
%  This function takes the data_Paths as input, which is the path that raw
%  data of experiment has been stroed, the output of the function is the
%  accuracy of subjects in the experiemnt

dir_Category_Level = dir(data_Path); % The directory of 3 categorization level, there should be all in Dataset folder
dir_Category_Level = dir_Category_Level(3:end); % remove " name-inode maps"

%% Data formating
% tidy up the data for visualization (not a proper tidy data)

for iCategory_Level = 1 : length(dir_Category_Level) % loop over different categorical levels, e.g., basic level
    
    current_Category = dir([data_Path '\' dir_Category_Level(iCategory_Level).name]); % all experiment in  this category (e.g., animal/non-animal)
    current_Category = current_Category(3:end); % remove " name-inode maps"
    
    for iExperimnet_InCategory = 1 : length(current_Category) % loop over all experiments in each categorical level
        
        this_Experiment = dir([data_Path '\' dir_Category_Level(iCategory_Level).name '\' current_Category(iExperimnet_InCategory).name]);
        this_Experiment = this_Experiment(3:end); % remove " name-inode maps"
        
        This_Experiment_Result.CatLevelName = dir_Category_Level(iCategory_Level).name; % store category level name (e.g., basic level)
        This_Experiment_Result.TaskName = current_Category(iExperimnet_InCategory).name;  % story experiment name (e.g., dog/non-dog)
        
        % empty array to store the result
        This_Experiment_Result.PerformanceAll = [];
        This_Experiment_Result.PerformanceClass_1 = [];
        This_Experiment_Result.PerformanceClass_1_Name = [];
        This_Experiment_Result.PerformanceClass_2 = [];
        This_Experiment_Result.PerformanceClass_2_Name = [];
        
        for iSubject = 1 : length(this_Experiment) % loop over subjects
            
            this_Subject = dir([data_Path '\' dir_Category_Level(iCategory_Level).name '\',...
                current_Category(iExperimnet_InCategory).name '\' this_Experiment(iSubject).name]);
            this_Subject = this_Subject(3);
            
            this_Subject_Data = readtable([data_Path '\' dir_Category_Level(iCategory_Level).name '\',...
                current_Category(iExperimnet_InCategory).name '\' this_Experiment(iSubject).name '\'  this_Subject.name]); % data for one subject
            
            stimulus_Position_Array = this_Subject_Data(:,4).Variables;  % Stimulud position on screen
            subjetc_Response_Array = this_Subject_Data(:,11).Variables;  % Subject responses, 1: correct, 0, incorrect
            task_Label_Array = this_Subject_Data(:,3).Variables;  % which experiment? e.g., A: animal, NA: non-animal
            unique_Task = unique(this_Subject_Data(:,3).Variables);  % Task_label is a cell array, here we take the unique task
            

            
            [~, idx_Class1] = ismember( task_Label_Array, unique_Task{1} ); % images indexes for class 1
            [~, idx_Class2] = ismember( task_Label_Array, unique_Task{2} ); % images indexes for class 2
            this_subject_Accuracy = []; this_subject_Accuracy_Class1 = []; this_subject_Accuracy_Class2 = []; % empty arrays for storing the results
            
            for iPosition = 1 : length(unique(stimulus_Position_Array)) % loop over positions
                
                this_subject_Accuracy(iPosition) = mean(subjetc_Response_Array(stimulus_Position_Array==iPosition)); % mean accuarct of this subject on this position
                this_subject_Accuracy_Class1(iPosition) = mean(subjetc_Response_Array(stimulus_Position_Array==iPosition & idx_Class1)); % mean accuracy in class 1
                this_subject_Accuracy_Class2(iPosition) = mean(subjetc_Response_Array(stimulus_Position_Array==iPosition & idx_Class2)); % mean accuracy in class 1
                
            end
            if isnan(this_subject_Accuracy)
                error('Accuracy should not be nan, there should be something wrong with the code')
            end
            
            This_Experiment_Result.PerformanceAll(iSubject, :) = this_subject_Accuracy;
            This_Experiment_Result.PerformanceClass_1(iSubject, :) = this_subject_Accuracy_Class1;
            This_Experiment_Result.PerformanceClass_2(iSubject, :) = this_subject_Accuracy_Class2;
            
        end
        
        This_Experiment_Result.PerformanceClass_1_Name = unique_Task{1};
        This_Experiment_Result.PerformanceClass_2_Name = unique_Task{2};
        Results{iCategory_Level}{iExperimnet_InCategory} = This_Experiment_Result;
        
    end
    
end

position_Tick = round(unique(this_Subject_Data(:,5).Variables))';