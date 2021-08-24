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

% This script sets the greenhouse gas reduction target based on the data
% collected in "ScenarioData_GHGTarget.xlsx"

clearvars;

% import ghg measured and target data for support years
ghgin = xlsread('ScenarioData_GHGTarget.xlsx');

% interpolate for energy based emissions 80% scenario
ghgte80l = interp1(ghgin(:,1),ghgin(:,2),1990:1:2050,'linear');

% interpolate for energy based emissions 95% scenario
ghgte95l = interp1(ghgin(:,3),ghgin(:,4),1990:1:2050,'linear');

% interpolate for total emissions 80% scenario
ghgtt80l = interp1(ghgin(1:23,5),ghgin(1:23,6),1990:1:2050,'linear');

% interpolate for total emissions 95% scenario
ghgtt95l = interp1(ghgin(1:23,7),ghgin(1:23,8),1990:1:2050,'linear');

% interpolate for heat based emissions 80% scenario
ghgth80l = interp1(ghgin(1:6,9),ghgin(1:6,10),1990:1:2050,'linear');

% interpolate for heat based emissions 95% scenario
ghgth95l = interp1(ghgin(1:6,11),ghgin(1:6,12),1990:1:2050,'linear');

% interpolate for ÖI based emissions 80% scenario
ghgto80l = interp1(ghgin(1:5,13),ghgin(1:5,14),1990:1:2050,'linear');

% interpolate for ÖI based emissions 95% scenario
ghgto95l = interp1(ghgin(1:5,15),ghgin(1:5,16),1990:1:2050,'linear');

% interpolate for building emissions 80% scenario
ghgtb80l = interp1(ghgin(1:6,21),ghgin(1:6,22),1990:1:2050,'linear');

% interpolate for building emissions 95% scenario
ghgtb95l = interp1(ghgin(1:6,23),ghgin(1:6,24),1990:1:2050,'linear');

% interpolate for Industry emissions 80% scenario
ghgti80l = interp1(ghgin(1:7,25),ghgin(1:7,26),1990:1:2050,'linear');

% interpolate for Industry emissions 95% scenario
ghgti95l = interp1(ghgin(1:7,27),ghgin(1:7,28),1990:1:2050,'linear');

% interpolate for heat based emissions 100% scenario
ghgth100 = interp1(ghgin(1:7,29),ghgin(1:7,30),1990:1:2050,'linear');

% interpolate for heat based emissions 95% in 2045 scenario
ghgth95_2045 = interp1(ghgin(1:7,31),ghgin(1:7,32),1990:1:2050,'linear');

% Calculation of GHG reduction compared to prervious year
ghgrede80l=zeros(1,61);
ghgrede95l=zeros(1,61);
ghgredt80l=zeros(1,61);
ghgredt95l=zeros(1,61);
ghgredh80l=zeros(1,61);
ghgredh95l=zeros(1,61);
ghgredo80l=zeros(1,61);
ghgredo95l=zeros(1,61);
ghgredh100=zeros(1,61);
ghgredh95_2045=zeros(1,61);
for t=2:61
    ghgrede80l(t)=1-ghgte80l(t)/ghgte80l(t-1);
    ghgrede95l(t)=1-ghgte95l(t)/ghgte95l(t-1);
    ghgredt80l(t)=1-ghgtt80l(t)/ghgtt80l(t-1);
    ghgredt95l(t)=1-ghgtt95l(t)/ghgtt95l(t-1);
    ghgredh80l(t)=1-ghgth80l(t)/ghgth80l(t-1);
    ghgredh95l(t)=1-ghgth95l(t)/ghgth95l(t-1);
    ghgredo80l(t)=1-ghgto80l(t)/ghgto80l(t-1);
    ghgredo95l(t)=1-ghgto95l(t)/ghgto95l(t-1);
    ghgredh100(t)=1-ghgth100(t)/ghgth100(t-1);
    ghgredh95_2045(t)=1-ghgth95_2045(t)/ghgth95_2045(t-1);
end

% Replace Nan by zero
ghgredh100(isnan(ghgredh100))=0;

% Calculation of percentage compared to 1990
ghg90e80l=zeros(1,61);
ghg90e95l=zeros(1,61);
ghg90t80l=zeros(1,61);
ghg90t95l=zeros(1,61);
ghg90h80l=zeros(1,61);
ghg90h95l=zeros(1,61);
ghg90o80l=zeros(1,61);
ghg90o95l=zeros(1,61);
for t=1:61
    ghg90e80l(t)=100*(1-ghgte80l(t)/ghgte80l(1));
    ghg90e95l(t)=100*(1-ghgte95l(t)/ghgte95l(1));
    ghg90t80l(t)=100*(1-ghgtt80l(t)/ghgtt80l(1));
    ghg90t95l(t)=100*(1-ghgtt95l(t)/ghgtt95l(1));
    ghg90h80l(t)=100*(1-ghgth80l(t)/ghgth80l(1));
    ghg90h95l(t)=100*(1-ghgth95l(t)/ghgth95l(1));
    ghg90o80l(t)=100*(1-ghgto80l(t)/ghgto80l(1));
    ghg90o95l(t)=100*(1-ghgto95l(t)/ghgto95l(1));
end


 % Save vector for model
  ghg80=ghgredh80l(31:61);
  save('ScenarioData.mat','ghg80','-append');
  ghg95=ghgredh95l(31:61);
  save('ScenarioData.mat','ghg95','-append');
  ghg100=ghgredh100(31:61);
  save('ScenarioData.mat','ghg100','-append');
  ghg95_2045=ghgredh95_2045(31:61);
  save('ScenarioData.mat','ghg95_2045','-append');

% Plot GHG Emission comparison
figure (1);
hold on
p1=plot(ghgtt80l,'b--o','color','red');
plot(ghgtt95l,'b--o','color','red')
p2=plot(ghgte80l,'color','blue');
plot(ghgte95l,'color','blue')
p3=plot(ghgth80l,'color','red');
plot(ghgth95l,'--','color','red')
p4=plot(ghgto80l,'color','green');
plot(ghgto95l,'--','color','green')
% p1.LineWidth=2;
% p2.LineWidth=2;
% p3.LineWidth=2;
% p4.LineWidth=2;
ax=gca;
ax.XTick = 1:5:61;
ax.XTickLabel=1990:5:2050;
ax.FontSize=12;
xlim([0 62])
title('GHG emission / target derived from "Energiekonzept" and "Klimaschutzplan" in comparison to ÖI','FontSize',16);
xlabel('Time [a]','FontSize',14);
ylabel('Emission [Mio t CO2 äqiv.]','FontSize',14);
l=legend('Total emission 80%','Total emission 95%','Energy based emission 80%','Energy based emission 95%','Heat based emission 80%','Heat based emission 95%','Heat based emission (ÖI) 80%','Heat based emission (ÖI) 95%','Location','northeast');
l.FontSize=14;
hold off

% Plot GHG Emission just heat
figure (2);
hold on
p3=plot(ghgth80l,'color','red');
plot(ghgth95l,'--','color','red')
p4=plot(ghgto80l,'color','green');
plot(ghgto95l,'--','color','green')
% p1.LineWidth=2;
% p2.LineWidth=2;
% p3.LineWidth=2;
% p4.LineWidth=2;
ax=gca;
ax.XTick = 1:5:61;
ax.XTickLabel=1990:5:2050;
ax.FontSize=12;
xlim([0 62])
title('Heat based emission / target derived from "Energiekonzept" and "Klimaschutzplan" in comparison to ÖI','FontSize',16);
xlabel('Time [a]','FontSize',14);
ylabel('Emission [Mio t CO2 äqiv.]','FontSize',14);
l=legend('Heat based emissionen 80%','Heat based emission 95%','Heat based emission (ÖI) 80%','Heat based emission (ÖI) 95%','Location','northeast');
l.FontSize=14;
hold off

% Plot GHG Emission industry and buildings
figure (3);
hold on
p1=plot(ghgtb80l,'color','blue');
plot(ghgtb95l,'--','color','blue')
p2=plot(ghgti80l,'color','red');
plot(ghgti95l,'--','color','red')
% p1.LineWidth=2;
% p2.LineWidth=2;
% p3.LineWidth=2;
% p4.LineWidth=2;
ax=gca;
ax.XTick = 1:5:61;
ax.XTickLabel=1990:5:2050;
ax.FontSize=12;
xlim([0 62])
title('Heat based emissions in buildings and industry','FontSize',16);
xlabel('Time [a]','FontSize',14);
ylabel('Emission [Mio t CO2 äqiv.]','FontSize',14);
l=legend('Buildings emission 80%','Buildings emission 95%','Industry emission 80%','Industry emission 95%', 'Location','northeast');
l.FontSize=14;
hold off

% Plot GHG emission compared to previos year
figure (4);
hold on
%yyaxis right
%plot(ghg90e80l)
%plot(ghg90e95l)
%plot(ghg90t80l)
%plot(ghg90t95l)
p5=plot(ghg90h80l,'color','red');
plot(ghg90h95l,'--','color','red')
p6=plot(ghg90o80l,'color','green');
plot(ghg90o95l,'--','color','green')
% p5.LineWidth=1;
% p6.LineWidth=1;
ax=gca;
ax.YAxisLocation = 'right';
ax.XTick = 1:5:61;
ax.XTickLabel=1990:5:2050;
ax.FontSize=12;
xlim([0 62])
title('Heat based reduction compared to 1990','FontSize',16);
xlabel('Time [a]','FontSize',14);
ylabel('Emission reduction compared to 1990 [%]','FontSize',14);
l=legend('Heat based emission 80%','Heat based emission 95%','Heat based emission (ÖI) 80%','Heat based emission (ÖI) 95%','Location','northwest');
l.FontSize=14;
hold off
