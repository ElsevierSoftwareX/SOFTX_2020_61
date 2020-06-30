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

% This script is used to generate the .gms files required for parallel
% computing of the sensitivity analysis (Sobol_Main.m)

par=45; %Number of parameters varied in the sensitivity analysis

for s=1:par+2
    % open and copy gams file
    copyfile('OptimizationModule.gms',['OptimizationModule' num2str(s) '.gms'])
    fid  = fopen('OptimizationModule.gms','r');
    f=fread(fid,'*char')';
    fclose(fid);
    % Replace required strings in the file
    f = strrep(f,'matsol.gdx',['matsol' num2str(s) '.gdx']);
    f = strrep(f,'matdata.gdx',['matdata' num2str(s) '.gdx']);
    f = strrep(f,'idxdata',['idxdata' num2str(s)]);
    % Write and close file
    fid  = fopen(['OptimizationModule' num2str(s) '.gms'],'w');
    fprintf(fid,'%s',f);
    fclose(fid);
end

