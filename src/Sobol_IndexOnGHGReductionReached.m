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

% With this script the Sobol indices for the green house gas reduction reached can be plotted

clearvars;

%load data
load('Sets.mat')
load('TechData.mat');
load('SetList.mat')


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


% Determine number of infeasible runs
NumInfFval=0;
for ts=1:typeset
    for s=1:sets
    NumInfFval=NumInfFval+sum(sum(sum(isnan(V1(ts,s)))));
    end
end
NumInfFval


%% Calculate Sobol on GHG reduction reached

% Define the model output on which the Sobol indices are applied
fval=GHGT;

Si = zeros(par,1); % Sobol Main effect
STi = zeros(par,1); % Sobol Total effect

% define on which year Sobol is applied
i=36; % 16=2030 ; 36=2050


% Calculate the variances
VA1=nanvar([fval(par+1,:,i) fval(par+2,:,i)]); % Varianz von A & B
VA2=nanvar(fval(par+1,:,i)); % Varianz von A

% calculate the sum of the formula for Si
sumi = cell(par,1);
for sm=1:par
    for s=1:sets
        sumi{sm}(s)=fval(par+2,s,i)*(fval(sm,s,i)-fval(par+1,s,i));
    end
end

% Calculate Si
for sm=1:par
    Si(sm)=(1/VA1)*(1/sets)*nansum(sumi{sm});
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
    STi(sm)=(1/VA2)*(1/(2*sets))*nansum(sumTi{sm});
end

% Sort the indices
[STiSort,STiSortInd] = sort(STi,'descend');
SiSort=Si(STiSortInd,1);
txtSort=txt(STiSortInd,1);

    
%% Plot results for fval (Impact on GHG emissions reached)

% Font sizes [Title x-/y-Labels Legend Axes]
FT=[18 16 16 14];

figsize=[10 49 1800 950]; % [left lower width height]
figure (1);
set(gcf,'position',figsize)
bar([STiSort(1:par,1) SiSort(1:par,1)]);
title('Sobol index on GHG reduction reached','FontSize',FT(1));
ylabel('Sobol index','FontSize',FT(2));
ax=gca;
ax.FontSize=FT(4);
ax.XTick = 1:par;
ax.XTickLabel=txtSort(1:par,1);
ax.XTickLabelRotation = 45;
legend({'Total effect ST_{i}' 'Main effect S_{i}'},'Location','East','FontSize',FT(3));

