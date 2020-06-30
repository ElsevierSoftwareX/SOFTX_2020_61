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

%This script imports the required parameter ranges for the Sobol analysis based on literature studies

clear all

% load model sets
load('Sets.mat')

% load prices & legend
EnergyPrices=xlsread('Sobol_ParameterRange.xlsx','EnergyPrices','B1:F92');
[~,LEG,~]=xlsread('Sobol_ParameterRange.xlsx','EnergyPrices','A1:A92');

% Power prices
for k=1:13
    PowerPrices(k,:) = interp1(EnergyPrices(1,:),EnergyPrices(k+2,:),2015:1:2050,'pchip')/3.6;
end
MeanPower = mean(PowerPrices,1);
STDPower = std(PowerPrices,1);
MaxPower = max(PowerPrices,[],1);
MinPower = min(PowerPrices,[],1);
UpperPower = MeanPower+STDPower;
LowerPower = MeanPower-STDPower;

% Gas prices
for k=1:14
    GasPrices(k,:) = interp1(EnergyPrices(1,:),EnergyPrices(k+21,:),2015:1:2050,'pchip');
end
MeanGas = mean(GasPrices,1);
STDGas = std(GasPrices,1);
MaxGas = max(GasPrices,[],1);
MinGas = min(GasPrices,[],1);
UpperGas = MeanGas+STDGas;
LowerGas = MeanGas-STDGas;

% Coal prices
for k=1:12
    CoalPrices(k,:) = interp1(EnergyPrices(1,:),EnergyPrices(k+39,:),2015:1:2050,'pchip');
end
MeanCoal = mean(CoalPrices,1);
STDCoal = std(CoalPrices,1);
MaxCoal = max(CoalPrices,[],1);
MinCoal = min(CoalPrices,[],1);
UpperCoal = MeanCoal+STDCoal;
LowerCoal = MeanCoal-STDCoal;

% CO2 prices
for k=1:24
    CO2Prices(k,:) = interp1(EnergyPrices(1,:),EnergyPrices(k+56,:),2015:1:2050,'pchip');
end
MeanCO2 = mean(CO2Prices,1);
STDCO2 = std(CO2Prices,1);
MaxCO2 = max(CO2Prices,[],1);
MinCO2 = min(CO2Prices,[],1);
UpperCO2 = MeanCO2+STDCO2;
LowerCO2 = MeanCO2-STDCO2;

% Power mix emission factor
for k=1:9
    PMEF(k,:) = interp1(EnergyPrices(1,:),EnergyPrices(k+83,:),2015:1:2050,'pchip');
end
MeanPMEF = mean(PMEF,1);
STDPMEF = std(PMEF,1);
MaxPMEF = max(PMEF,[],1);
MinPMEF = min(PMEF,[],1);
UpperPMEF = MeanPMEF+STDPMEF;
LowerPMEF = MeanPMEF-STDPMEF;


% Save upper and lower limit of energy prices and PMEF
save('EnergyPriceLimits.mat','UpperPower','LowerPower','UpperGas','LowerGas','UpperCoal','LowerCoal','UpperCO2','LowerCO2','UpperPMEF','LowerPMEF')

%% plot
% Font sizes [Title x-/y-Labels Legend Axes]
FT=[12 12 8 12];

figure (1);
   subplot(2,3,1)
        
        hold on
        x = 1 : 36;
        x2 = [x, fliplr(x)];
        inBetween = [(MeanPower-STDPower)*3.6, fliplr((MeanPower+STDPower)*3.6)];
        fill(x2, inBetween, [160/256,160/256,160/256]);
        
        inBetween2 = [(0.4*(UpperPower-LowerPower)+LowerPower)*3.6, fliplr((MeanPower+STDPower)*3.6)];
        %fill(x2, inBetween2, [0/256,153/256,0/256]);
        fill(x2, inBetween2, [160/256,160/256,160/256]);
        
        inBetween = [(MeanPower-STDPower)*3.6, fliplr((MeanPower+STDPower)*3.6)];
        fill(x2, inBetween, [160/256,160/256,160/256]);
        
        
        h=plot(3.6*PowerPrices');
        
        xlim([0 time+1])
        ax=gca;
        ax.XTick = [1 6:10:36];
        ax.XTickLabel=[2015 2020:10:2050];
        ax.FontSize=FT(4);
        title('Electricity energy only market price','FontSize',FT(1))
        ylabel('€/MWh','FontSize',FT(2));
        legend(h,LEG(3:15),'Location','NorthWest','FontSize',FT(3))
        
    subplot(2,3,2)
        
        hold on
        x = 1 : 36;
        x2 = [x, fliplr(x)];
        inBetween = [(MeanGas-STDGas)*3.6, fliplr((MeanGas+STDGas)*3.6)];
        fill(x2, inBetween, [160/256,160/256,160/256]);
        
        h=plot(3.6*GasPrices');
        
        xlim([0 time+1])
        ax=gca;
        ax.XTick = 1:5:36;
        ax.XTickLabel=2015:5:2050;
        ax.FontSize=FT(4);
        title('Gas price','FontSize',FT(1))
        ylabel('€/MWh','FontSize',FT(2));
        legend(h,LEG(22:35),'Location','NorthWest','FontSize',FT(3))


    subplot(2,3,3)
        
        hold on
        x = 1 : 36;
        x2 = [x, fliplr(x)];
        inBetween = [(MeanCoal-STDCoal), fliplr((MeanCoal+STDCoal))];
        fill(x2, inBetween, [160/256,160/256,160/256]);
        
        h=plot(CoalPrices');
        
        xlim([0 time+1])
        ax=gca;
        ax.XTick = 1:5:36;
        ax.XTickLabel=2015:5:2050;
        ax.FontSize=FT(4);
        title('Coal price','FontSize',FT(1))
        ylabel('€/GJ','FontSize',FT(2));
        legend(h,LEG(40:51),'Location','NorthWest','FontSize',FT(3))

        
        
    subplot(2,3,4)

        hold on
        x = 1 : 36;
        x2 = [x, fliplr(x)];
        inBetween = [(MeanCO2-STDCO2), fliplr((MeanCO2+STDCO2))];
        fill(x2, inBetween, [160/256,160/256,160/256]);
        
        h=plot(CO2Prices');
        
        xlim([0 time+1])
        ax=gca;
        ax.XTick = 1:5:36;
        ax.XTickLabel=2015:5:2050;
        ax.FontSize=FT(4);
        title('CO_2 price','FontSize',FT(1))
        ylabel('€/t CO_2 eqiv.','FontSize',FT(2));
        legend(h,LEG(57:80),'Location','NorthWest','FontSize',FT(3))


        
    subplot(2,3,5)

        hold on
        x = 1 : 36;
        x2 = [x, fliplr(x)];
        inBetween = [(MeanPMEF-STDPMEF), fliplr((MeanPMEF+STDPMEF))];
        fill(x2, inBetween, [160/256,160/256,160/256]);
        
        h=plot(PMEF');
        
        xlim([0 time+1])
        ax=gca;
        ax.XTick = 1:5:36;
        ax.XTickLabel=2015:5:2050;
        ax.FontSize=FT(4);
        title('Power mix emission factor','FontSize',FT(1))
        ylabel('g CO_2 eqiv./kWh','FontSize',FT(2));
        legend(h,LEG(84:92),'Location','NorthEast','FontSize',FT(3))



