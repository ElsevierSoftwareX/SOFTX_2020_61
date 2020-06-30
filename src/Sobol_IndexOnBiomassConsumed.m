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

% With this script the Sobol indices can be plotted. Set the timeframe! Set the biomass product!

clearvars;

bioprodplot=1; % Set on which biomass product the impact should be shown

%load data
load('Sets.mat')
load('TechData.mat');
load('SetList.mat')
% load English legend
legbioprod=SetList.textdata.SetList(2:bioprod+1,23);
% load colors
colbioprod=SetList.textdata.SetList(2:bioprod+1,24);
for b=1:bioprod
    colbioprod{b}=str2num(colbioprod{b})/255; %#ok<ST2NM>
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


%% Calculate Sobol for Biomass consumed (Impact on which biomass products are consumed)

% Define which timeframe to be investigated
fval=BC2+BC3;

% Calculate share of the technology types in relation to the sum of
% consumed biomass (not the available biomass! that is not possible due to PJ vs. ha)
for ts=1:typeset
    for s=1:sets
        fval(ts,s,:)=fval(ts,s,:)/sum(fval(ts,s,:),3);
    end
end

VA1 = zeros(1,bioprod);
VA2 = zeros(1,bioprod);
Si = zeros(par,bioprod);
STi = zeros(par,bioprod);
for i=1:bioprod
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

% Sort the indices
[STiSort,STiSortInd] = sort(STi,'descend');
for b=1:bioprod
    SiSort(:,b)=Si(STiSortInd(:,b),b);
    txtSort(:,b)=txt(STiSortInd(:,b),1);
end

%% Plot results for fval (Impact on technology types)

% Font sizes [Title x-/y-Labels Legend Axes]
FT=[12 12 12 12];

figsize=[10 49 1800 950]; % [left lower width height]
figure (1);
set(gcf,'position',figsize)
bar([STiSort(1:par,bioprodplot) SiSort(1:par,bioprodplot)]);
ylabel('Sobol index','FontSize',FT(2));
ax=gca;
ax.FontSize=FT(4);
ax.XTick = 1:par;
ax.XTickLabel=txtSort(1:par,bioprodplot);
ax.XTickLabelRotation = 45;
legend({'Total effect ST_{i}' 'Main effect S_{i}'},'Location','East','FontSize',FT(3));


