clear
clc
close all

Current_Path = cd ;          % Current Directory
Data_Path = [cd '\Dataset']; % Data directory
Dir_Cat_Level = dir(Data_Path); % The directory of 3 categorization level, there should be all in Dataset folder
Dir_Cat_Level = Dir_Cat_Level(3:end);
%% Data formating
for Cat_Lev_Cnt = 1 : length(Dir_Cat_Level)
    
    Curr_Cat = dir([Data_Path '\' Dir_Cat_Level(Cat_Lev_Cnt).name]);
    Curr_Cat = Curr_Cat(3:end);
    
    for Curr_Cat_Cnt = 1 : length(Curr_Cat)
        
        Exp_Curr_Cat = dir([Data_Path '\' Dir_Cat_Level(Cat_Lev_Cnt).name '\' Curr_Cat(Curr_Cat_Cnt).name]);
        Exp_Curr_Cat = Exp_Curr_Cat(3:end);
        
        Res.CatLevelName = Dir_Cat_Level(Cat_Lev_Cnt).name;
        Res.TaskName = Curr_Cat(Curr_Cat_Cnt).name;
        Res.PerformanceAll = [];
        Res.PerformanceClass_1 = [];
        Res.PerformanceClass_1_Name = [];
        
        Res.PerformanceClass_2 = [];
        Res.PerformanceClass_2_Name = [];
        
        for Subj_Cnt = 1 : length(Exp_Curr_Cat)
            
            Sub_Exp_Curr_Cat = dir([Data_Path '\' Dir_Cat_Level(Cat_Lev_Cnt).name '\',...
                Curr_Cat(Curr_Cat_Cnt).name '\' Exp_Curr_Cat(Subj_Cnt).name]);
            Sub_Exp_Curr_Cat = Sub_Exp_Curr_Cat(3);
            
            Table = readtable([Data_Path '\' Dir_Cat_Level(Cat_Lev_Cnt).name '\',...
                Curr_Cat(Curr_Cat_Cnt).name '\' Exp_Curr_Cat(Subj_Cnt).name '\'  Sub_Exp_Curr_Cat.name]);
            
            Pos = Table(:,4).Variables;
            Resp = Table(:,11).Variables;
            Tasklabel = Table(:,3).Variables;
            Task = unique(Table(:,3).Variables);
            Perfall = []; Perf1 = []; Perf2 = [];
            
            for p = 1 : 9 % positions
                
                Perfall(p) = mean(Resp(Pos==p));
                [~, idx] = ismember( Tasklabel, Task{1} );
                Perf1(p) = mean(Resp(Pos==p & idx));
                [~, idx] = ismember( Tasklabel, Task{2} );
                Perf2(p) = mean(Resp(Pos==p & idx));
                
                
            end
            if isnan(Perfall)
                error('d')
            end
            
            Res.PerformanceAll(Subj_Cnt, :) = Perfall;
            Res.PerformanceClass_1(Subj_Cnt, :) = Perf1;
            Res.PerformanceClass_1_Name = Task{1};
            
            Res.PerformanceClass_2(Subj_Cnt, :) = Perf2;
            Res.PerformanceClass_2_Name = Task{2};
            
            %           plot(Perfall, 'r'), hold on
            %           plot(Perf1, 'b')
            %           plot(Perf2, 'g')
            
            
        end
        
        
        Results{Cat_Lev_Cnt}{Curr_Cat_Cnt} = Res;
        
    end
    
    
end

PosTick = round(unique(Table(:,5).Variables))';
%% Ploting
close all
Markersize = 3;
Linwid = 0.5;
Color = colormap(jet);
Color = Color(1:2:end, :);
TickL = 2;
Xlim = [-4.1 4.1];
Ylim = [0.5 1];
Spc = 3;
close all
SavePDF = 0;
FontSiz = 10;

for Cat_Lev_Cnt = 1 : length(Results)
    
    
    for Curr_Cat_Cnt = 1 : length(Results{Cat_Lev_Cnt})
        figure('units','normalized','outerposition',[0 0 1 1])
        i = 1;
        for sub = 1 : size(Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.PerformanceAll,1)
            
            subplot(3, 4, sub)
            
            Perfall = Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.PerformanceAll(sub,:);
            h1 = plot(-4:4, Perfall);
            h1.Marker = 'o';
            h1.LineWidth = Linwid;
            h1.MarkerSize = Markersize;
            h1.Color = Color(i, :);
            h1.MarkerEdgeColor = Color(i, :);
            h1.MarkerFaceColor = Color(i, :);
            
            Ax =  gca;
            Ax.Box = 'off';
            Ax.TickDir = 'out';
            Ax.TickLength = TickL*Ax.TickLength;
            Ax.YLim = Ylim;
            Ax.XLim = Xlim;
            Ax.YTick = linspace(Ylim(1), Ylim(2), Spc);
            Ax.XTick = -4:4;
            Ax.XTickLabel = [-PosTick(end:-1:1) PosTick(2:end)];
            Ax.Title.String = [ Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.CatLevelName ' Sub:' num2str(sub) ];
            Ax.FontSize = FontSiz;
            
            L = legend(Ax, strrep(Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.TaskName, '_',' Vs. '), 'location', 'west');
            L.Box = 'off';
            
            i = i + 1;
        end
        
        Ax.XLabel.String = 'Degree';
        Ax.YLabel.String = 'Accuracy';
        
    end
    
    
end

set(gcf,'color','w')
set(gcf, 'Position', [0 0 600 700]) % Plos Comp supp
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',[20 20])
set(gcf, 'PaperPositionMode','auto')

if SavePDF
    print('-dpdf', '-r300', ['Accuracy_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
    winopen(['Accuracy_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
end


% Plot for inividual categories
Xlim = [-4.1 4.1];


for Cat_Lev_Cnt = 1 : length(Results)
    
    
    for Curr_Cat_Cnt = 1 : length(Results{Cat_Lev_Cnt})
        figure('units','normalized','outerposition',[0 0 1 1])
        i = 1;
        for sub = 1 : size(Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.PerformanceAll,1)
            
            subplot(3, 4, sub)
            
            Perfall = Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.PerformanceClass_1(sub,:);
            h1 = plot(-4:4, Perfall);
            h1.Marker = 'o';
            h1.LineWidth = Linwid;
            h1.MarkerSize = Markersize;
            h1.Color = Color(i, :);
            h1.MarkerEdgeColor = Color(i, :);
            h1.MarkerFaceColor = Color(i, :);
            hold on
            
            Perfall = Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.PerformanceClass_2(sub,:);
            h1 = plot(-4:4, Perfall);
            h1.Marker = 'o';
            h1.LineStyle = '--';
            h1.LineWidth = Linwid;
            h1.MarkerSize = Markersize;
            h1.Color = Color(i, :);
            h1.MarkerEdgeColor = Color(i, :);
            h1.MarkerFaceColor = Color(i, :);

            Ax =  gca;
            Ax.Box = 'off';
            Ax.TickDir = 'out';
            Ax.TickLength = TickL*Ax.TickLength;
            Ax.YLim = Ylim;
            Ax.XLim = Xlim;
            Ax.YTick = linspace(Ylim(1), Ylim(2), Spc);
            Ax.XTick = -4:4;
            Ax.XTickLabel = [-PosTick(end:-1:1) PosTick(2:end)];
            Ax.Title.String = [ Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.CatLevelName ' Sub:' num2str(sub) ];
            Ax.FontSize = FontSiz;
            
            L = legend(Ax, {Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.PerformanceClass_1_Name , Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.PerformanceClass_2_Name}, 'location', 'west');
            L.Box = 'off';

            i = i + 1;
        end
    end
end


Ax.XLabel.String = 'Degree';
Ax.YLabel.String = 'Accuracy';

set(gcf,'color','w')
set(gcf, 'Position', [0 0 800 600]) % Plos Comp supp
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',[20 20])
set(gcf, 'PaperPositionMode','auto')

if SavePDF
    print('-dpdf', '-r300', ['Accuracy_' Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
    winopen(['Accuracy_'  Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
end

