%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     BENOPT-HEAT - Optimizing bioenergy use in the German heat sector 
%     Copyright (C) 2015 - 2020 Markus Millinger, Matthias Jordan
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

function[BP]=BioFeedCost(time,bioprod,priceDevFactor,feedstockInputData,BioResiduesCosts,Sen)

    % %%%-------------DATA INPUT for energy crops

    dieselCostStart           =   0.9; %/l
    labourCostStart           =   15; %/h
    wheatPriceStart           =   189;%(202 not inflation adjusted); %/tFM - 5 year average between 14.04.2011-13.04.2016 - finanzen.net - daily values inflation adjusted with annual HICP data from Eurostat
    
    % Load data from FeedstockInputData
    numFeed                   =   size(feedstockInputData(1,:),2); % number of energy crops

    feedDMcontent             =   feedstockInputData(1,1:numFeed); % Verhltnis Trockenmasse zu Frischmasse
    feedDMenergyContent       =   feedstockInputData(2,1:numFeed); %GJ/tDM

    feedYieldFMstartMedium    =   feedstockInputData(4,1:numFeed); % Yield
    feedYieldFMendMedium      =   feedstockInputData(5,1:numFeed);

    feedLabourHaStart         =   feedstockInputData(17,1:numFeed); %Arbeitskraftstunden/ha
    feedServiceStart          =   feedstockInputData(18,1:numFeed); %Dienstleistung
    feedDieselHaStart         =   feedstockInputData(20,1:numFeed); %Dieselbedarf/ha
    feedMachineFixHaStart     =   feedstockInputData(22,1:numFeed);
    feedMachineVarHaStart     =   feedstockInputData(23,1:numFeed);
    feedDirectCostsHaStart    =   feedstockInputData(24,1:numFeed);

    feedLabourHaEnd           =   feedstockInputData(26,1:numFeed); %Arbeitskraftstunden/ha
    feedServiceEnd            =   feedstockInputData(27,1:numFeed); % Dienstleistung
    feedDieselHaEnd           =   feedstockInputData(29,1:numFeed); %Dieselbedarf l/ha
    feedMachineFixHaEnd       =   feedstockInputData(31,1:numFeed);
    feedMachineVarHaEnd       =   feedstockInputData(32,1:numFeed);

    feedYieldFMstart              =   feedYieldFMstartMedium;
    feedYieldFMend                =   feedYieldFMendMedium;

    % Method for calculating future energy crop prices based on DOI: 10.1016/j.jclepro.2016.11.175
    for t=1:time
        
        priceDev(t)=(1+priceDevFactor)^(t-1);  %#ok<*AGROW>
        
        % Calculation of Yield development
        feedYieldFM(t,:)=feedYieldFMstart+(t-1)*(feedYieldFMend-feedYieldFMstart)/(time-1);
        feedYieldDM(t,:)=feedYieldFM(t,:).*feedDMcontent;
        
        % Calculation of labour and diesel cost for the complete timespan []
        labourCost(t)=labourCostStart*priceDev(t);
        dieselCost(t)=dieselCostStart*priceDev(t);
 
        % Calculation of Labour, Diesel, Machine Fix, Machine var, Direct costs [/ha]
        feedLabourCostHa(t,:)=(feedLabourHaStart+(t-1)*(feedLabourHaEnd-feedLabourHaStart)/(time-1)).*labourCost(t);
        feedServiceHa(t,:)=(feedServiceStart+(t-1)*(feedServiceEnd-feedServiceStart)/(time-1));
        feedDieselHa(t,:)=(feedDieselHaStart+(t-1)*(feedDieselHaEnd-feedDieselHaStart)/(time-1));
        feedDieselCostHa(t,:)=dieselCost(t).*feedDieselHa(t,:);
        feedMachineFixHa(t,:)=feedMachineFixHaStart+(t-1)*(feedMachineFixHaEnd-feedMachineFixHaStart)/(time-1);
        feedMachineVarHa(t,:)=feedMachineVarHaStart+(t-1)*(feedMachineVarHaEnd-feedMachineVarHaStart)/(time-1);
        feedDirectCostsHa(t,:)=feedDirectCostsHaStart;%+(time-1)*(feedDirectCostsHaEnd-feedDirectCostsHaStart)/time;

        % Production cost per feed 
        feedExpensesHa(t,:)=feedLabourCostHa(t,:)+feedDieselCostHa(t,:)+feedMachineFixHa(t,:)+feedMachineVarHa(t,:)+feedDirectCostsHa(t,:)+feedServiceHa(t,:);
        
        % Wheat income for each year [/ha]
        wheatIncome(t)=wheatPriceStart*feedYieldFM(t,7)*priceDev(t);
        
        % Wheat Profit for each year [/ha]
        wheatProfit(t)=wheatIncome(t)-feedExpensesHa(t,7); % Achtung Weizen muss an Stelle 7 in der Excel Liste sein
        
        % Feed Income [/ha]
        feedIncomeHa(t,:)=feedExpensesHa(t,:)+wheatProfit(t);
        
        % Feed Price [/GJ]
        feedPriceGJ(t,:)=(feedIncomeHa(t,:)./feedYieldDM(t,:))./feedDMenergyContent;
    end


    
 % Prizes for residues [EUR/GJ]
    if Sen==0
        for b=1:9
            for t=1:time
                BP(t,b)=BioResiduesCosts(b,1)*(1+priceDevFactor)^(t-1);
            end
        end
        for t=1:time
            BP(t,27)=BioResiduesCosts(10,1)*(1+priceDevFactor)^(t-1);
            BP(t,28)=BioResiduesCosts(11,1)*(1+priceDevFactor)^(t-1);
        end
    else
        for b=[1:4 7]            
            for t=1:time
                BP(t,b)=(Sen(1,36)*(BioResiduesCosts(b,3)-BioResiduesCosts(b,2))+BioResiduesCosts(b,2))*(1+priceDevFactor)^(t-1);
            end
        end   
        for b=5           
            for t=1:time
                BP(t,b)=(Sen(1,37)*(BioResiduesCosts(b,3)-BioResiduesCosts(b,2))+BioResiduesCosts(b,2))*(1+priceDevFactor)^(t-1);
            end
        end  
        for b=8           
            for t=1:time
                BP(t,b)=(Sen(1,39)*(BioResiduesCosts(b,3)-BioResiduesCosts(b,2))+BioResiduesCosts(b,2))*(1+priceDevFactor)^(t-1);
            end
        end   
        for b=9           
            for t=1:time
                BP(t,b)=(Sen(1,38)*(BioResiduesCosts(b,3)-BioResiduesCosts(b,2))+BioResiduesCosts(b,2))*(1+priceDevFactor)^(t-1);
            end
        end   
    end
    
    % Grassland
    for t=1:time
        BP(t,21)=feedPriceGJ(1,10)*(1+(2/3)*priceDevFactor)^(t-1);
    end
    
    
% Calculation of Biomass products prices according Excel list for energy crops    
    
    
    % Applying the results from the method for energy crops
    BP(:,10)=feedPriceGJ(:,1); % Corn silage
    BP(:,11)=feedPriceGJ(:,2); % sugar beet
    BP(:,12)=feedPriceGJ(:,4)*1.107; % Poplar wood chips + Taxes
    %BP(:,15)=feedPriceGJ(:,6)*1.107; % Miscanthus wood chips + Taxes (alternative)
    BP(:,15)=BP(:,1)*0.95; % coupling of the Miscanthus price on forest wood chip price
    BP(:,18)=feedPriceGJ(:,8); % Silphie
    BP(:,19)=feedPriceGJ(:,9); % Agricultural grass
    BP(:,20)=feedPriceGJ(:,11); % Sorghum
    BP(:,22)=feedPriceGJ(:,12); % Grain
    BP(:,23)=feedPriceGJ(:,13); % Grain silage

    % Apply price increase for briquettes and pellets
    BP(:,13)=BP(:,12)+7; % Poplar briquettes
    BP(:,14)=BP(:,12)+5; % Poplar pellets
    BP(:,16)=BP(:,15)+7; % Miscanthus briquettes
    BP(:,17)=BP(:,15)+5; % Miscanthus pellets
    
    % Add specific costs for the conversion of biogas to biomethane in €/GJ
    BP(:,[10:11 18:23])=BP(:,[10:11 18:23])+0.015/0.0036;
    
    % Add specific costs for the feed-in of biomethane into the grid in €/GJ
    BP(:,[8:11 18:23])=BP(:,[8:11 18:23])+0.03/0.0036;

end




