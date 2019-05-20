% This code reads. the raw data of psychophysical experiments on object
% categorization. The code visualizes the accuracy (%d ') of subjects
% when categorizing different object at different visual angles (visual periphary)
clear
clc
close all

current_Path = cd ;          % Current Directory
data_Path = [current_Path '\Dataset']; % Data directory
save_PDF_Path = [current_Path '\Figure\'];  %  Directory to store printed PDF files 

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
%% Visualization
close all

figure(1) % Accuracy for all categorical levels and all experiments
MARKER_SIZE = 5;
LINE_WIDTH = 1;
AXIS_LINE_WIDTH = 1;
LINE_COLOR = colormap(brewermap([],'*YlGnBu'));
% LINE_COLOR = colormap(brewermap([],'*YlOrRd'));
TICK_LENGTH = 2;
X_AXIS_LIM = [-4.2 4.1];
Y_AXIS_LIM = [-0.2 4];
Y_AXIS_1ST_TICK = 0;
Y_AXIS_LABEL_NUM_STEPS = 3;
SAVE_PDF = false; % do you want to save PDF file of the paper
WANT_LEGEND = false;  % do you want legend
SAME_MARKER_FACECOLOR = false;% TRUE, same as line color, FALSE, white
sEM_AS_ERRORBAR = true; % FALSE std, TRUE sem
FONT_SIZE = 10;
FIGURE_DIMENSION = [0 0 600 800;
    0 0 300 800]; % dimesion of the printed figure
PRINTED_FIGURE_SIZE = [20, 20]; % the size of printed PDF file, cm
PDF_RESOLUTION = '-r300';
for iCategory_Level = 1 : length(Results)
    
    ind_Color = 1;
    color_Step = floor(size(LINE_COLOR,1)/length(Results{iCategory_Level}));
    all_Legends = [];
    for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
        
        
        subplot(3, 1, iCategory_Level)
        
        subject_Accuracy_Matrix = Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceAll;
        if sEM_AS_ERRORBAR == false
            h = errorbar(-4:4, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix));
        elseif sEM_AS_ERRORBAR == true
            h = errorbar(-4:4, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix)/sqrt(size(subject_Accuracy_Matrix,1)));
        end
        h.Marker = 'o';
        h.LineWidth = LINE_WIDTH;
        h.MarkerSize = MARKER_SIZE;
        h.Color = LINE_COLOR(ind_Color, :);
        h.MarkerEdgeColor = LINE_COLOR(ind_Color, :);
        if SAME_MARKER_FACECOLOR == true
            h.MarkerFaceColor = LINE_COLOR(ind_Color, :);
        elseif SAME_MARKER_FACECOLOR == false
            h.MarkerFaceColor = 'w';
        end
        h.CapSize = 0;
        hold on
        all_Legends{iExperimnet_InCategory} = strrep(Results{iCategory_Level}{iExperimnet_InCategory}.TaskName, '_', ' vs.  ');
        ind_Color = ind_Color + color_Step;
        
    end
    
    aX =  gca;
    aX.Box = 'off';
    aX.TickDir = 'out';
    aX.TickLength = TICK_LENGTH*aX.TickLength;
    aX.YLim = Y_AXIS_LIM;
    aX.XLim = X_AXIS_LIM;
    aX.YTick = linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM(2), Y_AXIS_LABEL_NUM_STEPS);
    aX.XTick = -4:4;
    aX.XTickLabel = [-position_Tick(end:-1:2) 0 position_Tick(2:end)];
    aX.Title.String = Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName;
    aX.FontSize = FONT_SIZE;
    aX.LineWidth = AXIS_LINE_WIDTH;
    if iCategory_Level == 3
        aX.XLabel.String = 'Eccentricity (^o)';
        aX.YLabel.String = 'd''';
    end
    if WANT_LEGEND == true
        hL = legend(aX, all_Legends, 'location', 'EastOutside');
        hL.Box = 'off';
        SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(1, :);
    elseif WANT_LEGEND == false
        SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(2, :);
    end
    
    
end

set(gcf,'color','w')
set(gcf, 'Position', SELECTED_FIGURE_DIMENSION)
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',PRINTED_FIGURE_SIZE)
set(gcf, 'PaperPositionMode','auto')

if SAVE_PDF == true
    if WANT_LEGEND == true
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_FullScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_FullScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
    elseif WANT_LEGEND==false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
    end
end

figure(2) % Aevrage accuracy of all experiment in every categorical level
FIGURE_DIMENSION = [0 0 600 250;
    0 0 300 250]; % dimesion of the printed figure
ind_Color = 1;
all_Legends = [];
color_Step = floor(size(LINE_COLOR,1)/length(Results));

for iCategory_Level = 1 : length(Results)
    
    this_subject_dPrime = [];
    for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
        subject_Accuracy_Matrix = [this_subject_dPrime; Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceAll];
    end
    
    if sEM_AS_ERRORBAR == false
        h = errorbar(-4:4, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix));
    elseif sEM_AS_ERRORBAR == true
        h = errorbar(-4:4, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix)/sqrt(size(subject_Accuracy_Matrix,1)));
    end
    h.Marker = 'o';
    h.LineWidth = LINE_WIDTH;
    h.MarkerSize = MARKER_SIZE;
    h.Color = LINE_COLOR(ind_Color, :);
    h.MarkerEdgeColor = LINE_COLOR(ind_Color, :);
    
    if SAME_MARKER_FACECOLOR == true
        h.MarkerFaceColor = LINE_COLOR(ind_Color, :);
    elseif SAME_MARKER_FACECOLOR == false
        h.MarkerFaceColor = 'w';
    end
    h.CapSize = 0;
    hold on
    all_Legends{iCategory_Level} = Results{iCategory_Level}{1}.CatLevelName;
    ind_Color = ind_Color + color_Step;
    
end

aX =  gca;
aX.Box = 'off';
aX.TickDir = 'out';
aX.TickLength = TICK_LENGTH*aX.TickLength;
aX.YLim = Y_AXIS_LIM;
aX.XLim = X_AXIS_LIM;
aX.YTick = linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM(2), Y_AXIS_LABEL_NUM_STEPS);
aX.XTick = -4:4;
aX.XTickLabel = [-position_Tick(end:-1:2) 0 position_Tick(2:end)];
aX.FontSize = FONT_SIZE;
aX.LineWidth = AXIS_LINE_WIDTH;

if iCategory_Level == 3
    aX.XLabel.String = 'Eccentricity (^o)';
    aX.YLabel.String = 'd''';
end

if WANT_LEGEND == true
    hL = legend(aX, all_Legends, 'location', 'EastOutside');
    hL.Box = 'off';
    SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(1, :);
elseif WANT_LEGEND == false
    SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(2, :);
end

set(gcf,'color','w')
set(gcf, 'Position', SELECTED_FIGURE_DIMENSION)
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',PRINTED_FIGURE_SIZE)
set(gcf, 'PaperPositionMode','auto')

if SAVE_PDF == true
    if WANT_LEGEND == true
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_FullScreen_Aveareg_of_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_FullScreen_Aveareg_of_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_FullScreen_Aveareg_of_All_Category_Levels_All_Tasks' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_FullScreen_Aveareg_of_All_Category_Levels_All_Tasks' date '.pdf'])
    end
end

figure(3) % Accuracy for all categorical levels and all experiments, avergared over left and right halves of screen
X_AXIS_LIM = [-0.2 4];
FIGURE_DIMENSION = [0 0 600 800;
    0 0 300 800]; % dimesion of the printed figure

for iCategory_Level = 1 : length(Results)
    
    ind_Color = 1;
    all_Legends = [];
    color_Step = floor(size(LINE_COLOR,1)/length(Results{iCategory_Level}));
    for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
        
        subplot(3, 1, iCategory_Level)
        
        subject_Accuracy_Matrix = Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceAll;
        mean_Accuracy = [mean(subject_Accuracy_Matrix(:, 5)) mean([subject_Accuracy_Matrix(:, 4); subject_Accuracy_Matrix(:, 6)]),...
            mean([subject_Accuracy_Matrix(:, 3);subject_Accuracy_Matrix(:, 7)]) mean([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 8)]),...
            mean([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 9)])];
        
        if sEM_AS_ERRORBAR == false
            sTD_Accuracy = [std(subject_Accuracy_Matrix(:, 5)) std([subject_Accuracy_Matrix(:, 4); subject_Accuracy_Matrix(:, 6)]),...
                std([subject_Accuracy_Matrix(:, 3);subject_Accuracy_Matrix(:, 7)]) std([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 8)]),...
                std([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 9)])];
            
            h = errorbar(0:4, mean_Accuracy, sTD_Accuracy);
        elseif sEM_AS_ERRORBAR == true
            sEM_Accuracy = [std(subject_Accuracy_Matrix(:, 5))/sqrt(length(subject_Accuracy_Matrix(:, 5))),...
                std([subject_Accuracy_Matrix(:, 4); subject_Accuracy_Matrix(:, 6)])/sqrt(length([subject_Accuracy_Matrix(:, 4); subject_Accuracy_Matrix(:, 6)])),...
                std([subject_Accuracy_Matrix(:, 3);subject_Accuracy_Matrix(:, 7)])/sqrt(length([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 7)])),...
                std([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 8)])/sqrt(length([subject_Accuracy_Matrix(:, 2); subject_Accuracy_Matrix(:, 8)])),...
                std([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 9)])/sqrt(length([subject_Accuracy_Matrix(:, 1); subject_Accuracy_Matrix(:, 9)]))];
            
            h = errorbar(0:4, mean_Accuracy, sEM_Accuracy);
        end
        h.Marker = 'o';
        h.LineWidth = LINE_WIDTH;
        h.MarkerSize = MARKER_SIZE;
        h.Color = LINE_COLOR(ind_Color, :);
        h.MarkerEdgeColor = LINE_COLOR(ind_Color, :);
        
        if SAME_MARKER_FACECOLOR == true
            h.MarkerFaceColor = LINE_COLOR(ind_Color, :);
        elseif SAME_MARKER_FACECOLOR == false
            h.MarkerFaceColor = 'w';
        end
        h.CapSize = 0;
        hold on
        all_Legends{iExperimnet_InCategory} = strrep(Results{iCategory_Level}{iExperimnet_InCategory}.TaskName, '_', ' vs.  ');
        ind_Color = ind_Color + color_Step;
        
    end
    
    aX =  gca;
    aX.Box = 'off';
    aX.TickDir = 'out';
    aX.TickLength = TICK_LENGTH*aX.TickLength;
    aX.YLim = Y_AXIS_LIM;
    aX.XLim = X_AXIS_LIM;
    aX.YTick = linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM(2), Y_AXIS_LABEL_NUM_STEPS);
    aX.XTick = 0:4;
    aX.XTickLabel = position_Tick;
    aX.Title.String = Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName;
    aX.FontSize = FONT_SIZE;
    aX.LineWidth = AXIS_LINE_WIDTH;
    if iCategory_Level == 3
        aX.XLabel.String = 'Eccentricity (^o)';
        aX.YLabel.String = 'd''';
    end
    if WANT_LEGEND == true
        hL = legend(aX, all_Legends, 'location', 'EastOutside');
        hL.Box = 'off';
        SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(1, :);
    elseif WANT_LEGEND == false
        SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(2, :);
    end
    
end

set(gcf,'color','w')
set(gcf, 'Position', SELECTED_FIGURE_DIMENSION)
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',PRINTED_FIGURE_SIZE)
set(gcf, 'PaperPositionMode','auto')

if SAVE_PDF == true
    if WANT_LEGEND == true
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_HalfScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_HalfScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_HalfScreen_All_Category_Levels_All_Tasks_' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_HalfScreen_All_Category_Levels_All_Tasks_' date '.pdf'])
    end
end

figure(4) % Aevrage accuracy of all experiment in every categorical level, avergared over left and right halves of screen
FIGURE_DIMENSION = [0 0 600 250;
    0 0 300 250]; % dimesion of the printed figure
ind_Color = 1;
all_Legends = [];
color_Step = floor(size(LINE_COLOR,1)/length(Results));
for iCategory_Level = 1 : length(Results)
    
    
    subject_Accuracy_Matrix = [];
    for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
        subject_Accuracy_Matrix = [subject_Accuracy_Matrix; Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceAll];
    end
    mean_Accuracy = [mean(subject_Accuracy_Matrix(:, 5)) mean([subject_Accuracy_Matrix(:, 4); subject_Accuracy_Matrix(:, 6)]),...
        mean([subject_Accuracy_Matrix(:, 3);subject_Accuracy_Matrix(:, 7)]) mean([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 8)]),...
        mean([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 9)])];
    if sEM_AS_ERRORBAR == false
        sTD_Accuracy = [std(subject_Accuracy_Matrix(:, 5)) std([subject_Accuracy_Matrix(:, 4); subject_Accuracy_Matrix(:, 6)]),...
            std([subject_Accuracy_Matrix(:, 3);subject_Accuracy_Matrix(:, 7)]) std([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 8)]),...
            std([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 9)])];
        
        h = errorbar(0:4, mean_Accuracy, sTD_Accuracy);
    elseif sEM_AS_ERRORBAR == true
        sEM_Accuracy = [std(subject_Accuracy_Matrix(:, 5))/sqrt(length(subject_Accuracy_Matrix(:, 5))),...
            std([subject_Accuracy_Matrix(:, 4); subject_Accuracy_Matrix(:, 6)])/sqrt(length([subject_Accuracy_Matrix(:, 4); subject_Accuracy_Matrix(:, 6)])),...
            std([subject_Accuracy_Matrix(:, 3);subject_Accuracy_Matrix(:, 7)])/sqrt(length([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 7)])),...
            std([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 8)])/sqrt(length([subject_Accuracy_Matrix(:, 2); subject_Accuracy_Matrix(:, 8)])),...
            std([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 9)])/sqrt(length([subject_Accuracy_Matrix(:, 1); subject_Accuracy_Matrix(:, 9)]))];
        
        h = errorbar(0:4, mean_Accuracy, sEM_Accuracy);
    end
    h.Marker = 'o';
    h.LineWidth = LINE_WIDTH;
    h.MarkerSize = MARKER_SIZE;
    h.Color = LINE_COLOR(ind_Color, :);
    h.MarkerEdgeColor = LINE_COLOR(ind_Color, :);
    
    if SAME_MARKER_FACECOLOR == true
        h.MarkerFaceColor = LINE_COLOR(ind_Color, :);
    elseif SAME_MARKER_FACECOLOR == false
        h.MarkerFaceColor = 'w';
    end
    h.CapSize = 0;
    hold on
    all_Legends{iCategory_Level} = Results{iCategory_Level}{1}.CatLevelName;
    ind_Color = ind_Color + color_Step;
    
end

aX =  gca;
aX.Box = 'off';
aX.TickDir = 'out';
aX.TickLength = TICK_LENGTH*aX.TickLength;
aX.YLim = Y_AXIS_LIM;
aX.XLim = X_AXIS_LIM;
aX.YTick = linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM(2), Y_AXIS_LABEL_NUM_STEPS);
aX.XTick = 0:4;
aX.XTickLabel = position_Tick;
aX.FontSize = FONT_SIZE;
aX.LineWidth = AXIS_LINE_WIDTH;

aX.XLabel.String = 'Eccentricity (^o)';
aX.YLabel.String = 'd''';

if WANT_LEGEND == true
    hL = legend(aX, all_Legends, 'location', 'EastOutside');
    hL.Box = 'off';
    SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(1, :);
elseif WANT_LEGEND == false
    SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(2, :);
end

set(gcf,'color','w')
set(gcf, 'Position', SELECTED_FIGURE_DIMENSION)
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',PRINTED_FIGURE_SIZE)
set(gcf, 'PaperPositionMode','auto')

if SAVE_PDF == true
    if WANT_LEGEND == true
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_HalfScreen_Average_of_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_HalfScreen_Average_of_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_HalfScreen_Average_of_All_Category_Levels_All_Tasks' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_HalfScreen_Average_of_All_Category_Levels_All_Tasks' date '.pdf'])
    end
end


figure(5) % accuracy for each class in each experiment, basic level
X_AXIS_LIM = [-4.2 4];
Y_AXIS_LIM = [-0.2 1.5];
Y_AXIS_1ST_TICK = 0;

FIGURE_DIMENSION = [0 0 800 500;
    0 0 800 500]; % dimesion of the printed figure
iCategory_Level = 1;
ind_Color = 1;
ind_subplot = 1;
all_Legends = [];
WANT_LEGEND = true;
for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
    
    subplot(2, 2, ind_subplot)
    
    subject_Accuracy_Matrix = Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceClass_1;
    if sEM_AS_ERRORBAR == false
        h = errorbar(-4:4, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix));
    elseif sEM_AS_ERRORBAR == true
        h = errorbar(-4:4, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix)/sqrt(size(subject_Accuracy_Matrix,1)));
    end
    h.Marker = 'o';
    h.LineWidth = LINE_WIDTH;
    h.MarkerSize = MARKER_SIZE;
    h.Color = LINE_COLOR(ind_Color, :);
    h.MarkerEdgeColor = LINE_COLOR(ind_Color, :);
    if SAME_MARKER_FACECOLOR == true
        h.MarkerFaceColor = LINE_COLOR(ind_Color, :);
    elseif SAME_MARKER_FACECOLOR == false
        h.MarkerFaceColor = 'w';
    end
    h.CapSize = 0;
    hold on
    
    subject_Accuracy_Matrix = Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceClass_2;
    if sEM_AS_ERRORBAR == false
        h = errorbar(-4:4, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix));
    elseif sEM_AS_ERRORBAR == true
        h = errorbar(-4:4, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix)/sqrt(size(subject_Accuracy_Matrix,1)));
    end
    h.Marker = 'o';
    h.LineWidth = LINE_WIDTH;
    h.MarkerSize = MARKER_SIZE;
    h.LineStyle = '--';
    h.Color = LINE_COLOR(ind_Color, :);
    h.MarkerEdgeColor = LINE_COLOR(ind_Color, :);
    if SAME_MARKER_FACECOLOR == true
        h.MarkerFaceColor = LINE_COLOR(ind_Color, :);
    elseif SAME_MARKER_FACECOLOR == false
        h.MarkerFaceColor = 'w';
    end
    h.CapSize = 0;
    if WANT_LEGEND == true
        hL = legend('Hitt Rate', 'False Alarm', 'location', 'EastOutside');
        hL.Box = 'off';
        SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(1, :);
    elseif WANT_LEGEND == false
        SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(2, :);
    end
    
    aX =  gca;
    aX.Box = 'off';
    aX.TickDir = 'out';
    aX.TickLength = TICK_LENGTH*aX.TickLength;
    aX.YLim = Y_AXIS_LIM;
    aX.XLim = X_AXIS_LIM;
    aX.YTick = linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM(2), Y_AXIS_LABEL_NUM_STEPS);
    aX.XTick = -4:4;
    aX.XTickLabel = [-position_Tick(end:-1:2) 0 position_Tick(2:end)];
    aX.LineWidth = AXIS_LINE_WIDTH;
    aX.FontSize = FONT_SIZE;
    aX.XLabel.String = 'Eccentricity (^o)';
    aX.YLabel.String = 'd''';
    aX.Title.String = [Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName ' : ', ...
        Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceClass_1_Name ' vs. ',...
        Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceClass_2_Name];
    ind_subplot = ind_subplot + 1;
    
end



set(gcf,'color','w')
set(gcf, 'Position', SELECTED_FIGURE_DIMENSION) % Plos Comp supp
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',PRINTED_FIGURE_SIZE)
set(gcf, 'PaperPositionMode','auto')

if SAVE_PDF == true
    if WANT_LEGEND == true
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_' Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_'  Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_' Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_'  Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
    end
end

figure(6)% accuracy for each class in each experiment, sub-ordinate level
FIGURE_DIMENSION = [0 0 800 1000;
    0 0 800 1000]; % dimesion of the printed figure
iCategory_Level = 2;
ind_Color = 1;
ind_subplot = 1;
all_Legends = [];
for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
    
    
    subplot(4, 2, ind_subplot)
    
    subject_Accuracy_Matrix = Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceClass_1;
    if sEM_AS_ERRORBAR == false
        h = errorbar(-4:4, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix));
    elseif sEM_AS_ERRORBAR == true
        h = errorbar(-4:4, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix)/sqrt(size(subject_Accuracy_Matrix,1)));
    end
    h.Marker = 'o';
    h.LineWidth = LINE_WIDTH;
    h.MarkerSize = MARKER_SIZE;
    h.Color = LINE_COLOR(ind_Color, :);
    h.MarkerEdgeColor = LINE_COLOR(ind_Color, :);
    if SAME_MARKER_FACECOLOR == true
        h.MarkerFaceColor = LINE_COLOR(ind_Color, :);
    elseif SAME_MARKER_FACECOLOR == false
        h.MarkerFaceColor = 'w';
    end
    h.CapSize = 0;
    hold on
    
    subject_Accuracy_Matrix = Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceClass_2;
    if sEM_AS_ERRORBAR == false
        h = errorbar(-4:4, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix));
    elseif sEM_AS_ERRORBAR == true
        h = errorbar(-4:4, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix)/sqrt(size(subject_Accuracy_Matrix,1)));
    end
    h.Marker = 'o';
    h.LineWidth = LINE_WIDTH;
    h.MarkerSize = MARKER_SIZE;
    h.LineStyle = '--';
    h.Color = LINE_COLOR(ind_Color, :);
    h.MarkerEdgeColor = LINE_COLOR(ind_Color, :);
    if SAME_MARKER_FACECOLOR == true
        h.MarkerFaceColor = LINE_COLOR(ind_Color, :);
    elseif SAME_MARKER_FACECOLOR == false
        h.MarkerFaceColor = 'w';
    end
    h.CapSize = 0;
    if WANT_LEGEND == true
        hL = legend('Hitt Rate', 'False Alarm', 'location', 'EastOutside');
        hL.Box = 'off';
        SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(1, :);
    elseif WANT_LEGEND == false
        SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(2, :);
    end
    
    aX =  gca;
    aX.Box = 'off';
    aX.TickDir = 'out';
    aX.TickLength = TICK_LENGTH*aX.TickLength;
    aX.YLim = Y_AXIS_LIM;
    aX.XLim = X_AXIS_LIM;
    aX.YTick = linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM(2), Y_AXIS_LABEL_NUM_STEPS);
    aX.XTick = -4:4;
    aX.XTickLabel = [-position_Tick(end:-1:2) 0 position_Tick(2:end)];
    aX.LineWidth = AXIS_LINE_WIDTH;
    aX.FontSize = FONT_SIZE;
    aX.XLabel.String = 'Eccentricity (^o)';
    aX.YLabel.String = 'd''';
    aX.Title.String = [Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName ' : ', ...
        Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceClass_1_Name ' vs. ',...
        Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceClass_2_Name];
    ind_subplot = ind_subplot + 1;
    
end


set(gcf,'color','w')
set(gcf, 'Position', SELECTED_FIGURE_DIMENSION) % Plos Comp supp
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',PRINTED_FIGURE_SIZE)
set(gcf, 'PaperPositionMode','auto')

if SAVE_PDF == true
    if WANT_LEGEND == true
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_' Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_'  Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_' Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_'  Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
    end
end

figure(7) % accuracy for each class in each experiment, supper-ordinate level
FIGURE_DIMENSION = [0 0 400 500;
    0 0 400 500]; % dimesion of the printed figure
iCategory_Level = 3;
ind_Color = 1;
ind_subplot = 1;
all_Legends = [];
for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
    
    
    subplot(2, 1, ind_subplot)
    
    subject_Accuracy_Matrix = Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceClass_1;
    if sEM_AS_ERRORBAR == false
        h = errorbar(-4:4, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix));
    elseif sEM_AS_ERRORBAR == true
        h = errorbar(-4:4, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix)/sqrt(size(subject_Accuracy_Matrix,1)));
    end
    h.Marker = 'o';
    h.LineWidth = LINE_WIDTH;
    h.MarkerSize = MARKER_SIZE;
    h.Color = LINE_COLOR(ind_Color, :);
    h.MarkerEdgeColor = LINE_COLOR(ind_Color, :);
    if SAME_MARKER_FACECOLOR == true
        h.MarkerFaceColor = LINE_COLOR(ind_Color, :);
    elseif SAME_MARKER_FACECOLOR == false
        h.MarkerFaceColor = 'w';
    end
    h.CapSize = 0;
    hold on
    
    subject_Accuracy_Matrix = Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceClass_2;
    if sEM_AS_ERRORBAR == false
        h = errorbar(-4:4, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix));
    elseif sEM_AS_ERRORBAR == true
        h = errorbar(-4:4, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix)/sqrt(size(subject_Accuracy_Matrix,1)));
    end
    h.Marker = 'o';
    h.LineWidth = LINE_WIDTH;
    h.MarkerSize = MARKER_SIZE;
    h.LineStyle = '--';
    h.Color = LINE_COLOR(ind_Color, :);
    h.MarkerEdgeColor = LINE_COLOR(ind_Color, :);
    if SAME_MARKER_FACECOLOR == true
        h.MarkerFaceColor = LINE_COLOR(ind_Color, :);
    elseif SAME_MARKER_FACECOLOR == false
        h.MarkerFaceColor = 'w';
    end
    h.CapSize = 0;
    if WANT_LEGEND == true
        hL = legend('Hitt Rate', 'False Alarm', 'location', 'EastOutside');
        hL.Box = 'off';
        SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(1, :);
    elseif WANT_LEGEND == false
        SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(2, :);
    end
    
    aX =  gca;
    aX.Box = 'off';
    aX.TickDir = 'out';
    aX.TickLength = TICK_LENGTH*aX.TickLength;
    aX.YLim = Y_AXIS_LIM;
    aX.XLim = X_AXIS_LIM;
    aX.YTick = linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM(2), Y_AXIS_LABEL_NUM_STEPS);
    aX.XTick = -4:4;
    aX.XTickLabel = [-position_Tick(end:-1:2) 0 position_Tick(2:end)];
    aX.LineWidth = AXIS_LINE_WIDTH;
    aX.FontSize = FONT_SIZE;
    aX.XLabel.String = 'Eccentricity (^o)';
    aX.YLabel.String = 'd''';
    aX.Title.String = [Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName ' : ', ...
        Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceClass_1_Name ' vs. ',...
        Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceClass_2_Name];
    ind_subplot = ind_subplot + 1;
    
end

set(gcf,'color','w')
set(gcf, 'Position', SELECTED_FIGURE_DIMENSION) % Plos Comp supp
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',PRINTED_FIGURE_SIZE)
set(gcf, 'PaperPositionMode','auto')

if SAVE_PDF == true
    if WANT_LEGEND == true
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_' Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_'  Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_' Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_'  Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
    end
end
