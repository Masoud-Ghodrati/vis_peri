function my_Figure_Handle = Set_Plot_Properties_Periphery(my_Figure_Handle, Line_Color,...
    position_Tick, Y_Axis_Label, Y_Axis_Label_Start, Y_Axis_Lim, Line_Style, X_Axis_Label)
if nargin > 6
    Line_Style = Line_Style;
else
    Line_Style = '-';
end
if nargin > 7
    X_Axis_Label = X_Axis_Label;
else
    X_Axis_Label = 'Eccentricity (^o)';
end
my_Figure_Handle.Color = Line_Color;
my_Figure_Handle.LineStyle = Line_Style;
% my_Figure_Handle.LineJoin = 'miter';
my_Figure_Handle.LineWidth = 1.2;
my_Figure_Handle.Marker = 'o';
my_Figure_Handle.MarkerEdgeColor = Line_Color;
my_Figure_Handle.MarkerFaceColor = 'w';
my_Figure_Handle.MarkerSize = 6;
my_Figure_Handle.CapSize = 0;
my_Figure_Handle.Parent.Box = 'off';
my_Figure_Handle.Parent.FontAngle = 'italic';
my_Figure_Handle.Parent.FontName = 'Arial';
my_Figure_Handle.Parent.FontSize = 10;
my_Figure_Handle.Parent.FontWeight = 'normal';
my_Figure_Handle.Parent.LabelFontSizeMultiplier = 1.2;
my_Figure_Handle.Parent.LineWidth = 1.5;
my_Figure_Handle.Parent.TickDir = 'out';
my_Figure_Handle.Parent.TickLength = 3 * [0.01, 0.025];

my_Figure_Handle.Parent.XLabel.String = X_Axis_Label;
my_Figure_Handle.Parent.XLabel.FontAngle = 'normal';
my_Figure_Handle.Parent.XLabel.FontWeight = 'normal';
my_Figure_Handle.Parent.XLim = [-0.2 4];
my_Figure_Handle.Parent.XTick = 0 : 4;
my_Figure_Handle.Parent.XTickLabel = position_Tick;
my_Figure_Handle.Parent.XTickLabelRotation = 0;

my_Figure_Handle.Parent.YLabel.String = Y_Axis_Label;
my_Figure_Handle.Parent.YLabel.FontAngle = 'normal';
my_Figure_Handle.Parent.YLabel.FontWeight = 'normal';
my_Figure_Handle.Parent.YLim = Y_Axis_Lim;
my_Figure_Handle.Parent.YTick = linspace(Y_Axis_Label_Start, Y_Axis_Lim(2), 6);