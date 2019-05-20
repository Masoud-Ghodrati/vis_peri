% This code compares the accuracy (% correct) of subject in two different
% experiments inclduing periphery and feedback experiments

clear
clc
close all

current_Path = cd ;          % Current Directory
save_PDF_Path = [current_Path '\Figure\'];  %  Directory to store printed PDF files

data_Path_Feedback = [current_Path '\Datasets-Feedback\']; % Data directory
data_Path_Periphery = [current_Path '\Dataset']; % Data directory
[Results_Feedback, position_Tick_Feedback] = calcualte_Feedback_RT(data_Path_Feedback);
fprintf('   Feedback data is loaded !')
%  Results_Feedback{3} TaskName: 'Animal_Nonanimal'
%  Results_Feedback{1} TaskName: 'Bird_Nonbird'
%  Results_Feedback{2} TaskName: 'Pegeon_Nonpegeon'


[Results_Periphery, position_Tick_Periphery] = calcualte_Periphery_RT(data_Path_Periphery);
clc, fprintf('   Periphery data is loaded !')
%  Results_Periphery{3}{1} TaskName: 'Animal_Nonanimal'
%  Results_Periphery{1}{1} TaskName: 'Bird_Nonbird'
%  Results_Periphery{2}{6} TaskName: 'Pegeon_Nonpegeon'

clc

%%  Tidy up the data and match the feedback and periphery data
matching_Index = [3 1;
    1 1;
    2 6];

position_Index = [1, 2, 3, 5, 7, 8, 9];

for iPeripheryDatatoMatch = 1 : length(Results_Feedback)
    
    this_Experiment_Raw_Data = Results_Periphery{matching_Index(iPeripheryDatatoMatch, 1)}{matching_Index(iPeripheryDatatoMatch, 2)};
    
    Results_Periphery_Matched{iPeripheryDatatoMatch}.CatLevelName = this_Experiment_Raw_Data.CatLevelName;
    Results_Periphery_Matched{iPeripheryDatatoMatch}.TaskName = this_Experiment_Raw_Data.TaskName;
    Results_Periphery_Matched{iPeripheryDatatoMatch}.RTAll = this_Experiment_Raw_Data.RTAll(:, position_Index);
    
    Results_Periphery_Matched{iPeripheryDatatoMatch}.RTClass_1 = this_Experiment_Raw_Data.RTClass_1(:, position_Index);
    Results_Periphery_Matched{iPeripheryDatatoMatch}.RTClass_1_Name = this_Experiment_Raw_Data.RTClass_1_Name;
    
    Results_Periphery_Matched{iPeripheryDatatoMatch}.RTClass_2 = this_Experiment_Raw_Data.RTClass_2(:, position_Index);
    Results_Periphery_Matched{iPeripheryDatatoMatch}.RTClass_2_Name = this_Experiment_Raw_Data.RTClass_2_Name;
    
end


%% analysis
% tidy up the data, save them in excel files for ANOVA

% making a table for periphery full screen
rt_Variable = [];
factor3_Angle = [];
factor2_Task = [];
factor1_CategoryLevel = [];

for iCategory_Level = 1 :length(Results_Periphery)
    
    for iTask = 1 :length(Results_Periphery{iCategory_Level})
        
        for iAngle = 1: size(Results_Periphery{iCategory_Level}{iTask}.RTAll,2)
            
            num_Subject = size(Results_Periphery{iCategory_Level}{iTask}.RTAll,1);
            rt_Variable = [ rt_Variable Results_Periphery{iCategory_Level}{iTask}.RTAll(:,iAngle)'];
            
            this_CategoryLevel = cell(1, num_Subject);
            this_CategoryLevel(:) = {strcat(Results_Periphery{iCategory_Level}{iTask}.CatLevelName)};
            factor1_CategoryLevel = [factor1_CategoryLevel this_CategoryLevel];
            
            this_Task = cell(1, num_Subject);
            this_Task(:) = {strcat(Results_Periphery{iCategory_Level}{iTask}.TaskName)};
            factor2_Task = [factor2_Task this_Task];
            
            factor3_Angle = [factor3_Angle ones(1, num_Subject,1)*iAngle];
            
        end
        
    end
    
end

table_Periphery_FullScreen = table(factor1_CategoryLevel', factor2_Task', factor3_Angle', rt_Variable',...
    'VariableNames',{'factor1_CategoryLevel', 'factor2_Task', 'factor3_Angle','rt_Variable'});
writetable(table_Periphery_FullScreen, 'rt_Periphery_FullScreen_Data.xlsx');


% making a table for periphery half screen
rt_Variable = [];
factor3_Angle = [];
factor2_Task = [];
factor1_CategoryLevel = [];

half_Screen_Angle = [5 6 7 8 9;
    5 4 3 2 1];

for iCategory_Level = 1 :length(Results_Periphery)
    
    for iTask = 1 :length(Results_Periphery{iCategory_Level})
        
        for iAngle = 1: size(half_Screen_Angle,2)
            
            if iAngle == 1
                
                temp_rt = Results_Periphery{iCategory_Level}{iTask}.RTAll(:, half_Screen_Angle(1, iAngle))';
                num_Subject = length(temp_rt);
                
                rt_Variable = [ rt_Variable temp_rt];
                
            else
                
                temp_rt = Results_Periphery{iCategory_Level}{iTask}.RTAll(:, half_Screen_Angle(:, iAngle));
                num_Subject = length(temp_rt(:));
                
                rt_Variable = [ rt_Variable temp_rt(:)'];
                
            end
            
            this_CategoryLevel = cell(1, num_Subject);
            this_CategoryLevel(:) = {strcat(Results_Periphery{iCategory_Level}{iTask}.CatLevelName)};
            factor1_CategoryLevel = [factor1_CategoryLevel this_CategoryLevel];
            
            this_Task = cell(1, num_Subject);
            this_Task(:) = {strcat(Results_Periphery{iCategory_Level}{iTask}.TaskName)};
            factor2_Task = [factor2_Task this_Task];
            
            factor3_Angle = [factor3_Angle ones(1, num_Subject,1)*iAngle];
            
        end
        
    end
    
end

table_Periphery_HalfScreen = table(factor1_CategoryLevel', factor2_Task', factor3_Angle', rt_Variable',...
    'VariableNames',{'factor1_CategoryLevel', 'factor2_Task', 'factor3_Angle','rt_Variable'});
writetable(table_Periphery_HalfScreen, 'rt_Periphery_HalfScreen_Data.xlsx');

% making a table for feedback full screen
rt_Variable = [];
factor3_SOA = [];
factor2_Angle = [];
factor1_Task = [];

for iTask = 1 :length(Results_Feedback)
    
    for iAngle = 1: size(Results_Feedback{iTask}.RTAll,2)
        
        for iSOA = 1 : size(Results_Feedback{iTask}.RTAll, 3)
            
            num_Subject = size(Results_Feedback{iTask}.RTAll(:, iAngle, iSOA), 1);
            rt_Variable = [ rt_Variable Results_Feedback{iTask}.RTAll(:, iAngle, iSOA )'];
            
            this_Task = cell(1, num_Subject);
            this_Task(:) = {strcat(Results_Feedback{iTask}.TaskName)};
            factor1_Task = [factor1_Task this_Task];
            
            factor2_Angle = [factor2_Angle ones(1, num_Subject,1)*iAngle];
            
            factor3_SOA = [factor3_SOA ones(1, num_Subject,1)*iSOA*100];
            
            
        end
        
    end
    
end

table_Feedback_FullScreen = table(factor1_Task', factor2_Angle', factor3_SOA', rt_Variable',...
    'VariableNames',{'factor1_Task', 'factor2_Angle', 'factor3_SOA','rt_Variable'});
writetable(table_Feedback_FullScreen, 'rt_Feedback_FullScreen_Data.xlsx');

% making a table for feedback half screen
rt_Variable = [];
factor3_SOA = [];
factor2_Angle = [];
factor1_Task = [];

half_Screen_Angle = [4 5 6 7;
    4 3 2 1];

for iTask = 1 :length(Results_Feedback)
    
    for iAngle = 1: size(half_Screen_Angle,2)
        
        for iSOA = 1 : size(Results_Feedback{iTask}.RTAll, 3)
            
            if iAngle == 1
                
                temp_rt = Results_Feedback{iTask}.RTAll(:, half_Screen_Angle(1, iAngle), iSOA)';
                num_Subject = length(temp_rt(:));
                
                rt_Variable = [ rt_Variable temp_rt];
                
            else
                
                temp_rt = Results_Feedback{iTask}.RTAll(:, half_Screen_Angle(:, iAngle), iSOA);
                num_Subject = length(temp_rt(:));
                
                rt_Variable = [ rt_Variable temp_rt(:)'];
                
            end
            
            this_Task = cell(1, num_Subject);
            this_Task(:) = {strcat(Results_Feedback{iTask}.TaskName)};
            factor1_Task = [factor1_Task this_Task];
            
            factor2_Angle = [factor2_Angle ones(1, num_Subject,1)*iAngle];
            
            factor3_SOA = [factor3_SOA ones(1, num_Subject,1)*iSOA*100];
               if iSOA >4
                error('we have 4 SOAs')
            end
        end
        
    end
    
end

table_Feedback_HalfScreen = table(factor1_Task', factor2_Angle', factor3_SOA', rt_Variable',...
    'VariableNames',{'factor1_Task', 'factor2_Angle', 'factor3_SOA','rt_Variable'});
writetable(table_Feedback_HalfScreen, 'rt_Feedback_HalfScreen_Data.xlsx');


% making a table for periphery match full screen
rt_Variable = [];
factor2_Angle = [];
factor1_Task = [];

for iTask = 1 : length(Results_Periphery_Matched)
    
    for iAngle = 1: size(Results_Periphery_Matched{iTask}.RTAll,2)
        
        num_Subject = size(Results_Periphery_Matched{iTask}.RTAll(:, iAngle), 1);
        rt_Variable = [ rt_Variable Results_Periphery_Matched{iTask}.RTAll(:, iAngle)'];
        
        this_Task = cell(1, num_Subject);
        this_Task(:) = {strcat(Results_Periphery_Matched{iTask}.TaskName)};
        factor1_Task = [factor1_Task this_Task];
        
        factor2_Angle = [factor2_Angle ones(1, num_Subject,1)*iAngle];
        
    end
    
end

table_PeripheryMatch_FullScreen = table(factor1_Task', factor2_Angle', rt_Variable',...
    'VariableNames',{'factor1_Task', 'factor2_Angle', 'rt_Variable'});
writetable(table_PeripheryMatch_FullScreen, 'rt_Periphery_Match_FullScreen_Data.xlsx');

% making a table for periphery match half screen
rt_Variable = [];
factor2_Angle = [];
factor1_Task = [];

half_Screen_Angle = [4 5 6 7;
    4 3 2 1];

for iTask = 1 : length(Results_Periphery_Matched)
    
    for iAngle = 1: size(half_Screen_Angle,2)
        
        
        
        if iAngle == 1
            
            temp_rt = Results_Periphery_Matched{iTask}.RTAll(:, half_Screen_Angle(1, iAngle))';
            num_Subject = length(temp_rt(:));
            
            rt_Variable = [ rt_Variable temp_rt];
            
        else
            
            temp_rt = Results_Periphery_Matched{iTask}.RTAll(:, half_Screen_Angle(:, iAngle));
            num_Subject = length(temp_rt(:));
            
            rt_Variable = [ rt_Variable temp_rt(:)'];
            
        end
        
        this_Task = cell(1, num_Subject);
        this_Task(:) = {strcat(Results_Periphery_Matched{iTask}.TaskName)};
        factor1_Task = [factor1_Task this_Task];
        
        factor2_Angle = [factor2_Angle ones(1, num_Subject,1)*iAngle];
        
        
    end
    
end

table_PeripheryMatch_HalfScreen = table(factor1_Task', factor2_Angle', rt_Variable',...
    'VariableNames',{'factor1_Task', 'factor2_Angle', 'rt_Variable'});
writetable(table_PeripheryMatch_HalfScreen, 'rt_Periphery_Match_HalfScreen_Data.xlsx');


% making a table for feedback joint with periphery for 3-way ANOVA, full screen
rt_Variable = [];
factor3_SOA = [];
factor2_Angle = [];
factor1_Task = [];

for iTask = 1 : length(Results_Periphery_Matched)
    
    for iAngle = 1: size(Results_Periphery_Matched{iTask}.RTAll,2)
        
        num_Subject = size(Results_Periphery_Matched{iTask}.RTAll(:, iAngle), 1);
        rt_Variable = [ rt_Variable Results_Periphery_Matched{iTask}.RTAll(:, iAngle)'];
        
        this_Task = cell(1, num_Subject);
        this_Task_Name = [Results_Periphery_Matched{iTask}.TaskName(1:find(Results_Periphery_Matched{iTask}.TaskName=='_', 1)-1),...
            '_Non' Results_Periphery_Matched{iTask}.TaskName(1:find(Results_Periphery_Matched{iTask}.TaskName=='_', 1)-1)];
        this_Task(:) = {strcat(this_Task_Name)};
        factor1_Task = [factor1_Task this_Task];
        
        factor2_Angle = [factor2_Angle ones(1, num_Subject,1)*iAngle];
        
        factor3_SOA = [factor3_SOA ones(1, num_Subject,1)*0];
        
    end
    
end


for iTask = 1 :length(Results_Feedback)
    
    for iAngle = 1: size(Results_Feedback{iTask}.RTAll,2)
        
        for iSOA = 1 : size(Results_Feedback{iTask}.RTAll, 3)
            
            num_Subject = size(Results_Feedback{iTask}.RTAll(:, iAngle, iSOA), 1);
            rt_Variable = [ rt_Variable Results_Feedback{iTask}.RTAll(:, iAngle, iSOA )'];
            
            this_Task = cell(1, num_Subject);
            this_Task_Name = [Results_Feedback{iTask}.TaskName(1:find(Results_Feedback{iTask}.TaskName=='_', 1)-1),...
                '_Non' Results_Feedback{iTask}.TaskName(1:find(Results_Feedback{iTask}.TaskName=='_', 1)-1)];
            this_Task(:) = {strcat(this_Task_Name)};
            factor1_Task = [factor1_Task this_Task];
            
            factor2_Angle = [factor2_Angle ones(1, num_Subject,1)*iAngle];
            
            factor3_SOA = [factor3_SOA ones(1, num_Subject,1)*iSOA*100];
            
            
        end
        
    end
    
end

table_Feedback_Periphery_3Way_FullScreen = table(factor1_Task', factor2_Angle', factor3_SOA', rt_Variable',...
    'VariableNames',{'factor1_Task', 'factor2_Angle', 'factor3_SOA','rt_Variable'});
writetable(table_Feedback_Periphery_3Way_FullScreen, 'rt_Feedback_Periphery_3way_FullScreen_Data.xlsx');

% making a table for feedback joint with periphery for 3-way ANOVA, half screen
rt_Variable = [];
factor3_SOA = [];
factor2_Angle = [];
factor1_Task = [];

half_Screen_Angle = [4 5 6 7;
    4 3 2 1];

for iTask = 1 : length(Results_Periphery_Matched)
    
    for iAngle = 1: size(half_Screen_Angle,2)
        
        
        
        if iAngle == 1
            
            temp_rt = Results_Periphery_Matched{iTask}.RTAll(:, half_Screen_Angle(1, iAngle))';
            num_Subject = length(temp_rt(:));
            
            rt_Variable = [ rt_Variable temp_rt];
            
        else
            
            temp_rt = Results_Periphery_Matched{iTask}.RTAll(:, half_Screen_Angle(:, iAngle));
            num_Subject = length(temp_rt(:));
            
            rt_Variable = [ rt_Variable temp_rt(:)'];
            
        end
        
        this_Task = cell(1, num_Subject);
        
        this_Task_Name = [Results_Periphery_Matched{iTask}.TaskName(1:find(Results_Periphery_Matched{iTask}.TaskName=='_', 1)-1),...
            '_Non' Results_Periphery_Matched{iTask}.TaskName(1:find(Results_Periphery_Matched{iTask}.TaskName=='_', 1)-1)];
        this_Task(:) = {strcat(this_Task_Name)};
        factor1_Task = [factor1_Task this_Task];
        
        factor2_Angle = [factor2_Angle ones(1, num_Subject,1)*iAngle];
        
        factor3_SOA = [factor3_SOA ones(1, num_Subject,1)*0];
        
    end
    
end


for iTask = 1 :length(Results_Feedback)
    
    for iAngle = 1: size(half_Screen_Angle,2)
        
        for iSOA = 1 : size(Results_Feedback{iTask}.RTAll, 3)
            
            if iAngle == 1
                
                temp_rt = Results_Feedback{iTask}.RTAll(:, half_Screen_Angle(1, iAngle), iSOA)';
                num_Subject = length(temp_rt(:));
                
                rt_Variable = [ rt_Variable temp_rt];
                
            else
                
                temp_rt = Results_Feedback{iTask}.RTAll(:, half_Screen_Angle(:, iAngle), iSOA);
                num_Subject = length(temp_rt(:));
                
                rt_Variable = [ rt_Variable temp_rt(:)'];
                
            end
            
            this_Task = cell(1, num_Subject);
            this_Task_Name = [Results_Feedback{iTask}.TaskName(1:find(Results_Feedback{iTask}.TaskName=='_', 1)-1),...
                '_Non' Results_Feedback{iTask}.TaskName(1:find(Results_Feedback{iTask}.TaskName=='_', 1)-1)];
            this_Task(:) = {strcat(this_Task_Name)};
            factor1_Task = [factor1_Task this_Task];
            
            factor2_Angle = [factor2_Angle ones(1, num_Subject,1)*iAngle];
            
            factor3_SOA = [factor3_SOA ones(1, num_Subject,1)*iSOA*100];
            
        end
        
    end
    
end

table_Feedback_Periphery_3Way_HalfScreen = table(factor1_Task', factor2_Angle', factor3_SOA', rt_Variable',...
    'VariableNames',{'factor1_Task', 'factor2_Angle', 'factor3_SOA','rt_Variable'});
writetable(table_Feedback_Periphery_3Way_HalfScreen, 'rt_Feedback_Periphery_3way_HalfScreen_Data.xlsx');



% making a table for periphery (figure 4-5), half screen
half_Screen_Angle = [5 6 7 8 9;
    5 4 3 2 1];
selected_Tasks = {[1, 4], [2, 3, 5, 7]};
% Basic: birdnbird 1, reptilenreptile 4
% Sub: ducknduck 2, fighternfighter 3, lizardnlizard 5, racernracer 7

for iCategory_Level = 1 : length(Results_Periphery)
    if strcmp(Results_Periphery{iCategory_Level}{1}.CatLevelName, 'Basic') ||  strcmp(Results_Periphery{iCategory_Level}{1}.CatLevelName, 'Sub-ordinate')
        for iTask = 1 : length(selected_Tasks{iCategory_Level})
            
            rt_Variable = [];
            factor3_Angle = [];
            factor2_SubTask = [];
            factor1_Task = [];
            
            for iSubTask = 1 : 2  % it's either Task or Nantask
                
                for iAngle = 1: size(half_Screen_Angle,2)
                    
                    if iSubTask == 1
                        
                        if iAngle == 1
                            
                            temp_accuarcy = Results_Periphery{iCategory_Level}{selected_Tasks{iCategory_Level}(iTask)}.RTClass_1(:, half_Screen_Angle(1, iAngle))';
                            num_Subject = length(temp_accuarcy);
                            
                            rt_Variable = [ rt_Variable temp_accuarcy];
                            
                        else
                            
                            temp_accuarcy = Results_Periphery{iCategory_Level}{selected_Tasks{iCategory_Level}(iTask)}.RTClass_1(:, half_Screen_Angle(:, iAngle));
                            num_Subject = length(temp_accuarcy(:));
                            
                            rt_Variable = [ rt_Variable temp_accuarcy(:)'];
                            
                        end
                        
                        this_Task = cell(1, num_Subject);
                        this_Task(:) = {strcat(Results_Periphery{iCategory_Level}{selected_Tasks{iCategory_Level}(iTask)}.TaskName)};
                        factor1_Task = [factor1_Task this_Task];
                        
                        this_SubTask = cell(1, num_Subject);
                        this_SubTask(:) = {strcat(Results_Periphery{iCategory_Level}{selected_Tasks{iCategory_Level}(iTask)}.RTClass_1_Name)};
                        factor2_SubTask = [factor2_SubTask this_SubTask];
                        
                        factor3_Angle = [factor3_Angle ones(1, num_Subject,1)*iAngle];
                        
                    else
                        
                        if iAngle == 1
                            
                            temp_accuarcy = Results_Periphery{iCategory_Level}{selected_Tasks{iCategory_Level}(iTask)}.RTClass_2(:, half_Screen_Angle(1, iAngle))';
                            num_Subject = length(temp_accuarcy);
                            
                            rt_Variable = [ rt_Variable temp_accuarcy];
                            
                        else
                            
                            temp_accuarcy = Results_Periphery{iCategory_Level}{selected_Tasks{iCategory_Level}(iTask)}.RTClass_2(:, half_Screen_Angle(:, iAngle));
                            num_Subject = length(temp_accuarcy(:));
                            
                            rt_Variable = [ rt_Variable temp_accuarcy(:)'];
                            
                        end
                        
                        this_Task = cell(1, num_Subject);
                        this_Task(:) = {strcat(Results_Periphery{iCategory_Level}{selected_Tasks{iCategory_Level}(iTask)}.TaskName)};
                        factor1_Task = [factor1_Task this_Task];
                        
                        this_SubTask = cell(1, num_Subject);
                        this_SubTask(:) = {strcat(Results_Periphery{iCategory_Level}{selected_Tasks{iCategory_Level}(iTask)}.RTClass_2_Name)};
                        factor2_SubTask = [factor2_SubTask this_SubTask];
                        
                        factor3_Angle = [factor3_Angle ones(1, num_Subject,1)*iAngle];
                    end
                    
                end
                
                
            end
            
            table_Periphery_HalfScreen_Figure5Data = table(factor1_Task', factor2_SubTask', factor3_Angle', rt_Variable',...
                'VariableNames',{'factor1_CategoryLevel', 'factor2_Task', 'factor3_Angle','rt_Variable'});
            writetable(table_Periphery_HalfScreen_Figure5Data, ['rt_Periphery_HalfScreen_Figure5_' strcat(Results_Periphery{iCategory_Level}{selected_Tasks{iCategory_Level}(iTask)}.TaskName) 'Data.xlsx']);
            
        end
    end
end


