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

% This script is required to generate the latin hypercube sampling for the
% random value estimate for the sensitivity analysis
% This script requires the statistics toolbox

clear all;

par=45; % parameters varied in the analysis
sets=1000; % number of sets

% latin hypercube sample (Sets,2*X parameter)
lhs = lhsdesign(sets,2*par);

% Create Matrix A and B for the Sobol calculation
A=lhs(:,1:par);
B=lhs(:,par+1:2*par);

% save
save('latinhypercube45para1000sets.mat','A','B');

