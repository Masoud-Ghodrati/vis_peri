function [Results, position_Tick] = calcualte_Periphery_RT(data_Path)
%  This function takes the data_Paths as input, which is the path that raw
%  data of experiment has been stroed, the output of the function is the
%  RT of subjects in the experiemnt

RT_LOW_CUTOFF = 250;  % low cut off for filtering RT
RT_HIGH_CUTOOF = 1500; % high cut off for filtering RT
RT_EXTRACTION_TYPE = 1; % 1, correct responses, 2, incorrect responses, 3, all responses

dir_Category_Level = dir(data_Path); % The directory of 3 categorization level, there should be all in Dataset folder
dir_Category_Level = dir_Category_Level(3:end); % remove " name-inode maps"

%% Data formating
% tidy up the data for visualization (not a proper tidy data)
for iCategory_Level = 1 : length(dir_Category_Level)
    
    current_Category = dir([data_Path '\' dir_Category_Level(iCategory_Level).name]);
    current_Category = current_Category(3:end);
    
    for iExperimnet_InCategory = 1 : length(current_Category)
        
        this_Experiment = dir([data_Path '\' dir_Category_Level(iCategory_Level).name '\' current_Category(iExperimnet_InCategory).name]);
        this_Experiment = this_Experiment(3:end);
        
        This_Experiment_Result.CatLevelName = dir_Category_Level(iCategory_Level).name;
        This_Experiment_Result.TaskName = current_Category(iExperimnet_InCategory).name;
        
        % empty array to store the result
        This_Experiment_Result.RTAll = [];
        This_Experiment_Result.RTClass_1 = [];
        This_Experiment_Result.RTClass_1_Name = [];
        This_Experiment_Result.RTClass_2 = [];
        This_Experiment_Result.RTClass_2_Name = [];
        
        for iSubject = 1 : length(this_Experiment)
            
            this_Subject = dir([data_Path '\' dir_Category_Level(iCategory_Level).name '\',...
                current_Category(iExperimnet_InCategory).name '\' this_Experiment(iSubject).name]);
            this_Subject = this_Subject(3);
            
            this_Subject_Data = readtable([data_Path '\' dir_Category_Level(iCategory_Level).name '\',...
                current_Category(iExperimnet_InCategory).name '\' this_Experiment(iSubject).name '\'  this_Subject.name]);
            
            stimulus_Position_Array = this_Subject_Data(:,4).Variables;
            subjetc_RT_Array = this_Subject_Data(:,10).Variables;
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
            
            [~, idx_Class1] = ismember( task_Label_Array, unique_Task{1} ); % images indexes for class 1
            [~, idx_Class2] = ismember( task_Label_Array, unique_Task{2} ); % images indexes for class 2
            rT_All = []; rT_Class1 = []; rT_Class2 = [];
            
            for iPosition = 1 : length(unique(stimulus_Position_Array)) % loop over positions
                
                % calculating mean and nanmedian RT
                if RT_EXTRACTION_TYPE == 1 % consider only correct responses
                    uN_Filtered_RT = subjetc_RT_Array(stimulus_Position_Array==iPosition & subjetc_Response_Array==1);
                elseif RT_EXTRACTION_TYPE == 2  % consider only incorrect responses
                    uN_Filtered_RT = subjetc_RT_Array(stimulus_Position_Array==iPosition & subjetc_Response_Array==0);
                elseif RT_EXTRACTION_TYPE == 3  % consider both correct and incorrect responses
                    uN_Filtered_RT = subjetc_RT_Array(stimulus_Position_Array==iPosition);
                else
                    error('RT_EXTRACTION_TYPE should be either 1, 2, or 3')
                end
                
                filtered_RT = uN_Filtered_RT(uN_Filtered_RT>=RT_LOW_CUTOFF & uN_Filtered_RT<=RT_HIGH_CUTOOF);
                if isempty(filtered_RT)
                    filtered_RT = NaN;
                end
                %                 rT_All(:, iPosition) = [mean(filtered_RT); nanmedian(filtered_RT)];
                rT_All(iPosition) = nanmedian(filtered_RT);
                
                % calculating mean and nanmedian RT for class 1
                if RT_EXTRACTION_TYPE == 1 % consider only correct responses
                    uN_Filtered_RT = subjetc_RT_Array(stimulus_Position_Array==iPosition & idx_Class1 & subjetc_Response_Array==1);
                elseif RT_EXTRACTION_TYPE == 2  % consider only incorrect responses
                    uN_Filtered_RT = subjetc_RT_Array(stimulus_Position_Array==iPosition & idx_Class1 & subjetc_Response_Array==0);
                else  % consider both correct and incorrect responses
                    uN_Filtered_RT = subjetc_RT_Array(stimulus_Position_Array==iPosition & idx_Class1);
                    
                end
                
                filtered_RT = uN_Filtered_RT(uN_Filtered_RT>=RT_LOW_CUTOFF & uN_Filtered_RT<=RT_HIGH_CUTOOF);
                if isempty(filtered_RT)
                    filtered_RT = NaN;
                end
                %                 rT_Class1(:, iPosition) = [mean(filtered_RT); nanmedian(filtered_RT)];
                rT_Class1(iPosition) = nanmedian(filtered_RT);
                
                % calculating mean and nanmedian RT for class 2
                if RT_EXTRACTION_TYPE == 1 % consider only correct responses
                    uN_Filtered_RT = subjetc_RT_Array(stimulus_Position_Array==iPosition & idx_Class2 & subjetc_Response_Array==1);
                elseif RT_EXTRACTION_TYPE == 2  % consider only incorrect responses
                    uN_Filtered_RT = subjetc_RT_Array(stimulus_Position_Array==iPosition & idx_Class2 & subjetc_Response_Array==0);
                else  % consider both correct and incorrect responses
                    uN_Filtered_RT = subjetc_RT_Array(stimulus_Position_Array==iPosition & idx_Class2);
                    
                end
                
                filtered_RT = uN_Filtered_RT(uN_Filtered_RT>=RT_LOW_CUTOFF & uN_Filtered_RT<=RT_HIGH_CUTOOF);
                if isempty(filtered_RT)
                    filtered_RT = NaN;
                end
                %                 rT_Class2(:, iPosition) = [mean(filtered_RT); nanmedian(filtered_RT)];
                rT_Class2(iPosition) = nanmedian(filtered_RT);
                
            end
            if isnan(rT_All)
                error('rT_All is a NaN array there should be something wrong in the code')
            end
            
            This_Experiment_Result.RTAll(iSubject, :) = rT_All;
            This_Experiment_Result.RTClass_1(iSubject, :) = rT_Class1;
            This_Experiment_Result.RTClass_1_Name = unique_Task{1};
            
            This_Experiment_Result.RTClass_2(iSubject, :) = rT_Class2;
            This_Experiment_Result.RTClass_2_Name = unique_Task{2};
            
        end
        
        Results{iCategory_Level}{iExperimnet_InCategory} = This_Experiment_Result;
        
    end
    
    
end

position_Tick = round(unique(this_Subject_Data(:,5).Variables))';