% this is just a plot to test Git and Matlab

clear
close all
clc

TICK_LENDTH = 3;
dimension_1 = 2;
dimension_2 = 400;

rnd = randn(dimension_2, dimension_1);
average_rnd = mean(rnd);
upsample_rnd = upsample(rnd, 2);
upsample_rnd(upsample_rnd(:, 1)==0, 1) = average_rnd(1);
upsample_rnd(upsample_rnd(:, 2)==0, 2) = average_rnd(2);

h = plot(upsample_rnd(:,1), upsample_rnd(:,2));
h.Marker = 'o';
h.MarkerEdgeColor = 'k';
h.MarkerFaceColor = 'r';
h.Color = 0.7*[1 1 1];

aX = gca;
aX.Box = 'off';
aX.TickDir = 'out';
aX.XLabel.String = 'x';
aX.YLabel.String = 'y';
aX.TickLength = TICK_LENDTH*aX.TickLength;