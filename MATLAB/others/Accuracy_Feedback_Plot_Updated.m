% This code reads the raw data from several psychophysical experiment where
% subject categorized images presented in different eccentricities. The task
% included a foveal noise image. The code then calculates the accuracy
% (% correct) of subjects in different experiments

clear
clc
close all

current_Path = cd ;          % Current Directory
save_PDF_Path = [current_Path '\Figure\'];  %  Directory to store printed PDF files 

data_Path = [current_Path '\Datasets-Feedback\']; % Data directory
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
        
        for isOA = 1 : length(unique_sOA)
            this_subject_Accuracy = []; this_subject_Accuracy_Class1 = []; this_subject_Accuracy_Class2 = [];
            for iPosition = 1 : length(unique_Position)% positions
                
                this_subject_Accuracy(iPosition) = mean(subjetc_Response_Array(stimulus_Position_Array==unique_Position(iPosition) & sOA_Array==unique_sOA(isOA)));
                this_subject_Accuracy_Class1(iPosition) = mean(subjetc_Response_Array(stimulus_Position_Array==unique_Position(iPosition) & idx_Class1 & sOA_Array==unique_sOA(isOA)));
                this_subject_Accuracy_Class2(iPosition) = mean(subjetc_Response_Array(stimulus_Position_Array==unique_Position(iPosition) & idx_Class2 & sOA_Array==unique_sOA(isOA)));
                
            end
            
            if isnan(this_subject_Accuracy)
                error('Accuracy should not be nan, there should be something wrong with the code')
            end
            
            This_Experiment_Result.PerformanceAll(iSubject, :, isOA) = this_subject_Accuracy;
            This_Experiment_Result.PerformanceClass_1(iSubject, :, isOA) = this_subject_Accuracy_Class1;
            This_Experiment_Result.PerformanceClass_1_Name = unique_Task{1};
            This_Experiment_Result.PerformanceClass_2(iSubject, :, isOA) = this_subject_Accuracy_Class2;
            This_Experiment_Result.PerformanceClass_2_Name = unique_Task{2};
            
        end
        
    end
    
    Results{iCategory_Level} = This_Experiment_Result;
    
end

position_Tick = round(unique(this_Subject_Data(:,5).Variables))';
%% Visualization
close all

MARKER_SIZE = 5;
LINE_WIDTH = 1;
AXIS_LINE_WIDTH = 1;
LINE_COLOR = colormap(brewermap([],'*YlGnBu'));
% LINE_COLOR = colormap(brewermap([],'*YlOrRd'));
TICK_LENGTH = 3;
X_AXIS_LIM = [-3.2 3];
Y_AXIS_LIM = [0.48 1;
    0.28 1];
Y_AXIS_1ST_TICK = 0.5;
Y_AXIS_2ND_TICK = 0.3;
Y_AXIS_LABEL_NUM_STEPS = 3;
SAVE_PDF = false; % do you want to save PDF file of the paper
WANT_LEGEND = false;  % do you want legend
SAME_MARKER_FACECOLOR = false;% TRUE, same as line color, FALSE, white
sEM_AS_ERRORBAR = true; % FALSE std, TRUE sem
FONT_SIZE = 10;
FIGURE_DIMENSION = [0 0 400 600;
    0 0 300 600]; % dimesion of the printed figure
PRINTED_FIGURE_SIZE = [20, 20]; % the size of printed PDF file, cm
PDF_RESOLUTION = '-r300';

for iCategory_Level = 1 : length(Results)
    figure(iCategory_Level)
    ind_Color = 1;
    color_Step = floor(size(LINE_COLOR,1)/length(Results));
    
    for iExperimnet_InCategory = 1 : size(Results{iCategory_Level}.PerformanceAll,3)
        
        subplot(2, 1, 1)
        
        subject_Accuracy_Matrix = Results{iCategory_Level}.PerformanceAll(:,:, iExperimnet_InCategory);
        if sEM_AS_ERRORBAR == true
            h = errorbar(-3:3, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix)./sqrt(size(subject_Accuracy_Matrix,1)));
        elseif sEM_AS_ERRORBAR == false
            h = errorbar(-3:3, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix));
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
        
        subplot(2, 1, 2)
        
        subject_Accuracy_Matrix = Results{iCategory_Level}.PerformanceClass_1(:,:, iExperimnet_InCategory);
        if sEM_AS_ERRORBAR == true
            h = errorbar(-3:3, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix)./sqrt(size(subject_Accuracy_Matrix,1)));
        elseif sEM_AS_ERRORBAR == false
            h = errorbar(-3:3, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix));
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
        
        subject_Accuracy_Matrix = Results{iCategory_Level}.PerformanceClass_2(:,:, iExperimnet_InCategory);
        if sEM_AS_ERRORBAR == true
            h = errorbar(-3:3, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix)./sqrt(size(subject_Accuracy_Matrix,1)));
        elseif sEM_AS_ERRORBAR == false
            h = errorbar(-3:3, mean(subject_Accuracy_Matrix), std(subject_Accuracy_Matrix));
        end
        h.Marker = 'o';
        h.LineStyle = '--';
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
        plot(X_AXIS_LIM, 0.5*[1 1], ':')
        ind_Color = ind_Color + color_Step;
        
    end
    subplot(2, 1, 1)
    aX =  gca;
    aX.Box = 'off';
    aX.TickDir = 'out';
    aX.TickLength = TICK_LENGTH*aX.TickLength;
    aX.LineWidth = AXIS_LINE_WIDTH;
    aX.YLim = Y_AXIS_LIM(1,:);
    aX.XLim = X_AXIS_LIM;
    aX.YTick = linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM(1,2), Y_AXIS_LABEL_NUM_STEPS);
    aX.XTick = -3:3;
    aX.XTickLabel = [-position_Tick(end:-1:2) 0 position_Tick(2:end)];
    aX.FontSize = FONT_SIZE;
    aX.XLabel.String = 'Eccentricity (^o)';
    aX.YLabel.String = 'Accuracy';
    aX.Title.String = strrep(Results{iCategory_Level}.TaskName, '_',' Vs. ');
    
    if WANT_LEGEND == true
        hL = legend(aX, {'100','200','300','400'}, 'location', 'EastOutside');
        hL.Box = 'off';
        SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(1, :);
    elseif WANT_LEGEND == false
        SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(2, :);
    end
    
    subplot(2, 1, 2)
    aX =  gca;
    aX.Box = 'off';
    aX.TickDir = 'out';
    aX.TickLength = TICK_LENGTH*aX.TickLength;
    aX.LineWidth = AXIS_LINE_WIDTH;
    aX.YLim = Y_AXIS_LIM(2,:);
    aX.XLim = X_AXIS_LIM;
    aX.YTick = linspace(Y_AXIS_2ND_TICK, Y_AXIS_LIM(2,2), Y_AXIS_LABEL_NUM_STEPS);
    aX.XTick = -3:3;
    aX.XTickLabel = [-position_Tick(end:-1:2) 0 position_Tick(2:end)];
    aX.FontSize = FONT_SIZE;
    aX.XLabel.String = 'Eccentricity (^o)';
    aX.YLabel.String = 'Accuracy';
    
    if WANT_LEGEND == true
        hL = legend(aX, {Results{iCategory_Level}.PerformanceClass_1_Name, Results{iCategory_Level}.PerformanceClass_2_Name}, 'location', 'EastOutside');
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
            print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'Accuracy_FullScreen_FeedBack_Legend_'  Results{iCategory_Level}.TaskName  '_' date '.pdf'])
            winopen([save_PDF_Path 'Accuracy_FullScreen_FeedBack_Legend_'  Results{iCategory_Level}.TaskName  '_' date '.pdf'])
        elseif WANT_LEGEND==false
            print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'Accuracy_FullScreen_FeedBack_'  Results{iCategory_Level}.TaskName  '_' date '.pdf'])
            winopen([save_PDF_Path 'Accuracy_FullScreen_FeedBack_'  Results{iCategory_Level}.TaskName  '_' date '.pdf'])
        end
    end
    
end


% plot half screen
X_AXIS_LIM = [-0.2 3];
Y_AXIS_LIM = [0.46 1;
              0.24 1];
Y_AXIS_1ST_TICK = 0.5;
Y_AXIS_2ND_TICK = 0.3;
for iCategory_Level = 1 : length(Results)
    
    figure(iCategory_Level + 3)
    color_Step = floor(size(LINE_COLOR,1)/length(Results));
    ind_Color = 1;
    for iExperimnet_InCategory = 1 : size(Results{iCategory_Level}.PerformanceAll,3)
        
        subplot(2, 1, 1)
        
        subject_Accuracy_Matrix = Results{iCategory_Level}.PerformanceAll(:,:, iExperimnet_InCategory);
        mean_Accuracy = [mean(subject_Accuracy_Matrix(:, 4)) mean([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 5)]),...
            mean([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 6)]) mean([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 7)])];
        
        if sEM_AS_ERRORBAR == true
            
            sTD_Accuracy = [std(subject_Accuracy_Matrix(:, 4)) std([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 5)]),...
                std([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 6)]) std([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 7)])]./sqrt(2*size(subject_Accuracy_Matrix,1));
        elseif sEM_AS_ERRORBAR == false
            sTD_Accuracy = [std(subject_Accuracy_Matrix(:, 4)) std([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 5)]),...
                std([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 6)]) std([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 7)])];
        end
        h = errorbar(0:3, mean_Accuracy, sTD_Accuracy);
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
        
        subplot(2, 1, 2)
        
        subject_Accuracy_Matrix = Results{iCategory_Level}.PerformanceClass_1(:,:, iExperimnet_InCategory);
        mean_Accuracy = [mean(subject_Accuracy_Matrix(:, 4)) mean([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 5)]),...
            mean([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 6)]) mean([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 7)])];
        if sEM_AS_ERRORBAR == true
            sTD_Accuracy = [std(subject_Accuracy_Matrix(:, 4)) std([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 5)]),...
                std([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 6)]) std([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 7)])]./sqrt(2*size(subject_Accuracy_Matrix,1));
        elseif sEM_AS_ERRORBAR == false
            sTD_Accuracy = [std(subject_Accuracy_Matrix(:, 4)) std([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 5)]),...
                std([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 6)]) std([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 7)])];
        end
        h = errorbar(0:3, mean_Accuracy, sTD_Accuracy);
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
        
        subject_Accuracy_Matrix = Results{iCategory_Level}.PerformanceClass_2(:,:, iExperimnet_InCategory);
        mean_Accuracy = [mean(subject_Accuracy_Matrix(:, 4)) mean([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 5)]),...
            mean([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 6)]) mean([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 7)])];
        
        if sEM_AS_ERRORBAR == true
            sTD_Accuracy = [std(subject_Accuracy_Matrix(:, 4)) std([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 5)]),...
                std([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 6)]) std([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 7)])]./sqrt(2*size(subject_Accuracy_Matrix,1));
        elseif sEM_AS_ERRORBAR == false
            sTD_Accuracy = [std(subject_Accuracy_Matrix(:, 4)) std([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 5)]),...
                std([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 6)]) std([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 7)])];
        end
        
        h = errorbar(0:3, mean_Accuracy, sTD_Accuracy);
        h.Marker = 'o';
        h.LineStyle = '--';
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
        plot(X_AXIS_LIM, 0.5*[1 1], ':')
        ind_Color = ind_Color + color_Step;
        
    end
    subplot(2, 1, 1)
    aX =  gca;
    aX.Box = 'off';
    aX.TickDir = 'out';
    aX.TickLength = TICK_LENGTH*aX.TickLength;
    aX.LineWidth = AXIS_LINE_WIDTH;
    aX.YLim = Y_AXIS_LIM(1,:);
    aX.XLim = X_AXIS_LIM;
    aX.YTick = linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM(1,2), Y_AXIS_LABEL_NUM_STEPS);
    aX.XTick = 0:3;
    aX.XTickLabel = position_Tick;
    aX.FontSize = FONT_SIZE;
    aX.XLabel.String = 'Eccentricity (^o)';
    aX.YLabel.String = 'Accuracy';
    aX.Title.String = strrep(Results{iCategory_Level}.TaskName, '_',' Vs. ');
    
    if WANT_LEGEND == true
        hL = legend(aX, {'100','200','300','400'}, 'location', 'EastOutside');
        hL.Box = 'off';
        SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(1, :);
    elseif WANT_LEGEND == false
        SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(2, :);
    end
    
    subplot(2, 1, 2)
    aX =  gca;
    aX.Box = 'off';
    aX.TickDir = 'out';
    aX.TickLength = TICK_LENGTH*aX.TickLength;
    aX.LineWidth = AXIS_LINE_WIDTH;
    aX.YLim = Y_AXIS_LIM(2,:);
    aX.XLim = X_AXIS_LIM;
    aX.YTick = linspace(Y_AXIS_2ND_TICK, Y_AXIS_LIM(2,2), Y_AXIS_LABEL_NUM_STEPS);
    aX.XTick = 0:3;
    aX.XTickLabel = position_Tick;
    aX.Title.String = strrep(Results{iCategory_Level}.TaskName, '_',' Vs. ');
    aX.FontSize = FONT_SIZE;
    aX.XLabel.String = 'Eccentricity (^o)';
    aX.YLabel.String = 'Accuracy';
    if WANT_LEGEND == true
        hL = legend(aX, {Results{iCategory_Level}.PerformanceClass_1_Name, Results{iCategory_Level}.PerformanceClass_2_Name}, 'location', 'EastOutside');
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
            print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'Accuracy_Half_Screen_FeedBack_Legend_'  Results{iCategory_Level}.TaskName  '_' date '.pdf'])
            winopen([save_PDF_Path 'Accuracy_Half_Screen_FeedBack_Legend_'  Results{iCategory_Level}.TaskName  '_' date '.pdf'])
        elseif WANT_LEGEND==false
            print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'Accuracy_Half_Screen_FeedBack_'  Results{iCategory_Level}.TaskName  '_' date '.pdf'])
            winopen([save_PDF_Path 'Accuracy_Half_Screen_FeedBack_'  Results{iCategory_Level}.TaskName  '_' date '.pdf'])
        end
    end
end