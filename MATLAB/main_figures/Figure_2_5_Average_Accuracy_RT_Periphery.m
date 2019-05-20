% This code reads the raw data of psychophysical experiments on object
% categorization. The code visualizes the accuracy (% correct) of subject
% when categorizing different object at different visual angles (visual periphary)

clear
clc
close all

current_Path            = 'C:\Users\masoudg\Dropbox\Project_Visual Periphery\Plots_Based_On_Farzad_Data_2Jan2018' ;  % Current Directory
data_Path_Periphery     = [current_Path '\Dataset'];  % Data directory
save_PDF_Path           = [current_Path '\Matlab_Code_V1_13March2018\Figure\'];  %  Directory to store printed PDF files

%% Data formating
% tidy up the data for visualization (not a proper tidy data)

[accuracy_Periphery, ~] = calcualte_Periphery_Accuracy(data_Path_Periphery);
clc, fprintf(' Periphery accuracy data analysis is done !')

[rt_Periphery, position_Tick_Periphery] = calcualte_Periphery_RT(data_Path_Periphery);
fprintf(' Periphery RT data analysis is done !')
clc

%% Visualization
close all

X_AXIS_LIM              = [-4.2 4];
Y_AXIS_LIM              = [0.48 1];
Y_AXIS_1ST_TICK         = 0.5;
SAVE_PDF                = true; % do you want to save PDF file of the paper
WANT_LEGEND             = false;  % do you want legend
sEM_AS_ERRORBAR         = true; % FALSE std, TRUE sem
FIGURE_DIMENSION        = [0 0 600 350;
    0 0 600 350]; % dimesion of the printed figure
PRINTED_FIGURE_SIZE     = [25, 25]; % the size of printed PDF file, cm
PDF_RESOLUTION          = '-r300';
RAND_SPACING            = 600;

figure(1) % Aevrage accuracy of all experiment in every categorical level, avergared over left and right halves of screen
COLOR_NAME              = {'YlOrRd', 'YlGnBu', 'YlGn'};
LINE_STYLES             = {'--','-.','-'};
for iPlot = 1 : 2  % number of subplot
    
    ind_Color           = 1;
    subplot(1, 2, iPlot)
    if iPlot == 1
        Results         = rt_Periphery;
        Y_Axis_Label    = 'Reaction time (ms)';
        Y_Axis_Lim      = [500 800];
        Y_Axis_Label_Start = 510;
    else
        Results         = accuracy_Periphery;
        Y_Axis_Label    = 'Accuracy (\itProbablity correct)';
        Y_Axis_Lim      = [0.48 1];
        Y_Axis_Label_Start = 0.5;
    end
    
    for iCategory_Level = 1 : length(Results)
        
        LINE_COLOR      = colormap(brewermap([], ['*' COLOR_NAME{iCategory_Level}]));
        THIS_LINE_STYLE = LINE_STYLES{iCategory_Level};
        subject_Data_Matrix = [];
        
        if iPlot == 1
            for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
                subject_Data_Matrix    = [subject_Data_Matrix; Results{iCategory_Level}{iExperimnet_InCategory}.RTAll];
            end
        else
            for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
                subject_Data_Matrix    = [subject_Data_Matrix; Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceAll];
            end
        end
        mean_Data       = [mean( subject_Data_Matrix(:, 5)),...
            mean([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)]),...
            mean([subject_Data_Matrix(:, 3); subject_Data_Matrix(:, 7)]),...
            mean([subject_Data_Matrix(:, 2); subject_Data_Matrix(:, 8)]),...
            mean([subject_Data_Matrix(:, 1); subject_Data_Matrix(:, 9)])];
        if sEM_AS_ERRORBAR == false
            sTD_Accuracy= [std(subject_Data_Matrix(:, 5)),...
                std([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)]),...
                std([subject_Data_Matrix(:, 3); subject_Data_Matrix(:, 7)]),...
                std([subject_Data_Matrix(:, 2); subject_Data_Matrix(:, 8)]),...
                std([subject_Data_Matrix(:, 1); subject_Data_Matrix(:, 9)])];
            
            h           = errorbar([0 : 4]-(rand/RAND_SPACING), mean_Data, sTD_Accuracy);
            
        elseif sEM_AS_ERRORBAR == true
            sEM_Data    = [std(subject_Data_Matrix(:, 5))/sqrt(length(subject_Data_Matrix(:, 5))),...
                std([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)])/sqrt(length([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)])),...
                std([subject_Data_Matrix(:, 3);subject_Data_Matrix(:, 7)])/sqrt(length([subject_Data_Matrix(:, 3); subject_Data_Matrix(:, 7)])),...
                std([subject_Data_Matrix(:, 2);subject_Data_Matrix(:, 8)])/sqrt(length([subject_Data_Matrix(:, 2); subject_Data_Matrix(:, 8)])),...
                std([subject_Data_Matrix(:, 1);subject_Data_Matrix(:, 9)])/sqrt(length([subject_Data_Matrix(:, 1); subject_Data_Matrix(:, 9)]))];
            
            h           = errorbar([0 : 4]-(rand/RAND_SPACING), mean_Data, sEM_Data);
        end
        
        my_Figure_Handle= Set_Plot_Properties_Periphery(h, LINE_COLOR(ind_Color, :), position_Tick_Periphery, Y_Axis_Label, Y_Axis_Label_Start, Y_Axis_Lim, THIS_LINE_STYLE);
        
        hold on
        all_Legends{iCategory_Level} = Results{iCategory_Level}{1}.CatLevelName;
        
    end
    
end

if WANT_LEGEND == true
    hL                  = legend(gca, all_Legends, 'location', 'EastOutside');
    hL.Box              = 'off';
    SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(1, :);
elseif WANT_LEGEND == false
    SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(2, :);
end

set(gcf, 'Position', SELECTED_FIGURE_DIMENSION)
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',PRINTED_FIGURE_SIZE)
set(gcf, 'PaperPositionMode','auto')

if SAVE_PDF == true
    if WANT_LEGEND == true
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'Figure_2_Average_Accuracy_RT_Periphery_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'Figure_2_Average_Accuracy_RT_Periphery_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'Figure_2_Average_Accuracy_RT_Periphery_' date '.pdf'])
        winopen([save_PDF_Path 'Figure_2_Average_Accuracy_RT_Periphery_' date '.pdf'])
    end
end

figure(2) % Accuracy for all categorical levels and all experiments, avergared over left and right halves of screen
subplot_Order           = [1:6];
color_Step_Array        = [10 6 15];
subpot_Ind              = 1;
FIGURE_DIMENSION        = [0 0 940 710;
    0 0 940 710]; % dimesion of the printed figure

for iPlot = 1 : 2  % number of subplot
    
    
    if iPlot == 1
        Results         = rt_Periphery;
        Y_Axis_Label    = 'Reaction time (ms)';
        Y_Axis_Lim      = [500 800];
        Y_Axis_Label_Start = 510;
    else
        Results         = accuracy_Periphery;
        Y_Axis_Label    = 'Accuracy (\itProbablity correct)';
        Y_Axis_Lim      = [0.48 1];
        Y_Axis_Label_Start = 0.5;
    end
    for iCategory_Level = [3, 1, 2]  % sup, basic, sub
        
        subplot(2, 3, subplot_Order(subpot_Ind))
        ind_Color       = 1;
        all_Legends     = [];
        LINE_COLOR      = colormap(brewermap([], ['*' COLOR_NAME{iCategory_Level}]));
        %         color_Step = floor(size(LINE_COLOR,1) / (length(Results{iCategory_Level})));
        color_Step      = color_Step_Array(iCategory_Level);
        THIS_LINE_STYLE = LINE_STYLES{iCategory_Level};
        for iExperimnet_InCategory = 1 : length(Results{iCategory_Level})
            
            if iPlot == 1
                subject_Data_Matrix = Results{iCategory_Level}{iExperimnet_InCategory}.RTAll;
            else
                subject_Data_Matrix = Results{iCategory_Level}{iExperimnet_InCategory}.PerformanceAll;
            end
            mean_Data = [mean(subject_Data_Matrix(:, 5)) mean([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)]),...
                mean([subject_Data_Matrix(:, 3);subject_Data_Matrix(:, 7)]) mean([subject_Data_Matrix(:, 2);subject_Data_Matrix(:, 8)]),...
                mean([subject_Data_Matrix(:, 1);subject_Data_Matrix(:, 9)])];
            
            if sEM_AS_ERRORBAR == false
                sTD_Accuracy = [std(subject_Data_Matrix(:, 5)) std([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)]),...
                    std([subject_Data_Matrix(:, 3);subject_Data_Matrix(:, 7)]) std([subject_Data_Matrix(:, 2);subject_Data_Matrix(:, 8)]),...
                    std([subject_Data_Matrix(:, 1);subject_Data_Matrix(:, 9)])];
                
                h = errorbar([0 : 4]-(rand/RAND_SPACING), mean_Data, sTD_Accuracy);
            elseif sEM_AS_ERRORBAR == true
                sEM_Data = [std(subject_Data_Matrix(:, 5))/sqrt(length(subject_Data_Matrix(:, 5))),...
                    std([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)])/sqrt(length([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)])),...
                    std([subject_Data_Matrix(:, 3);subject_Data_Matrix(:, 7)])/sqrt(length([subject_Data_Matrix(:, 3); subject_Data_Matrix(:, 7)])),...
                    std([subject_Data_Matrix(:, 2);subject_Data_Matrix(:, 8)])/sqrt(length([subject_Data_Matrix(:, 2); subject_Data_Matrix(:, 8)])),...
                    std([subject_Data_Matrix(:, 1);subject_Data_Matrix(:, 9)])/sqrt(length([subject_Data_Matrix(:, 1); subject_Data_Matrix(:, 9)]))];
                
                h = errorbar([0 : 4]-(rand/RAND_SPACING), mean_Data, sEM_Data);
            end
            
            hold on
            my_Figure_Handle = Set_Plot_Properties_Periphery(h, LINE_COLOR(ind_Color, :), position_Tick_Periphery, Y_Axis_Label, Y_Axis_Label_Start, Y_Axis_Lim, THIS_LINE_STYLE);
            all_Legends{iExperimnet_InCategory} = strrep(Results{iCategory_Level}{iExperimnet_InCategory}.TaskName, '_', ' vs.  ');
            ind_Color = ind_Color + color_Step;
            
        end
        
        if WANT_LEGEND == true
            hL = legend(gca, all_Legends, 'location', 'EastOutside');
            hL.Box = 'off';
            SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(1, :);
        elseif WANT_LEGEND == false
            SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(2, :);
        end
        
        subpot_Ind = subpot_Ind + 1;
    end
end
set(gcf,'color','w')
set(gcf, 'Position', SELECTED_FIGURE_DIMENSION)
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',PRINTED_FIGURE_SIZE)
set(gcf, 'PaperPositionMode','auto')

if SAVE_PDF == true
    if WANT_LEGEND == true
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'Figure_3_Average_Accuracy_RT_Periphery_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'Figure_3_Average_Accuracy_RT_Periphery_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'Figure_3_Average_Accuracy_RT_Periphery_' date '.pdf'])
        winopen([save_PDF_Path 'Figure_3_Average_Accuracy_RT_Periphery_' date '.pdf'])
    end
end

figure(3) % accuracy for each class in each experiment, basic level
% Basic: birdnbird 1, reptilenreptile 4
% Sub: ducknduck 2, fighternfighter 3, lizardnlizard 5, racernracer 7

Y_Axis_Label =  'Accuracy (\itProbablity correct)';
Y_Axis_Lim = [0.28 1];
Y_Axis_Label_Start = 0.3;
FIGURE_DIMENSION = [0 0 940 710;
    0 0 940 710]; % dimesion of the printed figure

ind_Color   = 1;
all_Legends = [];
color_Step  = 10;
selected_Tasks = {[1, 4], [2, 3, 5, 7]};
subplot_Ind    = {[1, 4], [2, 3, 5, 6]};

Results = accuracy_Periphery;
for iCategory_Level = 1 : 2  % basic and sub
    
    LINE_COLOR = colormap(brewermap([], ['*' COLOR_NAME{iCategory_Level}]));
    
    for iExperimnet_InCategory = 1 : length(selected_Tasks{iCategory_Level})
        
        subplot(2, 3, subplot_Ind{iCategory_Level}(iExperimnet_InCategory))
        
        if selected_Tasks{iCategory_Level}(iExperimnet_InCategory) == 7 || selected_Tasks{iCategory_Level}(iExperimnet_InCategory) == 4  % this is for lizard and nanlizard as they are not in usual order
            subject_Data_Matrix = Results{iCategory_Level}{selected_Tasks{iCategory_Level}(iExperimnet_InCategory)}.PerformanceClass_2;
        else
            subject_Data_Matrix = Results{iCategory_Level}{selected_Tasks{iCategory_Level}(iExperimnet_InCategory)}.PerformanceClass_1;
        end
        mean_Data = [mean(subject_Data_Matrix(:, 5)) mean([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)]),...
            mean([subject_Data_Matrix(:, 3);subject_Data_Matrix(:, 7)]) mean([subject_Data_Matrix(:, 2);subject_Data_Matrix(:, 8)]),...
            mean([subject_Data_Matrix(:, 1);subject_Data_Matrix(:, 9)])];
        
        if sEM_AS_ERRORBAR == false
            sTD_Accuracy = [std(subject_Data_Matrix(:, 5)) std([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)]),...
                std([subject_Data_Matrix(:, 3);subject_Data_Matrix(:, 7)]) std([subject_Data_Matrix(:, 2);subject_Data_Matrix(:, 8)]),...
                std([subject_Data_Matrix(:, 1);subject_Data_Matrix(:, 9)])];
            
            h = errorbar([0 : 4]-(rand/RAND_SPACING), mean_Data, sTD_Accuracy);
        elseif sEM_AS_ERRORBAR == true
            sEM_Data = [std(subject_Data_Matrix(:, 5))/sqrt(length(subject_Data_Matrix(:, 5))),...
                std([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)])/sqrt(length([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)])),...
                std([subject_Data_Matrix(:, 3);subject_Data_Matrix(:, 7)])/sqrt(length([subject_Data_Matrix(:, 3); subject_Data_Matrix(:, 7)])),...
                std([subject_Data_Matrix(:, 2);subject_Data_Matrix(:, 8)])/sqrt(length([subject_Data_Matrix(:, 2); subject_Data_Matrix(:, 8)])),...
                std([subject_Data_Matrix(:, 1);subject_Data_Matrix(:, 9)])/sqrt(length([subject_Data_Matrix(:, 1); subject_Data_Matrix(:, 9)]))];
            
            h = errorbar([0 : 4]-(rand/RAND_SPACING), mean_Data, sEM_Data);
        end
        
        hold on
        my_Figure_Handle = Set_Plot_Properties_Periphery(h, LINE_COLOR(ind_Color, :), position_Tick_Periphery, Y_Axis_Label, Y_Axis_Label_Start, Y_Axis_Lim);
        
        subject_Data_Matrix = [];
        if selected_Tasks{iCategory_Level}(iExperimnet_InCategory) == 7 || selected_Tasks{iCategory_Level}(iExperimnet_InCategory) == 4  % this is for lizard and nanlizard as they are not in usual order
            subject_Data_Matrix = Results{iCategory_Level}{selected_Tasks{iCategory_Level}(iExperimnet_InCategory)}.PerformanceClass_1;
        else
            subject_Data_Matrix = Results{iCategory_Level}{selected_Tasks{iCategory_Level}(iExperimnet_InCategory)}.PerformanceClass_2;
        end
        
        mean_Data = [mean(subject_Data_Matrix(:, 5)) mean([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)]),...
            mean([subject_Data_Matrix(:, 3);subject_Data_Matrix(:, 7)]) mean([subject_Data_Matrix(:, 2);subject_Data_Matrix(:, 8)]),...
            mean([subject_Data_Matrix(:, 1);subject_Data_Matrix(:, 9)])];
        
        if sEM_AS_ERRORBAR == false
            sTD_Accuracy = [std(subject_Data_Matrix(:, 5)) std([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)]),...
                std([subject_Data_Matrix(:, 3);subject_Data_Matrix(:, 7)]) std([subject_Data_Matrix(:, 2);subject_Data_Matrix(:, 8)]),...
                std([subject_Data_Matrix(:, 1);subject_Data_Matrix(:, 9)])];
            
            h = errorbar([0 : 4]-(rand/RAND_SPACING), mean_Data, sTD_Accuracy);
        elseif sEM_AS_ERRORBAR == true
            sEM_Data = [std(subject_Data_Matrix(:, 5))/sqrt(length(subject_Data_Matrix(:, 5))),...
                std([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)])/sqrt(length([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)])),...
                std([subject_Data_Matrix(:, 3);subject_Data_Matrix(:, 7)])/sqrt(length([subject_Data_Matrix(:, 3); subject_Data_Matrix(:, 7)])),...
                std([subject_Data_Matrix(:, 2);subject_Data_Matrix(:, 8)])/sqrt(length([subject_Data_Matrix(:, 2); subject_Data_Matrix(:, 8)])),...
                std([subject_Data_Matrix(:, 1);subject_Data_Matrix(:, 9)])/sqrt(length([subject_Data_Matrix(:, 1); subject_Data_Matrix(:, 9)]))];
            
            h = errorbar([0 : 4]-(rand/RAND_SPACING), mean_Data, sEM_Data);
        end
        
        my_Figure_Handle = Set_Plot_Properties_Periphery(h, LINE_COLOR(ind_Color, :), position_Tick_Periphery, Y_Axis_Label, Y_Axis_Label_Start, Y_Axis_Lim, '--');
        all_Legends{iCategory_Level}{iExperimnet_InCategory} = strrep(Results{iCategory_Level}{selected_Tasks{iCategory_Level}(iExperimnet_InCategory)}.TaskName, '_', ' vs.  ');
        
        plot([0 4], 0.5*[1 1], ':k')
        
        if WANT_LEGEND == true
            legend_Name = Results{iCategory_Level}{selected_Tasks{iCategory_Level}(iExperimnet_InCategory)}.TaskName;
            legend_Label1= legend_Name(1:find(legend_Name=='_',1)-1);
            legend_Label2= legend_Name(find(legend_Name=='_',1)+1:end);
            hL = legend(legend_Label1, legend_Label2, 'location', 'EastOutside');
            hL.Box = 'off';
            SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(1, :);
        elseif WANT_LEGEND == false
            SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(2, :);
        end
        
    end
end
set(gcf,'color','w')
set(gcf, 'Position', SELECTED_FIGURE_DIMENSION) % Plos Comp supp
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',PRINTED_FIGURE_SIZE)
set(gcf, 'PaperPositionMode','auto')

if SAVE_PDF == true
    if WANT_LEGEND == true
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'Figure_4_Average_Accuracy_Periphery_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'Figure_4_Average_Accuracy_Periphery_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'Figure_4_Average_Accuracy_Periphery_' date '.pdf'])
        winopen([save_PDF_Path 'Figure_4_Average_Accuracy_Periphery_' date '.pdf'])
    end
end


figure(4) % accuracy for each class in each experiment, basic level
% Basic: birdnbird 1, reptilenreptile 4
% Sub: ducknduck 2, fighternfighter 3, lizardnlizard 5, racernracer 7

Y_Axis_Label = 'Reaction time (ms)';
Y_Axis_Lim = [500 850];
Y_Axis_Label_Start = 510;
FIGURE_DIMENSION = [0 0 940 710;
    0 0 940 710]; % dimesion of the printed figure

ind_Color   = 1;
all_Legends = [];
color_Step  = 10;
selected_Tasks = {[1, 4], [2, 3, 5, 7]};
subplot_Ind    = {[1, 4], [2, 3, 5, 6]};

Results = rt_Periphery;
for iCategory_Level = 1 : 2  % basic and sub
    
    LINE_COLOR = colormap(brewermap([], ['*' COLOR_NAME{iCategory_Level}]));
    
    for iExperimnet_InCategory = 1 : length(selected_Tasks{iCategory_Level})
        
        subplot(2, 3, subplot_Ind{iCategory_Level}(iExperimnet_InCategory))
        
        subject_Data_Matrix = Results{iCategory_Level}{selected_Tasks{iCategory_Level}(iExperimnet_InCategory)}.RTClass_1;
        mean_Data = [ nanmean( subject_Data_Matrix(:, 5)),...
            nanmean([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)]),...
            nanmean([subject_Data_Matrix(:, 3); subject_Data_Matrix(:, 7)]),...
            nanmean([subject_Data_Matrix(:, 2); subject_Data_Matrix(:, 8)]),...
            nanmean([subject_Data_Matrix(:, 1); subject_Data_Matrix(:, 9)])];
        
        if sEM_AS_ERRORBAR == false
            sTD_Accuracy = [ nanstd( subject_Data_Matrix(:, 5)),...
                nanstd([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)]),...
                nanstd([subject_Data_Matrix(:, 3); subject_Data_Matrix(:, 7)]),...
                nanstd([subject_Data_Matrix(:, 2); subject_Data_Matrix(:, 8)]),...
                nanstd([subject_Data_Matrix(:, 1); subject_Data_Matrix(:, 9)])];
            
            h = errorbar([0 : 4]-(rand/RAND_SPACING), mean_Data, sTD_Accuracy);
        elseif sEM_AS_ERRORBAR == true
            sEM_Data = [nanstd(subject_Data_Matrix(:, 5))/sqrt(length(subject_Data_Matrix(:, 5))),...
                nanstd([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)])/sqrt(length([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)])),...
                nanstd([subject_Data_Matrix(:, 3);subject_Data_Matrix(:, 7)])/sqrt(length([subject_Data_Matrix(:, 3); subject_Data_Matrix(:, 7)])),...
                nanstd([subject_Data_Matrix(:, 2);subject_Data_Matrix(:, 8)])/sqrt(length([subject_Data_Matrix(:, 2); subject_Data_Matrix(:, 8)])),...
                nanstd([subject_Data_Matrix(:, 1);subject_Data_Matrix(:, 9)])/sqrt(length([subject_Data_Matrix(:, 1); subject_Data_Matrix(:, 9)]))];
            
            h = errorbar([0 : 4]-(rand/RAND_SPACING), mean_Data, sEM_Data);
        end
        
        hold on
        my_Figure_Handle = Set_Plot_Properties_Periphery(h, LINE_COLOR(ind_Color, :), position_Tick_Periphery, Y_Axis_Label, Y_Axis_Label_Start, Y_Axis_Lim);
        
        subject_Data_Matrix = [];
        
        subject_Data_Matrix = Results{iCategory_Level}{selected_Tasks{iCategory_Level}(iExperimnet_InCategory)}.RTClass_2;
        
        mean_Data = [mean(subject_Data_Matrix(:, 5)) mean([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)]),...
            mean([subject_Data_Matrix(:, 3);subject_Data_Matrix(:, 7)]) mean([subject_Data_Matrix(:, 2);subject_Data_Matrix(:, 8)]),...
            mean([subject_Data_Matrix(:, 1);subject_Data_Matrix(:, 9)])];
        
        if sEM_AS_ERRORBAR == false
            sTD_Accuracy = [std(subject_Data_Matrix(:, 5)) std([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)]),...
                std([subject_Data_Matrix(:, 3);subject_Data_Matrix(:, 7)]) std([subject_Data_Matrix(:, 2);subject_Data_Matrix(:, 8)]),...
                std([subject_Data_Matrix(:, 1);subject_Data_Matrix(:, 9)])];
            
            h = errorbar([0 : 4]-(rand/RAND_SPACING), mean_Data, sTD_Accuracy);
        elseif sEM_AS_ERRORBAR == true
            sEM_Data = [std(subject_Data_Matrix(:, 5))/sqrt(length(subject_Data_Matrix(:, 5))),...
                std([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)])/sqrt(length([subject_Data_Matrix(:, 4); subject_Data_Matrix(:, 6)])),...
                std([subject_Data_Matrix(:, 3);subject_Data_Matrix(:, 7)])/sqrt(length([subject_Data_Matrix(:, 3); subject_Data_Matrix(:, 7)])),...
                std([subject_Data_Matrix(:, 2);subject_Data_Matrix(:, 8)])/sqrt(length([subject_Data_Matrix(:, 2); subject_Data_Matrix(:, 8)])),...
                std([subject_Data_Matrix(:, 1);subject_Data_Matrix(:, 9)])/sqrt(length([subject_Data_Matrix(:, 1); subject_Data_Matrix(:, 9)]))];
            
            h = errorbar([0 : 4]-(rand/RAND_SPACING), mean_Data, sEM_Data);
        end
        
        my_Figure_Handle = Set_Plot_Properties_Periphery(h, LINE_COLOR(ind_Color, :), position_Tick_Periphery, Y_Axis_Label, Y_Axis_Label_Start, Y_Axis_Lim, '--');
        all_Legends{iCategory_Level}{iExperimnet_InCategory} = strrep(Results{iCategory_Level}{selected_Tasks{iCategory_Level}(iExperimnet_InCategory)}.TaskName, '_', ' vs.  ');
        
        if WANT_LEGEND == true
            legend_Name = Results{iCategory_Level}{selected_Tasks{iCategory_Level}(iExperimnet_InCategory)}.TaskName;
            legend_Label1= legend_Name(1:find(legend_Name=='_',1)-1);
            legend_Label2= legend_Name(find(legend_Name=='_',1)+1:end);
            hL = legend(legend_Label1, legend_Label2, 'location', 'EastOutside');
            hL.Box = 'off';
            SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(1, :);
        elseif WANT_LEGEND == false
            SELECTED_FIGURE_DIMENSION = FIGURE_DIMENSION(2, :);
        end
        
    end
end
set(gcf, 'color','w')
set(gcf, 'Position',   SELECTED_FIGURE_DIMENSION) % Plos Comp supp
set(gcf, 'PaperUnits', 'centimeters')
set(gcf, 'PaperSize',  PRINTED_FIGURE_SIZE)
set(gcf, 'PaperPositionMode','auto')

if SAVE_PDF == true
    if WANT_LEGEND == true
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'Figure_5_Average_RT_Periphery_Legend_' date '.pdf'])
        winopen([save_PDF_Path 'Figure_5_Average_RT_Periphery_Legend_' date '.pdf'])
    elseif WANT_LEGEND == false
        print('-dpdf', PDF_RESOLUTION, [save_PDF_Path 'Figure_5_Average_RT_Periphery_' date '.pdf'])
        winopen([save_PDF_Path 'Figure_5_Average_RT_Periphery_' date '.pdf'])
    end
end
