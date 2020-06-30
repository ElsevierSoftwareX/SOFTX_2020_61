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

% With this script the Sobol indices can be plotted. Set the timeframe!

clearvars;

%load data
load('Sets.mat')
load('TechData.mat');
load('SetList.mat')
legtechtype=SetList.textdata.SetList(2:techtype+1,10);
coltechtype=SetList.textdata.SetList(2:techtype+1,11);
for i=1:length(coltechtype)
    coltechtype{i}=str2num(coltechtype{i})/255; %#ok<ST2NM>
end

% load legend
[num,txt,raw]  = xlsread('Sobol_ParameterRange.xlsx','A2:A46');

% load exemplary results
load('SensitivityResults.mat')

% Sets
% Number of Parameters
par=45;
% Number of types for sets
typeset = par+2;
%Number of sets
sets = 1000;


% Number of infeasible runs
NumInfFval=0;
for ts=1:typeset
    for s=1:sets
    NumInfFval=NumInfFval+sum(sum(sum(isnan(V1(ts,s)))));
    end
end
NumInfFval

% Define which timeframe to be investigated
V=V1+V2+V3;
VGAS=VGAS1+VGAS2+VGAS3;
BA=BA1+BA2+BA3;


%% calculate share of technology types (Net energy) over time
fval = zeros(typeset,sets,techtype);
for ts=1:typeset
    for s=1:sets
        if isnan(V(ts,s))==0
            for i=1:tech
                for j=1:market
                    if i==24 || i==26 || i==41 || i==46
                        fval(ts,s,1)=fval(ts,s,1)+V(ts,s,i,j)*TP(5,i,j); %Coal share
                    else
                        fval(ts,s,2)=fval(ts,s,2)+VGAS(ts,s,i,j)*TP(5,i,j); %Natural gas share
                        fval(ts,s,3)=fval(ts,s,3)+(V(ts,s,i,j)*TP(5,i,j)-VGAS(ts,s,i,j)*TP(5,i,j)); %Biogas share
                    end
                    fval(ts,s,4)=fval(ts,s,4)+V(ts,s,i,j)*TP(6,i,j); %ST share
                    if (j==1 && i==6) || (j==18 && i==42)
                        fval(ts,s,6)=fval(ts,s,6)+V(ts,s,i,j)*TP(7,i,j); %EDH share
                    else
                        fval(ts,s,5)=fval(ts,s,5)+V(ts,s,i,j)*TP(7,i,j); %WP share
                    end
                    if i==2 || i==11 || i==16 || i==17
                        fval(ts,s,7)=fval(ts,s,7)+V(ts,s,i,j)*TP(8,i,j); %LogWood share
                    elseif i==12 || i==13 || i==14 || i==15 || i==18 || i==19 || i==20 || i==21 || i==22
                        fval(ts,s,8)=fval(ts,s,8)+V(ts,s,i,j)*TP(8,i,j); %Pellet share
                    elseif i==23 || i==26 || i==28 || i==29 || i==33 || i==34 || i==35 || i==39 || i==44 || i==45
                        fval(ts,s,9)=fval(ts,s,9)+V(ts,s,i,j)*TP(8,i,j); %WoodChip share
                    elseif i==47
                        fval(ts,s,10)=fval(ts,s,10)+V(ts,s,i,j)*TP(8,i,j); %Biocoke
                    end
                end
            end
        else
            fval(ts,s,:)=nan;
        end
    end
end


%% Calculate Sobol for fvtypesum (Impact on technology types)

VA1 = zeros(1,techtype);
VA2 = zeros(1,techtype);
Si = zeros(par,techtype);
STi = zeros(par,techtype);
for i=1:techtype
    % Calculate the variances
    VA1(i)=nanvar([fval(par+1,:,i) fval(par+2,:,i)]); % Varianz von A & B
    VA2(i)=nanvar(fval(par+1,:,i)); % Varianz von A

    % calculate the sum of the formula for Si
    sumi = cell(par,1);
    for sm=1:par
        for s=1:sets
            sumi{sm}(s)=fval(par+2,s,i)*(fval(sm,s,i)-fval(par+1,s,i));
        end
    end

    % Calculate Si
    for sm=1:par
        Si(sm,i)=(1/VA1(i))*(1/sets)*nansum(sumi{sm});
    end


    % calculate the sum of the formula for STi
    sumTi = cell(par,1);
    for sm=1:par
        for s=1:sets
            sumTi{sm}(s)=(fval(sm,s,i)-fval(par+1,s,i))^2;
        end
    end
    
    % Calculate STi
    for sm=1:par
        STi(sm,i)=(1/VA2(i))*(1/(2*sets))*nansum(sumTi{sm});
    end

end
 
    
%% Plot results for fval (Impact on technology types)

% Font sizes [Title x-/y-Labels Legend Axes]
FT=[12 12 12 12];

scrsz = get(groot,'ScreenSize');
figure('Position',scrsz);
subplot(2,1,1) % Main effect
h=bar(Si(:,1:techtype));
for i=1:techtype
    h(i).FaceColor=coltechtype{i};
end
title('Main effect on market share of technology types','FontSize',FT(1));
ylabel('Sobol Index (Main effect)','FontSize',FT(2));
ax=gca;
ax.FontSize=FT(4);
ax.XTick = 1:par;
ax.XTickLabel=txt;
ax.XTickLabelRotation = 45;
xlim([0 par+1]);
ylim([0 1]);
legend({legtechtype{1:techtype}},'Location','EastOutside','FontSize',FT(3));

subplot(2,1,2) % Total effect
h=bar(STi(:,1:techtype));
for i=1:techtype
    h(i).FaceColor=coltechtype{i};
end
title('Total effect on market share of technology types','FontSize',FT(1));
ylabel('Sobol Index (Total effect)','FontSize',FT(2));
ax=gca;
ax.FontSize=FT(4);
ax.XTick = 1:par;
ax.XTickLabel=txt;
ax.XTickLabelRotation = 45;
xlim([0 par+1]);
ylim([0 1]);
legend({legtechtype{1:techtype}},'Location','EastOutside','FontSize',FT(3));
 
