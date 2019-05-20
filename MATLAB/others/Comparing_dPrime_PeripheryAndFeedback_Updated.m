% This code compares the dPrime  of subject in two different
% experiments inclduing periphery and feedback experiments

clear
close all
clc

clear
clc
close all

current_Path = cd ;          % Current Directory
save_PDF_Path = [current_Path '\Figure\'];  %  Directory to store printed PDF files

data_Path_Feedback = [current_Path '\Datasets-Feedback\']; % Data directory
data_Path_Periphery = [current_Path '\Dataset']; % Data directory

[Results_Feedback, position_Tick_Feedback] = calcualte_Feedback_dPrime(data_Path_Feedback);
clc, fprintf('   Feedback data analysis is done !')
%  Results_Periphery{1} TaskName: 'Animal_Nonanimal'
%  Results_Periphery{1} TaskName: 'Bird_Nonbird'
%  Results_Periphery{3} TaskName: 'Pegeon_Nonpegeon'


[Results_Periphery, position_Tick_Periphery] = calcualte_Periphery_dPrime(data_Path_Periphery);
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

figure(1) % dPrime for all categorical levels and all experiments
MARKER_SIZE = 5;
LINE_WIDTH = 1;
LINE_WIDTH_FOR_PERIPHERY  = 1.5;
AXIS_LINE_WIDTH = 1;
LINE_COLOR = colormap(brewermap([],'*YlGnBu'));
% LINE_COLOR = colormap(brewermap([],'*YlOrRd'));
LINE_COLOR_FOR_PERIPHERY = 0*[1 1 1];
TICK_LENGTH = 3;
X_AXIS_LIM = [-3.2 3];
Y_AXIS_LIM = [-0.2 4];
Y_AXIS_1ST_TICK = 0;
Y_AXIS_LABEL_NUM_STEPS = 3;
SAVE_PDF = false; % do you want to save PDF file of the paper
WANT_LEGEND = false;  % do you want legend
SAME_MARKER_FACECOLOR = false;% TRUE, same as line color, FALSE, white
sEM_AS_ERRORBAR = true; % FALSE std, TRUE sem
FONT_SIZE = 10;
FIGURE_DIMENSION = [0 0 400 800;
    0 0 300 800]; % dimesion of the printed figure
PRINTED_FIGURE_SIZE = [20, 20]; % the size of printed PDF file, cm
PDF_RESOLUTION = '-r300';
all_Legends = {'No Noise','100','200','300','400'};
for iCategory_Level = 1 : length(Results_Periphery_Matched)
    
    
    subplot(3, 1, iCategory_Level)
    
    subject_dPrime_Matrix = Results_Periphery_Matched{iCategory_Level}.PerformanceAll;
    if sEM_AS_ERRORBAR == false
        h = errorbar(-3:3, mean(subject_dPrime_Matrix), std(subject_dPrime_Matrix));
    elseif sEM_AS_ERRORBAR == true
        h = errorbar(-3:3, mean(subject_dPrime_Matrix), std(subject_dPrime_Matrix)/sqrt(size(subject_dPrime_Matrix,1)));
    end
    
    h.Marker = 'o';
    h.LineWidth = LINE_WIDTH_FOR_PERIPHERY;
    h.MarkerSize = MARKER_SIZE;
    h.Color = LINE_COLOR_FOR_PERIPHERY;
    h.MarkerEdgeColor = LINE_COLOR_FOR_PERIPHERY;
    if SAME_MARKER_FACECOLOR == true
        h.MarkerFaceColor = LINE_COLOR_FOR_PERIPHERY;
    elseif SAME_MARKER_FACECOLOR == false
        h.MarkerFaceColor = 'w';
    end
    h.CapSize = 0;
    hold on
    
    ind_Color = 1;
    color_Step = floor(size(LINE_COLOR,1)/size(Results_Feedback{iCategory_Level}.PerformanceAll, 3));
    for isOA = 1 : size(Results_Feedback{iCategory_Level}.PerformanceAll, 3)
        
        subject_dPrime_Matrix = Results_Feedback{iCategory_Level}.PerformanceAll(:, :, isOA);
        if sEM_AS_ERRORBAR == false
            h = errorbar(-3:3, mean(subject_dPrime_Matrix), std(subject_dPrime_Matrix));
        elseif sEM_AS_ERRORBAR == true
            h = errorbar(-3:3, mean(subject_dPrime_Matrix), std(subject_dPrime_Matrix)/sqrt(size(subject_dPrime_Matrix,1)));
        end
        h.Marker = 'o';
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
        
    end
    
    aX =  gca;
    aX.Box = 'off';
    aX.TickDir = 'out';
    aX.TickLength = TICK_LENGTH*aX.TickLength;
    aX.YLim = Y_AXIS_LIM;
    aX.XLim = X_AXIS_LIM;
    aX.YTick = linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM(2), Y_AXIS_LABEL_NUM_STEPS);
    aX.XTick = -3:3;
    aX.XTickLabel = [-position_Tick(end:-1:2) 0 position_Tick(2:end)];
    aX.Title.String = [Results_Periphery_Matched{iCategory_Level}.CatLevelName ' ( ',...
        strrep(Results_Periphery_Matched{iCategory_Level}.TaskName, '_', ' vs.  ')  ' )'];
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
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_Feedback_and_Periphery_FullScreen_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_Feedback_and_Periphery_FullScreen_Legend_' date '.pdf'])
    elseif WANT_LEGEND==false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_Feedback_and_Periphery_FullScreen_' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_Feedback_and_Periphery_FullScreen_' date '.pdf'])
    end
end


% plot half screen
figure(2) % dPrime for all categorical levels and all experiments
X_AXIS_LIM = [-0.15 3];
Y_AXIS_LIM = [-0.2 4];
Y_AXIS_1ST_TICK = 0;
for iCategory_Level = 1 : length(Results_Periphery_Matched)
    
    
    subplot(3, 1, iCategory_Level)
    
    subject_dPrime_Matrix = Results_Periphery_Matched{iCategory_Level}.PerformanceAll;
    
    mean_dPrime = [mean(subject_dPrime_Matrix(:, 4)) mean([subject_dPrime_Matrix(:, 3); subject_dPrime_Matrix(:, 5)]),...
        mean([subject_dPrime_Matrix(:, 2);subject_dPrime_Matrix(:, 6)]) mean([subject_dPrime_Matrix(:, 1);subject_dPrime_Matrix(:, 7)])];
    
    if sEM_AS_ERRORBAR == true
        
        sTD_dPrime = [std(subject_dPrime_Matrix(:, 4)) std([subject_dPrime_Matrix(:, 3); subject_dPrime_Matrix(:, 5)]),...
            std([subject_dPrime_Matrix(:, 2);subject_dPrime_Matrix(:, 6)]) std([subject_dPrime_Matrix(:, 1);subject_dPrime_Matrix(:, 7)])]./sqrt(2*size(subject_dPrime_Matrix,1));
    elseif sEM_AS_ERRORBAR == false
        sTD_dPrime = [std(subject_dPrime_Matrix(:, 4)) std([subject_dPrime_Matrix(:, 3); subject_dPrime_Matrix(:, 5)]),...
            std([subject_dPrime_Matrix(:, 2);subject_dPrime_Matrix(:, 6)]) std([subject_dPrime_Matrix(:, 1);subject_dPrime_Matrix(:, 7)])];
    end
    h = errorbar(0:3, mean_dPrime, sTD_dPrime);
    h.Marker = 'o';
    h.LineWidth = LINE_WIDTH_FOR_PERIPHERY;
    h.MarkerSize = MARKER_SIZE;
    h.Color = LINE_COLOR_FOR_PERIPHERY;
    h.MarkerEdgeColor = LINE_COLOR_FOR_PERIPHERY;
    if SAME_MARKER_FACECOLOR == true
        h.MarkerFaceColor = LINE_COLOR_FOR_PERIPHERY;
    elseif SAME_MARKER_FACECOLOR == false
        h.MarkerFaceColor = 'w';
    end
    h.CapSize = 0;
    hold on
    
    ind_Color = 1;
    color_Step = floor(size(LINE_COLOR,1)/size(Results_Feedback{iCategory_Level}.PerformanceAll, 3));
    for isOA = 1 : size(Results_Feedback{iCategory_Level}.PerformanceAll, 3)
        
        subject_dPrime_Matrix = Results_Feedback{iCategory_Level}.PerformanceAll(:, :, isOA);
        mean_dPrime = [mean(subject_dPrime_Matrix(:, 4)) mean([subject_dPrime_Matrix(:, 3); subject_dPrime_Matrix(:, 5)]),...
            mean([subject_dPrime_Matrix(:, 2);subject_dPrime_Matrix(:, 6)]) mean([subject_dPrime_Matrix(:, 1);subject_dPrime_Matrix(:, 7)])];
        
        if sEM_AS_ERRORBAR == true
            
            sTD_dPrime = [std(subject_dPrime_Matrix(:, 4)) std([subject_dPrime_Matrix(:, 3); subject_dPrime_Matrix(:, 5)]),...
                std([subject_dPrime_Matrix(:, 2);subject_dPrime_Matrix(:, 6)]) std([subject_dPrime_Matrix(:, 1);subject_dPrime_Matrix(:, 7)])]./sqrt(2*size(subject_dPrime_Matrix,1));
        elseif sEM_AS_ERRORBAR == false
            sTD_dPrime = [std(subject_dPrime_Matrix(:, 4)) std([subject_dPrime_Matrix(:, 3); subject_dPrime_Matrix(:, 5)]),...
                std([subject_dPrime_Matrix(:, 2);subject_dPrime_Matrix(:, 6)]) std([subject_dPrime_Matrix(:, 1);subject_dPrime_Matrix(:, 7)])];
        end
        h = errorbar(0:3, mean_dPrime, sTD_dPrime);
        h.Marker = 'o';
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
        
    end
    
    aX =  gca;
    aX.Box = 'off';
    aX.TickDir = 'out';
    aX.TickLength = TICK_LENGTH*aX.TickLength;
    aX.YLim = Y_AXIS_LIM;
    aX.XLim = X_AXIS_LIM;
    aX.YTick = linspace(Y_AXIS_1ST_TICK, Y_AXIS_LIM(2), Y_AXIS_LABEL_NUM_STEPS);
    aX.XTick = 0:3;
    aX.XTickLabel = position_Tick;
    aX.Title.String = [Results_Periphery_Matched{iCategory_Level}.CatLevelName ' ( ',...
        strrep(Results_Periphery_Matched{iCategory_Level}.TaskName, '_', ' vs.  ')  ' )'];
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
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_Feedback_and_Periphery_HalfScreen_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_Feedback_and_Periphery_HalfScreen_Legend_' date '.pdf'])
    elseif WANT_LEGEND==false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'dPrime_Feedback_and_Periphery_HalfScreen_' date '.pdf'])
        winopen([save_PDF_Path 'dPrime_Feedback_and_Periphery_HalfScreen_' date '.pdf'])
    end
end
