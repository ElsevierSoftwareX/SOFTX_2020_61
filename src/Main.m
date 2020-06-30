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

function[]=Main(target,Heatdemand,residues,crop,biouse,BioPriceInc,CO2,power,sc,InvSub,KWKG,EEGUml,EEGUmlRed,PrivPowerInd,InvBeh,...
    fig1,fig2,fig3,fig4,fig5,fig6,fig7,fig8,fig9,fig10,fig11,fig12,fig13,fig14,fig15,figBeh,...
    CapTech,nMarket,nMarketOp,saveval,language)

% add the path of the GAMS installation. Example:
%addpath 'C:\PROGRAMS\GAMS';

% There exists one tradeoff in the GAMS nfct: Modules are deleted after
% reaching the lifetime of the module. When the base modul of house A
% expires e.g. the storage of pellet burner lives on. If house A replaces its heating system with the same
% technology, the storage can be used without new investment (good case). If house A
% picks another technology and house B builds a new pellet burner, it uses
% the storage of house A, without new investment (bad case).

% When changing biomass values in the starting year: Maybe a run without GHG
% target needs to be done to prevent infeasibility

% When using msg server
%addpath 'Y:\Home\martinm\GAMS';

tic
disp('Pre-calculations started');

%% Define Sets

load('SetList.mat');
time = 36;  % t
tech = find(cellfun(@isempty,SetList.textdata.SetList(:,1))==1,1)-2; % i
techtype = find(cellfun(@isempty,SetList.textdata.SetList(:,9))==1,1)-2;  % tt
modul = find(cellfun(@isempty,SetList.textdata.SetList(:,5))==1,1)-2;  % m 
market = find(cellfun(@isempty,SetList.textdata.SetList(:,13))==1,1)-2; % j  refers to the sub-sectors, described in the publications
cluster=3;  %c
biotype = find(cellfun(@isempty,SetList.textdata.SetList(:,18))==1,1)-2; % bt 
bioprod = find(cellfun(@isempty,SetList.textdata.SetList(:,22))==1,1)-2; % b 
GHGtechtype = find(cellfun(@isempty,SetList.textdata.SetList(:,27))==1,1)-2; % gtt 

% Reforming for GAMS communication
tims= strsplit(num2str(1:time));
techs= strsplit(num2str(1:tech));
techtyps= strsplit(num2str(1:techtype));
moduls = strsplit(num2str(1:modul));
markets = strsplit(num2str(1:market));
clusters= strsplit(num2str(1:cluster));
biotypes = strsplit(num2str(1:biotype));
bioprods = strsplit(num2str(1:bioprod));

% Prepare to send sets

T.name = 't';
T.type='set';
T.uels = {tims};

I.name = 'i';
I.type='set';
I.uels = {techs};

M.name = 'm';
M.type='set';
M.uels = {moduls};

J.name = 'j';
J.type='set';
J.uels = {markets};

C.name = 'c';
C.type='set';
C.uels = {clusters};

BM.name = 'bm';
BM.type='set';
BM.uels = {biotypes};

B.name = 'b';
B.type='set';
B.uels = {bioprods};

%% dependencies between the sets

% Definition of which technologies are used on which markets
techmarket=SetList.data.Tech2Market(3:end,3:end);
techmarket(isnan(techmarket))=0;

MT=cell(1,12);
for j=1:market
    MT{j}=transpose(find(techmarket(:,j)==1));
end

mt.uels = {techs,markets};
mt.name = 'MT';
mt.type='set';
mt.form='full';
mt.val=techmarket;

% Definition of which modules are used in which technologies
modultech=SetList.data.Module2Tech(3:end,3:end);

TM=cell(1,22);
for i=1:tech
    TM{i}=find(modultech(:,i)==1);
end

% Definition of which biomass products go into which technologies
bioprodtech=SetList.data.BioProduct2Tech(3:end,3:end);
bioprodtech(isnan(bioprodtech))=0;

TB=cell(1,22);
for i=1:tech
    TB{i}=transpose(find(bioprodtech(:,i)==1));
end

tb.uels = {techs,bioprods};
tb.name = 'TB';
tb.type='set';
tb.form='full';
tb.val=bioprodtech';

%Definition of which biomass types go into which biomass products
biotypebioprod=SetList.data.BioType2BioProduct(3:end,3:end);
biotypebioprod(isnan(biotypebioprod))=0;

BB=cell(1,biotype);
for bm=1:biotype
    BB{bm}=transpose(find(biotypebioprod(:,bm)==1));
end

bb.uels = {biotypes,bioprods};
bb.name = 'BB';
bb.type='set';
bb.form='full';
bb.val=biotypebioprod;

% Defintion of which GHGtechtypes go into which technologies
GHGTechType2Tech = SetList.textdata.GHGTechType2Tech(2:end,2:end);

%% save sets and dependencies for later processes (Sensitivity)
save('Sets.mat','time','tech','techtype','modul','market','cluster','biotype','bioprod','GHGtechtype',...
    'tims','techs','moduls','markets','clusters','biotypes','bioprods','techmarket',...
    'T','I','J','C','M','BM','B','MT','TB','TM','BB','mt','tb','bb','GHGTechType2Tech');

%% call function Set Parameter 
Sen=0; %placeholder when no sensitivity is done
[d,dcap,vc,inv,pmBio,pmGas,pm3,efBio,efGas,efMethan,life,ba,bamaxw,bamaxc,nstart,nsdec,yield,culstart,ghgr,ghgfeed,alloc,ghgmax,...
    TP,PowerPrice,GasPrice,CoalPrice,ghgtarget,COCert,BP,dBeh,vcBeh,invBeh]=...
    SetParameter(target,Heatdemand,residues,crop,biouse,BioPriceInc,CO2,power,sc,InvSub,KWKG,EEGUml,EEGUmlRed,PrivPowerInd,InvBeh,...
    time,tech,modul,market,cluster,biotype,bioprod,...
    tims,techs,moduls,markets,clusters,biotypes,bioprods,techmarket,GHGTechType2Tech,Sen); %#ok<ASGLU>

% Check, if capacity in the first year is fulfilled
for j=1:market
    if d.val(1,j)-sum(nstart.val(:,j))*dcap.val(1,j) > 10^-11
        j  
        d.val(1,j) - sum(nstart.val(:,j))*dcap.val(1,j) 
        warning('Capacity for starting year is not fulfilled');
    end
end
toc


%% Transfer paramter to GAMS and receive optimization results
tic
disp('Optimization started');

gamso.output = 'std';
gamso.form = 'full';
gamso.compress = true;
stat=gams('OptimizationModule',T,I,M,J,C,BM,B,tb,mt,bb,d,dcap,vc,inv,pmBio,pmGas,pm3,efBio,efGas,efMethan,life,ba,bamaxw,bamaxc,nstart,nsdec,yield,culstart,ghgr,ghgfeed,alloc,ghgmax,dBeh,vcBeh,invBeh);
toc

%Test if problem is infeasible
if stat(1,1)~=1 || stat(2,1)~=1
    error('Problem infeasible!')
end

% Reading indexed results from idxdata.gdx
irgdx('idxdata')

% Renaming
v=vp;
vBio=vBiop; %#ok<*NASGU>
vGas=vGasp;
v3=v3p;
bu=bup;
bc=bcp;
ghgf=ghgfp;
ghgt=ghgtp;
ncap=ncapp;
ncap1=ncap1p;
ncap2=ncap2p;
next=nextp;
nprod=nprodp;
nxdec=nxdecp;
vBeh=vBehp;
tc=tcp;

clear vp vBiop vGasp v3p bup bcp ncapp ncap1p ncap2p nextp nprodp nxdecp tcp ghgfp ghgtp vBehp


% Display total costs in trillion EUR
disp(['Total costs (Trillion €): ' num2str(tc/1000000000000)]);

%% Save data

% save sets, input and output data from GAMS in mat file (Sets, input data, results)
if saveval==1
    
    dt=char(datetime('now','Format','yyyy-MM-dd HH-mm-ss'));
    save(['Results/' dt '.mat'],...
        'time','tech','techtype','modul','market','biotype','bioprod','MT','TB','TM','BB',...
        'd','dcap','vc','inv','pmBio','pmGas','pm3','efBio','efGas','efMethan','life','ba','bamaxw','bamaxc','nstart','nsdec','ghgmax','yield','PowerPrice','GasPrice','CoalPrice','COCert','TP',...
        'v','vBio','vGas','v3','bu','bc','ghgf','ghgt','ncap','ncap1','ncap2','next','nprod','nxdec','BP','vBeh');
end

% save data temporarily for plot (Sets, input data, results)
save('Results/Temp.mat',...
   'time','tech','techtype','modul','market','biotype','bioprod','MT','TB','TM','BB',...
   'd','dcap','vc','inv','pmBio','pmGas','pm3','efBio','efGas','efMethan','life','ba','bamaxw','bamaxc','nstart','nsdec','ghgmax','yield','PowerPrice','GasPrice','CoalPrice','COCert','TP',...
   'v','vBio','vGas','v3','bu','bc','ghgf','ghgt','ncap','ncap1','ncap2','next','nprod','nxdec','BP','vBeh');

FileName='Temp.mat';
PathName='Results/';


%% Call function for plot

Plotting(FileName,PathName,fig1,fig2,fig3,fig4,fig5,fig6,fig7,fig8,fig9,fig10,fig11,fig12,fig13,fig14,fig15,figBeh,CapTech,nMarket,nMarketOp,language)
end

