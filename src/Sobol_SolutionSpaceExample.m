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

% With this script a solution space can be plotted based on the results of
% the Sobol analysis and earlier calculated model output. In this script
% exemplary results from a publication are shown: https://doi.org/10.1016/j.apenergy.2020.114534

clearvars

%% load data

% load model sets
 load('Sets.mat')
 load('TechData.mat')


%% load the pre-calculated optimization data, in which the power and gas price was varied

load('Sobol_Solution_Space_PowerGas2.mat') % Original data from publication: https://doi.org/10.1016/j.apenergy.2020.114534

%% Setting and data for plot

% Figure size
figsize=[10 49 1901 1069];

% Font sizes [Title x-/y-Labels Legend Axes]
FT=[12 12 12 10];

load('SetList.mat');

% load legend
legtech=SetList.textdata.SetList(2:tech+1,2);

% load colors
coltech=SetList.textdata.SetList(2:tech+1,36);
for i=1:tech
    coltech{i}=str2num(coltech{i})/255; %#ok<ST2NM>
end

%% Solution space for the .mat file

% competitive bioenergy technologies, which are plotted
BioTech = [2 11 16 19 22 28 29 33 45]; 

% Calculate the biomass share of the technology concepts
for k=1:4
    for i=1:tech-1
        for j=1:market
            vSolidBio{k}(:,i,j)=vall{k}(:,i,j)*TP(8,i,j);
        end
    end
end

% plot
figure (1);
set(gcf,'position',figsize)
for k=1:4
    subplot(2,2,k);
    hold on
    h=area(squeeze(sum(vSolidBio{k}(:,BioTech,:),3))/1000000);
    for i = 1:length(BioTech)
             h(i).FaceColor=coltech{BioTech(i)};
    end
    xlim([0.9 time+0.1])
    ylim([0 750])
    ax=gca;
    ax.YTick = [0:200:600];
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
        ylabel('Min','FontSize',FT(2));
        title('Min','FontSize',FT(2));
        legend([h(end:-1:1)],{legtech{BioTech(end:-1:1)}},'Location','southeast','FontSize',FT(3));
        text(3, 600, {'88% GHG','reduction'},'FontSize',FT(2)); 
    end
    if k==2
        title('Max','FontSize',FT(2))
        text(27, 600, {'80% GHG','reduction'},'FontSize',FT(2)); 
    end
    if k==3
        ylabel('Max','FontSize',FT(2));
        text(3, 600, {'88% GHG','reduction'},'FontSize',FT(2)); 
    end
    if k==4
        text(27, 600, {'95% GHG','reduction'},'FontSize',FT(2)); 
    end
    hold off
    
end

h2=suplabel('Power price','t');
set(h2,'FontSize',FT(2))

supAxes = [.11 .08 .84 .84];
h1=suplabel('Gas price','y',supAxes);
set(h1,'FontSize',FT(2))

% Titel not "Bold"
set(findall(gcf, 'Type', 'Text'),'FontWeight', 'Normal')

axall = get(gcf,'children');
ind = find(isgraphics(axall,'Legend'));
set(gcf,'children',axall([ind:end,1:ind-1]))

