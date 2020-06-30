%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     BENOPT-HEAT - Optimizing bioenergy use in the German heat sector 
%     Copyright (C) 2017 - 2020 Matthias Jordan
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%     contact: matthias.jordan@ufz.de
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[]=Plotting(FileName,PathName,fig1,fig2,fig3,fig4,fig5,fig6,fig7,fig8,fig9,fig10,fig11,fig12,fig13,fig14,fig15,figBeh,...
    CapTech,nMarket,nMarketOp,language)

%% load data and sets
tic
disp('Plotting started');

load([PathName FileName]);

load('SetList.mat');

%% Plots

% Figure size
figsize=[10 49 1901 900];

% Font sizes [Title x-/y-Labels Legend Axes] can be adjusted for all figures here
FT=[12 10 8 10];

% load legends
if strcmp(language,'German')==1
    % legends long German
    legtech=SetList.textdata.SetList(2:tech+1,1);
    legmodul=SetList.textdata.SetList(2:modul+1,5);
    legtechtype=SetList.textdata.SetList(2:techtype+1,9);
    legmarket=SetList.textdata.SetList(2:market+1,14);
    legbiotype=SetList.textdata.SetList(2:biotype+1,18);
    legbioprod=SetList.textdata.SetList(2:bioprod+1,22);   
    legfig1add={'Primärenergiebedarf','Endenergiebedarf','Strombedarf'};
    legfig3add1='Max verf. biomasse';
    legfig3add2='Max verf. biomasse für Wärme';
    legfig3add3={'Gesamte verfügbare Fläche','Verfügbare Fläche für Wärme ','Fläche genutzt für Wärme'};
elseif strcmp(language,'English')==1
% legends long English
    legtech=SetList.textdata.SetList(2:tech+1,2);
    legmodul=SetList.textdata.SetList(2:modul+1,6);
    legtechtype=SetList.textdata.SetList(2:techtype+1,10);
    legmarket=SetList.textdata.SetList(2:market+1,15);
    legbiotype=SetList.textdata.SetList(2:biotype+1,19);
    legbioprod=SetList.textdata.SetList(2:bioprod+1,23);
    legfig1add={'Primary energy demand','Final energy demand','Power demand'};
    legfig3add1='Max av. biomass residues';
    legfig3add2='Max av. biomass residues for heat';
    legfig3add3={'Total available area','Area available for heat','Area used for heat'};
end

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
if strcmp(language,'German')==1
    titlefig1='Wärmeproduktion über alle Sub-Sektoren';
    title1fig3='Verfügbare Biomasse aus Reststoffen';
    title2fig3='Genutzte Biomasse aus Reststoffen';
    title3fig3='Anbaufläche verfügbar und erschlossen';
    title1fig31='Biomasseverteilung über die Sub-Sektoren';
    title2fig31='Biomasseverteilung nach Produkten';
    title1fig4='Gesamtkosten = Investment + variable Kosten';
    title2fig4='Variable Kosten';
    title1fig9='Gaspreis';
    title2fig9='Strompreis';
    title3fig9='CO2-Zertifikatspreis';
    title4fig9='Erträge';
    
elseif strcmp(language,'English')==1
    titlefig1='Total heat generation over all markets';
    title1fig3='Biomass potential from residues';
    title2fig3='Consumed biomass from residues';
    title3fig3='Land for energy crops available and exploited';
    title1fig31='Biomass distribution by markets';
    title2fig31='Biomass distribution by products';
    title1fig4='Total costs = investment + variable costs';
    title2fig4='Variable costs';
    title1fig9='Gas price';
    title2fig9='Electricity price';
    title3fig9='CO2-certificate price';
    title4fig9='Yields';
end

% X-Labels
if strcmp(language,'German')==1
    xlabtime='Zeit (a)';
elseif strcmp(language,'English')==1
    xlabtime='Time (a)';
end

% Y-Labels
if strcmp(language,'German')==1
    ylabheat='Nutzwärmeerzeugung (PJ)';
    ylabbiomass='Biomasse (PJ)';
    ylabarea='Fläche (Mio ha)';
    ylabcost1='Kosten (€/GJ)';
    ylabcost2='Kosten (€/t CO2)';
    ylabcost3='Kosten (Mrd. €)';
    ylabyield='Ertrag (GJ/ha)';
elseif strcmp(language,'English')==1
    ylabheat='Net energy generation (PJ)';
    ylabbiomass='Biomass (PJ)';
    ylabarea='Land area (Mio ha)';
    ylabcost1='Costs (€/GJ)';
    ylabcost2='Costs (€/t CO2)';
    ylabcost3='Costs (Bil.€)';
    ylabyield='Yield (GJ/ha)';
end

%% plot heat consumption per technology type
if fig1==1
    % calculate market share of technology types (net energy consumption)
    vtype=zeros(time,10);
    for t=1:time
        for i=1:tech
            for j=1:market
                if i==24 || i==26 || i==41 || i==46
                    vtype(t,1)=vtype(t,1)+v(t,i,j)*TP(5,i,j); %Coal share
                else
                    for b=1:bioprod
                        if b==24 || b==26
                            vtype(t,2)=vtype(t,2)+vGas(t,i,j,b);%*TP(5,i,j); %Gas share
                        else
                            vtype(t,3)=vtype(t,3)+vGas(t,i,j,b);%*TP(5,i,j); %Biogas share
                        end
                    end
                end
                vtype(t,4)=vtype(t,4)+v(t,i,j)*TP(6,i,j); %ST share
                if (j==1 && i==6) || (j==18 && i==42)
                    vtype(t,6)=vtype(t,6)+v(t,i,j)*TP(7,i,j); %EDH share
                else
                    vtype(t,5)=vtype(t,5)+v(t,i,j)*TP(7,i,j); %WP share
                end
                if i==2 || i==11 || i==16 || i==17
                    vtype(t,7)=vtype(t,7)+v(t,i,j)*TP(8,i,j); %FireWood share
                elseif i==12 || i==13 || i==14 || i==15 || i==18 || i==19 || i==20 || i==21 || i==22
                    vtype(t,8)=vtype(t,8)+v(t,i,j)*TP(8,i,j); %Pellet share
                elseif i==23 || i==26 || i==28 || i==29 || i==33 || i==34 || i==35 || i==39 || i==44 || i==45 || i==48
                    vtype(t,9)=vtype(t,9)+v(t,i,j)*TP(8,i,j); %WoodChip share
                elseif i==47
                    vtype(t,10)=vtype(t,10)+v(t,i,j)*TP(8,i,j); %Biocoke
                end
            end
        end
    end
    
    % plot figure
    figure (1);
    set(gcf,'position',figsize)
    hold on
    h=area(vtype(:,:)/1000000);
    for i=1:10
            h(i).FaceColor=coltechtype{i};
    end
    xlim([0 time+1])
    ax=gca;
    ax.XTick = [1 5:10:36];
    ax.XTickLabel=[2015 2020:10:2050];
    ax.FontSize=FT(4);
    title(titlefig1,'FontSize',FT(1));
    ylabel(ylabheat,'FontSize',FT(2));
    legend([h(end:-1:1)],{legtechtype{end:-1:1}},'Location','southwest','FontSize',FT(3));
    hold off

end


%% plot market shares per technologies in the sub-sectors over time (in two plots)
if fig2==1
    
    % plot #1 (private households)
    figure (21);
    set(gcf,'position',figsize)
    k=1;
    for j=1:8
        subplot(3,3,k)
        k=k+1;
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
        title(legmarket{j},'FontSize',FT(1));
        l=legend(h(end:-1:1),legtech{MT{j}(end:-1:1)},'Location','southwest');
        l.FontSize=FT(3);
        hold off
    end

    h2=suplabel(ylabheat,'y');
    set(h2,'FontSize',FT(2)+1)

    % plot #2 (Trade/ commerce, district heating and industry)
    figure (22);
    set(gcf,'position',figsize)
    k=1;
    for j=9:19
        subplot(3,4,k)
        k=k+1;
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
        title(legmarket{j},'FontSize',FT(1));
        l=legend(h(end:-1:1),legtech{MT{j}(end:-1:1)},'Location','southwest');
        l.FontSize=FT(3);
        hold off
    end
    h2=suplabel(ylabheat,'y');
    set(h2,'FontSize',FT(2)+1)

end
 
%% Technology distribution in the clusters (sub-sub-sector)

if figBeh==1
    figure (16);
    set(gcf,'position',figsize)
    k=1;
    for j=1:5
        for c=1:4
            subplot(5,5,k)
            k=k+1;
            if c==4
                h=area(v(:,MT{j},j)/1000000);
            else
                h=area(vBeh(:,MT{j},j,c)/1000000);
            end
            for i=1:length(MT{j})
                h(i).FaceColor=coltech{MT{j}(i)};
            end
            hold on
            xlim([0 time+1])
            ax=gca;
            if j==5
                ax.XTick = [1 6:10:36];
                ax.XTickLabel= [2015 2020:10:2050];
                ax.FontSize=FT(4);
            else
                ax.XTickLabel={[]};
            end
            ax.FontSize=FT(4);
            if c==1
                if j==2
                    ylabel(legmarket{j}(1:4),'FontSize',FT(1));
                else  
                    ylabel(legmarket{j}(1:7),'FontSize',FT(1));
                end
            end
            if j==1
                if c==1
                    title('The convenience-oriented','FontSize',FT(1));
                elseif c==2
                    title('The consequences-aware','FontSize',FT(1));
                elseif c==3
                    title('The multilaterally-motivated','FontSize',FT(1));
                elseif c==4
                    title('Sum','FontSize',FT(1));
                end
            end
            if c==4
                l=legend(h(end:-1:1),legtech{MT{j}(end:-1:1)},'Location','southwest');
            end
            l.FontSize=FT(3);
            hold off
        end
        k=k+1;
    end
end


%% Gas/coal distribution per technology    
if fig3==1    
    figure (3);
    set(gcf,'position',figsize)
    k=1;
    for i=1:tech
        if sum(sum(sum(vGas(:,i,:,:),1),3),4)>0
            subplot(4,5,k)
            k=k+1;
            h=area(squeeze(sum(vGas(:,i,:,TB{i}),3)/1000000));
            for b=1:length(TB{i})
                h(b).FaceColor=colbioprod{TB{i}(b)};
            end
            hold on
            xlim([0 time+1])
            ax=gca;
            ax.XTick = [1 6:10:36];
            ax.XTickLabel=[2015 2020:10:2050];
            ax.FontSize=FT(4);
            title(legtech{i},'FontSize',FT(1));
            l=legend(h(end:-1:1),legbioprod{TB{i}(end:-1:1)},'Location','southwest');
            l.FontSize=FT(3);
            hold off
        end
    end
    h2=suplabel(ylabheat,'y');
    set(h2,'FontSize',FT(2)+1)       
end

%% Figure Biomass capacity and consumption
if fig4==1
 
    figure (4)
    set(gcf,'position',figsize)
        % Subplot biomass residues available
        subplot(3,2,[1 2]);
        hold on
        h=area(ba.val(:,1:11)/1000000);
        xlim([0 time+1])
        ylim([0 max(sum(ba.val(:,1:11)/1000000,2))+100])
        ax=gca;
        ax.XTick = 1:5:36;
        ax.XTickLabel=2015:5:2050;
        ax.FontSize=FT(4);
        title(title1fig3,'FontSize',FT(1));
        ylabel(ylabbiomass,'FontSize',FT(2));
        legend(h(end:-1:1),legbiotype(11:-1:1),'Location','bestoutside','FontSize',FT(3));
        hold off
    
        %Subplot biomass residues consumed
        subplot(3,2,[3 4]);
        hold on
        h=area(squeeze(sum(bu(:,:,1:11),2)/1000000));
        h2=plot(sum(ba.val(:,1:11),2)/1000000);
        h3=plot(sum(ba.val(:,1:11),2).*bamaxw.val(:)/1000000);
        xlim([0 time+1])
        ylim([0 max(sum(ba.val(:,1:11)/1000000,2))+100])
        ax=gca;
        ax.XTick = [1 6:10:36];
        ax.XTickLabel=[2015 2020:10:2050];
        ax.FontSize=FT(4);
        title(title2fig3,'FontSize',FT(1));
        ylabel(ylabbiomass,'FontSize',FT(2));
        legend([h2 h3 h(end:-1:1)],{legfig3add1,legfig3add2,legbiotype{11:-1:1}},'Location','bestoutside','FontSize',FT(3));
        hold off

        % Subplot cultivation
        subplot(3,2,[5 6])
        hold on
        plot(ba.val(:,12)/1000000)
        plot(ba.val(:,12).*bamaxc.val(:)/1000000)
        plot(squeeze(sum(squeeze(bu(:,:,12))./yield.val(:,:),2,'omitnan')/(1000000)),'--','color','black')
        xlim([0 time+1])
        ax=gca;
        ax.XTick = [1 6:10:36];
        ax.XTickLabel=[2015 2020:10:2050];
        ax.FontSize=FT(4);
        title(title3fig3,'FontSize',FT(1));
        ylabel(ylabarea,'FontSize',FT(2));
        legend(legfig3add3,'Location','bestoutside','FontSize',FT(3));
        hold off
    end

%% Biomass in markets and products
if fig5==1

    % Biomass distribution over markets
    figure (5);
    set(gcf,'position',figsize)
    subplot(3,1,1)
    h=area(squeeze(sum(sum(bc(:,:,:,1:23),2),4))/1000000);
    xlim([0 time+1])
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title(title1fig31,'FontSize',FT(1));
    ylabel(ylabbiomass,'FontSize',FT(2));
    legend(h(end:-1:1),legmarket(end:-1:1),'Location','bestoutside','FontSize',FT(3));

    % Biomass distribution over biomass products
    subplot(2,1,2)
    h=area(squeeze(sum(sum(bc(:,:,:,1:23),2),3))/1000000);
    for b=1:20
            h(b).FaceColor=colbioprod{b};
    end
    xlim([0 time+1])
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title(title2fig31,'FontSize',FT(1));
    ylabel(ylabbiomass,'FontSize',FT(2));
    legend(h(end:-1:1),legbioprod(23:-1:1),'Location','bestoutside','FontSize',FT(3)); 
end

%% Biomass use in technologies
if fig6==1
    % Biomass distribution over technologies
    figure (6);
    set(gcf,'position',figsize)
    h=area(squeeze(sum(sum(bc(:,:,:,1:23),3),4))/1000000);
    for i=1:tech
            h(i).FaceColor=coltech{i};
    end
    xlim([0 time+1])
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title('Biomasseverteilung nach Technologien','FontSize',FT(1));
    ylabel(ylabbiomass,'FontSize',FT(2));
    legend(h(end:-1:1),legtech(end:-1:1),'Location','bestoutside','FontSize',FT(3));
end

%% Total system costs
if fig7==1
    
    % Calculate investment costs & variable costs
    investcost = zeros(time,tech); % Total Investment costs
    for t = 1:time
        for j = 1:market
            for i = 1:tech
                for m = 1:modul
                    investcost(t,i) = investcost(t,i) + inv.val(t,i,m,j)*ncap(t,i,m,j);
                end
            end
        end
    end
    % Total Production costs
    prodcostall(:,:,:) = sum(vc.val(:,:,:,:).*vBio(:,:,:,:)+vc.val(:,:,:,:).*vGas(:,:,:,:),4)+vc.val(:,:,:,1).*v3(:,:,:);
    prodcost(:,:) = sum(prodcostall(:,:,:),3);
    % Total costs
    costs = investcost + prodcost;
    costyearly=sum(costs,2);
    
    figure (7);
    set(gcf,'position',figsize)
    % Total costs
    subplot(2,1,1)
    Yneg = prodcost;
    Yneg(Yneg>0) = 0;
    Ypos = prodcost;
    Ypos(Ypos<0) = 0;
    Ypos = Ypos+investcost;
    h=bar(Yneg/1000000000,'stack');
    for i=1:tech
            h(i).FaceColor=coltech{i};
    end
    xlim([0 time+1])
    hold on
    h=bar(Ypos/1000000000,'stack');
    for i=1:tech
            h(i).FaceColor=coltech{i};
    end
    plot(costyearly/1000000000,'color','k','LineWidth',2)
    xlim([0 time+1])
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title(title1fig4,'FontSize',FT(1));
    xlabel(xlabtime,'FontSize',FT(2));
    ylabel(ylabcost3,'FontSize',FT(2));
    legend(legtech,'Location','eastoutside','FontSize',FT(3));
    hold off


    % Variable costs
    subplot(2,1,2)
    Yneg = prodcost;
    Yneg(Yneg>0) = 0;
    Ypos = prodcost;
    Ypos(Ypos<0) = 0;
    h=bar(Yneg/1000000000,'stack');
    for i=1:tech
            h(i).FaceColor=coltech{i};
    end
    xlim([0 time+1])
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    hold on
    h=bar(Ypos/1000000000,'stack');
    for i=1:tech
            h(i).FaceColor=coltech{i};
    end
    xlim([0 time+1])
    title(title2fig4,'FontSize',FT(1));
    xlabel(xlabtime,'FontSize',FT(2));
    ylabel(ylabcost3,'FontSize',FT(2));
    hold off
end

%% Total system GHG emission
if fig8==1
    figure (8)
    set(gcf,'position',figsize)
    h=area(sum(ghgt(:,:,:),3)/1000000+sum(sum(ghgf(:,:,:,:),3),4)/1000000,'DisplayName','ghg');
    for i=1:tech
            h(i).FaceColor=coltech{i};
    end
    xlim([0 time+1])
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    hold on;
    line(1:time,ghgmax.val(:)/1000000,'color','black');
    xlim([0 time+1])
    hold off;
    title('GHG emission per technology concept','FontSize',FT(1));
    ylabel('GHG emission in Mio t','FontSize',FT(2));
    legend(h(end:-1:1),legtech(end:-1:1),'Location','eastoutside','FontSize',FT(3));
end



%% Capacity and production
if fig9==1   
    figure (9)
    set(gcf,'position',figsize)
    % Overcapacity
    subplot(2,1,1)
    plot(100*sum(sum(ncap2(:,:,1,:),2),4)./sum(sum(nprod(:,:,:),2),3))
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title('Overcapacity in %/a','FontSize',FT(1));
    ylabel('%','FontSize',FT(2));

    % Number of heating systems in the model
    subplot(2,1,2)
    h=area(sum(ncap(:,:,1,:),4)/1000000);
    for i=1:tech
            h(i).FaceColor=coltech{i};
    end
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title('Number of heating systems','FontSize',FT(1));
    ylabel('Number of model heating systems in Mio','FontSize',FT(2));
    legend(h(end:-1:1),legtech(end:-1:1),'Location','bestoutside','FontSize',FT(3));
end

%% ncap2 (Overcapacity in the model. Restricted to fossil technologies and 1%/a)
if fig10==1
    figure (10);
    set(gcf,'position',figsize)
    for j=1:market
        subplot(4,5,j)
        h=bar(ncap2(:,MT{j},1,j),'stacked');
        for i=1:length(MT{j})
            h(i).FaceColor=coltech{MT{j}(i)};
        end
        hold on
        xlim([0 time+1])
        ax=gca;
        ax.XTick = [1 6:10:36];
        ax.XTickLabel=[2015 2020:10:2050];
        ax.FontSize=FT(4);
        title(legmarket{j},'FontSize',8);
        ylabel('ncap2','FontSize',FT(2));
        l=legend(legtech{MT{j}},'Location','southwest');
        l.FontSize=5;
        hold off
    end
end


%% all n's (plots related to the number of heating systems installed, newly invested in, decomissioned, etc.)
if fig11==1
    figure (11);
    set(gcf,'position',figsize)
    j=nMarket;
    
    % Subplot Overcapacity
    subplot(3,2,1)
    h=bar(ncap2(:,MT{j},1,j),'stacked');
    for i=1:length(MT{j})
        h(i).FaceColor=coltech{MT{j}(i)};
    end
    hold on
    xlim([0 time+1])
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title(['Overcapacity (ncap2) - ' legmarket{j}],'FontSize',FT(1));
    ylabel('Number heating systems','FontSize',FT(2));
    l=legend(legtech{MT{j}},'Location','best');
    l.FontSize=FT(3);
    hold off
  
    % Subplot used capacity
    subplot(3,2,2)
    h=bar(ncap1(:,MT{j},1,j),'stacked');
    for i=1:length(MT{j})
        h(i).FaceColor=coltech{MT{j}(i)};
    end
    hold on
    xlim([0 time+1])
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title(['Used capacity (ncap1) - ' legmarket{j}],'FontSize',FT(1));
    ylabel('Number heating systems','FontSize',FT(2));
    l=legend(legtech{MT{j}},'Location','best');
    l.FontSize=FT(3);
    hold off
    
    % Subplot decommissioned heating systems
    subplot(3,2,5)
    h=bar(nxdec(:,MT{j},1,j),'stacked');
    for i=1:length(MT{j})
        h(i).FaceColor=coltech{MT{j}(i)};
    end
    hold on
    xlim([0 time+1])
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title(['Decommisioned from the newly invested (nxdec) - ' legmarket{j}],'FontSize',FT(1));
    ylabel('Number heating systems','FontSize',FT(2));
    l=legend(legtech{MT{j}},'Location','best');
    l.FontSize=FT(3);
    hold off
    
    % Subplot newly invested in
    subplot(3,2,3)
    h=bar(next(:,MT{j},1,j),'stacked');
    for i=1:length(MT{j})
        h(i).FaceColor=coltech{MT{j}(i)};
    end
    hold on  
    xlim([0 time+1])
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title(['Newly invested in (next) - ' legmarket{j}],'FontSize',FT(1));
    ylabel('Number heating systems','FontSize',FT(2));
    legend(legtech{MT{j}},'Location','best');
    hold off
    
    % Subplot all n's
    m=1;
    subplot(3,2,[4 6])
    plot(sum(ncap(:,:,m,j),2))
    hold on
    plot(sum(ncap1(:,:,m,j),2))
    plot(sum(ncap2(:,:,m,j),2))
    plot(sum(nprod(:,:,j),2),'--')
    plot(sum(nsdec.val(:,:,m,j),2))
    plot(sum(next(:,:,1,j),2))
    plot(sum(nxdec(:,:,1,j),2))
    plot(1,sum(nstart.val(:,j)),'*')
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title(['All n`s - ' legmarket{j}],'FontSize',FT(1));
    ylabel('Number heating systems','FontSize',FT(2));
    legend({'ncap' 'ncap1' 'ncap2' 'nprod' 'nsdec' 'next' 'nxdec' 'nstart'},'Location','best');
    hold off
    
end

%% Capacity and investments in modules
if fig12==1
    figure (12)
    set(gcf,'position',figsize)
    
    % Capacity of modules
    subplot(2,1,1)
    bar(squeeze(sum(ncap(:,CapTech,TM{CapTech},:),4)),'DisplayName','ncap')
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title(['Capacity of plant modules in ' legtech{CapTech}],'FontSize',FT(1));
    ylabel('Number of plants','FontSize',FT(2));
    l=legend(legmodul{TM{CapTech}},'Location','northeast');
    l.FontSize=FT(3);

    % Investments in modules
    subplot(2,1,2);
    bar(squeeze(sum(next(:,CapTech,TM{CapTech},:),4)),'DisplayName','next')
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title(['Investments in ' legtech{CapTech}],'FontSize',FT(1));
    ylabel('Number of plants','FontSize',FT(2));
    l=legend(legmodul{TM{CapTech}},'Location','northeast');
    l.FontSize=FT(3);
end


%% Gas price, electricity price, CO2 price, yields
if fig13==1
    figure (13)
    set(gcf,'position',figsize)
    
    % Gasprice
    subplot(2,2,1);
    plot(GasPrice*0.36)
    xlim([0 time+1])
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title(title1fig9,'FontSize',FT(1));
    ylabel('Cent/kWh','FontSize',FT(2));
    l=legend('20 GJ (Household)','20-200 GJ (Household)','>200 GJ (Household)','400GJ (Trade)','400GJ (Industry)','Location','northwest');
    l.FontSize=FT(3);
    
    % Power price
    subplot(2,2,2);
    plot(PowerPrice(:,[1 9 15])*0.36)
    xlim([0 time+1])
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title(title2fig9,'FontSize',FT(1));
    ylabel('Cent/kWh','FontSize',FT(2));
    l=legend('Household','Trade','Industry','Location','northwest');
    l.FontSize=FT(3);
    
    % Co2 certificate price
    subplot(2,2,3);
    h1=plot(COCert);
    xlim([0 time+1])
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title(title3fig9,'FontSize',FT(1));
    ylabel(ylabcost2,'FontSize',FT(2));
    hold off
    
    % Yields of energy crops
    subplot(2,2,4);
    plot(yield.val(:,[10 11 12 15 18:23]))
    xlim([0 time+1])
    ax=gca;
    ax.XTick = 1:5:36;
    ax.XTickLabel=2015:5:2050;
    ax.FontSize=FT(4);
    title(title4fig9,'FontSize',FT(1));
    ylabel(ylabyield,'FontSize',FT(2));
    l=legend(legbioprod([10 11 12 15 18:23]),'Location','northwest');
    l.FontSize=FT(3);
end



%% Plot for investment and variable costs over time / markets/ technologies / biomassproducts
if fig14==1
    for j=nMarketOp
        figure (14)
        set(gcf,'position',figsize)
        k=1;
        for i=[MT{j} 1000]
            if length(MT{j})+1<=4
                subplot(2,2,k);
            elseif length(MT{j})+1>4 && length(MT{j})+1<=6
                subplot(2,3,k);
            elseif length(MT{j})+1>6 && length(MT{j})+1<=9
                subplot(3,3,k);
            elseif length(MT{j})+1>9 && length(MT{j})+1<=12
                subplot(3,4,k);
            end
            k=k+1;

            % Investment costs
            if i==1000
                plot(sum(inv.val(:,MT{j},:,j),3)/1000)
                xlim([0 time+1])
                ax=gca;
                ax.XTick = 1:5:36;
                ax.XTickLabel=2015:5:2050;
                ax.FontSize=FT(4);
                title('Investment costs including subsidies (if selected)','FontSize',FT(1));
                ylabel('Costs [t€]','FontSize',FT(2));
                l=legend(legtech{MT{j}},'Location','northeast');
                l.FontSize=FT(3);
            else % variable costs
                if isempty(TB{i})==1
                    plot(squeeze(vc.val(:,i,j,1)))
                else
                    plot(squeeze(vc.val(:,i,j,TB{i})))
                end
                xlim([0 time+1])
                ax=gca;
                ax.XTick = 1:5:36;
                ax.XTickLabel=2015:5:2050;
                ax.FontSize=FT(4);
                title([legtech{i}],'FontSize',FT(1));
                ylabel('Costs [€/GJ]','FontSize',FT(2));
                if length(TB{i})>1
                    l=legend(legbioprod{TB{i}},'Location','northwest');
                    l.FontSize=FT(3);
                end
            end
        end
    end
end

%% Biomass prices
if fig15==1
    figure (15)
        bioprodfig=1:23;
        set(gcf,'position',figsize)
        h1=plot(BP(:,bioprodfig),'linewidth',1);
        for b=1:length(bioprodfig)
                h1(b).Color=colbioprod{bioprodfig(b)};
        end
        hold on
        xlim([0 time+1])
        ax=gca;
        ax.XTick = [1 6:10:36];
        ax.XTickLabel=[2015 2020:10:2050];
        ax.YTick = [5 10:10:100];
        ax.FontSize=FT(4);
        ylabel('Costs (€/GJ)','FontSize',FT(2));
        l=legend({legbioprod{1:23}},'Location','northwest');
        l.FontSize=FT(3);
end

toc
end

