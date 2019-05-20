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
    %     fprintf(['Level: ' Dir_Cat_Level(Cat_Lev_Cnt).name])
    for Curr_Cat_Cnt = 1 : length(Curr_Cat)
        
        Exp_Curr_Cat = dir([Data_Path '\' Dir_Cat_Level(Cat_Lev_Cnt).name '\' Curr_Cat(Curr_Cat_Cnt).name]);
        Exp_Curr_Cat = Exp_Curr_Cat(3:end);
        
        Res.CatLevelName = Dir_Cat_Level(Cat_Lev_Cnt).name;
        Res.TaskName = Curr_Cat(Curr_Cat_Cnt).name;
        Res.Perf_RT_All = [];
        %         fprintf(['Level: ' Dir_Cat_Level(Cat_Lev_Cnt).name, ',    Task:  ' Curr_Cat(Curr_Cat_Cnt).name])
        Subj_Cnt_tem = 1;
        for Subj_Cnt = 1 : length(Exp_Curr_Cat)
            
            Sub_Exp_Curr_Cat = dir([Data_Path '\' Dir_Cat_Level(Cat_Lev_Cnt).name '\',...
                Curr_Cat(Curr_Cat_Cnt).name '\' Exp_Curr_Cat(Subj_Cnt).name]);
            Sub_Exp_Curr_Cat = Sub_Exp_Curr_Cat(3);
            
            Table = readtable([Data_Path '\' Dir_Cat_Level(Cat_Lev_Cnt).name '\',...
                Curr_Cat(Curr_Cat_Cnt).name '\' Exp_Curr_Cat(Subj_Cnt).name '\'  Sub_Exp_Curr_Cat.name]);
            
            Pos = Table(:,4).Variables;
            Resp = Table(:,11).Variables;
            Reaction_tim = Table(:,10).Variables;
            Tasklabel = Table(:,3).Variables;
            Task = unique(Table(:,3).Variables);
            ImNum = Table(:,2).Variables;
            ImNumUnq = unique(ImNum);
            Perf_and_RT = [];
            for itsk = 1 : length(Task)
                
                for im = 1 : length(ImNumUnq)
                    
                    [~, idx] = ismember( Tasklabel, Task{itsk} );
                    Temp_Pos = Pos(idx & ImNum==ImNumUnq(im));
                    Perf_and_RT = [Perf_and_RT ; Resp(idx & ImNum==ImNumUnq(im)) Reaction_tim(idx & ImNum==ImNumUnq(im)) Temp_Pos];
                    
                end
            end
            if isnan(Perf_and_RT)
                error('d')
            end
            if size(Perf_and_RT,1)<=400
                Res.Perf_RT_All(:, :, Subj_Cnt_tem) = Perf_and_RT;
                Subj_Cnt_tem = Subj_Cnt_tem + 1;
            end
            
            
            %           plot(Perfall, 'r'), hold on
            %           plot(Perf1, 'b')
            %           plot(Perf2, 'g')
            
            fprintf(['Level: ' Dir_Cat_Level(Cat_Lev_Cnt).name, ',    Task:  ' Curr_Cat(Curr_Cat_Cnt).name,...
                ',   sub:  ' Exp_Curr_Cat(Subj_Cnt).name])
            
        end
        fprintf('\n')
        
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
Ylim = [-1 0];
Spc = 3;
figure(1)
SavePDF = 0;
FontSiz = 10;

for Cat_Lev_Cnt = 1 : length(Results)
    
    i = 1;
    Leg = [];
    for Curr_Cat_Cnt = 1 : length(Results{Cat_Lev_Cnt})
        
        
        subplot(3, 1, Cat_Lev_Cnt)
        
        AllData = mean(Results{Cat_Lev_Cnt}{Curr_Cat_Cnt}.Perf_RT_All, 3);
        UnqPos = unique(Pos);
        for pi = 1 : length(unique(Pos))
           
            c(pi) = corr(AllData(AllData(:,3)==UnqPos(pi), 1), AllData(AllData(:,3)==UnqPos(pi), 2));
            
        end
        h1 = plot(-4:4, c);
        h1.Marker = 'o';
        h1.LineWidth = Linwid;
        h1.MarkerSize = Markersize;
        h1.Color = Color(i, :);
        h1.MarkerEdgeColor = Color(i, :);
        h1.MarkerFaceColor = Color(i, :);

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
        Ax.YLabel.String = 'Accuracy';
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
    print('-dpdf', '-r300', ['Accuracy_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
    winopen(['Accuracy_FullScreen_All_Category_Levels_All_Tasks' date '.pdf'])
end
