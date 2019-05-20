% This code compares the accuracy (% correct) of subject in two different
% experiments inclduing periphery and feedback experiments

clear
clc
close all

current_Path = 'C:\Users\masoudg\Dropbox\Project_Visual Periphery\Plots_Based_On_Farzad_Data_2Jan2018' ;  % Current Directory

save_PDF_Path = [current_Path '\Matlab_Code_V1_13March2018\Figure\'];  %  Directory to store printed PDF files

data_Path_Feedback = [current_Path '\Datasets-Feedback\']; % Data directory
data_Path_Periphery = [current_Path '\Dataset']; % Data directory

[Results_Feedback, position_Tick_Feedback] = calcualte_Feedback_RT(data_Path_Feedback);
clc, fprintf('   Feedback data is loaded !')
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


Results_Feedback_Matched = Results_Feedback;

position_Tick = position_Tick_Feedback;
%% Visualization
close all

figure(1)

SAVE_PDF = true; % do you want to save PDF file of the paper
WANT_LEGEND = false;  % do you want legend
sEM_AS_ERRORBAR = true; % FALSE std, TRUE sem
FIGURE_DIMENSION = [0 0 940 325;
    0 0 940 325]; % dimesion of the printed figure
PRINTED_FIGURE_SIZE = [25, 25]; % the size of printed PDF file, cm
PDF_RESOLUTION = '-r300';
all_Legends = {'No Noise','100','200','300','400'};
position_Tick_SOA = [0 100 200 300 400];
COLOR_NAME = {'YlGn', 'YlOrRd', 'YlGnBu'};
LINE_STYLES = {'-','--','-.'};
Y_Axis_Label = 'Accuracy (%)';
Y_Axis_Lim = [0.58 0.9];
Y_Axis_Label_Start = 0.6;
RAND_SPACING = 600;

ind_Color = 1;

for iPlot = 1 : 1  % number of subplot
    
    ind_Color = 1;
    subplot(1, 4, iPlot)
    
    
    Y_Axis_Label = 'Reaction time (ms)';
    Y_Axis_Lim = [500 1000];
    Y_Axis_Label_Start = 510;
    
    for iCategory_Level = 1 : length(Results_Periphery_Matched)
        
        
        LINE_COLOR = colormap(brewermap([], ['*' COLOR_NAME{iCategory_Level}]));
        THIS_LINE_STYLE = LINE_STYLES{iCategory_Level};
        subject_Data_Matrix = [];
        
        for iSOA = 1 : 5  % 4 SOA + without noise
            subject_Data_Matrix_temp = [];
            if iSOA == 1
                subject_Data_Matrix_temp = Results_Periphery_Matched{iCategory_Level}.RTAll;
                subject_Data_Matrix_temp = subject_Data_Matrix_temp(:);
            else
                subject_Data_Matrix_temp = Results_Feedback_Matched{iCategory_Level}.RTAll(:, :, iSOA-1);
                subject_Data_Matrix_temp = subject_Data_Matrix_temp(:);
            end
            
            subject_Data_Matrix = [subject_Data_Matrix subject_Data_Matrix_temp(1:70)];
            
        end
        
        mean_Data = nanmean(subject_Data_Matrix);
        
        if sEM_AS_ERRORBAR == true
            
            sEM_Data = nanstd(subject_Data_Matrix)/sqrt(size(subject_Data_Matrix, 1));
            h = errorbar([0 : 4]-(rand/RAND_SPACING), mean_Data, sEM_Data);
            
        elseif sEM_AS_ERRORBAR == false
            
            sEM_Data = nanstd(subject_Data_Matrix);
            h = errorbar([0 : 4]-(rand/RAND_SPACING), mean_Data, sEM_Data);
            
        end
        
        my_Figure_Handle = Set_Plot_Properties_Periphery(h, LINE_COLOR(ind_Color, :), position_Tick_SOA, Y_Axis_Label, Y_Axis_Label_Start, Y_Axis_Lim, THIS_LINE_STYLE, 'SOA');
        hold on
    end
end


% figure(2) % Accuracy for all categorical levels and all experiments
MARKER_SIZE = 5;
LINE_WIDTH = 1.2;
LINE_WIDTH_FOR_PERIPHERY_MEAN  = 1.5;
LINE_WIDTH_FOR_PERIPHERY_STD  = 1;
AXIS_LINE_WIDTH = 1.5;
LINE_COLOR_FOR_PERIPHERY = 0.5*[1 1 1];
TICK_LENGTH = 3;
Y_AXIS_LIM = 1000*[0.5 1];
Y_AXIS_1ST_TICK = 1000*0.51;
Y_AXIS_LABEL_NUM_STEPS = 6;
FONT_SIZE = 10;
BAR_WIDTH = 0.95;
X_AXIS_OFFSER = 3;
Eccentricity_Array = [4 4;
                      3 5;
                      2 6;
                      1 7];
color_Step = 3;
for iCategory_Level = 1 : length(Results_Periphery_Matched)
    
    subplot(1, 4, iCategory_Level+1)
    LINE_COLOR = colormap(brewermap([], ['*' COLOR_NAME{iCategory_Level}]));
    bar_Index = 1;
    ind_Color = 1;
    for iEccentricity = 1 : 4
        
        for iSOA = 1 : 4   % 4 SOA + without noise
            
            subject_Data_Matrix = [];
            if iEccentricity == 1
                subject_Data_Matrix = Results_Feedback_Matched{iCategory_Level}.RTAll(:, Eccentricity_Array(iEccentricity, 1), iSOA);
            else
                subject_Data_Matrix = Results_Feedback_Matched{iCategory_Level}.RTAll(:, Eccentricity_Array(iEccentricity, :), iSOA);
            end
            
            mean_Data = nanmean(subject_Data_Matrix(:));
            
            if sEM_AS_ERRORBAR == true
                sTD_Data = nanstd(subject_Data_Matrix(:))/sqrt(length(subject_Data_Matrix(:)));
            elseif sEM_AS_ERRORBAR == false
                sTD_Data = nanstd(subject_Data_Matrix(:));
            end
            
            hp = bar(bar_Index, mean_Data);
            hp.FaceColor = LINE_COLOR(ind_Color, :);
            hp.EdgeColor = 'none';
            hp.BarWidth = BAR_WIDTH;
            hold on
            h = errorbar(bar_Index, mean_Data, sTD_Data);
            h.Marker = '.';
            h.LineWidth = LINE_WIDTH;
            h.MarkerSize = MARKER_SIZE;
            h.Color = LINE_COLOR(ind_Color, :);
            h.MarkerEdgeColor = LINE_COLOR(ind_Color, :);
            h.CapSize = 0;
            
            h.MarkerFaceColor = LINE_COLOR(ind_Color, :);
            ind_Color = ind_Color + color_Step;
            bar_Index = bar_Index + 1;
        end
        
        bar_Index = bar_Index - X_AXIS_OFFSER-1;
        subject_Data_Matrix = [];
        if iEccentricity == 1
            subject_Data_Matrix = Results_Periphery_Matched{iCategory_Level}.RTAll(:, Eccentricity_Array(iEccentricity, 1));
        else
            subject_Data_Matrix = Results_Periphery_Matched{iCategory_Level}.RTAll(:, Eccentricity_Array(iEccentricity, :));
        end
        
        mean_Data = nanmean(subject_Data_Matrix(:));
        
        if sEM_AS_ERRORBAR == true
            sTD_Data = nanstd(subject_Data_Matrix(:))/sqrt(length(subject_Data_Matrix(:)));
        elseif sEM_AS_ERRORBAR == false
            sTD_Data = nanstd(subject_Data_Matrix(:));
        end
        
        hp = plot([bar_Index bar_Index+X_AXIS_OFFSER], mean_Data*[1 1]);
        hp.Color = LINE_COLOR_FOR_PERIPHERY;
        hp.LineWidth = LINE_WIDTH_FOR_PERIPHERY_MEAN;
        hold on
        
        hp = plot([bar_Index bar_Index+X_AXIS_OFFSER], mean_Data*[1 1]-sTD_Data);
        hp.Color = LINE_COLOR_FOR_PERIPHERY;
        hp.LineWidth = LINE_WIDTH_FOR_PERIPHERY_STD;
        hp.LineStyle = ':';
        
        hp = plot([bar_Index bar_Index+X_AXIS_OFFSER], mean_Data*[1 1]+sTD_Data);
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
    if iCategory_Level > 1
        aX.YTickLabel = '';
    end
    aX.XTick = 0:bar_Index-1;
    if iEccentricity == 4
        aX.XTickLabel = {'','100','200','300','400'};
        
    end
    
    aX.XTickLabelRotation = 90;
    aX.LineWidth = AXIS_LINE_WIDTH;
    aX.FontAngle = 'normal';
    aX.XLabel.String = {'  0^o    12^o  18^o   24^o'; 'Eccentricity (^o)'};
    aX.XLabel.FontAngle = 'normal';
    aX.YLabel.FontAngle = 'normal';
    aX.XAxis.FontSize = 7;    
    aX.YAxis.FontSize = 10; 
    aX.XAxis.Label.FontSize = 12;
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
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'Figure_7_RT_Feedback_and_Periphery_AllSOAs_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'Figure_7_RT_Feedback_and_Periphery_AllSOAs_Legend_' date '.pdf'])
    elseif WANT_LEGEND==false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'Figure_7_RT_Feedback_and_Periphery_AllSOAs_' date '.pdf'])
        winopen([save_PDF_Path 'Figure_7_RT_Feedback_and_Periphery_AllSOAs_' date '.pdf'])
    end
end

