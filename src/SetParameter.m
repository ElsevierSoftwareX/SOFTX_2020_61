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

function[d,dcap,vc,inv,pmBio,pmGas,pm3,efBio,efGas,efMethan,life,ba,bamaxw,bamaxc,nstart,nsdec,yield,culstart,ghgr,ghgfeed,alloc,ghgmax,...
    TP,PowerPrice,GasPrice,CoalPrice,ghgtarget,COCert,BP,dBeh,vcBeh,invBeh]=...
    SetParameter(target,Heatdemand,residues,crop,biouse,BioPriceInc,CO2,power,sc,InvSub,KWKG,EEGUml,EEGUmlRed,PrivPowerInd,InvBeh,...
    time,tech,modul,market,cluster,biotype,bioprod,tims,techs,moduls,markets,clusters,biotypes,bioprods,techmarket,GHGTechType2Tech,Sen)

    % Parameter Name in Matlab (capital letters) = Parameter Name in GAMS (small letters)


    % sc=1 --> KSS2050 https://www.oeko.de/oekodoc/2441/2015-598-de.pdf
    % sc=2 --> BMWi Langfristszenarien https://www.bmwi.de/Redaktion/DE/Artikel/Energie/langfrist-und-klimaszenarien.html
    % sc=3 --> BioStromWärme https://www.energetische-biomassenutzung.de/fileadmin/Steckbriefe/dokumente/03KB114_Bericht_Bio-Strom-W%C3%A4rme.pdf
    % sc=4 --> Constant prices
    % sc=5 or Par=5 --> Sobol sensitivity calculation (Sobol_Main.m)

    %% load/ set data
    
    set=1000; % Adjust this value, when calculating a sensitivity analysis
    
    % load Tech data
    load('TechData.mat');
    
    % load ScenarioData
    load('ScenarioData.mat');
    
    % load BiomassData
    load('BiomassData.mat');
    

    %% Discount rate
    if sc==5 %Sensitivity
        ir=Sen(1,7);
    else
        ir=0.04; % interest rate is set to 4% in the model
    end
    
    
    %% Available biomass and fossil potential (t,bm) [GJ] or [Ha]
    BA=zeros(biotype,time);
        
    % Biomass potential for residues
    if residues==1 % Min
        for bm=1:12
            BA(bm,:) = interp1(BAMinMaxData(1,2:end),BAMinMaxData(bm+3,2:end),2020:1:2050,'pchip');
        end
    elseif residues==2 % Medium
        for bm=1:12
            BA(bm,:) = interp1(BAMinMaxData(1,2:end),(BAMinMaxData(bm+3,2:end)+BAMinMaxData(bm+21,2:end))/2,2020:1:2050,'pchip');
        end        
    elseif residues==3 % Max
        for bm=1:12
            BA(bm,:) = interp1(BAMinMaxData(1,2:end),BAMinMaxData(bm+21,2:end),2020:1:2050,'pchip');
        end
    elseif residues==5 % Sensitivity
        for bm=[1:5 7] % Wood
            BA(bm,:) = interp1(BAMinMaxData(1,2:end),(BAMinMaxData(bm+3,2:end)+(BAMinMaxData(bm+21,2:end)-BAMinMaxData(bm+3,2:end))*Sen(1,32)),2020:1:2050,'pchip');
        end
        for bm=[6 8 9 10] % Waste wood etc.
            BA(bm,:) = interp1(BAMinMaxData(1,2:end),(BAMinMaxData(bm+3,2:end)+(BAMinMaxData(bm+21,2:end)-BAMinMaxData(bm+3,2:end))*Sen(1,33)),2020:1:2050,'pchip');
        end
        for bm=12 % Digestable
            BA(bm,:) = interp1(BAMinMaxData(1,2:end),(BAMinMaxData(bm+3,2:end)+(BAMinMaxData(bm+21,2:end)-BAMinMaxData(bm+3,2:end))*Sen(1,34)),2020:1:2050,'pchip');
        end
        for bm=11 % Straw
            BA(bm,:) = interp1(BAMinMaxData(1,2:end),(BAMinMaxData(bm+3,2:end)+(BAMinMaxData(bm+21,2:end)-BAMinMaxData(bm+3,2:end))*Sen(1,35)),2020:1:2050,'pchip');
        end
    end
    
    % optional plot of the residues potential
%     figure (1)
%         for bm=1:11
%             BA(bm,:) = interp1(BAMinMaxData(1,:),BAMinMaxData(bm+3,:),2015:1:2050,'pchip');
%         end
%         plot(sum(BA(1:11,:),1),'--','color','black')
%         hold on
%         for bm=1:11
%             BA(bm,:) = interp1(BAMinMaxData(1,:),(BAMinMaxData(bm+3,:)+BAMinMaxData(bm+20,:))/2,2015:1:2050,'pchip');
%         end 
%         plot(sum(BA(1:11,:),1),'color','black')
%         hold on
%         for bm=1:11
%             BA(bm,:) = interp1(BAMinMaxData(1,:),BAMinMaxData(bm+20,:),2015:1:2050,'pchip');
%         end
%         plot(sum(BA(1:11,:),1),'--','color','black')
%         xlim([0 38])
%         ax=gca;
%         ax.XTick = [1 6:10:36];
%         ax.XTickLabel= [2015 2020:10:2050];
%         text(1,sum(BA(1:11,1),1),'Energetic usage 2015 (max)')
%         text(15,1000,1,'Energetic usage 2015 (max)')
%         text(15,900,1,'+ exploitable potential (max)')
%         text(15,550,1,'Energetic usage 2015 (min)')
%         text(1,900,1,'Applied potential in the scenarios')
%         hold on
%         ylabel('Biomass potential from residues in PJ')
%         x = [0.1,0.5];
%         y = [0.1,0.5];
%         annotation('textarrow',x,y)
%         
%         set(gcf, 'Renderer', 'painters');
%         saveas(gcf,'BiomassPotential.eps','eps')
    
    
    % Potential available land for energy crops
    if crop==1
        BA(13,:) = interp1(BAdata(1,2:end),BAdata(8,2:end),2020:1:2050,'pchip');
    elseif crop==5 %Sensitivity
        BA(13,:) = interp1(BAdata(1,2:end),BAdata(9,2:end)+(BAdata(8,2:end)-BAdata(9,2:end))*Sen(1,31),2020:1:2050,'pchip');
    else
        BA(13,:) = interp1(BAdata(1,2:end),BAdata(9,2:end),2020:1:2050,'pchip');
    end
    
    % Set fossil potential to 20.000 PJ (equals unlimited)
    BA(14,:)= 20*10^9;
    
    % Set data format for GAMS
    ba.uels = {tims,biotypes};
    ba.type = 'parameter';
    ba.form = 'full';
    ba.name='ba';
    ba.val=transpose(BA.*1000000);
    
    %% Biomass Pre-allocation for heating (t) [%]

    BAmaxW=zeros(time); % Maximal Biomass usage for residues 80%
    BAmaxC=zeros(time); % Maximal Biomass usage for cultivation 80%
    if biouse == 1
        BAmaxW = interp1(BAdata(1,[2 3 4]),BAdata(24,[2 3 4]),2020:1:2050,'pchip'); % Maximal Biomass usage for residues 80%
        BAmaxC = interp1(BAdata(1,[2 3 4]),BAdata(25,[2 3 4]),2020:1:2050,'pchip'); % Maximal Biomass usage for cultivation 80%
    elseif biouse==2
        BAmaxW = interp1(BAdata(1,[2 3 4]),BAdata(31,[2 3 4]),2020:1:2050,'pchip');% Maximal Biomass usage for residues 95%
        BAmaxC = interp1(BAdata(1,[2 3 4]),BAdata(32,[2 3 4]),2020:1:2050,'pchip');% Maximal Biomass usage for cultivation 95%
    elseif biouse==5 %Sensitivity
        BAmaxW = interp1(BAdata(1,[2 3 4]),BAdata(31,[2 3 4])+(BAdata(24,[2 3 4])-BAdata(31,[2 3 4]))*Sen(1,30),2020:1:2050,'pchip');% Maximal Biomass usage for residues
        BAmaxC = interp1(BAdata(1,[2 3 4]),BAdata(32,[2 3 4])+(BAdata(25,[2 3 4])-BAdata(32,[2 3 4]))*Sen(1,30),2020:1:2050,'pchip');% Maximal Biomass usage for cultivation
    end
    
    % Set data format for GAMS
    bamaxw.uels = {tims};
    bamaxw.type = 'parameter';
    bamaxw.form = 'full';
    bamaxw.name='bamaxw';
    bamaxw.val=BAmaxW;
    
    bamaxc.uels = {tims};
    bamaxc.type = 'parameter';
    bamaxc.form = 'full';
    bamaxc.name='bamaxc';
    bamaxc.val=BAmaxC;
 
    %% CO2 price
    
    % set CO2 price path according to the selected user choice. The first
    % years are historical and according the planned political setting
    % until 2025.
    if CO2==0
        COCert(1,1:time)=0;
    elseif CO2==100
        COCert(1,:)=interp1([1:2 6 31],[0 25 55 100],1:time);
    elseif CO2==200
        COCert(1,:)=interp1([1:2 6 31],[0 25 55 200],1:time);
    elseif CO2==275
        COCert(1,:)=interp1([1:2 6 31],[0 25 55 275],1:time);
    elseif CO2==5
        
        CO22050=interp1([1 set],[65 300],1:1:set); % Defines the sensitivity range, which is investigated
        for c=1:set
            CO2Price(c,:)=interp1([1:2 6 31],[0 25 55 CO22050(c)],1:time);
        end
        COCert=CO2Price(Sen(1,4),:);
    else
            COCert=CO2;
    end 
 
    
    %% Power price [€/GJ]
    
    % Sets the power price according to the selected value (user interface)
    if power==32
        PowerPriceStockRaw=(interp1([1 time],[30.47 30.47],1:time)/3.6)'; % Day ahead auction
    elseif power==52
        PowerPriceStockRaw=PowerPricesStock(6:end,2);
    elseif power==120
        PowerPriceStockRaw=PowerPricesStock(6:end,3);
    elseif power==215
        PowerPriceStockRaw=PowerPricesStock(6:end,4);
    elseif power==5
        Power2050=interp1([1 set],[15 165],1:1:set); 
        for p=1:set
            PowerPriceTimeSeries(p,:)=interp1([1 time],[30.47 Power2050(p)],1:time)/3.6; % Day ahead auction
        end
        Power2050=interp1([1 set],[15 165],1:1:set); % Defines the sensitivity range, which is investigated
        for p=1:set
            PowerPriceTimeSeries(p,:)=interp1([1:6 36],[31.2 28.2 32.89 43.26 36.64 36 Power2050(p)],1:36)/3.6; % Defines the sensitivity range, which is investigated
        end
        PowerPriceStockRaw=PowerPriceTimeSeries(Sen(1,1),:)';
    else
        PowerPriceStockRaw=power';
    end
    
    %calculate power price for the sub-sectors
    for j=1:market
        if PrivPowerInd==1 || (PrivPowerInd==5 && Sen(1,44)>=0.5) % Sensitivity
            PowerPrice(:,j)=PowerPriceStockRaw(:,1) + squeeze(sum(PowerPriceSuppRed(6:end,[2:5 7:10],j),2));
        else
            PowerPrice(:,j)=PowerPriceStockRaw(:,1) + squeeze(sum(PowerPriceSupp(6:end,[2:5 7:10],j),2));
        end
        if EEGUml==1 || (EEGUml==5 && Sen(1,42)>=0.5) % Sensitivity
            PowerPrice(:,j)=PowerPrice(:,j)+ squeeze(PowerPriceSupp(6:end,11,j));
        end
        if EEGUmlRed==1
            PowerPrice(:,j)=PowerPrice(:,j)+ squeeze(PowerPriceSupp(6:end,12,j));
        end
        if KWKG==1 || (KWKG==5 && Sen(1,41)>=0.5) % Sensitivity
            PowerPrice(:,j)=PowerPrice(:,j)+ squeeze(PowerPriceSupp(6:end,6,j));
        end
        % Add the VAT of 19% for private households
        if j<=8
            PowerPrice(:,j)=PowerPrice(:,j)*1.19;
        end
    end
    
    
    %% set scenario data according APP
    
    % 80% scenario
    if (strcmp(target,'80 %') || strcmp(target,'88 %'))
        if sc==1 || sc==6 || sc==7 % KSS 2050
            GasPrice=GasPriceKSS(end-time+1:end,:);
            CoalPrice=CoalPriceKSS(:,end-time+1:end);
            ghgPowerMix=ghgPowerMixKSS80(:,end-time+1:end); % German power mix specific ghg emission factor [g/kWh] for the 80% reduction scenario 
        elseif sc==2 % BMWi
            GasPrice=GasPriceBMWi;
            CoalPrice=CoalPriceBMWi(:,end-time+1:end);
            ghgPowerMix=ghgPowerMixBMWi80(:,end-time+1:end); % German power mix specific ghg emission factor [g/kWh] for the 80% reduction scenario 
        elseif sc==3 % BioStromWärme
            GasPrice=GasPriceBSW(end-time+1:end,:);
            CoalPrice=CoalPriceBSW(:,end-time+1:end);
            ghgPowerMix=ghgPowerMixBSW80(:,end-time+1:end); % German power mix specific ghg emission factor [g/kWh] for the 80% reduction scenario
        
        end
        
    % 95% scenario
    elseif (strcmp(target,'95 %') || strcmp(target,'97 % in 2045') || strcmp(target,'100 %') || strcmp(target,'No target'))
        if sc==1 || sc==6 || sc==7% KSS 2050
            GasPrice=GasPriceKSS(end-time+1:end,:);
            CoalPrice=CoalPriceKSS(:,end-time+1:end);
            ghgPowerMix=ghgPowerMixKSS95(:,end-time+1:end); % German power mix specific ghg emission factor [g/kWh] for the 95% reduction scenario
        elseif sc==2 %BMWi
            error('For 95% reduction no data from the "BMWi Langfristszenarien" exist')
        elseif sc==3 % BioStromWärme7  
            GasPrice=GasPriceBSW(end-time+1:end,:);
            CoalPrice=CoalPriceBSW(:,end-time+1:end);
            ghgPowerMix=ghgPowerMixBSW95(:,end-time+1:end); % German power mix specific ghg emission factor [g/kWh] for the 95% reduction scenario
        end
    end
       
    %% Constant prices
    if sc==4
            GasPrice=GasPriceConst(end-time+1:end,:);
            CoalPrice=CoalPriceConst(:,end-time+1:end);
            ghgPowerMix=ghgPowerMixConst(:,end-time+1:end); % German power mix specific ghg emission factor [g/kWh] for the 80% reduction scenario
    end
    
    %% Sobol Sensitivity calculation (Sobol_Main.m)
    if sc==5    
        load('EnergyPriceLimits.mat')
        
        % Gas Price
        GasPriceStock=Sen(1,2)*(UpperGas-LowerGas)+LowerGas; % 36*19
        % GasPrice for all markets
        for j=1:19
            GasPrice(:,j) = GasPriceStock(1,:)/GasFactor(j,1);
        end
        
        % Coal price
        CoalPrice=Sen(1,3)*(UpperCoal-LowerCoal)+LowerCoal; % 1*36
        
        % Power mix emission factor
        ghgPowerMix=Sen(1,5)*(UpperPMEF-LowerPMEF)+LowerPMEF; % 1*36
             
    end    
        
  
    %% Load heat demand
    
    if strcmp(Heatdemand,'1-2 %')
        load('HeatDemand80fit.mat')
    elseif strcmp(Heatdemand,'2-3 %')    
        load('HeatDemand95fit.mat')
    elseif strcmp(Heatdemand,'SC5') % Sensitivity: the heat demand can only be varied between 2 data sets
        if Sen(1,45)<0.5
            load('HeatDemand80fit.mat')
        elseif Sen(1,45)>=0.5
            load('HeatDemand95fit.mat')
        end
    end
    
    % Use DCAP only for the required timeframe
    DCAP = DCAP(end-time+1:end,1:market);
    

    % Set data format for GAMS
    % heat demand for each market (t,j) [GJ]
    d.uels = {tims,markets};
    d.type = 'parameter';
    d.form = 'full';
    d.name='d';
    d.val=D(end-time+1:end,1:market);   %#ok<NODEF> %[GJ]
    
    % Heat demand for one house/unit (t,j) [GJ]
    dcap.uels = {tims,markets};
    dcap.type = 'parameter';
    dcap.form = 'full';
    dcap.name ='dcap';
    dcap.val = DCAP;    
    
    %% Feedstock prices (t,b,j) [€/GJ]
    
    % Set yearly biomass price increase for sensitivity analysis or
    % according user interace
    if BioPriceInc==5
        BioPriceDev=Sen(1,6);
    else
        BioPriceDev=str2double(BioPriceInc)/100;
    end

    % Start function BioFeedCost for calculating future biomass price development (t,b) [€/GJ]
    BPBio=BioFeedCost(time,bioprod,BioPriceDev,feedstockInputData,BioResiduesCosts,Sen);
    
    for j=1:market
        BP(:,:,j)=BPBio; % Biomass Prices
    end
    
    % Biogas surcharge for taxes and levies
    for t = 1:time
        for b=[8:11 18:23]
            BP(t,b,:) = squeeze(BP(t,b,:))./BiogasFactor(:,1);
        end
    end
    
    BP(:,24,:)=GasPrice; % Gas price
    for j=1:market
        BP(:,25,j)=CoalPrice; % Coal price
        BP(:,26,j)=0; % Plastic waste price
    end     
        
    %% Cultivation portfolio in the starting years
    
    % Set data format for GAMS
    culstart.uels = {bioprods};
    culstart.type = 'parameter';
    culstart.form = 'full';
    culstart.name='culstart';
    culstart.val=CULSTART;   
    
    %% Yields of the energy crops (t,b) [GJ/ha)

    Y20=[0 0 0 0 0 0 0 0 0 YD(1,1) YD(1,2) YD(1,4) YD(1,4) YD(1,4) YD(1,6) YD(1,6) YD(1,6) YD(1,8) YD(1,9) YD(1,11) YD(1,10) YD(1,12) YD(1,13) 0 0 0 0 0];
    Y50=[0 0 0 0 0 0 0 0 0 YD(2,1) YD(2,2) YD(2,4) YD(2,4) YD(2,4) YD(2,6) YD(2,6) YD(2,6) YD(2,8) YD(2,9) YD(2,11) YD(2,10) YD(2,12) YD(2,13) 0 0 0 0 0];
    YIELD=zeros(time,bioprod);
    for b=1:bioprod
        YIELD(1:time,b)=interp1([2020 2050],[Y20(1,b) Y50(1,b)],2020:1:2050,'linear');
    end
    
    if sc==5
        YIELD(:,12:17) = YIELD(:,12:17)*Sen(1,28);
        YIELD(:,[10 11 18:23]) = YIELD(:,[10 11 18:23])*Sen(1,29);
    end
    
    % Set data format for GAMS
    yield.uels = {tims,bioprods};
    yield.type = 'parameter';
    yield.form = 'full';
    yield.name='yield';
    yield.val=YIELD;

    
    %% Lifetime of plant (i,m,j) [years]
    
    %load the lifetimes of the plants
    LIFE=permute(TP(11:10+modul,1:tech,1:market),[2 1 3]);
    
     if sc==5
        % Apply factor for sensitivity analysis
        % wood chips
        LIFE([23 26 29 33:35 39 44 45 47],1,:)=round(LIFE([23 26 29 33:35 39 44 45 47],1,:)*Sen(1,15));
        LIFE(28,2,:)=round(LIFE(28,2,:)*Sen(1,15));
        % Pellet
        LIFE([13:15 18:22],1,:)=round(LIFE([13:15 18:22],1,:)*Sen(1,16));
        LIFE(12,2,:)=round(LIFE(12,2,:)*Sen(1,16));
        % Scheit
        LIFE([16 17],1,:)=round(LIFE([16 17],1,:)*Sen(1,17));
        LIFE([2 11],2,:)=round(LIFE([2 11],2,:)*Sen(1,17));
        % EDH/Lichtbogen
        LIFE([6 42],1,:)=round(LIFE([6 42],1,:)*Sen(1,18));
        % Wärmepumpe
        LIFE([7:12 27 32 35],1,:)=round(LIFE([7:12 27 32 35],1,:)*Sen(1,19));
        LIFE([19 22],2,:)=round(LIFE([19 22],2,:)*Sen(1,19));
        % Solarthermie
        LIFE([3 4 6 9 10 14:16 20 23 27 32],3,:)=round(LIFE([3 4 6 9 10 14:16 20 23 27 32],3,:)*Sen(1,20));
        % Gas/Biogas/Kohle
        LIFE([1:5 24:26 28 30 31 36:38 40 41 43 46],1,:)=round(LIFE([1:5 24:26 28 30 31 36:38 40 41 43 46],1,:)*Sen(1,21));
        LIFE([5 27],2,:)=round(LIFE([5 27],2,:)*Sen(1,21));
     end
    
    % Set data format for GAMS
    life.uels = {techs,moduls,markets};
    life.type = 'parameter';
    life.form = 'full';
    life.name='life';
    life.val=LIFE;
    life.val(isnan(life.val))=100; %replace all nan lifetime values with 100
    life.val(life.val==0)=100;
    
    %% Investment costs per plant (t,i,m,j) [€]
    
    % load invest costs in 2015 and learning factor. Calculate investment
    % time series until 2050
    INV=zeros(time,tech,modul,market); % Investment costs in each year
    INVini=zeros(modul,tech,market); % investment costs in 2020
    INVlearn=zeros(tech,market); % investment learning factor
    for j=1:market
        INVini(1:modul,1:tech,j) = TP(20:19+modul,1:tech,j);
        INVlearn(1:tech,j)=TP(18,1:tech,j);
        for i=1:tech
            for m=1:modul
                for t=1:time
                    if time+1-t>=life.val(i,m,j)
                        INV(t,i,m,j) = INVini(m,i,j)*(1+INVlearn(i,j)/100*(t-1));
                    elseif time+1-t<life.val(i,m,j)
                        INV(t,i,m,j) = INVini(m,i,j)*(1+INVlearn(i,j)/100*(t-1))*((time+1-t)/life.val(i,m,j));
                    end
                end
            end
        end
    end
          
    % Calcualte investment annuity costs (AN) and sum of annuity costs over lifetime (ANsum) per plant (t,i,m,j) [€]
    INVa=zeros(time,tech,modul,market);
    INVini=zeros(modul,tech, market);
    INVlearn=zeros(tech,market);
    for j=1:market
        INVini(1:modul,1:tech,j) = TP(20:19+modul,1:tech,j);
        INVlearn(1:tech,j)=TP(18,1:tech,j);
        for i=1:tech
            for m=1:modul
                for t=1:time
                    INVa(t,i,m,j) = INVini(m,i,j)*(1+INVlearn(i,j)/100*(t-1));
                    % Substract Investment subsidies if option is activated
                    if (InvSub==1 && m==1 && t<=24)  || (InvSub==5 && Sen(1,40)>=0.5 && m==1 && t<=24) % Sensitivity
                        INVa(t,i,m,j) = INVa(t,i,m,j)-TP(36,i,j);
                    end
                    if (i==57 || i==58) && m==2 % set ir=0 for HPR and GobiGas modul 2
                        AN(t,i,m,j) = INVa(t,i,m,j)*0.000000000001*(1+0.000000000001)^life.val(i,m,j)/((1+0.000000000001)^life.val(i,m,j)-1);
                    else
                        AN(t,i,m,j) = INVa(t,i,m,j)*ir*(1+ir)^life.val(i,m,j)/((1+ir)^life.val(i,m,j)-1);
                    end
                    if time+1-t>=life.val(i,m,j)
                        ANsum(t,i,m,j) = AN(t,i,m,j).*life.val(i,m,j);
                    elseif time+1-t<life.val(i,m,j)
                        ANsum(t,i,m,j) = AN(t,i,m,j).*(time+1-t);
                    end
                end
            end
        end
    end
     
    AN(isnan(AN))=0;
    ANsum(isnan(ANsum))=0;
    
    if sc==5
        % Apply factor for sensitivity analysis
        % HHS
        SenInvHHS=interp1([1 time],[1 Sen(1,8)],1:1:time);
        AN(:,[23 26 29 33:35 39 44 45 47],1,:)=bsxfun(@times,AN(:,[23 26 29 33:35 39 44 45 47],1,:),SenInvHHS');
        AN(:,28,2,:)=bsxfun(@times,AN(:,28,2,:),SenInvHHS');
        % Pellet
        SenInvPel=interp1([1 time],[1 Sen(1,9)],1:1:time);
        AN(:,[13:15 18:22],1,:)=bsxfun(@times,AN(:,[13:15 18:22],1,:),SenInvPel');
        AN(:,12,2,:)=bsxfun(@times,AN(:,12,2,:),SenInvPel');
        % Scheit
        SenInvScheit=interp1([1 time],[1 Sen(1,10)],1:1:time);
        AN(:,[16 17],1,:)=bsxfun(@times,AN(:,[16 17],1,:),SenInvScheit');
        AN(:,[2 11],2,:)=bsxfun(@times,AN(:,[2 11],2,:),SenInvScheit');
        % EDH/Lichtbogen
        SenInvEDH=interp1([1 time],[1 Sen(1,11)],1:1:time);
        AN(:,[6 42],1,:)=bsxfun(@times,AN(:,[6 42],1,:),SenInvEDH');
        % Wärmepumpe
        SenInvWP=interp1([1 time],[1 Sen(1,12)],1:1:time);
        AN(:,[7:12 27 32 35],1,:)=bsxfun(@times,AN(:,[7:12 27 32 35],1,:),SenInvWP');
        AN(:,[19 22],2,:)=bsxfun(@times,AN(:,[19 22],2,:),SenInvWP');
        % Solarthermie
        SenInvST=interp1([1 time],[1 Sen(1,13)],1:1:time);
        AN(:,[3 4 6 9 10 14:16 20 23 27 32],3,:)=bsxfun(@times,AN(:,[3 4 6 9 10 14:16 20 23 27 32],3,:),SenInvST');
        % Gas/Biogas/Kohle
        SenInvGas=interp1([1 time],[1 Sen(1,14)],1:1:time);
        AN(:,[1:5 24:26 28 30 31 36:38 40 41 43 46],1,:)=bsxfun(@times,AN(:,[1:5 24:26 28 30 31 36:38 40 41 43 46],1,:),SenInvGas');
        AN(:,[5 27],2,:)=bsxfun(@times,AN(:,[5 27],2,:),SenInvGas');
    end
    
    % Set data format for GAMS
    inv.uels = {tims,techs,moduls,markets};
    inv.type = 'parameter';
    inv.form = 'full';
    inv.name='inv';
    inv.val=AN;
    
    %% Capacity per (hybrid) technology concept per plant (i,j) [%]
    
    % Solid biomass capacity (t,i,j) [%]
    PMBIO=zeros(time,tech,market);
    for t=1:time
        for j=1:market
            PMBIO(t,1:tech,j)=squeeze(TP(8,1:tech,j)); % percentage share of Biomass
        end
    end
    
    % Set data format for GAMS
    pmBio.uels = {tims,techs,markets};
    pmBio.type = 'parameter';
    pmBio.form = 'full';
    pmBio.name='pmBio';
    pmBio.val=PMBIO;
    
    % Gas/biogas/coal/waste capacity (t,i,j) [%]
    PMGAS=zeros(time,tech,market);
    for t=1:time
        for j=1:market
            PMGAS(t,1:tech,j)=squeeze(TP(5,1:tech,j)); % percentage share of Gas
        end
    end
    
    % Set data format for GAMS
    pmGas.uels = {tims,techs,markets};
    pmGas.type = 'parameter';
    pmGas.form = 'full';
    pmGas.name='pmGas';
    pmGas.val=PMGAS;
    
    % Non Biomass/gas/coal Capacity (t,i,j) [%]
    PM3=zeros(time,tech,market);
    for t= 1:time
        for j=1:market
            PM3(t,1:tech,j)=squeeze(TP(6,1:tech,j)+TP(7,1:tech,j)); % percentage share of ST, HP and EDH
        end
    end
    
    % Set data format for GAMS
    pm3.uels = {tims,techs,markets};
    pm3.type = 'parameter';
    pm3.form = 'full';
    pm3.name='pm3';
    pm3.val=PM3;
    
    %% Degree of efficiency solid biomass and gas/biogas/coal/waste (t,i,j), Methan (t,b)
    
    % load efficiencies in 2015 and learning factor. Calculate efficiency
    % for each year.
    EFFini(1:tech,1:market)= TP(1,1:tech,1:market); % Efficency solid biomass in 2015
    EFFiniGas(1:tech,1:market)= TP(30,1:tech,1:market); % Efficiency gas/biogas/coal/waste in 2015
    EFFlearn(1:tech,1:market)=TP(2,1:tech,1:market); % Efficiency learning solid biomass
    EF=zeros(time,tech,market); % Efficiency in each year
    EFGas=zeros(time,tech,market);
    for t=1:time
        for i=1:tech
            for j=1:market
                EF(t,i,j) = EFFini(i,j)*(1+EFFlearn(i,j)/100*(t-1)); 
                EFGas(t,i,j) = EFFiniGas(i,j)*(1+EFFlearn(i,j)/100*(t-1));
            end
        end
    end
    
    % Biomethane potential from residues is already in biomethane
    EFMethan = ones(time,bioprod);
    for b = [10:11 18:23]
        EFMethan(:,b) = linspace(0.56, 0.7, time);
    end

    if sc==5
        % Apply factor for sensitivity analysis
        % HHS
        SenEFHHS=interp1([1 time],[min([1 Sen(1,24)]) Sen(1,24)],1:1:time);
        EF(:,[23 26 28 29 33:35 39 44 45 47],:)=bsxfun(@times,EF(:,[23 26 28 29 33:35 39 44 45 47],:),SenEFHHS');
        % Pellet
        SenEFPel=interp1([1 time],[min([1 Sen(1,25)]) Sen(1,25)],1:1:time);
        EF(:,[12:15 18:22],:)=bsxfun(@times,EF(:,[12:15 18:22],:),SenEFPel');
        % Scheit
        SenEFScheit=interp1([1 time],[min([1 Sen(1,26)]) Sen(1,26)],1:1:time);
        EF(:,[2 11 16 17],:)=bsxfun(@times,EF(:,[2 11 16 17],:),SenEFScheit');
        % Biogas
        SenEFBiogas=interp1([1 time],[min([1 Sen(1,27)]) Sen(1,27)],1:1:time);
        EF(:,[1:5 25 27 30 31 36 38 43],:)=bsxfun(@times,EF(:,[1:5 25 27 30 31 36 38 43],:),SenEFBiogas'); 
    end
    
    % Set data format for GAMS
    efBio.uels = {tims,techs,markets};
    efBio.type = 'parameter';
    efBio.form = 'full';
    efBio.name='efBio';
    efBio.val=EF;
    
    efGas.uels = {tims,techs,markets};
    efGas.type = 'parameter';
    efGas.form = 'full';
    efGas.name='efGas';
    efGas.val=EFGas;
    
    efMethan.uels = {tims,bioprods};
    efMethan.type = 'parameter';
    efMethan.form = 'full';
    efMethan.name='efMethan';
    efMethan.val=EFMethan;    
    
    %% Number of plants/ plantmodules in 2020 (i,j)
    for j=2:14
        TP(10,1,j)=houses(6,j)-sum(TP(10,2:end,j)); % Calculation of plantnumbers of GasBW in market 2-14
    end
    
    % Sub-sector En30
    TP(10,7,1)=300; % Change plantnumber of WPel+PV
    TP(10,6,1)=houses(6,1)-sum(TP(10,7:end,1)); % Correct plantnumbers of EDH+ST on market En30
    
    % Sub-sector district heating, according Excel Sheet own calculations
    TP(10,24,15)=1494; % Kohle-HKW
    TP(10,25,15)=2660; % GUD-Kraftwerk
    TP(10,26,15)=300; %HHS-KohleHKW
    TP(10,27,15)=0; % HT-WP + ST + BM-BHKW
    TP(10,28,15)=670; % MüllHKW+HHS-K
    TP(10,29,15)=houses(6,15)-sum(TP(10,24:28,15)); % HHS-V-KWK: ~1069
    
    % Sub-sector Industry<200°
    TP(10,30,16)=houses(6,16)-sum(TP(10,31:end,16)); % Correct plantnumbers of GasNT
    
    % Sub-sector Industry 200°-500°
    TP(10,36,17)=houses(6,17)-sum(TP(10,[33 37:end],17)); % Correct plantnumbers of GasK
    
    % Sub-sector Industry>500°
    TP(10,40,18)=houses(6,18)-sum(TP(10,41:end,18)); % Correct plantnumbers of GasDirektF
    
    % BioCoke Sub-sector (Assumption 2020: all CoalCoke)!
    TP(10,46,19)=houses(6,19);

    % Set data format for GAMS
    nstart.uels = {techs,markets};
    nstart.type = 'parameter';
    nstart.form = 'full';
    nstart.name='nstart';
    nstart.val=squeeze(TP(10,1:tech,1:market));
    
    %% Plant Decrease of initial stock (t,i,m,j)
    NDEC=zeros(time,tech,modul,market);
    for t=1:time-1
        for i=1:tech
            for m=1:modul
                for j=1:market
                    if(isnan(TP(10+m,i,j))==0 && TP(10+m,i,j)>=t)  %check if lifetime is nan (modul does not exist)    
                        if nstart.val(i,j)>=TP(10+m,i,j)
                            NDEC(t+1,i,m,j)=round((TP(10,i,j)/TP(10+m,i,j)));
                        else
                            for n=1:nstart.val(i,j)
                                NDEC(n+1,i,m,j)=1;
                            end
                        end
                    else
                        NDEC(t+1,i,m,j)=0;
                    end
                end
            end
        end
    end

%     NDEC(19,24,:,15)=nstart.val(24,15)-sum(NDEC(1:18,24,1,15));  % Kohleausstieg 2038
%     % Decomission all starting plants in the final year of the modeling to
%     % give the model a chance to reach the climate target
%     for i=1:tech
%         for m=1:modul
%             for j=1:market
%                 NDEC(time,i,m,j)=nstart.val(i,j)-sum(NDEC(1:time-1,i,m,j));
%             end
%         end
%     end
    
    
    % Correct, if not all or additional HS are decreases (caused by round)
    for j=1:market
        for i=1:tech
            if sum(NDEC(1:time,i,1,j),1)-nstart.val(i,j) ~= 0
                NDEC(2,i,1,j)=NDEC(2,i,1,j)-(sum(NDEC(1:time,i,1,j),1)-nstart.val(i,j));
                if NDEC(2,i,1,j)<0
                    n=2;
                    while NDEC(n,i,1,j)<0
                        NDEC(n+1,i,1,j)=NDEC(n+1,i,1,j)+NDEC(n,i,1,j);
                        NDEC(n,i,1,j)=0;
                        n=n+1;
                    end
                end
            end
        end
    end
 
    % Set data format for GAMS
    nsdec.uels = {tims,techs,moduls,markets};
    nsdec.type = 'parameter';
    nsdec.form = 'full';
    nsdec.name='nsdec';
    nsdec.val=NDEC;
    
    %% Technology specific GHG emissions [t/GJ]
    
    % Determine the technologies, which belong to a value in TechData_Raw.xlxs' row
    THGtech=cell(length(THGRAW),1); % technologies, which belong to a value in TechData_Raw.xlxs' row
    for k=1:length(THGRAW)
       if isnumeric(THGRAW{k,1})==0
           THGtech{k}=str2num(THGRAW{k,1});
       elseif (isnan(THGRAW{k,1}(1))==0 && isnumeric(THGRAW{k,1})==1)
           THGtech{k}=THGRAW{k,1};
       end
       if (isnan(THGRAW{k,2}(1))==0 && isnumeric(THGRAW{k,2})==1)
           THGtechtype(k)=THGRAW{k,2};
           THGInfra2017(k)=THGRAW{k,9}; % infra emission value in 2017 [g/MJ] (Infrastructure emissions without feedstock)
           THGOper2017(k)=THGRAW{k,13}; % operating emission value in 2017 [g/MJ] (Operating emissions without feedstock)
           AllocHeatRaw(k)=THGRAW{k,17}; % Allocation factor for heat emissions
       end
    end
    
    % Define share of ST, Heat pump, PV and Tech5
    TP6.val=TP(6,:,:);
    TP7.val=TP(7,:,:);
    for j=1:market
        PV.val(1,1:tech,j)=TP(27,:,j)*1000/(TP(35,1,j)*3.6); %  PV Units [kWp] * PV return (1000) [kWh/kWp]/(heatoutput/plant[kWh]), kWh -> MJ
    end
    T5BW.val(1,5,[7 8 11:14])=[0.25 0.2 0.2 0.25 0.2 0.25];
    T5BZ.val(1,5,[7 8 11:14])=[0.65 0.5 0.5 0.6 0.65 0.6];
    
    %Test if Tech 5 is proper allocated
    if squeeze(pmGas.val(1,5,[7 8 11:14])-T5BW.val(1,5,[7 8 11:14])-T5BZ.val(1,5,[7 8 11:14])) > 10^-12
        warning('Share of GasBW or GasBZ in Tech5 is incorrect!');
    end
    
    % Determine technology system ghg emissions for 2017 according to the share of the subsystem
    ghgInfra2017=zeros(tech,market);
    ghgOper2017=zeros(tech,market);
    for k=1:length(THGtech)
       for i=THGtech{k,1}
           for j=find(techmarket(i,:)==1)
               share = GHGTechType2Tech(THGtechtype(1,k),i);
               ghgInfra2017(i,j) = ghgInfra2017(i,j)+eval([share{1,1} '.val(1,i,j)'])*THGInfra2017(1,k)*3.6/(1000*1000*0.0036); %g/MJ -> t/GJ
               ghgOper2017(i,j) = ghgOper2017(i,j)+eval([share{1,1} '.val(1,i,j)'])*THGOper2017(1,k)*3.6/(1000*1000*0.0036); %g/MJ -> t/GJ
               AllocHeat(i,j) = AllocHeatRaw(k); % Allocation factor for heat emissions
           end
       end
    end
    
    % Replace AllocHeat NaN values with 1
    AllocHeat(isnan(AllocHeat))=1;
        
    % Determine technology system ghg emissions for 2050 by reducing the infrastructure emissions by... 
    if strcmp(target,'80 %') || strcmp(target,'88 %')
        ghgInfra2050=0.35*ghgInfra2017; % ...65% for the 80% reduction scenario 
    elseif strcmp(target,'95 %') || strcmp(target,'No target')
        ghgInfra2050=0.2*ghgInfra2017; % ...80% for the 95% reduction scenario 
    elseif strcmp(target,'97 % in 2045') || strcmp(target,'100 %')
        ghgInfra2050=0*ghgInfra2017; % ...0% for the 97% reduction scenario 
    end
    
    % Add infrastructure emissions
    ghg2017 = ghgInfra2017;
    ghg2050 = ghgInfra2050;
    
    % Test, if all heating systems have an emission factor
    if all(ghg2017(techmarket==1))==0
        warning('min. 1 emission factor is not allocated');
    end
    
    % Interpolate technology specific emissions from 2015-2050 [t/GJ]
    for i=1:tech
        for j=1:market
            GHGR(1:time,i,j) = interp1([1 time],[ghg2017(i,j) ghg2050(i,j)],1:1:time,'linear');
        end
    end
    
    % Calculation power specific emissions
    
    % el demand & byproduct
    ELdem = squeeze(TP(31,:,:)); % [kWh/a]
    ElecByPrd = squeeze(TP(32,:,:)); % [kWh/a]
    
    % electricity specific emissions in the several cases
    ghgpower=zeros(time,tech,market);
    Alloc=ones(tech,market);
    for t=1:time
        for i=1:tech
            for j=1:market
                if ElecByPrd(i,j) == 0
                    ghgpower(t,i,j) = 10^-6*ELdem(i,j)*ghgPowerMix(t)/DCAP(t,j);
                elseif ElecByPrd(i,j)-ELdem(i,j) <= 0
                    %Allocation = 1 -> automatically
                    ghgpower(t,i,j) = 10^-6*(ELdem(i,j)-ElecByPrd(i,j))*ghgPowerMix(t)/DCAP(t,j);
                elseif ElecByPrd(i,j)-ELdem(i,j) > 0
                    Alloc(i,j) = AllocHeat(i,j) + (1-AllocHeat(i,j))*(ELdem(i,j)/ElecByPrd(i,j));
                end
            end
        end
    end
    
    % Add emissions for torrefiing pellets (see excel sheet THG Raw)
    GHGR(:,21,[1 2 6])=GHGR(:,21,[1 2 6])+0.002686;
    GHGR(:,22,2:5)=GHGR(:,22,2:5)+0.002686;
       
    % Add power specific emissions
    GHGRtotal = GHGR+ghgpower;   
    
    
    % Set data format for GAMS
    % Infrastructure and operation specific emission factor
    ghgr.uels={tims,techs,markets};
    ghgr.type = 'parameter';
    ghgr.form = 'full';
    ghgr.name='ghgr';
    ghgr.val=GHGRtotal;
    
    % Allocation factor for CHP heating systems
    alloc.uels={techs,markets};
    alloc.type = 'parameter';
    alloc.form = 'full';
    alloc.name='alloc';
    alloc.val=Alloc;
    
    %% Feedstock specific GHG emissions [t/GJ]
    
    GHGFeedfinal = THGFeed/1000; %g/MJ -> t/GJ
    
    % Apply factor for sensitivity analysis
    if sc==5
        GHGFeedfinal(1:23) = GHGFeedfinal(1:23)*Sen(1,22);
        GHGFeedfinal(24:26) = GHGFeedfinal(24:26)*Sen(1,23);
    end
    
    % Additional emissions through line losses of biomethan (Leitungsverluste)
    GHGFeedfinal([8:11 18:23]) = GHGFeedfinal([8:11 18:23]) + 5/1000; 
    % Additional infrastructure emissions for "Biomethaneinspeiseanlage"
    GHGFeedfinal([8:11 18:23]) = GHGFeedfinal([8:11 18:23]) + 1.74/1000;
    
    % Set data format for GAMS
    ghgfeed.uels={bioprods};
    ghgfeed.type = 'parameter';
    ghgfeed.form = 'full';
    ghgfeed.name='ghgfeed';
    ghgfeed.val=GHGFeedfinal;  

    %% GHG emission target (i) [t]
    GHGMAX = zeros(1,time);
    
    % Set GHG reduction target according user selection
    if strcmp(target,'80 %')
        ghgtarget=ghg80;
    elseif strcmp(target,'88 %')
        ghgtarget=ghg80BPW;
    elseif strcmp(target,'95 %')
        ghgtarget=ghg95;
    elseif strcmp(target,'97 % in 2045')
        ghgtarget=ghg95_2045;
    elseif strcmp(target,'100 %')
        ghgtarget=ghg100;
    elseif strcmp(target,'No target')
        ghgtarget=GHGMAX;
    end
    
    % calculate target if a target is set
    if strcmp(target,'No target')==0
    
        load('Results/Temp.mat','bc'); % Feedstock emissions in 2020 are based on the last model run. Required to set a target!

        % Calculate total emissions in the first year based on previous optimization results for bioproduct choice, allocation factor applied to the complete heating system
        for j=1:market
            for i=1:tech
                GHGMAX(1,1) = GHGMAX(1,1) + Alloc(i,j)*DCAP(1,j)*nstart.val(i,j)*GHGRtotal(1,i,j);   % Technology specific emissions
                for b=1:bioprod
                    GHGMAX(1,1) = GHGMAX(1,1) + Alloc(i,j)*bc(1,i,j,b)*ghgfeed.val(b,1);   % Feedstock specific emissions
                end
            end
        end

        %set emission target (ghgtarget is reduction compared to previous year [%])
        for t=2:time
            GHGMAX(t)= GHGMAX(t-1)*(1-ghgtarget(t));
        end
    end
    
    % Set data format for GAMS
    ghgmax.uels = {tims};
    ghgmax.type = 'parameter';
    ghgmax.form = 'full';
    ghgmax.name='ghgmax';
    ghgmax.val=GHGMAX;
    
    %% variable costs (t,i,j,b) [€/GJ]
    
    % power demand of heating system [kWh/a]
    Pdem = squeeze(TP(31,:,:));

    % power byproduct [kWh/a]
    Pby = squeeze(TP(32,:,:));
    
    % Power self use share [%]
    SU = squeeze(TP(34,:,:));
    
    % Power feed in share [[kWh/a]
    PFeedIn = Pby.*(1-SU);
    
    % calculate share of power from net, power 2 heating system and power 2 home [kWh/a]
    for j = 1:market
        for i= 1:tech
            if SU(i,j)*Pby(i,j) >= Pdem(i,j)
                P2Heat(i,j) = SU(i,j)*Pby(i,j)-Pdem(i,j);
                P2Home(i,j) = SU(i,j)*Pby(i,j) - P2Heat(i,j);
                PfromNet(i,j) = 0;
            elseif SU(i,j)*Pby(i,j) < Pdem(i,j)
                PfromNet(i,j) = Pdem(i,j) - SU(i,j)*Pby(i,j);
                P2Heat(i,j) = SU(i,j)*Pby(i,j);
                P2Home(i,j) = 0;
            end
        end
    end
    
    
    %Calculate variable costs
    VC=zeros(time,tech,market,bioprod);
    DelCharge=zeros(time,tech,market);
    for t=1:time
        for i=1:tech
            for j=1:market
                if PMBIO(t,i,j)~=0 && DCAP(t,j)~=0
                    DelCharge(t,i,j)= 50/(PMBIO(t,i,j).*DCAP(t,j)); % charge for delivery of solid biomass (50€ per delivery)
                end
                %DelCharge(DelCharge==Inf)=0;
                for b=1:bioprod
                    if t<=31
                        VC(t,i,j,b) = BP(t,b,j)*PMBIO(t,i,j)/EF(t,i,j)... % Feedstock price*Share of solid biomass/ Degree of efficiency 
                        + BP(t,b,j)*PMGAS(t,i,j)/EFGas(t,i,j)... % Gas/biogas/coal/waste Price * Gas Share / Degree of efficiency   
                        + PfromNet(i,j)*0.0036*PowerPrice(t,j)/DCAP(t,j)...  % costs for electricity demand
                        - P2Home(i,j)*0.0036*(1-TP(2,i,j)*(t-1)/100)*PowerPrice(t,j)/DCAP(t,j)...  % internally used el power (Hausstrom) [kWh/a] rewarded with elec. price - GasBZ change of efficiency considered
                        - PFeedIn(i,j)*0.0036*(1-TP(2,i,j)*(t-1)/100)*PowerPriceStockRaw(t,1)/DCAP(t,j)...  % feed in el byproduct [kWh/a] rewarded with x times elec. price - GasBZ change of efficiency considered
                        + DelCharge(t,i,j)... % charge for delivery of solid biomass (50€ per delivery)
                        + TP(33,i,j)/DCAP(t,j)...  % Maintanance
                        + COCert(t)*GHGR(t,i,j)... % CO2 Certificate price on technology specific emissions (excl. power from net based based emissions)
                        + COCert(t)*ghgfeed.val(b);% CO2 Certificate price on feedstock
                        
                       
                        % KWKG Bonus if option is activated
                        if (KWKG ==1 && i<=13 && i~=7 && t<=16) || (KWKG==5 && Sen(1,41)>=0.5) % Sensitivity % Power feed in Bonus <50KW
                            VC(t,i,j,b)=VC(t,i,j,b)-PFeedIn(i,j)*0.08/DCAP(t,j);
                            VC(t,i,j,b)=VC(t,i,j,b)-(P2Home(i,j)+P2Heat(i,j))*0.04/DCAP(t,j);
                        elseif (KWKG ==1 && i==7 && i==14 && t<=16) || (KWKG==5 && Sen(1,41)>=0.5) % Sensitivity % Power feed in Bonus 50-250KW
                            VC(t,i,j,b)=VC(t,i,j,b)-PFeedIn(i,j)*0.06/DCAP(t,j);
                            VC(t,i,j,b)=VC(t,i,j,b)-(P2Home(i,j)+P2Heat(i,j))*0.03/DCAP(t,j);
                        elseif (KWKG ==1 && i>=15 && t<=16) || (KWKG==5 && Sen(1,41)>=0.5) % Sensitivity % Power feed in Bonus >2000KW
                            VC(t,i,j,b)=VC(t,i,j,b)-PFeedIn(i,j)*0.031/DCAP(t,j);
                            VC(t,i,j,b)=VC(t,i,j,b)-(P2Home(i,j)+P2Heat(i,j))*0.018/DCAP(t,j);
                        end
                            
                        
                    elseif t>31
                        VC(t,i,j,b)=VC(36,i,j,b); % if timespan is increased, variable costs remain on the the level of 2050
                    end
                end
            end
        end
    end
    
    % price increase for technologies that need a seperator (Abscheider) [€/GJ]
    VC(:,[12:15 18:20],:,14)=VC(:,[12:15 18:20],:,14)+0.3; % price increase for poplar pellets going into pellet boiler/TorrHP/HP technologies
    VC(:,12:15,:,17)=VC(:,12:15,:,17)+0.2; % price increase for miscanthus pellets going into pellet boiler technologies
    VC(:,[2 11 17],:,13)=VC(:,[2 11 17],:,13)+0.05; % price increase for poplar briquettes going into Scheit techs
    VC(:,[23 28 33 35],:,8)=VC(:,[23 28 33 35],:,8)+0.4; % price increase for straw going into wood chip boiler technologies
    VC(:,[23 29 34 39 44],:,12)=VC(:,[23 29 34 39 44],:,12)+0.2; % price increase for poplar wood chips going into wood chip/gasifier technologies
    VC(:,23,:,15)=VC(:,23,:,15)+0.2; % price increase for miscanthus wood chips going into wood chip technologies
    
    % price increase for technologies that use torrified woodpellets (increase of 14% of pellet price in 2015) derived from Volkers prices [in %]
    VC(:,21:22,:,3)=VC(:,21:22,:,3)+0.14*BP(1,3);
    
    % Price increase for Coalcoke (+90%)
    VC(:,46,19,25)=VC(:,46,19,25)+CoalPrice(1,:)'*0.9;
    
    % Substract the taxes for the feedstock to avoid double taxing and add biomethane taxes and levies on the feedstock costs of HPR and GobiGas
    for b=[1 3 4 17]
        for i= 57:58
            % 19% for wood chips
            if b==1
                VC(:,i,18,b) = VC(:,i,18,b) - 0.19*BP(:,b,18).*PMBIO(:,i,18)./EF(:,i,18);
            end
            % 7% for pellets
            if b==3 || b==4 || b==17
                VC(:,i,18,b) = VC(:,i,18,b) - 0.07*BP(:,b,18).*PMBIO(:,i,18)./EF(:,i,18);
            end
            % Final taxes and levies
            VC(:,i,18,b) = VC(:,i,18,b) + (BP(:,b,18).*squeeze(PMBIO(:,i,18)./EF(:,i,18)))*(1/BiogasFactor(18,1)-1);
        end
    end
    
    % Set data format for GAMS
    VC(isnan(VC))=0; % replaces NaN with zero
    vc.uels = {tims,techs,markets,bioprods};
    vc.type = 'parameter';
    vc.form = 'full';
    vc.name='vc';
    vc.type='parameter';
    vc.val=VC;
    
    %% Implement investment behavior /Consumer Choice
    % Number of sub-sectors on which consumer choice is applied
    marketBeh=5;
    
    VCBeh=zeros(time,tech,market,cluster); % indirect variable costs in the clusters
    INVBeh=zeros(time,tech,market,cluster); % indirect investment costs in the clusters
    DBeh=zeros(time,market,cluster); % Heat demand in the clusters
    
    if InvBeh==1 || (InvBeh==5 && Sen(1,43)>=0.5) % Sensitivity
        % indirect variable cost - vcBeh(t,i,j,c)
        for t=1:time
            for i=1:tech
                for j=1:marketBeh
                    for c=1:cluster
                        if i==1 || i==4 % Gas Techs
                            VCBeh(t,i,j,c)=-MarginalEffect(i,c)*vc.val(t,i,j,24);
                        elseif i==6 || i==7 || i==9 || i==11 % Mainly power based techs
                            VCBeh(t,i,j,c)=-MarginalEffect(i,c)*vc.val(t,i,j,1);
                        elseif i==13 || i==15 || i==21 || i==22 % Pellet Techs
                            VCBeh(t,i,j,c)=-MarginalEffect(i,c)*vc.val(t,i,j,3);
                        elseif i==16 || i==17 % log wood techs
                            VCBeh(t,i,j,c)=-MarginalEffect(i,c)*vc.val(t,i,j,7);    
                        end
                    end
                end
            end
        end
        
        
        % indirect investment cost - invBeh(t,i,j,c)
        for t=1:time
            for i=1:tech
                for j=1:marketBeh
                    for c=1:cluster        
                        INVBeh(t,i,j,c)=-MarginalEffect(i,c)*sum(inv.val(t,i,:,j),3);
                    end
                end
            end
        end
        
        
        % Demand of the clusters - dBeh(t,j,c)
        dShare=[0.544 0.322 0.134];
        
        for t=1:time
            for j=1:marketBeh
                for c=1:cluster
                    DBeh(t,j,c)=dShare(1,c)*d.val(t,j);
                end
            end
        end

    end
    
    % Set data format for GAMS
    vcBeh.uels = {tims,techs,markets,clusters};
    vcBeh.type = 'parameter';
    vcBeh.form = 'full';
    vcBeh.name='vcBeh';
    vcBeh.val=VCBeh;

    invBeh.uels = {tims,techs,markets,clusters};
    invBeh.type = 'parameter';
    invBeh.form = 'full';
    invBeh.name='invBeh';
    invBeh.val=INVBeh;

    dBeh.uels = {tims,markets,clusters};
    dBeh.type = 'parameter';
    dBeh.form = 'full';
    dBeh.name='dBeh';
    dBeh.val=DBeh;
    
end

