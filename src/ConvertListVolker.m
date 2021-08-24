% Structure in the WG and NWG markets seems to be equal


clearvars;
close all;

tech = 47;  % i 
modul = 7;  % m 
market = 18; % j


%% Import Volkers Data
%[~,sheets] = xlsfinfo('TechData_DataVolker_190124_PVSp.xlsx');
[~,sheets] = xlsfinfo('TechData_DataVolker_SmartWs_23032021_MJ.xlsx');

VData=zeros(90,14,market);
for j=1:market
    s1=size(xlsread('TechData_DataVolker_SmartWs_23032021_MJ.xlsx',sheets{j}));
    VData(1:s1(1),1:s1(2),j) = xlsread('TechData_DataVolker_SmartWs_23032021_MJ.xlsx',sheets{j});
end

% Correct "Netzverluste" in district heating market
VData(20,5,15)=VData(20,5,15)*(100-VData(24,5,15))/100;
VData(20,6,15)=VData(20,6,15)*(100-VData(24,6,15))/100;
VData(27,6,15)=VData(27,6,15)*(100-VData(24,6,15))/100;
VData(28,7,15)=VData(28,7,15)*(100-VData(24,7,15))/100;
VData(22,5,15)=VData(4,5,15)*0.05;

% load matrix showing in which row of Volkers Excel the technology is placed (i,j)
id=xlsread('TechData_TechnologyColumnsVolkersDataSheet.xlsx');

%% Generate 3D-Matrix Technology data according to my datasheet
TP=zeros(36,tech,market);
for j=1:market
    TP(35,1,j)=VData(4,5,j);    % Capacity of market
    %TP(35,1,12)=17500000;    % Capacity of industry 1
    for i=1:tech
        if id(i,j) ~= 0
            for k=25:28
                if isnan(VData(k,id(i,j),j))==0 && VData(k,id(i,j),j)~=TP(1,i,j)
                    if TP(1,i,j)~=0 && VData(k,id(i,j),j)~=TP(1,i,j)
                        warning(['biomass thermal degree of efficiency is double on market ' num2str(j) ' and technology ' num2str(i)]);
                    end
                    TP(1,i,j)=VData(k,id(i,j),j)/100;    % biomass thermal degree of efficiency
                end
            end  
            for k=[19 20]
                if isnan(VData(k,id(i,j),j))==0 && VData(k,id(i,j),j)~=TP(30,i,j)
                    if TP(30,i,j)~=0 && VData(k,id(i,j),j)~=TP(30,i,j)
                        %warning(['gas thermal degree of efficiency is double on market ' num2str(j) ' and technology ' num2str(i)]);
                    end
                    TP(30,i,j)=VData(k,id(i,j),j)/100;    % gas thermal degree of efficiency
                end
            end     
            TP(2,i,j)=sum(VData(84,id(i,j),j),'omitnan');    %efficiency learning electrical (overwritten if thermal efficiency learning exists)
            if isnan(VData(83,id(i,j),j))==0
                TP(2,i,j)=sum(VData(83,id(i,j),j),'omitnan');    %efficiency learning thermal
            end
            
            if isnan(VData(30,id(i,j),j))==0
                 TP(5,i,j)=round(VData(30,id(i,j),j)/TP(35,1,j),2); % Share of Gas
                 TP(28,i,j)=1; % Set gas factor to 1
            end
            if isnan(VData(22,id(i,j),j))==0
                 TP(6,i,j)=round(VData(22,id(i,j),j)/TP(35,1,j),2); % Share of Solar Thermal
            end
            if isnan(VData(32,id(i,j),j))==0
                 TP(7,i,j)=round(VData(32,id(i,j),j)/TP(35,1,j),2); % Share of Heat Pump
            end
            
            TP(8,i,j)=round(1-TP(5,i,j)-TP(6,i,j)-TP(7,i,j),2); % Share of Biomass
            TP(3,i,j)= TP(8,i,j)*TP(35,1,j);     % Biomass capacity
            TP(4,i,j)= (TP(5,i,j)+TP(6,i,j)+TP(7,i,j))*TP(35,1,j);     % Non Biomass capacity
            
            TP(10,i,j)=VData(82,id(i,j),j);    %installed plants 2011
            
            TP(13,i,j)=VData(52,id(i,j),j);    %lifetime ST
            if isnan(VData(55,id(i,j),j))==0
                TP(13,i,j)=sum(VData(55,id(i,j),j),'omitnan');    %lifetime PV
                if isnan(VData(52,id(i,j),j))==0 && VData(52,id(i,j),j)~=VData(55,id(i,j),j)
                     warning(['lifetime of ST and PV in market ' num2str(j) ' and technology ' num2str(i) ' are not equal']); % Test according text
                end
            end
            TP(14,i,j)=VData(53,id(i,j),j);    %lifetime pump
            if isnan(VData(56,id(i,j),j))==0
                TP(14,i,j)=sum(VData(56,id(i,j),j),'omitnan');    %lifetime Wechselrichter
                if isnan(VData(53,id(i,j),j))==0 && VData(53,id(i,j),j)~=VData(56,id(i,j),j)
                     warning(['lifetime of pump and Wechselrichter in market ' num2str(j) ' and technology ' num2str(i) ' are not equal']); % Test according text
                end
            end
            TP(15,i,j)=VData(59,id(i,j),j);    %lifetime storage
            TP(16,i,j)=VData(60,id(i,j),j);    %lifetime puffer
            TP(17,i,j)=VData(61,id(i,j),j);    %lifetime Nachheizstab/HHS-Trocknung
            TP(18,i,j)=VData(85,id(i,j),j);    %investment learning
            TP(19,i,j)=sum(VData(76,id(i,j),j),'omitnan');    %sum of investment
            TP(22,i,j)=sum([VData(64,id(i,j),j) VData(67,id(i,j),j)],'omitnan');    %invest ST and/or PV modul
            TP(23,i,j)=sum([VData(65,id(i,j),j) VData(68,id(i,j),j)],'omitnan');    %invest Pump and/or Wechselrichter
            TP(24,i,j)=sum(VData(71,id(i,j),j),'omitnan');    %invest storage
            TP(25,i,j)=sum(VData(73,id(i,j),j),'omitnan');    %invest puffer
            TP(26,i,j)=sum(VData(74,id(i,j),j),'omitnan');    %invest Nachheizstab
            TP(29,i,j)=sum(VData(79,id(i,j),j),'omitnan');    %Pellet price (overwritten if Scheitholz price exists)
            if isnan(VData(80,id(i,j),j))==0
                TP(29,i,j)=sum(VData(80,id(i,j),j),'omitnan');    %Scheitholz price
            end
            TP(27,i,j)=sum(VData(34,id(i,j),j),'omitnan');    %Units of PV
            TP(31,i,j)=sum(VData(78,id(i,j),j),'omitnan');    %Electricity demand
            TP(32,i,j)=sum(VData(35,id(i,j),j),'omitnan');    %Electricity Byproduct
            TP(34,i,j)=sum(VData(87,id(i,j),j)/100,'omitnan');%Electricity internal use (for heating system and remaining internal use)
            TP(33,i,j)=sum(VData(77,id(i,j),j),'omitnan');    %Maintanance
            TP(36,i,j)=sum(VData(89,id(i,j),j),'omitnan');    %Investment Subsidies
            
            
             % lifetime & invest for base tech
             l=0;
             for k=[51 58 50 54 57]
                 if (isnan(VData(k,id(i,j),j))==0 && l==0)
                    TP(11+l,i,j)=VData(k,id(i,j),j);    % lifetime of Tech1
                    TP(20+l,i,j)=sum([VData(k+12,id(i,j),j) VData(72,id(i,j),j) VData(75,id(i,j),j)],'omitnan');    %invest base tech(s)+Systemregelung+Montage
                    l=l+1;
                 elseif (isnan(VData(k,id(i,j),j))==0 && l==1)
                    TP(11+l,i,j)=VData(k,id(i,j),j);    % lifetime of Tech2
                    TP(20+l,i,j)=VData(k+12,id(i,j),j);    %invest base tech(s)+Systemregelung+Montage
                 elseif l==3
                     warning('More than 2 main technologies exist'); 
                 end
             end
     
            % Test, if sum of investment costs are correct
            if round(sum([TP(20,i,j) TP(21,i,j) TP(22,i,j) TP(23,i,j) TP(24,i,j) TP(25,i,j) TP(26,i,j)]),0) ~= round(TP(19,i,j),0)
                warning(['Sum of investment costs is incorrect on market ' num2str(j) ' and technology ' num2str(i)]);
            end
        end
        
        if TP(1,i,j)==0
             TP(1,i,j)=1; % replace 0 with 1 to avoid division by zero
        end
        if TP(30,i,j)==0
             TP(30,i,j)=1; % replace 0 with 1 to avoid division by zero
        end
    end
end

%% manual corrections!

TP(1,26,15)=0.1; % Degree of efficiency of HHS-KohleHKW is 0,1% for the HHS share
for j=[7 8 11:14]
    TP(30,5,j) = VData(30,id(5,j),j)./VData(31,id(5,j),j); % Correction of Gas degree of efficiency of Tech Gas-BZ+BW+ST
end

% Correct Share of ST & Biomass in HT-WP + ST + BM-BHKW, needs to be changed again!!! Leitungsverluste nicht berücksichtigt!!!!!!
TP(6,27,15)=0.05;
TP([3 8],27,15)=0;
TP(4,27,15)=18000000;

% Correct Units of PV in Industry and district heating
TP(27,:,15:end)=0;    %Units of PV

%% Write data into Excel sheet
for j=1:market
    xlswrite('TechData_FinalData.xlsx',TP(:,:,j),sheets{j},'C3:AW38')
end

