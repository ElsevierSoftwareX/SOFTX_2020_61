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

% This script shows some exemplary scatter plots for analyses based on the Sobol Indices

clear all

% load data
load('SobolC_45Par_1000Sets.mat')
%load('20191209_SensitivityResults_noGHGTarget_32Par.mat')
load('SensitivityResults.mat')
[~,~,legPR] = xlsread('Sobol_ParameterRange.xlsx','ParameterRange','A2:A46');

load('Sets.mat')
load('TechData.mat');
load('SetList.mat')
legbioprod=SetList.textdata.SetList(2:bioprod+1,23);

% Sets
% Number of Parameters
par=45;
% Number of types for sets
typeset = par+2;
%Number of sets
sets = 1000;

% Year which is shown in the plot
year=16;


% Calculate GHG reduction compared to 1990 in %
GHGP=(1-GHGT./448900000)*100;

% The sum of all biomass consumed
BCall=BC1+BC2+BC3;


%% Scatter plots for power price and CO2 price
figure (1);
figsize=[10 49 1800 900]; % [left lower width height]
set(gcf,'position',figsize)
        
    % subplot CO2 price
    subplot(1,3,1)
    %Cmat2=Cmat{1}(:,40);
    for k=1:typeset
        %scatter(Cmat{k}(:,42),GHGP(k,:,year),1,'k')
        scatter(Cmat{k}(:,6),sum(BCall(k,:,1:23),3),1,'k')
        %Cmat2=[Cmat2 Cmat{k}(:,40)];
        hold on
    end
    ax1=gca;
    %lsline(ax1)
    ax1.XTick = [0 0.05];
    ax1.XTickLabel= [{'min' 'max'}];
    xlabel('Increase biomass price','FontSize',12);
    ylabel(['Biomass consumed 2015-2050 '],'FontSize',12);
    ax1=gca;
    ax1.FontSize=12;
    hold off

    % subplot power price
    subplot(1,3,2)
    for k=1:typeset
        %scatter(Cmat{k}(:,44),GHGP(k,:,year),1,'k')
        scatter(Cmat{k}(:,38),sum(BCall(k,:,1:23),3),1,'k')
        hold on
    end
    %lsline
    ax2=gca;
    ax2.XTick = [0 1];
    ax2.XTickLabel= [{'min' 'max'}];
    xlabel('BioPrice Digest','FontSize',12);
    ylabel(['Biomass consumed 2015-2050 '],'FontSize',12);
    ax2=gca;
    ax2.FontSize=12;
    hold off
    
    % subplot gas price
    subplot(1,3,3)
    for k=1:typeset
        %scatter(Cmat{k}(:,44),GHGP(k,:,year),1,'k')
        scatter(Cmat{k}(:,30),sum(BCall(k,:,1:23),3),1,'k')
        hold on
    end
    %lsline
    ax3=gca;
    ax3.XTick = [0 1];
    ax3.XTickLabel= [{'min' 'max'}];
    xlabel('Biomass Pre-allocation','FontSize',12);
    ylabel(['Biomass consumed 2015-2050 '],'FontSize',12);
    ax3=gca;
    ax3.FontSize=12;
    hold off
   
    
    
%% Scatter plot for "Increase of biomas price" on biomass market shares

figure (2);
figsize=[10 49 400 400]; % [left lower width height]
set(gcf,'position',figsize)
    xv=Cmat{1}(:,6);
    yv=sum(BCall(1,:,1:23),3);
    for k=2:typeset
        %scatter(Cmat{k}(:,6),sum(BCall(k,:,1:23),3),1,'k')
        xv=[xv; Cmat{k}(:,6)];
        yv=[yv sum(BCall(k,:,1:23),3)];
        hold on
    end

    scatter(xv,yv*10^-9,1,'k')
    
    ax1=gca;
    h=lsline(ax1);
    set(h,'LineWidth',1,'color','r')
    ax1.XTick = [0 0.01 0.02 0.03 0.04 0.05];
    ax1.XTickLabel= [{'0' '1' '2' '3' '4' '5'}];
    xlabel('Increase biomass price in %/a','FontSize',12);
    ylabel(['Biomass consumed 2015-2050 in EJ'],'FontSize',12);
    ax1=gca;
    ax1.FontSize=12;
    hold off    
    
    
%% Scatter plot for "Increase of biomas price" on GHG reduction in 2030

figure (3);
figsize=[10 49 400 400]; % [left lower width height]
set(gcf,'position',figsize)
    xv=Cmat{1}(:,6);
    yv=GHGP(1,:,year);
    for k=2:typeset
        %scatter(Cmat{k}(:,6),GHGP(k,:,year),1,'k')
        xv=[xv; Cmat{k}(:,6)];
        yv=[yv GHGP(k,:,year)];
        hold on
    end

    scatter(xv,yv,1,'k')
    
    ax1=gca;
    h=lsline(ax1);
    set(h,'LineWidth',1,'color','r')
    ax1.XTick = [0 0.01 0.02 0.03 0.04 0.05];
    ax1.XTickLabel= [{'0' '1' '2' '3' '4' '5'}];
    xlabel('Increase biomass price in %/a','FontSize',12);
    ylabel(['GHG reduction in 2030 compared to 1990 in %'],'FontSize',12);
    ax1=gca;
    ax1.FontSize=12;
    hold off    

    
%% Scatter plot for "Behavior" on log wood market shares

BCall=BC1+BC2+BC3;
figure (4);
figsize=[10 49 800 800]; % [left lower width height]
set(gcf,'position',figsize)
    xv=Cmat{1}(:,43);
    yv=sum(BCall(1,:,7),3);
    for k=2:typeset
        %scatter(Cmat{k}(:,6),sum(BCall(k,:,1:23),3),1,'k')
        xv=[xv; Cmat{k}(:,43)];
        yv=[yv sum(BCall(k,:,7),3)];
        hold on
    end

    scatter(xv,yv*10^-9,1,'k')
    
    ax1=gca;

    ax1.XTick = [0 1];
    ax1.XTickLabel= [{'off' 'on'}];
    xlabel('Consumer behavior','FontSize',12);
    ylabel(['Log wood consumed 2015-2050 in EJ'],'FontSize',12);
    ax1=gca;
    ax1.FontSize=12;
    hold off    
    
   