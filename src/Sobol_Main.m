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

% With this script the Sobol' anysis can be applied on the model

% Telling GAMS which GDX file to use within the command line is not possible
% So 32 GAMS model files and 32 gdx files are required

clearvars
% When using msg server
addpath 'Y:\Home\martinm\GAMS';

% this command closes the pool
%delete(gcp('nocreate'))

% define sensitivity sets
par=45;
typeset = par+2;
set = 1000;

% create pool
%poolobj = parpool('local',typeset);

% load model sets
load('Sets.mat')

% define target,crop,biouse,sc,etc.
target = 'No target';
Heatdemand='SC5';
residues=5;
crop=5;
biouse=5;
BioPriceInc=5;
CO2=5;
power=5;
sc=5;
InvSub=5;
KWKG=5;
EEGUml=5;
EEGUmlRed=0;
PrivPowerInd=5;
InvBeh=5;


%% Gather data for Sensitivity Analysis

%Import Latin Hypercube Samples
lhsimport=importdata('SobolLatinhypercube45para1000sets.mat');
Amat=lhsimport.A;
Bmat=lhsimport.B;

% load parameter range data
PR = xlsread('Sobol_ParameterRange.xlsx','ParameterRange','C2:E46');

% rescaling the latin hypercube samples
for k=6:29
    Amat(:,k)=Amat(:,k)*(PR(k,3)-PR(k,1))+PR(k,1);
    Bmat(:,k)=Bmat(:,k)*(PR(k,3)-PR(k,1))+PR(k,1);
end

% rescaling for CO2 price
Amat(:,4)=round(Amat(:,4)*(set-1)+1);
Bmat(:,4)=round(Bmat(:,4)*(set-1)+1);
% rescaling for power price
Amat(:,1)=round(Amat(:,1)*(set-1)+1);
Bmat(:,1)=round(Bmat(:,1)*(set-1)+1);

% Creating Matrices Ci{typeset}(sets,par) % Cmat = AB Matrix + A + B
Cmat = cell(typeset,1);
Cmat{1}=[Bmat(:,1) Amat(:,2:par)];
for k=2:(par-1)
    Cmat{k}=[Amat(:,1:k-1) Bmat(:,k) Amat(:,k+1:par)];
end
Cmat{par}=[Amat(:,1:par-1) Bmat(:,par)];
Cmat{par+1}=Amat;
Cmat{par+2}=Bmat;

save('SobolC_45Par_1000Sets.mat','Cmat')

%clear A B lhsimport PR sheets

%%

% Peallocate result variables
SaveCounter=1;
for s=1:set
    tic
    % set parameter
    parfor type = 1:typeset
        
        % Define Sensitivity factor for all parameters
        Sen=Cmat{type}(s,1:par);
        
        % Call funtion set parameter      
        [d,dcap,vc,inv,pmBio,pmGas,pm3,efBio,efGas,efMethan,life,ba,bamaxw,bamaxc,nstart,nsdec,yield,culstart,ghgr,ghgfeed,alloc,ghgmax,...
        TP,PowerPrice,GasPrice,CoalPrice,ghgtarget,COCert,BP,dBeh,vcBeh,invBeh]=...
        SetParameter(target,Heatdemand,residues,crop,biouse,BioPriceInc,CO2,power,sc,InvSub,KWKG,EEGUml,EEGUmlRed,PrivPowerInd,InvBeh,...
        time,tech,modul,market,cluster,biotype,bioprod,tims,techs,moduls,markets,clusters,biotypes,bioprods,techmarket,GHGTechType2Tech,Sen);
        
        % Write parameters in matdata.gdx file
        wgdx(['matdata' num2str(type) '.gdx'],T,I,M,J,C,BM,B,tb,mt,bb,d,dcap,vc,inv,pmBio,pmGas,pm3,efBio,efGas,efMethan,life...
            ,ba,bamaxw,bamaxc,nstart,nsdec,yield,culstart,ghgr,ghgfeed,alloc,ghgmax,dBeh,vcBeh,invBeh);
        
        % Saving availabilty of biomass in workspace
        BA=ba.val(:,1:11).*bamaxw.val';
        BA(:,12)=ba.val(:,12).*bamaxc.val';
        BA1(type,s,:)=squeeze(sum(BA(1:16,:),1));
        BA2(type,s,:)=squeeze(sum(BA(17:26,:),1));
        BA3(type,s,:)=squeeze(sum(BA(27:36,:),1));
        
    end
    toc
    
    tic
    % run GAMS parallel
    parfor type = 1:typeset
        system(['start Y:\Home\martinm\GAMS\gams OptimizationModule' num2str(type)]); 
        % wait for GAMS to end by waiting for gdx to be created 
    end
    toc
    
    % continue, when idxdata was saved
    tic
    for type = 1:typeset
        while exist(['idxdata' num2str(type) '.gdx'],'file')==0
            pause(1)
        end 
    end
    toc

    tic
    % Reading results and delete .gdx
    for type=1:typeset
        % Reading indexed results from idxdata.gdx
        % If reading error occurs, wait and try again
        w=1;
        while w==1
            try
                irgdx(['idxdata' num2str(type)])
                w=0;
            catch MS
                pause(1)
            end
        end
        
        
        
        % check if solution is infeasible
        if sum(sum(sum(vp,1),2),3)==0 || isempty(find(vp<-0.0001,1))==0
            % saving in workspace
            V1(type,s,:)=NaN;
            V2(type,s,:)=NaN;
            V3(type,s,:)=NaN;
            
            VGAS1(type,s,:)=NaN;
            VGAS2(type,s,:)=NaN;
            VGAS3(type,s,:)=NaN;
            
            BC1(type,s,:)=NaN;
            BC2(type,s,:)=NaN;
            BC3(type,s,:)=NaN;
            
            TC(type,s)=NaN;
            
            GHGT(type,s,:)=NaN;
 
        else
            % Saving in workspace
            V1(type,s,:,:)=squeeze(sum(vp(1:16,:,:),1));
            V2(type,s,:,:)=squeeze(sum(vp(17:26,:,:),1));
            V3(type,s,:,:)=squeeze(sum(vp(27:36,:,:),1));
            
            VGAS1(type,s,:,:)=squeeze(sum(sum(vGasp(1:16,:,:,[21 23]),1),4));
            VGAS2(type,s,:,:)=squeeze(sum(sum(vGasp(17:26,:,:,[21 23]),1),4));
            VGAS3(type,s,:,:)=squeeze(sum(sum(vGasp(27:36,:,:,[21 23]),1),4));
            
            BC1(type,s,:)=squeeze(sum(sum(sum(bcp(1:16,:,:,:),1),2),3));
            BC2(type,s,:)=squeeze(sum(sum(sum(bcp(17:26,:,:,:),1),2),3));
            BC3(type,s,:)=squeeze(sum(sum(sum(bcp(27:36,:,:,:),1),2),3));
            
            TC(type,s)=tcp;
            
            GHGT(type,s,:)=squeeze(sum(sum(sum(ghgfp,2),3),4)+sum(sum(ghgtp,2),3));
            
        end
        %delete .gdx file
        delete(['idxdata' num2str(type) '.gdx'])
    end
    toc
    
    %save in .mat file
    if s/(SaveCounter*25)==1
        %first create .mat file Version 6 or higher
        %save('SensitivityResults.mat','V1','V2','V3','VGAS1','VGAS2','VGAS3','BC1','BC2','BC3','BA1','BA2','BA3','TC','GHGT','-v7')
        % regularly append results to not loose results in case of a crash
        save('SensitivityResults.mat','V1','V2','V3','VGAS1','VGAS2','VGAS3','BC1','BC2','BC3','BA1','BA2','BA3','TC','GHGT','-append')
        SaveCounter=SaveCounter+1;
    end
end




