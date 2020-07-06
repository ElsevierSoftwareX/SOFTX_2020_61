*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*     BENOPT-HEAT - Optimizing bioenergy use in the German heat sector 
*     Copyright (C) 2017 - 2020 Matthias Jordan
* 
*     This program is free software: you can redistribute it and/or modify
*     it under the terms of the GNU General Public License as published by
*     the Free Software Foundation, either version 3 of the License, or
*     (at your option) any later version.
* 
*     This program is distributed in the hope that it will be useful,
*     but WITHOUT ANY WARRANTY; without even the implied warranty of
*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*     GNU General Public License for more details.
* 
*     You should have received a copy of the GNU General Public License
*     along with this program.  If not, see <http://www.gnu.org/licenses/>.
*     contact: matthias.jordan@ufz.de
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

$set matout "'matsol.gdx', returnstat ";

$gdxin matdata.gdx

sets
 stat            Solve status /solvestat,modelstat/

 t               Time
$loadR t
 t2034(t)        Time before 2035 /1*20/

 i               Technologies
$loadR i
 i2034(i)        Technologies that do not use poplar pellets before 2035 /18,19,20/
 ihp(i)          Heat pump technologies /7*12,19,22,27,32,35/

 m               Plantmodules
$loadR m

 j               Markets referring to sub-sectors
$loadR j
 jclus(j)        Markets with sub-clusters /1*5/

 c               Clusters
$loadR c

 bm              Biotype
$loadR bm
 bmwaste(bm)     Biotype residues /1*11/

 b               Bioproduct
$loadR b
 bwaste(b)       Bioproduct residues /1*9/
 bcult(b)        Bioproduct cultivation /10*23/
 bkup(b)         SRC products /12*14/
 bmis(b)         Miscanthus products /15*17/
 bwoodchip(b)    Wood chip products (for waste2energy equation) /1,4,5,12,15/
 bwoodchip2(b)   Wood chip products (for HHSCoal equation) /1,4,5,12/
 bfire(b)        Firewood and briquette products /2,7,13,16/
 bculst(b)       cultivated biomass products that are used in 2015 /10,11,18,19,21*23/
 bScheit(b)      Biomass products used for log wood boiler /2,7,13/
 bGas(b)         Biogas products used for GasTech /8*11,18*24/

 MT(i,j)         Technologies used on markets
$loadR MT

 TB(i,b)         Bioproducts used in technologies
$loadR TB

 BB(bm,b)        Biotypes used in bioproducts
$loadR BB

;

parameters
 vc(t,i,j,b)     Variable costs [:GJ]
 inv(t,i,m,j)    Investment cost per plant []
 pmBio(t,i,j)    biomass share per technology [%]
 pmGas(t,i,j)    gas_coal share per technology [%]
 pm3(t,i,j)      non biomass_gas_coal share per technology [%]
 efBio(t,i,j)    Conversion efficiency solid biomass
 efGas(t,i,j)    Conversion efficiency gas_biogas
 efMethan(t,b)   Conversion efficiency for the "biomethaneinspeiseanlage"
 life(i,m,j)     lifetime of heating system [a]
 ba(t,bm)        Available biomass [GJ and ha]
 bamaxw(t)       Maximal allowed biomass usage from waste ba [%]
 bamaxc(t)       Maximal allowed biomass usage from cultivation ba [%]
 yield(t,b)      Yield of cultivation products [GJ:ha]
 ghgr(t,i,j)     GHG emission per technology [t:GJ]
 ghgfeed(b)      GHG emissions per bioproduct [t:GJ]
 alloc(i,j)      Allocation factor of emissions to heat sector
 ghgmax(t)       GHG emission target [t]
 d(t,j)          Heat demand [GJ]
 dcap(t,j)       Heat demand per house or HS [GJ]
 nstart(i,j)     Initial stock of HS
 nsdec(t,i,m,j)  Yearly decrease of initial stock of HS
 culstart(b)     Crop cultivation portfolio in the first 5 years
 vcBeh(t,i,j,c)  Intangible variable costs [:GJ]
 invBeh(t,i,j,c) Intangible investment costs []
 dBeh(t,j,c)     Demand in the clusters

* definition of parameters for the export (equal the variables)
 vp(t,i,j)        Heat production [GJ]
 vBiop(t,i,j,b)   Solid Biomass heat production [GJ]
 vGasp(t,i,j,b)   gas_biogas_coal heat production [GJ]
 v3p(t,i,j)       Non-Biomass heat production [GJ]
 bup(t,b,bm)      Actual converted biomass from biotype to bioprod [GJ]
 bcp(t,i,j,b)     Actual consumed biomass in the technology [GJ]
 ghgfp(t,i,j,b)   Actual feedstock GHG emissions [t]
 ghgtp(t,i,j)     Actual technology GHG emissions [t]
 nprodp(t,i,j)    Number of HS producing heat
 ncapp(t,i,m,j)   Number of existing HS per technology (Capacity)
 ncap1p(t,i,m,j)  Number of existing HS used for production
 ncap2p(t,i,m,j)  Overcapacity of existing HS
 nextp(t,i,m,j)   Number of heating systems\modules extended
 nxdecp(t,i,m,j)  Number of HS of next that reach their lifetime
 vBehp(t,i,j,c)   Heat production in the clusters [GJ]
 tcp
 returnStat(stat);
;

$loadR d, dcap, vc, inv, pmBio, pmGas, pm3, efBio, efGas, efMethan , life, ba, bamaxw, bamaxc, nstart, nsdec, yield, culstart, ghgr, ghgfeed, alloc, ghgmax, vcBeh, invBeh, dBeh

free variable
 tc              Total costs []
 ghgtot          GHG total emission [t]
;

positive variables
 v(t,i,j)        Heat production [GJ]
 vBio(t,i,j,b)   Solid biomass heat production [GJ]
 vGas(t,i,j,b)   Gas_biogas_coal heat production [GJ]
 v3(t,i,j)       Non-Biomass heat production [GJ]
 bu(t,b,bm)      Actual converted biomass from biotype to bioprod [GJ]
 bc(t,i,j,b)     Actual consumed biomass in the technology [GJ]
 ghgf(t,i,j,b)   Actual feedstock GHG emissions [t]
 ghgt(t,i,j)     Actual technology GHG emissions [t]
 nprod(t,i,j)    Number of HS producing heat
 ncap(t,i,m,j)   Number of existing HS per technology (Capacity)
 ncap1(t,i,m,j)  Number of existing HS used for production
 ncap2(t,i,m,j)  Overcapacity of existing HS
 next(t,i,m,j)   Number of heating systems\modules extended
 ndec(t,i,m,j)   Sum of all HS reductions
 nxdec(t,i,m,j)  Number of HS of next that reach their lifetime
 nprodBeh(t,i,j,c)  Number of HS producing heat in the clusters
 vBeh(t,i,j,c)      Heat production in the clusters [GJ]
;

*fixed values for starting year
ncap2.fx("1",i,m,j)=0;
next.fx("1",i,m,j)=0;
ndec.fx("1",i,m,j)=0;
nxdec.fx("1",i,m,j)=0;

*forbids certain technologies on certain markets
v.fx(t,i,j) $ (not MT(i,j))=0;

*forbids certain technologies to use certain biomass products
bc.fx(t,i,j,b) $ (not TB(i,b))=0;
bc.fx(t2034,i2034,j,"14")=0;

*forbids certain bioproducts to use certain biomass types
bu.fx(t,b,bm) $ (not BB(bm,b))=0;

*number of plants in starting year
ncap1.fx("1",i,m,j)=nstart(i,j);

*sets MllHKW constant
nprod.fx(t,"28","15")=nstart("28","15");

*sets Leach boiler constant
nprod.fx(t,"48","16")=nstart("48","16");

*During the decrease of the initial stock, overcapacity is forbidden; despite in district heating market (i=24) and market 14 in the 95% case
ncap2.fx(t,i,"1",j) $ (ord(t)<=life(i,"1",j)+1 and not ord(i)=24 and not ord(j)=14)=0;

*overcapacity only allowed for gas boiler/coal...
ncap2.fx(t,i,"1",j) $ (not ord(i)=1 and not ord(i)=24  and not ord(i)=25  and not ord(i)=30  and not ord(i)=36 and not ord(i)=40  and not ord(i)=46)=0;

*Sets nxdec=0 before any lifetime reduction of next happens
nxdec.fx(t,i,m,j) $ (ord(t)<=(life(i,m,j)))=0;

equations

totcostfct       Total costs over all years  = Sum of invest + variable total costs  (objective)
totghgfct        GHG total emission (objective)

demandfct        Heat demand per market = sum of heat consumption per market
dcapfct          This equation is supposed to tell that one HS is exactly for one house

nfct             capacity of heating systems in t+1 = capacity in t + next in t+1 - ndec in t+1

ncapfct          Total capacity = capacity used + overcapacity
ncap2fct         Overcapacity = total capacity - production capacity
ncap3fct         HS in overcapacity cannot be reused for production
ncap2ctrl1       Yearly overcapacity is limited to XX%

ndecfct          defines all ndecs
nxdec1fct        Defines nxdec in relation to next

nocfct           allowes number of producing HS to be smaller than number of capacity HS (overcapacity for secondary modules possible) also defines minimum number of all modules
n1fct            Forbids over capacity of modul 1 of ncap1
mbioprodfct      Definition of maximum solid biomass production per technology
mgasprodfct      Definition of maximum gas_biogas_coal production per technology
m3prodfct        Definition of maximum non-biomass production per technology
mprodsumfct      Total heat production = biomass production + non biomass production

bcfct            Consumed biomass = heat consumption divided by degree of efficiency
bcGasScheit      Technology GasBW+ScheitO can use different biomass products for different components. This equation regulates this issue
bcWaste2Energy   Technology MllHKW+HHS-Kessel can use different biomass products for different components. This equation regulates this issue
bcHHSCoal        Technology HHSCoal can use different biomass products for different components. This equation regulates this issue
bamaxwastefct    Consumed biomass of residues is limited to a certain degree of percentage
ba1fct           Which residue biomass types can be used for which biomass products
ba2fct           Limitation of energy crops land potential to biomass products
ba3fct           Which fossil biomass types can be used for which biomass products

bufct            Produced amount biomass products = sum of consumed biomass per technologies

bustart          set portfolio of energy crops in starting years
bustartKup       set portfolio of KUP in starting years
bustartMis       set portfolio of Miscanthus in the starting years
bumax            max increase of energy crops
bumaxKup         max increase of KUP
bumaxMis         max increase of miscanthus

ghgffct          feedstock GHG abatement per technology
ghgtfct          technology GHG abatement per technology
ghgmaxfct        GHG emission target >= yearly total GHG emission _ if ghgmax(1)==0 --> no target is set

vBehfct1         Demand in clusters equals production in clusters        
vBehfct2         Sum of production in clusters equals the production in markets 
nprodBehfct1     Number of HS in clusters * Dcap equals production in clusters
nprodBehfct2     Sum of number of HS in clusters equals the numer of HS in market
;

* Objective function minimizing costs
totcostfct..             tc=e=sum((t,i,j),vc(t,i,j,"1")*v3(t,i,j))+sum((t,i,j,b),vc(t,i,j,b)*vBio(t,i,j,b))+sum((t,i,j,b),vc(t,i,j,b)*vGas(t,i,j,b))+sum((t,i,m,j),ncap(t,i,m,j)*inv(t,i,m,j))+sum((t,i,j,c),vcBeh(t,i,j,c)*vBeh(t,i,j,c))+sum((t,i,j,c),invBeh(t,i,j,c)*nprodBeh(t,i,j,c));

*Alternate Objective funtion minimizing GHG emissions
totghgfct..              ghgtot=e=sum((t,i,j,b),ghgf(t,i,j,b))+sum((t,i,j),ghgt(t,i,j));

* Restrictions
demandfct(t,j)..                                                 d(t,j)=e=sum((i),v(t,i,j));
dcapfct(t,j)..                                                   d(t,j)=e=sum(i,nprod(t,i,j))*dcap(t,j);

nfct(t+1,i,m,j) $ (ord(t)<36)..                                  ncap(t+1,i,m,j)=e=ncap(t,i,m,j)+next(t+1,i,m,j)-ndec(t+1,i,m,j);

ncapfct(t,i,m,j)..                                               ncap(t,i,m,j)=e=ncap1(t,i,m,j)+ncap2(t,i,m,j);
ncap2fct(t,i,m,j) $ (ord(t)>1)..                                 ncap2(t,i,m,j)=e=ncap(t,i,m,j)-nprod(t,i,j);
ncap3fct(t+1,i,j) $ (ord(t)<36)..                                ncap2(t+1,i,"1",j)=g=ncap2(t,i,"1",j)-nsdec(t+1,i,"1",j)-nxdec(t+1,i,"1",j);
ncap2ctrl1(t)..                                                  sum((i,j),ncap2(t,i,"1",j))=l=0.01*sum((i,j),nprod(t,i,j));

ndecfct(t,i,m,j) $ (ord(t)>1)..                                  ndec(t,i,m,j)=e=nsdec(t,i,m,j)+nxdec(t,i,m,j);
nxdec1fct(t,i,m,j) $ (ord(t)+life(i,m,j)<37) ..                  nxdec(t+life(i,m,j),i,m,j)=e=next(t,i,m,j);

nocfct(t,i,m,j)..                                                nprod(t,i,j)=l=ncap1(t,i,m,j);
n1fct(t,i,m,j)..                                                 nprod(t,i,j)=e=ncap1(t,i,"1",j);
mbioprodfct(t,i,j)..                                             nprod(t,i,j)*pmBio(t,i,j)*dcap(t,j)=e=sum(b,vBio(t,i,j,b));
mgasprodfct(t,i,j)..                                             nprod(t,i,j)*pmGas(t,i,j)*dcap(t,j)=e=sum(b,vGas(t,i,j,b));
m3prodfct(t,i,j)..                                               nprod(t,i,j)*pm3(t,i,j)*dcap(t,j)=e=v3(t,i,j);
mprodsumfct(t,i,j)..                                             v(t,i,j)=e=sum(b,vBio(t,i,j,b))+sum(b,vGas(t,i,j,b))+v3(t,i,j);

bcfct(t,i,j,b)..                                                 bc(t,i,j,b)=e=vBio(t,i,j,b)/efBio(t,i,j)+vGas(t,i,j,b)/(efGas(t,i,j)*efMethan(t,b));
bcGasScheit(t,j)..                                               sum(b,bc(t,"2",j,b))=e=sum(bGas,vGas(t,"2",j,bGas)/(efGas(t,"2",j)*efMethan(t,bGas)))+sum(bScheit,vBio(t,"2",j,bScheit))/efBio(t,"2",j);
bcWaste2Energy(t,j)..                                            sum(b,bc(t,"28",j,b))=e=vGas(t,"28",j,"26")/efGas(t,"28",j)+sum(bwoodchip,vBio(t,"28",j,bwoodchip))/efBio(t,"28",j);
bcHHSCoal(t,j)..                                                 sum(b,bc(t,"26",j,b))=e=vGas(t,"26",j,"25")/efGas(t,"26",j)+sum(bwoodchip2,vBio(t,"26",j,bwoodchip2))/efBio(t,"26",j);
bamaxwastefct(t)..                                               sum(bmwaste(bm),ba(t,bm))*bamaxw(t)=g=sum((i,j,bwaste(b)),bc(t,i,j,b));

ba1fct(t,bmwaste)..                                              ba(t,bmwaste)=g=sum(b,bu(t,b,bmwaste));
ba2fct(t)..                                                      ba(t,"12")*bamaxc(t)=g=sum(bcult(b),bu(t,b,"12")/yield(t,b));
ba3fct(t)..                                                      ba(t,"13")=g=sum(b,bu(t,b,"13"));

bufct(t,b)..                                                     sum(bm,bu(t,b,bm))=e=sum((i,j),bc(t,i,j,b));

bustart(bculst)..                                                bu("1",bculst,"12")=e=yield("1",bculst)*culstart(bculst);
bustartKup..                                                     sum((bkup,bm),bu("1",bkup,bm))=e=yield("1","12")*culstart("12");
bustartMis..                                                     sum((bmis,bm),bu("1",bmis,bm))=e=yield("1","15")*culstart("15");
bumax(t+1,bculst) $ (ord(t)<36)..                                bu(t+1,bculst,"12")=l=2*bu(t,bculst,"12");
bumaxKup(t+1) $ (ord(t)<36)..                                    sum(bkup,bu(t+1,bkup,"12"))=l=2*sum(bkup,bu(t,bkup,"12"));
bumaxMis(t+1) $ (ord(t)<36)..                                    sum(bmis,bu(t+1,bmis,"12"))=l=2*sum(bmis,bu(t,bmis,"12"));

ghgffct(t,i,j,b)..                                               ghgf(t,i,j,b)=e=alloc(i,j)*ghgfeed(b)*bc(t,i,j,b);
ghgtfct(t,i,j)..                                                 ghgt(t,i,j)=e=alloc(i,j)*ghgr(t,i,j)*v(t,i,j);
ghgmaxfct(t) $(ghgmax("1")>0) ..                                 ghgmax(t)=g=sum((i,j,b),ghgf(t,i,j,b))+sum((i,j),ghgt(t,i,j));

vBehfct1(t,jclus,c) $(dBeh("1","1","1")>0) ..                    dBeh(t,jclus,c)=e=sum(i,vBeh(t,i,jclus,c));
vBehfct2(t,i,jclus) $(dBeh("1","1","1")>0) ..                    sum(c,vBeh(t,i,jclus,c))=e=v(t,i,jclus);
nprodBehfct1(t,i,jclus,c) $(dBeh("1","1","1")>0) ..              nprodBeh(t,i,jclus,c)*dcap(t,jclus)=e=vBeh(t,i,jclus,c);
nprodBehfct2(t,i,jclus) $(dBeh("1","1","1")>0) ..                sum(c,nprodBeh(t,i,jclus,c))=e=nprod(t,i,jclus);




model BensimHeat /all/;

option LP=cplex;
*option MINLP=CBC;
*option MIP=cplex;
*option MIP=CBC;

*this option terminates the solver after X seconds
option Reslim=45000;

*This option can reduce or track runtime (model generation?)
*option profile=1;

*option threads=4;

*turning off scaling
* this creates a option file on the fly
*$onecho > cplex.opt
*scaind=-1
*$offecho
* this tells GAMS to use the option file
*benopt.optfile=1;

*specifying a smaller integrality tolerance
*option epint=1e-005;

*but in cases where the parameter NumericalEmphasis is turned on, CPLEX computes MIP kappa for a sample of subproblems
*option numericalemphasis=1;

* With these options all the information is not stored in the list file
option limrow = 0;
option limcol = 0;
option solprint = off;

* Define the objective function and solve
solve BensimHeat minimizing tc using LP;

returnStat('solvestat') = BensimHeat.solvestat;
returnStat('modelstat') = BensimHeat.modelstat;

* save results in parameter for indexed GDX file transfer
vp(t,i,j) = v.l(t,i,j);
vBiop(t,i,j,b) = vBio.l(t,i,j,b);
vGasp(t,i,j,b) = vGas.l(t,i,j,b);
v3p(t,i,j) = v3.l(t,i,j);
bup(t,b,bm) = bu.l(t,b,bm);
bcp(t,i,j,b) = bc.l(t,i,j,b);
ghgfp(t,i,j,b) = ghgf.l(t,i,j,b);
ghgtp(t,i,j) = ghgt.l(t,i,j);
nprodp(t,i,j) = nprod.l(t,i,j);
ncapp(t,i,m,j) = ncap.l(t,i,m,j);
ncap1p(t,i,m,j) = ncap1.l(t,i,m,j);
ncap2p(t,i,m,j) = ncap2.l(t,i,m,j);
nextp(t,i,m,j) = next.l(t,i,m,j);
nxdecp(t,i,m,j) = nxdec.l(t,i,m,j);
vBehp(t,i,j,c) = vBeh.l(t,i,j,c);
tcp = tc.l;

execute_unload %matout%;
execute_unloadIdx 'idxdata', vp, vBiop, vGasp, v3p, ghgfp, ghgtp, bup, bcp, ncapp, ncap1p, ncap2p, nextp, nprodp, nxdecp, vBehp, tcp;
