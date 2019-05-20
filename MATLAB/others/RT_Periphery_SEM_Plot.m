clear
clc
close all

Current_Path = cd ;          % Current Directory
Data_Path = [cd '\Dataset']; % Data directory
Dir_Cat_Level = dir(Data_Path); % The directory of 3 categorization level, there should be all in Dataset folder
Dir_Cat_Level = Dir_Cat_Level(3:end);
RT_low = 250;
RT_high = 1500;
%% Data formating
for Cat_Lev_Cnt = 1 : length(Dir_Cat_Level)
    
    Curr_Cat = dir([Data_Path '\' Dir_Cat_Level(Cat_Lev_Cnt).name]);
    Curr_Cat = Curr_Cat(3:end);
    
    for Curr_Cat_Cnt = 1 : length(Curr_Cat)
        
        Exp_Curr_Cat = dir([Data_Path '\' Dir_Cat_Level(Cat_Lev_Cnt).name '\' Curr_Cat(Curr_Cat_Cnt).name]);
        Exp_Curr_Cat = Exp_Curr_Cat(3:end);
        
        Res.CatLevelName = Dir_Cat_Level(Cat_Lev_Cnt).name;
        Res.TaskName = Curr_Cat(Curr_Cat_Cnt).name;
        Res.RTAll = [];
        Res.RTClass_1 = [];
        Res.RTClass_1_Name = [];
        
        Res.PerformanceClass_2 = [];
        Res.PerformanceClass_2_Name = [];
        
        for Subj_Cnt = 1 : length(Exp_Curr_Cat)
            
            Sub_Exp_Curr_Cat = dir([Data_Path '\' Dir_Cat_Level(Cat_Lev_Cnt).name '\',...
                Curr_Cat(Curr_Cat_Cnt).name '\' Exp_Curr_Cat(Subj_Cnt).name]);
            Sub_Exp_Curr_Cat = Sub_Exp_Curr_Cat(3);
            
            Table = readtable([Data_Path '\' Dir_Cat_Level(Cat_Lev_Cnt).name '\',...
                Curr_Cat(Curr_Cat_Cnt).name '\' Exp_Curr_Cat(Subj_Cnt).name '\'  Sub_Exp_Curr_Cat.name]);
            
            Pos = Table(:,4).Variables;
            RT = Table(:,10).Variables;
            Resp = Table(:,11).Variables;
            Tasklabel = Table(:,3).Variables;
            Task = unique(Table(:,3).Variables);
            RTall = []; RT1 = []; RT2 = [];
            
            for p = 1 : 9 % positions
                Un_FLT_RT = RT(Pos==p & Resp==1);
                FLT_RT = Un_FLT_RT(Un_FLT_RT>=RT_low & Un_FLT_RT<=RT_high);
                if isempty(FLT_RT),
                    FLT_RT = NaN;
                end
                RTall(p) = mean(FLT_RT);
                
                [~, idx] = ismember( Tasklabel, Task{1} );
                Un_FLT_RT = RT(Pos==p & idx & Resp==1);
                FLT_RT = Un_FLT_RT(Un_FLT_RT>=RT_low & Un_FLT_RT<=RT_high);
                if isempty(FLT_RT)
                    FLT_RT = NaN;
                end
                RT1(p) = mean(FLT_RT);
                
                [~, idx] = ismember( Tasklabel, Task{2} );
                Un_FLT_RT = RT(Pos==p & idx & Resp==1);
                FLT_RT = Un_FLT_RT(Un_FLT_RT>=RT_low & Un_FLT_RT<=RT_high);
                if isempty(FLT_RT)
                    FLT_RT = NaN;
                end
                RT2(p) = mean(FLT_RT);
                
                
            end
            if isnan(RTall)
                error('d')
            end
            
            Res.RTAll(Subj_Cnt, :) = RTall;
            Res.RTClass_1(Subj_Cnt, :) = RT1;
            Res.RTClass_1_Name = Task{1};
            
            Res.RTClass_2(Subj_Cnt, :) = RT2;
            Res.RTClass_2_Name = Task{2};
            
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
Color = Color(1:8:end, :);
TickL = 2;
Xlim = [-4.1 4.1];
Ylim = [500 900];
Spc = 3;
figure(1)
SavePDF = 0;
FontSiz = 10;

for Cat_Lev_Cnt = 1 : length(Results)
    
    i = 1;
    Leg = [];
    for Curr_Cat_Cnt = 1 : length(Results{Cat_Lev_Cnt})
        
        
        subplot(3, 1, Cat_Lev_Cnt)
        
        RTall = Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.RTAll;
        h1 = errorbar(-4:4, mean(RTall), std(RTall)/sqrt(size(RTall, 1)));
        h1.Marker = 'o';
        h1.LineWidth = Linwid;
        h1.MarkerSize = Markersize;
        h1.Color = Color(i, :);
        h1.MarkerEdgeColor = Color(i, :);
        h1.MarkerFaceColor = Color(i, :);
        h1.CapSize = 0;
        hold on
        Leg{Curr_Cat_Cnt} = strrep(Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.TaskName, '_', ' vs.  ');
        i = i + 1;
        
    end
    
    Ax =  gca;
    Ax.Box = 'off';
    Ax.TickDir = 'out';
    Ax.TickLength = TickL*Ax.TickLength;
    Ax.YLim = Ylim;
    Ax.XLim = Xlim;
    Ax.YTick = linspace(Ylim(1), Ylim(2), Spc);
    Ax.XTick = -4:4;
    Ax.XTickLabel = [-PosTick(end:-1:1) PosTick(2:end)];
    Ax.Title.String = Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.CatLevelName;
    Ax.FontSize = FontSiz;
    
    if Cat_Lev_Cnt==3
        Ax.XLabel.String = 'Degree';
        Ax.YLabel.String = 'RT';
    end
    L = legend(Ax, Leg, 'location', 'EastOutside');
    L.Box = 'off';
    
    
end

set(gcf,'color','w')
set(gcf, 'Position', [0 0 600 700]) % Plos Comp supp
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',[20 20])
set(gcf, 'PaperPositionMode','auto')

if SavePDF
    print('-dpdf', '-r300', ['RT_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
    winopen(['RT_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
end

figure(2)
i = 1;
Leg = [];
for Cat_Lev_Cnt = 1 : length(Results)
    
    RTall = [];
    for Curr_Cat_Cnt = 1 : length(Results{Cat_Lev_Cnt})
        RTall = [RTall; Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.RTAll];
    end
    
    
    h1 = errorbar(-4:4, mean(RTall), std(RTall)/sqrt(size(RTall,1)));
    h1.Marker = 'o';
    h1.LineWidth = Linwid;
    h1.MarkerSize = Markersize;
    h1.Color = Color(i, :);
    h1.MarkerEdgeColor = Color(i, :);
    h1.MarkerFaceColor = Color(i, :);
    h1.CapSize = 0;
    hold on
    Leg{Cat_Lev_Cnt} = Results{Cat_Lev_Cnt}{1}.CatLevelName;
    i = i + 2;
    
end

Ax =  gca;
Ax.Box = 'off';
Ax.TickDir = 'out';
Ax.TickLength = TickL*Ax.TickLength;
Ax.YLim = Ylim;
Ax.XLim = Xlim;
Ax.YTick = linspace(Ylim(1), Ylim(2), Spc);
Ax.XTick = -4:4;
Ax.XTickLabel = [-PosTick(end:-1:1) PosTick(2:end)];
Ax.FontSize = FontSiz;

if Cat_Lev_Cnt==3
    Ax.XLabel.String = 'Degree';
    Ax.YLabel.String = 'RT';
end

L = legend(Ax, Leg, 'location', 'EastOutside');
L.Box = 'off';

set(gcf,'color','w')
set(gcf, 'Position', [0 0 500 300]) % Plos Comp supp
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',[20 20])
set(gcf, 'PaperPositionMode','auto')

if SavePDF
    print('-dpdf', '-r300', ['RT_FullScreen_Aveareg_of_All_Category_Levels_All_Tasks' date '.pdf'])
    winopen(['RT_FullScreen_Aveareg_of_All_Category_Levels_All_Tasks' date '.pdf'])
end


figure(3)
Xlim = [-0.1 4.1];
for Cat_Lev_Cnt = 1 : length(Results)
    
    i = 1;
    Leg = [];
    for Curr_Cat_Cnt = 1 : length(Results{Cat_Lev_Cnt})
        
        
        subplot(3, 1, Cat_Lev_Cnt)
        
        RTall = Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.RTAll;
        Mean = [mean(RTall(:, 5)) mean([RTall(:, 4); RTall(:, 6)]),...
            mean([RTall(:, 3);RTall(:, 7)]) mean([RTall(:, 2);RTall(:, 8)]),...
            mean([RTall(:, 1);RTall(:, 9)])];
        
        STD = [std(RTall(:, 5)) std([RTall(:, 4); RTall(:, 6)]),...
            std([RTall(:, 3);RTall(:, 7)]) std([RTall(:, 2);RTall(:, 8)]),...
            std([RTall(:, 1);RTall(:, 9)])]./sqrt(2*size(RTall,1));
        h1 = errorbar(0:4, Mean, STD);
        h1.Marker = 'o';
        h1.LineWidth = Linwid;
        h1.MarkerSize = Markersize;
        h1.Color = Color(i, :);
        h1.MarkerEdgeColor = Color(i, :);
        h1.MarkerFaceColor = Color(i, :);
        h1.CapSize = 0;
        hold on
        Leg{Curr_Cat_Cnt} = strrep(Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.TaskName, '_', ' vs.  ');
        i = i + 1;
        
    end
    
    Ax =  gca;
    Ax.Box = 'off';
    Ax.TickDir = 'out';
    Ax.TickLength = TickL*Ax.TickLength;
    Ax.YLim = Ylim;
    Ax.XLim = Xlim;
    Ax.YTick = linspace(Ylim(1), Ylim(2), Spc);
    Ax.XTick = 0:4;
    Ax.XTickLabel = PosTick;
    Ax.Title.String = Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.CatLevelName;
    Ax.FontSize = FontSiz;
    
    if Cat_Lev_Cnt==3
        Ax.XLabel.String = 'Degree';
        Ax.YLabel.String = 'RT';
    end
    L = legend(Ax, Leg, 'location', 'EastOutside');
    L.Box = 'off';
    
    
end

set(gcf,'color','w')
set(gcf, 'Position', [0 0 600 700]) % Plos Comp supp
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',[20 20])
set(gcf, 'PaperPositionMode','auto')

if SavePDF
    print('-dpdf', '-r300', ['RT_HalfScreen_All_Category_Levels_All_Tasks' date '.pdf'])
    winopen(['RT_HalfScreen_All_Category_Levels_All_Tasks' date '.pdf'])
end



figure(4)
Xlim = [-0.1 4.1];
i = 1;
Leg = [];
for Cat_Lev_Cnt = 1 : length(Results)
    
    
    RTall = [];
    for Curr_Cat_Cnt = 1 : length(Results{Cat_Lev_Cnt})
        RTall = [RTall; Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.RTAll];
    end
    Mean = [mean(RTall(:, 5)) mean([RTall(:, 4); RTall(:, 6)]),...
        mean([RTall(:, 3);RTall(:, 7)]) mean([RTall(:, 2);RTall(:, 8)]),...
        mean([RTall(:, 1);RTall(:, 9)])];
    STD = [std(RTall(:, 5)) std([RTall(:, 4); RTall(:, 6)]),...
        std([RTall(:, 3);RTall(:, 7)]) std([RTall(:, 2);RTall(:, 8)]),...
        std([RTall(:, 1);RTall(:, 9)])]./sqrt(2*size(RTall,1));
    h1 = errorbar(0:4, Mean, STD);
    h1.Marker = 'o';
    h1.LineWidth = Linwid;
    h1.MarkerSize = Markersize;
    h1.Color = Color(i, :);
    h1.MarkerEdgeColor = Color(i, :);
    h1.MarkerFaceColor = Color(i, :);
    h1.CapSize = 0;
    hold on
    Leg{Cat_Lev_Cnt} = Results{Cat_Lev_Cnt}{1}.CatLevelName;
    i = i + 2;
    
end

Ax =  gca;
Ax.Box = 'off';
Ax.TickDir = 'out';
Ax.TickLength = TickL*Ax.TickLength;
Ax.YLim = Ylim;
Ax.XLim = Xlim;
Ax.YTick = linspace(Ylim(1), Ylim(2), Spc);
Ax.XTick = 0:4;
Ax.XTickLabel = PosTick;
Ax.FontSize = FontSiz;

if Cat_Lev_Cnt==3
    Ax.XLabel.String = 'Degree';
    Ax.YLabel.String = 'RT';
end
L = legend(Ax, Leg, 'location', 'EastOutside');
L.Box = 'off';


set(gcf,'color','w')
set(gcf, 'Position', [0 0 500 300]) % Plos Comp supp
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',[20 20])
set(gcf, 'PaperPositionMode','auto')

if SavePDF
    print('-dpdf', '-r300', ['RT_HalfScreen_Average_of_All_Category_Levels_All_Tasks' date '.pdf'])
    winopen(['RT_HalfScreen_Average_of_All_Category_Levels_All_Tasks' date '.pdf'])
end


% Plot for inividual categories
figure(5)
Xlim = [-4.1 4.1];
Cat_Lev_Cnt = 1;
i = 1;
Leg = [];
for Curr_Cat_Cnt = 1 : length(Results{Cat_Lev_Cnt})
    
    
    subplot(2, 2, i)
    
    RTall = Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.RTClass_1;
    h1 = errorbar(-4:4, mean(RTall), std(RTall)./sqrt(size(RTall,1)));
    h1.Marker = 'o';
    h1.LineWidth = Linwid;
    h1.MarkerSize = Markersize;
    h1.Color = Color(1, :);
    h1.MarkerEdgeColor = Color(1, :);
    h1.MarkerFaceColor = Color(1, :);
    h1.CapSize = 0;
    hold on
    
    RTall = Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.RTClass_2;
    h1 = errorbar(-4:4, mean(RTall), std(RTall)./sqrt(size(RTall,1)));
    h1.Marker = 'o';
    h1.LineWidth = Linwid;
    h1.MarkerSize = Markersize;
    h1.Color = Color(3, :);
    h1.MarkerEdgeColor = Color(3, :);
    h1.MarkerFaceColor = Color(3, :);
    h1.CapSize = 0;
    
    L = legend(Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.RTClass_1_Name,...
        Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.RTClass_2_Name, 'location', 'EastOutside');
    L.Box = 'off';
    
    Ax =  gca;
    Ax.Box = 'off';
    Ax.TickDir = 'out';
    Ax.TickLength = TickL*Ax.TickLength;
    Ax.YLim = Ylim;
    Ax.XLim = Xlim;
    Ax.YTick = linspace(Ylim(1), Ylim(2), Spc);
    Ax.XTick = -4:4;
    Ax.XTickLabel = [-PosTick(end:-1:1) PosTick(2:end)];
    
    Ax.FontSize = FontSiz;
    if Curr_Cat_Cnt==1
        Ax.Title.String = Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.CatLevelName;
    end
    i = i + 1;
    
end


Ax.XLabel.String = 'Degree';
Ax.YLabel.String = 'RT';

set(gcf,'color','w')
set(gcf, 'Position', [0 0 800 600]) % Plos Comp supp
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',[20 20])
set(gcf, 'PaperPositionMode','auto')

if SavePDF
    print('-dpdf', '-r300', ['RT_' Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
    winopen(['RT_'  Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
end

figure(6)
Cat_Lev_Cnt = 2;
i = 1;
Leg = [];
for Curr_Cat_Cnt = 1 : length(Results{Cat_Lev_Cnt})
    
    
    subplot(4, 2, i)
    
    RTall = Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.RTClass_1;
    h1 = errorbar(-4:4, mean(RTall), std(RTall)./sqrt(size(RTall,1)));
    h1.Marker = 'o';
    h1.LineWidth = Linwid;
    h1.MarkerSize = Markersize;
    h1.Color = Color(1, :);
    h1.MarkerEdgeColor = Color(1, :);
    h1.MarkerFaceColor = Color(1, :);
    h1.CapSize = 0;
    hold on
    
    RTall = Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.RTClass_2;
    h1 = errorbar(-4:4, mean(RTall), std(RTall)./sqrt(size(RTall,1)));
    h1.Marker = 'o';
    h1.LineWidth = Linwid;
    h1.MarkerSize = Markersize;
    h1.Color = Color(3, :);
    h1.MarkerEdgeColor = Color(3, :);
    h1.MarkerFaceColor = Color(3, :);
    h1.CapSize = 0;
    
    L = legend(Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.RTClass_1_Name,...
        Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.RTClass_2_Name, 'location', 'EastOutside');
    L.Box = 'off';
    
    Ax =  gca;
    Ax.Box = 'off';
    Ax.TickDir = 'out';
    Ax.TickLength = TickL*Ax.TickLength;
    Ax.YLim = Ylim;
    Ax.XLim = Xlim;
    Ax.YTick = linspace(Ylim(1), Ylim(2), Spc);
    Ax.XTick = -4:4;
    Ax.XTickLabel = [-PosTick(end:-1:1) PosTick(2:end)];
    
    Ax.FontSize = FontSiz;
    if Curr_Cat_Cnt==1
        Ax.Title.String = Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.CatLevelName;
    end
    i = i + 1;
    
end


Ax.XLabel.String = 'Degree';
Ax.YLabel.String = 'RT';

set(gcf,'color','w')
set(gcf, 'Position', [0 0 800 600]) % Plos Comp supp
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',[20 20])
set(gcf, 'PaperPositionMode','auto')

if SavePDF
    print('-dpdf', '-r300', ['RT_' Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
    winopen(['RT_'  Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
end

figure(7)
Cat_Lev_Cnt = 3;
i = 1;
Leg = [];
for Curr_Cat_Cnt = 1 : length(Results{Cat_Lev_Cnt})
    
    
    subplot(2, 1, i)
    
    RTall = Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.RTClass_1;
    h1 = errorbar(-4:4, mean(RTall), std(RTall)./sqrt(size(RTall,1)));
    h1.Marker = 'o';
    h1.LineWidth = Linwid;
    h1.MarkerSize = Markersize;
    h1.Color = Color(1, :);
    h1.MarkerEdgeColor = Color(1, :);
    h1.MarkerFaceColor = Color(1, :);
    h1.CapSize = 0;
    hold on
    
    RTall = Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.RTClass_2;
    h1 = errorbar(-4:4, mean(RTall), std(RTall)./sqrt(size(RTall,1)));
    h1.Marker = 'o';
    h1.LineWidth = Linwid;
    h1.MarkerSize = Markersize;
    h1.Color = Color(3, :);
    h1.MarkerEdgeColor = Color(3, :);
    h1.MarkerFaceColor = Color(3, :);
    h1.CapSize = 0;
    
    L = legend(Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.RTClass_1_Name,...
        Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.RTClass_2_Name, 'location', 'EastOutside');
    L.Box = 'off';
    
    Ax =  gca;
    Ax.Box = 'off';
    Ax.TickDir = 'out';
    Ax.TickLength = TickL*Ax.TickLength;
    Ax.YLim = Ylim;
    Ax.XLim = Xlim;
    Ax.YTick = linspace(Ylim(1), Ylim(2), Spc);
    Ax.XTick = -4:4;
    Ax.XTickLabel = [-PosTick(end:-1:1) PosTick(2:end)];
    
    Ax.FontSize = FontSiz;
    if Curr_Cat_Cnt==1
        Ax.Title.String = Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.CatLevelName;
    end
    i = i + 1;
    
end


Ax.XLabel.String = 'Degree';
Ax.YLabel.String = 'RT';

set(gcf,'color','w')
set(gcf, 'Position', [0 0 800 600]) % Plos Comp supp
set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',[20 20])
set(gcf, 'PaperPositionMode','auto')

if SavePDF
    print('-dpdf', '-r300', ['RT_' Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
    winopen(['RT_'  Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.CatLevelName '_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
end
