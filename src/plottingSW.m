% Biomass used in the single technology concepts

% clear all
% load('results/Temp.mat','vBio')
% 
% % FB combustion 100
% 
% bioSW100 = squeeze(vBio(:,49,7,:));
% 
% figure (1)
% area(bioSW100,'DisplayName','bioSW100')
% 
% 
% % FB combustion 250
% bioSW250 = squeeze(vBio(:,51,16,:));
% 
% figure (2)
% area(bioSW250,'DisplayName','bioSW250')



%% Start loading data for plots


clearvars
% When using msg server
%addpath 'Y:\Home\martinm\GAMS';

% load BenOpt sets
 load('Sets.mat')
 load('TechData.mat')


% Figure size
%figsize=[10 49 900 500];
figsize=[10 49 1901 1069];

% Font sizes [Title x-/y-Labels Legend Axes]
FT=[18 18 18 16]; % Paper
%FT=[20 20 20 18]; % Poster

load('SetList.mat');
% legends long English
legtech=SetList.textdata.SetList(2:tech+1,2);
legmodul=SetList.textdata.SetList(2:modul+1,6);
legtechtype=SetList.textdata.SetList(2:techtype+1,10);
legmarket=SetList.textdata.SetList(2:market+1,15);
legbiotype=SetList.textdata.SetList(2:biotype+1,19);
legbioprod=SetList.textdata.SetList(2:bioprod+1,23);
legfig1add={'Primary energy demand','Final energy demand','Power demand'};
legfig3add1='Max av. waste biomass';
legfig3add2='Max av. waste biomass for heat';
legfig3add3={'Total available area','Area available for heat','Area used for heat'};


% load colors
coltech=SetList.textdata.SetList(2:tech+1,3);
for i=1:tech
    coltech{i}=str2num(coltech{i})/255; %#ok<ST2NM>
end
colbiotype=SetList.textdata.SetList(2:biotype+1,20);
for bm=1:biotype
    colbiotype{bm}=str2num(colbiotype{bm})/255; %#ok<ST2NM>
end
colbioprod=SetList.textdata.SetList(2:bioprod+1,24);
for b=1:bioprod
    colbioprod{b}=str2num(colbioprod{b})/255; %#ok<ST2NM>
end
coltechtype=SetList.textdata.SetList(2:techtype+1,11);
for i=1:length(coltechtype)
    coltechtype{i}=str2num(coltechtype{i})/255; %#ok<ST2NM>
end

% Titles
titlefig1='Total heat generation over all markets';
title1fig3='Waste biomass potential';
title2fig3='Consumed waste biomass';
title3fig3='Cultivation area available and exploited';
title1fig31='Biomass distribution by markets';
title2fig31='Biomass distribution by products';
title1fig4='Total costs = investment + variable costs';
title2fig4='Variable costs';
title1fig9='Gas price';
title2fig9='Electricity price';
title3fig9='CO2-certificate price';
title4fig9='Yields';


% X-Labels
xlabtime='Time (a)';

% Y-Labels
ylabheat='Net energy generation (PJ)';
ylabbiomass='Biomass (PJ)';
ylabarea='Land area (Mio ha)';
ylabcost1='Costs (€/GJ)';
ylabcost2='Costs (€/t CO2)';
ylabcost3='Costs (Bil.€)';
ylabyield='Yield (GJ/ha)';


%% Scenario plots

% load actual data

load('Results\2021-04-12 15-56-27_CO2 100_power 32.mat','v','bc')
v1=v;
bc1=bc;
clear v bc;

load('Results\2021-04-12 16-02-12_CO2 100_power 215.mat','v')
v2=v;
clear v;

load('Results\2021-04-12 15-59-36_CO2 200_power 32.mat','v')
v3=v;
clear v;

load('Results\2021-04-12 16-06-05_CO2 200_power 215.mat','v')
v4=v;
clear v;



%% plot
figsize=[10 49 1800 1000]; % [left lower width height]
figure (1);
set(gcf,'position',figsize)

% select the sub-sector
%j=7;
j=16;
for k=1:4
    v=eval(['v' num2str(k)]);
    subplot(2,2,k);
    hold on
    
    h=area(v(:,MT{j},j)/1000000);
    for i=1:length(MT{j})
        h(i).FaceColor=coltech{MT{j}(i)};
    end
    hold on
    xlim([0 time+1])
    ylim([0 max(sum(v(:,MT{j},j)/1000000,2))+max(sum(v(:,MT{j},j)/1000000,2))/20])
    ax=gca;
    ax.XTick = [1 6:10:36];
    ax.XTickLabel= [2015 2020:10:2050];
    ax.FontSize=FT(4);

    ax=gca;
    %ax.YTick = [0:200:600];
    
    % x/y ticks, labels, legend
    if k==3 || k==4
        ax.XTick = [1 6:10:36];
        ax.XTickLabel= [2015 2020:10:2050];
        ax.FontSize=FT(4);
    else
        ax.XTickLabel={[]};
    end
    
    if k==1 || k==3
        ax.FontSize=FT(4);
    else
        ax.YTickLabel={[]};
    end

    if k==1
        ylabel('100 €/tCO_{2} eq.','FontSize',FT(2));
        title('32 €/MWh','FontSize',FT(2));
    end
    if k==2
        title('215 €/MWh','FontSize',FT(2))
    end
    if k==3
        ylabel('200 €/tCO_{2} eq.','FontSize',FT(2));
    end
    if k==4
        l=legend(h(end:-1:1),legtech{MT{j}(end:-1:1)},'Location','southwest');
        l.FontSize=FT(3);
    end
    hold off
    
end

%supAxes = [.08 .08 .84 .84];


%h2=suplabel('Power price','t');
h2=suplabel('Power price (stock market)','t');
set(h2,'FontSize',FT(2))

supAxes = [.11 .08 .84 .84];
%supAxes = [.13 .08 .84 .84];
%h1=suplabel('Gas price','y',supAxes);
h1=suplabel('CO_{2} emission allowance','y',supAxes);
set(h1,'FontSize',FT(2))



% Titel nicht "Fett"
set(findall(gcf, 'Type', 'Text'),'FontWeight', 'Normal')

axall = get(gcf,'children');
ind = find(isgraphics(axall,'Legend'));
set(gcf,'children',axall([ind:end,1:ind-1]))



% Save

% saveas(gcf,'SW_GM90.eps','epsc')
% saveas(gcf,'SW_Industry200 paper.emf')
% saveas(gcf,'SW_GM90.png')


% Biomass distribution over technologies
FT=[24 24 24 22]; % Paper
%FT=[28 28 28 26]; % Poster

bc1temp(:,1)=squeeze(sum(sum(sum(bc1(:,[2 11:26 28 29 33:35 39 44:48 50 51:56],:,[1:23 27 28]),2),3),4))/1000000;
bc1temp(:,2)=squeeze(sum(sum(sum(bc1(:,[49 51],:,[1:23 27 28]),2),3),4))/1000000;
bc1temp(:,3)=squeeze(sum(sum(sum(bc1(:,[1 3 4 5 27 30 31 36:38 40 43],:,[1:23 27 28]),2),3),4))/1000000;

figure (2);
hold on
figsize=[10 49 950 535];
set(gcf,'position',figsize)
h=area(bc1temp(:,:));
hold on
set(h(1),'FaceColor',coltech{22});
set(h(2),'FaceColor',coltech{49});
set(h(3),'FaceColor',coltech{38});

xlim([0 time+1])
ax=gca;
ax.XTick = [1 6:10:36];
ax.XTickLabel=[2015 2020:10:2050];
ax.FontSize=FT(4);
ylabel(ylabbiomass,'FontSize',FT(2));
legend(h(end:-1:1),{'Biogas','Fluidized-bed combustion','Solid biomass combustion (FB excl.)'},'Location','best','FontSize',FT(3));

% saveas(gcf,'SW_biomass paper.emf')

