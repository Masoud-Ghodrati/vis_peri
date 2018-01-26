% this is just a plot to test Git and Matlab

clear
close all
clc

dimension_1 = 2;
dimension_2 = 300;

rnd = randn(dimension_1, dimension_2);

h = plot(rnd(1,:), rnd(2,:));
h.Marker = 'o';
h.MarkerEdgeColor = 'k';
h.MarkerFaceColor = 'r';
h.Color = 0.7*[1 1 1];

aX = gca;
aX.Box = 'off';
aX.TickDir = 'out';
aX.XLabel.String = 'x';
aX.YLabel.String = 'y';