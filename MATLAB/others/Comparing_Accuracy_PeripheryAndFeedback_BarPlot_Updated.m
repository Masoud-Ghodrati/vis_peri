% This code compares the accuracy (% correct) of subject in two different
% experiments inclduing periphery and feedback experiments

clear
clc
close all

current_Path = cd ;          % Current Directory
save_PDF_Path = [current_Path '\Figure\'];  %  Directory to store printed PDF files

data_Path_Feedback = [current_Path '\Datasets-Feedback\']; % Data directory
data_Path_Periphery = [current_Path '\Dataset']; % Data directory

[Results_Feedback, position_Tick_Feedback] = calcualte_Feedback_Accuracy(data_Path_Feedback);
clc, fprintf('   Feedback data analysis is done !')
%  Results_Periphery{1} TaskName: 'Animal_Nonanimal'
%  Results_Periphery{1} TaskName: 'Bird_Nonbird'
%  Results_Periphery{3} TaskName: 'Pegeon_Nonpegeon'


[Results_Periphery, position_Tick_Periphery] = calcualte_Periphery_Accuracy(data_Path_Periphery);
clc, fprintf('   Periphery data analysis is done !')
%  Results_Periphery{1}{1} TaskName: 'Bird_Nonbird'
%  Results_Periphery{2}{6} TaskName: 'Pegeon_Nonpegeon'
%  Results_Periphery{3}{1} TaskName: 'Animal_Nonanimal'
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
    Results_Periphery_Matched{iPeripheryDatatoMatch}.PerformanceAll = this_Experiment_Raw_Data.PerformanceAll(:, position_Index);
    
    Results_Periphery_Matched{iPeripheryDatatoMatch}.PerformanceClass_1_Name = this_Experiment_Raw_Data.PerformanceClass_2(:, position_Index);
    Results_Periphery_Matched{iPeripheryDatatoMatch}.PerformanceClass_1_Name = this_Experiment_Raw_Data.PerformanceClass_1_Name;
    
    Results_Periphery_Matched{iPeripheryDatatoMatch}.PerformanceClass_2 = this_Experiment_Raw_Data.PerformanceClass_2(:, position_Index);
    Results_Periphery_Matched{iPeripheryDatatoMatch}.PerformanceClass_2_Name = this_Experiment_Raw_Data.PerformanceClass_2_Name;
    
end

position_Tick = position_Tick_Feedback;
%% Visualization
close all

figure(1) % Accuracy for all categorical levels and all experiments
MARKER_SIZE = 5;
LINE_WIDTH = 1;
LINE_WIDTH_FOR_PERIPHERY_MEAN  = 1.5;
LINE_WIDTH_FOR_PERIPHERY_STD  = 0.5;
AXIS_LINE_WIDTH = 1;
LINE_COLOR = colormap(brewermap([],'*YlGnBu'));
% LINE_COLOR = colormap(brewermap([],'*YlOrRd'));
LINE_COLOR_FOR_PERIPHERY = 0.5*[1 1 1];
TICK_LENGTH = 3;
Y_AXIS_LIM = [0.5 1];
Y_AXIS_1ST_TICK = 0.5;
Y_AXIS_LABEL_NUM_STEPS = 3;
SAVE_PDF = true; % do you want to save PDF file of the paper
WANT_LEGEND = false;  % do you want legend
SAME_MARKER_FACECOLOR = false;% TRUE, same as line color, FALSE, white
sEM_AS_ERRORBAR = true; % FALSE std, TRUE sem
FONT_SIZE = 8;
FONT_SIZE_YLABEL = 10;
FIGURE_DIMENSION = [0 0 400 800;
    0 0 240 800]; % dimesion of the printed figure
PRINTED_FIGURE_SIZE = [20, 20]; % the size of printed PDF file, cm
PDF_RESOLUTION = '-r300';
all_Legends = {'No Noise','100','200','300','400'};
BAR_WIDTH = 0.95;
X_AXIS_OFFSER = 3;
for iEccentricity = 1 : 4
    
    bar_Index = 1;
    
    ind_Color = 1;
    color_Step = floor(size(LINE_COLOR,1)/(3*size(Results_Feedback{iCategory_Level}.PerformanceAll, 3)));
    subplot(4, 1, iEccentricity)
    for iCategory_Level = 1 : length(Results_Periphery_Matched)
        
        
        for isOA = 1 : size(Results_Feedback{iCategory_Level}.PerformanceAll, 3)
            
            subject_Accuracy_Matrix = Results_Feedback{iCategory_Level}.PerformanceAll(:, :, isOA);
            mean_Accuracy = [mean(subject_Accuracy_Matrix(:, 4)) mean([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 5)]),...
                mean([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 6)]) mean([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 7)])];
            
            if sEM_AS_ERRORBAR == true
                
                sTD_Accuracy = [std(subject_Accuracy_Matrix(:, 4)) std([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 5)]),...
                    std([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 6)]) std([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 7)])]./sqrt(2*size(subject_Accuracy_Matrix,1));
            elseif sEM_AS_ERRORBAR == false
                sTD_Accuracy = [std(subject_Accuracy_Matrix(:, 4)) std([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 5)]),...
                    std([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 6)]) std([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 7)])];
            end
            
            hp = bar(bar_Index, mean_Accuracy(iEccentricity));
            hp.FaceColor = LINE_COLOR(ind_Color, :);
            hp.EdgeColor = 'none';
            hp.BarWidth = BAR_WIDTH;
            hold on
            h = errorbar(bar_Index, mean_Accuracy(iEccentricity), sTD_Accuracy(iEccentricity));
            h.Marker = '.';
            h.LineWidth = LINE_WIDTH;
            h.MarkerSize = MARKER_SIZE;
            h.Color = LINE_COLOR(ind_Color, :);
            h.MarkerEdgeColor = LINE_COLOR(ind_Color, :);
            h.CapSize = 0;
            if SAME_MARKER_FACECOLOR == true
                h.MarkerFaceColor = LINE_COLOR(ind_Color, :);
            elseif SAME_MARKER_FACECOLOR == false
                h.MarkerFaceColor = 'w';
            end
            ind_Color = ind_Color + color_Step;
            bar_Index = bar_Index + 1;
        end
        
        bar_Index = bar_Index - X_AXIS_OFFSER-1;
        subject_Accuracy_Matrix = Results_Periphery_Matched{iCategory_Level}.PerformanceAll;
        
        mean_Accuracy = [mean(subject_Accuracy_Matrix(:, 4)) mean([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 5)]),...
            mean([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 6)]) mean([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 7)])];
        
        if sEM_AS_ERRORBAR == true
            
            sTD_Accuracy = [std(subject_Accuracy_Matrix(:, 4)) std([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 5)]),...
                std([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 6)]) std([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 7)])]./sqrt(2*size(subject_Accuracy_Matrix,1));
        elseif sEM_AS_ERRORBAR == false
            sTD_Accuracy = [std(subject_Accuracy_Matrix(:, 4)) std([subject_Accuracy_Matrix(:, 3); subject_Accuracy_Matrix(:, 5)]),...
                std([subject_Accuracy_Matrix(:, 2);subject_Accuracy_Matrix(:, 6)]) std([subject_Accuracy_Matrix(:, 1);subject_Accuracy_Matrix(:, 7)])];
        end
        hp = plot([bar_Index bar_Index+X_AXIS_OFFSER], mean_Accuracy(iEccentricity)*[1 1]);
        hp.Color = LINE_COLOR_FOR_PERIPHERY;
        hp.LineWidth = LINE_WIDTH_FOR_PERIPHERY_MEAN;
        hold on
        
        hp = plot([bar_Index bar_Index+X_AXIS_OFFSER], mean_Accuracy(iEccentricity)*[1 1]-sTD_Accuracy(iEccentricity));
        hp.Color = LINE_COLOR_FOR_PERIPHERY;
        hp.LineWidth = LINE_WIDTH_FOR_PERIPHERY_STD;
        hp.LineStyle = ':';
        
        hp = plot([bar_Index bar_Index+X_AXIS_OFFSER], mean_Accuracy(iEccentricity)*[1 1]+sTD_Accuracy(iEccentricity));
        hp.Color = LINE_COLOR_FOR_PERIPHERY;
        hp.LineWidth = LINE_WIDTH_FOR_PERIPHERY_STD;
        hp.LineStyle = ':';
        bar_Index = bar_Index + X_AXIS_OFFSER + 2;
        
    end
    
    aX =  gca;
    aX.Box = 'off';
    aX.TickDir = 'out';
    aX.TickLength = TICK_LENGTH*aX.TickLength;
    aX.YLim = Y_AXIS_LIM;
    aX.XLim = [0 bar_Index-1.5];
    aX.YTick = linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM(2), Y_AXIS_LABEL_NUM_STEPS);
    aX.XTick = 0:bar_Index-1;
    if iEccentricity == 4
        aX.XTickLabel = {'100','200','300','400', ''};
    else
        aX.XTickLabel = '';
    end
    aX.XTickLabelRotation = 60;
    aX.FontSize = FONT_SIZE;
    aX.LineWidth = AXIS_LINE_WIDTH;
    if iEccentricity == 1
        aX.Title.String = 'Super      Basic      Sub';
    end
    if iCategory_Level == 3
        %     aX.XLabel.String = 'Eccentricity (^o)';
        aX.YLabel.String = 'Accuracy';
        aX.YLabel.FontSize = FONT_SIZE_YLABEL;
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
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'Accuracy_Feedback_and_Periphery_HalfScreen_Bar_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'Accuracy_Feedback_and_Periphery_HalfScreen_Bar_Legend_' date '.pdf'])
    elseif WANT_LEGEND==false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'Accuracy_Feedback_and_Periphery_HalfScreen_Bar_' date '.pdf'])
        winopen([save_PDF_Path 'Accuracy_Feedback_and_Periphery_HalfScreen_Bar_' date '.pdf'])
    end
end



