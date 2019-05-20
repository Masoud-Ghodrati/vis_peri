% This code reads the raw data of psychophysical experiments on object
% categorization. The code visualizes the reaction time (ms) of subjects
% when categorizing different object at different visual angles (visual periphary)

clear
clc
close all

current_Path = cd ;          % Current Directory
data_Path = [current_Path '\Dataset']; % Data directory
save_PDF_Path = [current_Path '\Figure\'];  %  Directory to store printed PDF files 

dir_Category_Level = dir(data_Path); % The directory of 3 categorization level, there should be all in Dataset folder
dir_Category_Level = dir_Category_Level(3:end);
RT_LOW_CUTOFF = 250;  % low cut off for filtering RT
RT_HIGH_CUTOOF = 1500; % high cut off for filtering RT
RT_EXTRACTION_TYPE = 1; % 1, correct responses, 2, incorrect responses, 3, all responses


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
                
                % calculating mean and median RT
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
                rT_All(:, iPosition) = [mean(filtered_RT); median(filtered_RT)];
                
                % calculating mean and median RT for class 1
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
                rT_Class1(:, iPosition) = [mean(filtered_RT); median(filtered_RT)];
                
                % calculating mean and median RT for class 2
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
                rT_Class2(:, iPosition) = [mean(filtered_RT); median(filtered_RT)];
                
            end
            if isnan(rT_All)
                error('rT_All is a NaN array there should be something wrong in the code')
            end
            
            This_Experiment_Result.RTAll(:, :, iSubject) = rT_All;
            This_Experiment_Result.RTClass_1(:, :, iSubject) = rT_Class1;
            This_Experiment_Result.RTClass_1_Name = unique_Task{1};
            
            This_Experiment_Result.RTClass_2(:, :, iSubject) = rT_Class2;
            This_Experiment_Result.RTClass_2_Name = unique_Task{2};
            
        end
        
        Results{iCategory_Level}{iExperimnet_InCategory} = This_Experiment_Result;
        
    end
    
    
end

position_Tick = round(unique(this_Subject_Data(:,5).Variables))';
%% Visualization
close all

figure(1) % RT for all categorical levels and all experiments
MARKER_SIZE = 5;
LINE_WIDTH = 1;
AXIS_LINE_WIDTH = 1;
LINE_COLOR = colormap(brewermap([],'*YlGnBu'));
% LINE_COLOR = colormap(brewermap([],'*YlOrRd'));
TICK_LENGTH = 3;
X_AXIS_LIM = [-4.2 4];
Y_AXIS_LIM = [490 900];
Y_AXIS_1ST_TICK = 500;
Y_AXIS_LABEL_NUM_STEPS = 3;
SAVE_PDF = true; % do you want to save PDF file of the paper
WANT_LEGEND = false;  % do you want legend
SAME_MARKER_FACECOLOR = false;% TRUE, same as line color, FALSE, white
sEM_AS_ERRORBAR = true; % FALSE std, TRUE sem
FONT_SIZE = 10;
FIGURE_DIMENSION = [0 0 600 800;
    0 0 300 800]; % dimesion of the printed figure
PRINTED_FIGURE_SIZE = [20, 20]; % the size of printed PDF file, cm
PDF_RESOLUTION = '-r300';
PLOT_MEAN = 1; % 1 plots the mean RT, 2 plots the median RT
for iCategory_Level = 1 : length(Results)
    
    ind_Color = 1;
    color_Step = floor(size(LINE_COLOR,1)/length(Results{iCategory_Level}));
    all_Legends = [];
    for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
        
        
        subplot(3, 1, iCategory_Level)
        
        subject_RT_Matrix = squeeze(Results{iCategory_Level}{iExperimnet_InCategory}.RTAll(PLOT_MEAN,:,:))';
        
        if sEM_AS_ERRORBAR == false
            h = errorbar(-4:4, mean(subject_RT_Matrix), std(subject_RT_Matrix));
        elseif sEM_AS_ERRORBAR == true
            h = errorbar(-4:4, mean(subject_RT_Matrix), std(subject_RT_Matrix)/sqrt(size(subject_RT_Matrix,1)));
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
    if iCategory_Level==3
        aX.XLabel.String = 'Eccentricity (^o)';
        aX.YLabel.String = 'Reaction Time (ms)';
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
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'RT_FullScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'RT_FullScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
    elseif WANT_LEGEND==false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'RT_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
        winopen([save_PDF_Path 'RT_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
    end
end

figure(2)  % RT accuracy of all experiment in every categorical level
FIGURE_DIMENSION = [0 0 600 250;
    0 0 300 250]; % dimesion of the printed figure
ind_Color = 1;
all_Legends = [];
color_Step = floor(size(LINE_COLOR,1)/length(Results));
for iCategory_Level = 1 : length(Results)
    
    subject_RT_Matrix = [];
    for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
        subject_RT_Matrix = [subject_RT_Matrix; squeeze(Results{iCategory_Level}{iExperimnet_InCategory}.RTAll(PLOT_MEAN,:,:))'];
    end
    
    if sEM_AS_ERRORBAR == false
        h = errorbar(-4:4, mean(subject_RT_Matrix), std(subject_RT_Matrix));
    elseif sEM_AS_ERRORBAR == true
        h = errorbar(-4:4, mean(subject_RT_Matrix), std(subject_RT_Matrix)/sqrt(size(subject_RT_Matrix,1)));
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
    aX.YLabel.String = 'Reaction Time (ms)';
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
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'RT_FullScreen_Aveareg_of_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'RT_FullScreen_Aveareg_of_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'RT_FullScreen_Aveareg_of_All_Category_Levels_All_Tasks' date '.pdf'])
        winopen([save_PDF_Path 'RT_FullScreen_Aveareg_of_All_Category_Levels_All_Tasks' date '.pdf'])
    end
end


figure(3) % RT for all categorical levels and all experiments, avergared over left and right halves of screen
X_AXIS_LIM = [-0.2 4];
FIGURE_DIMENSION = [0 0 600 800;
    0 0 300 800]; % dimesion of the printed figure

for iCategory_Level = 1 : length(Results)
    
    
    ind_Color = 1;
    all_Legends = [];
    color_Step = floor(size(LINE_COLOR,1)/length(Results{iCategory_Level}));
    for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
        
        
        subplot(3, 1, iCategory_Level)
        
        subject_RT_Matrix = squeeze(Results{iCategory_Level}{iExperimnet_InCategory}.RTAll(PLOT_MEAN,:,:))';
        mean_Accuracy = [mean(subject_RT_Matrix(:, 5)) mean([subject_RT_Matrix(:, 4); subject_RT_Matrix(:, 6)]),...
            mean([subject_RT_Matrix(:, 3); subject_RT_Matrix(:, 7)]) mean([subject_RT_Matrix(:, 2);subject_RT_Matrix(:, 8)]),...
            mean([subject_RT_Matrix(:, 1); subject_RT_Matrix(:, 9)])];
        
        if sEM_AS_ERRORBAR == false
            sTD_Accuracy = [std(subject_RT_Matrix(:, 5)) std([subject_RT_Matrix(:, 4); subject_RT_Matrix(:, 6)]),...
                std([subject_RT_Matrix(:, 3);subject_RT_Matrix(:, 7)]) std([subject_RT_Matrix(:, 2);subject_RT_Matrix(:, 8)]),...
                std([subject_RT_Matrix(:, 1);subject_RT_Matrix(:, 9)])];
            
            h = errorbar(0:4, mean_Accuracy, sTD_Accuracy);
        elseif sEM_AS_ERRORBAR == true
            sEM_Accuracy = [std(subject_RT_Matrix(:, 5))/sqrt(length(subject_RT_Matrix(:, 5))),...
                std([subject_RT_Matrix(:, 4); subject_RT_Matrix(:, 6)])/sqrt(length([subject_RT_Matrix(:, 4); subject_RT_Matrix(:, 6)])),...
                std([subject_RT_Matrix(:, 3);subject_RT_Matrix(:, 7)])/sqrt(length([subject_RT_Matrix(:, 3); subject_RT_Matrix(:, 7)])),...
                std([subject_RT_Matrix(:, 2);subject_RT_Matrix(:, 8)])/sqrt(length([subject_RT_Matrix(:, 2); subject_RT_Matrix(:, 8)])),...
                std([subject_RT_Matrix(:, 1);subject_RT_Matrix(:, 9)])/sqrt(length([subject_RT_Matrix(:, 1); subject_RT_Matrix(:, 9)]))];
            
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
        aX.YLabel.String = 'Reaction Time (ms)';
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
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'RT_HalfScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'RT_HalfScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'RT_HalfScreen_All_Category_Levels_All_Tasks_' date '.pdf'])
        winopen([save_PDF_Path 'RT_HalfScreen_All_Category_Levels_All_Tasks_' date '.pdf'])
    end
end

figure(4) % RT accuracy of all experiment in every categorical level, avergared over left and right halves of screen
FIGURE_DIMENSION = [0 0 600 250;
    0 0 300 250]; % dimesion of the printed figure
ind_Color = 1;
all_Legends = [];
color_Step = floor(size(LINE_COLOR,1)/length(Results));
for iCategory_Level = 1 : length(Results)
    
    
    subject_RT_Matrix = [];
    for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
        subject_RT_Matrix = [subject_RT_Matrix; squeeze(Results{iCategory_Level}{iExperimnet_InCategory}.RTAll(PLOT_MEAN,:,:))'];
    end
    subject_RT_Matrix = squeeze(Results{iCategory_Level}{iExperimnet_InCategory}.RTAll(PLOT_MEAN,:,:))';
    mean_Accuracy = [mean(subject_RT_Matrix(:, 5)) mean([subject_RT_Matrix(:, 4); subject_RT_Matrix(:, 6)]),...
        mean([subject_RT_Matrix(:, 3); subject_RT_Matrix(:, 7)]) mean([subject_RT_Matrix(:, 2);subject_RT_Matrix(:, 8)]),...
        mean([subject_RT_Matrix(:, 1); subject_RT_Matrix(:, 9)])];
    
    if sEM_AS_ERRORBAR == false
        sTD_Accuracy = [std(subject_RT_Matrix(:, 5)) std([subject_RT_Matrix(:, 4); subject_RT_Matrix(:, 6)]),...
            std([subject_RT_Matrix(:, 3);subject_RT_Matrix(:, 7)]) std([subject_RT_Matrix(:, 2);subject_RT_Matrix(:, 8)]),...
            std([subject_RT_Matrix(:, 1);subject_RT_Matrix(:, 9)])];
        
        h = errorbar(0:4, mean_Accuracy, sTD_Accuracy);
    elseif sEM_AS_ERRORBAR == true
        sEM_Accuracy = [std(subject_RT_Matrix(:, 5))/sqrt(length(subject_RT_Matrix(:, 5))),...
            std([subject_RT_Matrix(:, 4); subject_RT_Matrix(:, 6)])/sqrt(length([subject_RT_Matrix(:, 4); subject_RT_Matrix(:, 6)])),...
            std([subject_RT_Matrix(:, 3);subject_RT_Matrix(:, 7)])/sqrt(length([subject_RT_Matrix(:, 3); subject_RT_Matrix(:, 7)])),...
            std([subject_RT_Matrix(:, 2);subject_RT_Matrix(:, 8)])/sqrt(length([subject_RT_Matrix(:, 2); subject_RT_Matrix(:, 8)])),...
            std([subject_RT_Matrix(:, 1);subject_RT_Matrix(:, 9)])/sqrt(length([subject_RT_Matrix(:, 1); subject_RT_Matrix(:, 9)]))];
        
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
aX.YLabel.String = 'Reaction Time (ms)';

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
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'RT_HalfScreen_Average_of_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'RT_HalfScreen_Average_of_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'RT_HalfScreen_Average_of_All_Category_Levels_All_Tasks' date '.pdf'])
        winopen([save_PDF_Path 'RT_HalfScreen_Average_of_All_Category_Levels_All_Tasks' date '.pdf'])
    end
end

figure(5) % accuracy for each class in each experiment, basic level
X_AXIS_LIM = [-4.2 4];
Y_AXIS_LIM = [490 900];
Y_AXIS_1ST_TICK = 500;

FIGURE_DIMENSION = [0 0 800 500;
    0 0 800 500]; % dimesion of the printed figure
iCategory_Level = 1;
ind_Color = 1;
ind_subplot = 1;
all_Legends = [];
WANT_LEGEND = true;
for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
    
    
    subplot(2, 2, ind_subplot)
    
    subject_RT_Matrix = squeeze(Results{iCategory_Level}{iExperimnet_InCategory}.RTClass_1(PLOT_MEAN, :, :))';
    if sEM_AS_ERRORBAR == false
        h = errorbar(-4:4, mean(subject_RT_Matrix), std(subject_RT_Matrix));
    elseif sEM_AS_ERRORBAR == true
        h = errorbar(-4:4, mean(subject_RT_Matrix), std(subject_RT_Matrix)/sqrt(size(subject_RT_Matrix,1)));
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
    
    subject_RT_Matrix = squeeze(Results{iCategory_Level}{iExperimnet_InCategory}.RTClass_2(PLOT_MEAN, :, :))';
    if sEM_AS_ERRORBAR == false
        h = errorbar(-4:4, mean(subject_RT_Matrix), std(subject_RT_Matrix));
    elseif sEM_AS_ERRORBAR == true
        h = errorbar(-4:4, mean(subject_RT_Matrix), std(subject_RT_Matrix)/sqrt(size(subject_RT_Matrix,1)));
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
        hL = legend(Results{iCategory_Level}{iExperimnet_InCategory}.RTClass_1_Name,...
            Results{iCategory_Level}{iExperimnet_InCategory}.RTClass_2_Name, 'location', 'EastOutside');
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
    aX.YLabel.String = 'Reaction Time (ms)';
    if iExperimnet_InCategory == 1
        aX.Title.String = Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName;
    end
    ind_subplot = ind_subplot + 1;
end


set(gcf,'color','w')
set(gcf, 'Position', SELECTED_FIGURE_DIMENSION) % Plos Comp supp
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',PRINTED_FIGURE_SIZE)
set(gcf, 'PaperPositionMode','auto')

if SAVE_PDF == true
    if WANT_LEGEND == true
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'RT_' Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'RT_'  Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'RT_' Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
        winopen([save_PDF_Path 'RT_'  Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
    end
end


figure(6)  % RT for each class in each experiment, sub-ordinate level
X_AXIS_LIM = [-4.2 4];
Y_AXIS_LIM = [490 900];
Y_AXIS_1ST_TICK = 500;

FIGURE_DIMENSION = [0 0 800 1000;
    0 0 800 1000]; % dimesion of the printed figure
iCategory_Level = 2;
ind_Color = 1;
ind_subplot = 1;
all_Legends = [];

for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
    
    
    subplot(4, 2, ind_subplot)
    
    subject_RT_Matrix = squeeze(Results{iCategory_Level}{iExperimnet_InCategory}.RTClass_1(PLOT_MEAN, :, :))';
    if sEM_AS_ERRORBAR == false
        h = errorbar(-4:4, mean(subject_RT_Matrix), std(subject_RT_Matrix));
    elseif sEM_AS_ERRORBAR == true
        h = errorbar(-4:4, mean(subject_RT_Matrix), std(subject_RT_Matrix)/sqrt(size(subject_RT_Matrix,1)));
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
    
    subject_RT_Matrix = squeeze(Results{iCategory_Level}{iExperimnet_InCategory}.RTClass_2(PLOT_MEAN, :, :))';
    if sEM_AS_ERRORBAR == false
        h = errorbar(-4:4, mean(subject_RT_Matrix), std(subject_RT_Matrix));
    elseif sEM_AS_ERRORBAR == true
        h = errorbar(-4:4, mean(subject_RT_Matrix), std(subject_RT_Matrix)/sqrt(size(subject_RT_Matrix,1)));
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
        hL = legend(Results{iCategory_Level}{iExperimnet_InCategory}.RTClass_1_Name,...
            Results{iCategory_Level}{iExperimnet_InCategory}.RTClass_2_Name, 'location', 'EastOutside');
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
    aX.YLabel.String = 'Reaction Time (ms)';
    if iExperimnet_InCategory == 1
        aX.Title.String = Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName;
    end
    ind_subplot = ind_subplot + 1;
end


set(gcf,'color','w')
set(gcf, 'Position', SELECTED_FIGURE_DIMENSION) % Plos Comp supp
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',PRINTED_FIGURE_SIZE)
set(gcf, 'PaperPositionMode','auto')

if SAVE_PDF == true
    if WANT_LEGEND == true
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'RT_' Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'RT_'  Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'RT_' Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
        winopen([save_PDF_Path 'RT_'  Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
    end
end

figure(7) % accuracy for each class in each experiment, supper-ordinate level
X_AXIS_LIM = [-4.2 4];
Y_AXIS_LIM = [490 900];
Y_AXIS_1ST_TICK = 500;

FIGURE_DIMENSION = [0 0 400 500;
    0 0 400 500]; % dimesion of the printed figure
iCategory_Level = 3;
ind_Color = 1;
ind_subplot = 1;
all_Legends = [];

for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
    
    
    subplot(2, 1, ind_subplot)
    
    subject_RT_Matrix = squeeze(Results{iCategory_Level}{iExperimnet_InCategory}.RTClass_1(PLOT_MEAN, :, :))';
    if sEM_AS_ERRORBAR == false
        h = errorbar(-4:4, mean(subject_RT_Matrix), std(subject_RT_Matrix));
    elseif sEM_AS_ERRORBAR == true
        h = errorbar(-4:4, mean(subject_RT_Matrix), std(subject_RT_Matrix)/sqrt(size(subject_RT_Matrix,1)));
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
    
    subject_RT_Matrix = squeeze(Results{iCategory_Level}{iExperimnet_InCategory}.RTClass_2(PLOT_MEAN, :, :))';
    if sEM_AS_ERRORBAR == false
        h = errorbar(-4:4, mean(subject_RT_Matrix), std(subject_RT_Matrix));
    elseif sEM_AS_ERRORBAR == true
        h = errorbar(-4:4, mean(subject_RT_Matrix), std(subject_RT_Matrix)/sqrt(size(subject_RT_Matrix,1)));
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
        hL = legend(Results{iCategory_Level}{iExperimnet_InCategory}.RTClass_1_Name,...
            Results{iCategory_Level}{iExperimnet_InCategory}.RTClass_2_Name, 'location', 'EastOutside');
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
    aX.YLabel.String = 'Reaction Time (ms)';
    if iExperimnet_InCategory == 1
        aX.Title.String = Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName;
    end
    ind_subplot = ind_subplot + 1;
end


set(gcf,'color','w')
set(gcf, 'Position', SELECTED_FIGURE_DIMENSION) % Plos Comp supp
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',PRINTED_FIGURE_SIZE)
set(gcf, 'PaperPositionMode','auto')

if SAVE_PDF == true
    if WANT_LEGEND == true
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'RT_' Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'RT_'  Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'RT_' Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
        winopen([save_PDF_Path 'RT_'  Results{iCategory_Level}{iExperimnet_InCategory}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
    end
end
