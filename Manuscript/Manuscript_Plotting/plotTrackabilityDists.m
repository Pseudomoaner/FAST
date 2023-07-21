clear all
close all

SDs = 10.^(-0.25:0.25:0.75);
xVals = -15:0.1:15;

unifSD = 8;
unifRange = sqrt((unifSD^2)*12);

subplot(1,3,[1 2])
hold on
for i = 1:size(SDs,2)
    col = [0,i/6,1];
    normDist = makedist('Normal','mu',0,'sigma',SDs(i));
    plot(xVals,pdf(normDist,xVals),'Color',col,'LineWidth',1.5)
end

unifDist = makedist('Uniform','upper',unifRange/2,'lower',-unifRange/2);
plot(xVals,pdf(unifDist,xVals),'r','LineWidth',1.5)

ax1 = gca;
ax1.LineWidth = 1.5;
ax1.XTick = [];
ax1.YTick = [];
ax1.YAxisLocation = 'origin';

subplot(1,3,3)
hold on
for i = 1:size(SDs,2)
    col = [0,i/6,1];
    trackability = 0.5*log2((unifSD^2)/SDs(i)^2)+0.5*log2(6/(pi*exp(1)));
    plot(SDs(i),trackability,'.','Color',col,'MarkerSize',18)
end

ax2 = gca;
ax2.LineWidth = 1.5;
ax2.XTick = [0];
ax2.Box = 'on';