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

function[]=xlsx2mat()

% This function can be executed from the user interface or standalone

disp('Data update started');

tic

%Set List
SetList=importdata('SetList.xlsx');
save('SetList.mat','SetList');

%% Technology data
market = find(cellfun(@isempty,SetList.textdata.SetList(:,13))==1,1)-2; % j
[~,sheets] = xlsfinfo('TechData_FinalData.xlsx');
for j=1:market
    TP(:,:,j) = xlsread('TechData_FinalData.xlsx',sheets{j},'C3:BH38');
end

%GHG data
[~,~,THGRAW]=xlsread('TechData_GHGRAW.xlsx','HaushalteIndustrie','A7:Q57');
THGFeed=xlsread('TechData_GHGRAW.xlsx','Brennstoff','H9:H36');
save('TechData.mat','TP','THGRAW','THGFeed','-append');

%% Biomass data
% Biomass potentials
BAdata=xlsread('Biomass_Data','Potentials');
save('BiomassData.mat','BAdata','-append');

% Biomass potentialsMinMax
BAMinMaxData=xlsread('Biomass_Data','PotentialMinMax','C2:F34');
save('BiomassData.mat','BAMinMaxData','-append');

% CostsBioProductsResidues [€/GJ]
BioResiduesCosts=xlsread('Biomass_Data','CostsBioProductsResidues','D2:F12');
save('BiomassData.mat','BioResiduesCosts','-append');

% Portfolio of cultivation in 2019
CULSTART=xlsread('Biomass_Data','CulStart','B8:AC8');
save('BiomassData.mat','CULSTART','-append');

% Yield energy crops
YD=xlsread('Biomass_Data','feedStockInputdata','C11:O12');
save('BiomassData.mat','YD','-append');

% FeedStock Input Data (for the enegy price calculations)
feedstockInputData=xlsread('Biomass_Data','feedStockInputdata');
save('BiomassData.mat','feedstockInputData','-append');


%% Scenario data

% import scenario data
dataKSS = xlsread('ScenarioData_PriceDevelopmentPowerFossilCO2.xlsx','KSS');
dataBMWi = xlsread('ScenarioData_PriceDevelopmentPowerFossilCO2.xlsx','BMWi');
dataBSW = xlsread('ScenarioData_PriceDevelopmentPowerFossilCO2.xlsx','BioStromWärme');
dataConst = xlsread('ScenarioData_PriceDevelopmentPowerFossilCO2.xlsx','ConstantPrices');
dataCO2 = xlsread('ScenarioData_PriceDevelopmentPowerFossilCO2.xlsx','CO2');
dataPowerPriceStock = xlsread('ScenarioData_PriceDevelopmentPowerFossilCO2.xlsx','PowerPriceStock');
dataPowerPriceSupp = xlsread('ScenarioData_PriceDevelopmentPowerFossilCO2.xlsx','PowerPriceSupp');
GasFactor = xlsread('ScenarioData_PriceDevelopmentPowerFossilCO2.xlsx','Gas','N9:N27');
BiogasFactor = xlsread('ScenarioData_PriceDevelopmentPowerFossilCO2.xlsx','Gas','O9:O27');


%% Power prices Stock for various scenarios [€/GJ]
for s=1:6
    PowerPricesStock(:,s) = interp1(dataPowerPriceStock(1,1:end),dataPowerPriceStock(s+1,1:end),2015:1:2050,'linear')/3.6;
end

%% Power price components (taxes and levies) [Cent/kWh]
%private households
for j=1:8
    PowerPriceSupp(:,:,j)=dataPowerPriceSupp(2:13,:)'/0.36;
end
%trade & commerce
for j=9:14
    PowerPriceSupp(:,:,j)=dataPowerPriceSupp(19:30,:)'/0.36;
end
%industry
for j=15:19
    PowerPriceSupp(:,:,j)=dataPowerPriceSupp(36:47,:)'/0.36;
end

% Power price components (taxes and levies) for priviliged power prices in the industry
%private households
for j=1:8
    PowerPriceSuppRed(:,:,j)=dataPowerPriceSupp(2:13,:)'/0.36;
end
%trade & commerce
for j=9:14
    PowerPriceSuppRed(:,:,j)=dataPowerPriceSupp(19:30,:)'/0.36;
end
%industry
for j=15:19
    PowerPriceSuppRed(:,:,j)=dataPowerPriceSupp(53:64,:)'/0.36;
end

save('ScenarioData.mat','PowerPricesStock','PowerPriceSupp','PowerPriceSuppRed','-append');


%% Gas prices

% Gas Price Stock Market [€/GJ]
GasPriceStockKSS = interp1(dataKSS(5,1:end),dataKSS(7,1:end),2015:1:2050,'pchip');
GasPriceStockBMWi = interp1(dataBMWi(5,1:end),dataBMWi(7,1:end),2015:1:2050,'pchip');
GasPriceStockBSW = interp1(dataBSW(5,[1 5]),dataBSW(7,[1 5]),2015:1:2050,'linear');
GasPriceStockConst = interp1(dataConst(5,1:end),dataConst(7,1:end),2015:1:2050,'pchip');

% GasPrice for all markets
for j=1:19
    GasPriceKSS(:,j) = GasPriceStockKSS(1,:)/GasFactor(j,1);
    GasPriceBMWi(:,j) = GasPriceStockBMWi(1,:)/GasFactor(j,1);
    GasPriceBSW(:,j) = GasPriceStockBSW(1,:)/GasFactor(j,1);
    GasPriceConst(:,j) = GasPriceStockConst(1,:)/GasFactor(j,1);
end
save('ScenarioData.mat','GasPriceKSS','GasPriceBMWi','GasPriceBSW','GasPriceConst','GasFactor','BiogasFactor','-append');

%% Coal price
% Coal Price all scenarios [€/GJ]
CoalPriceKSS = interp1(dataKSS(5,1:end),dataKSS(8,1:end),2015:1:2050,'pchip');
CoalPriceBMWi = interp1(dataBMWi(5,1:end),dataBMWi(8,1:end),2015:1:2050,'pchip');
CoalPriceBSW = interp1(dataBSW(5,[1 5]),dataBSW(8,[1 5]),2015:1:2050,'linear');
CoalPriceConst = interp1(dataConst(5,1:end),dataConst(8,1:end),2015:1:2050,'pchip');
save('ScenarioData.mat','CoalPriceKSS','CoalPriceBMWi','CoalPriceBSW','CoalPriceConst','-append');

%% CO2 price
% CO2 price [€/t CO2]
COCertKSS80 = interp1(dataKSS(11,1:end),dataKSS(12,1:end),2015:1:2050,'pchip');
COCertKSS95 = interp1(dataKSS(11,1:end),dataKSS(13,1:end),2015:1:2050,'pchip');
COCertBMWi80 = interp1(dataBMWi(11,1:end),dataBMWi(12,1:end),2015:1:2050,'pchip');
COCertBSW80 = interp1(dataBSW(11,1:end),dataBSW(12,1:end),2015:1:2050,'pchip');
COCertBSW95 = interp1(dataBSW(11,1:end),dataBSW(13,1:end),2015:1:2050,'pchip');
COCertConst = interp1(dataConst(11,1:end),dataConst(12,1:end),2015:1:2050,'pchip');

% CO2 prices for various scenarios
for s=1:5
    COCertAll(s,:) = interp1(dataCO2(1,1:end),dataCO2(s+1,1:end),2015:1:2050,'linear');
end

save('ScenarioData.mat','COCertKSS80','COCertKSS95','COCertBMWi80','COCertBSW80','COCertBSW95','COCertConst','COCertAll','-append');


%% German power mix specific ghg emission factor [g/kWh]
ghgPowerMixKSS80 = interp1(dataKSS(15,1:end),dataKSS(16,1:end),2015:1:2050,'pchip');
ghgPowerMixKSS95 = interp1(dataKSS(15,1:end),dataKSS(17,1:end),2015:1:2050,'pchip');
ghgPowerMixBMWi80 = interp1(dataBMWi(15,1:end),dataBMWi(16,1:end),2015:1:2050,'pchip');
ghgPowerMixBSW80 = interp1(dataBSW(15,1:end),dataBSW(16,1:end),2015:1:2050,'pchip');
ghgPowerMixBSW95 = interp1(dataBSW(15,1:end),dataBSW(17,1:end),2015:1:2050,'pchip');
ghgPowerMixConst = interp1(dataConst(15,1:end),dataConst(16,1:end),2015:1:2050,'pchip');
save('ScenarioData.mat','ghgPowerMixKSS80','ghgPowerMixKSS95','ghgPowerMixBMWi80','ghgPowerMixBSW80','ghgPowerMixBSW95','ghgPowerMixConst','-append');

%% Behavior data
MarginalEffect=xlsread('Behavior','MarginalEffect','C2:E49');
save('ScenarioData.mat','MarginalEffect','-append');

toc



