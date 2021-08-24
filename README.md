# BENOPT-HEAT - Optimizing bioenergy use in the German heat sector

The model was developed to identify the optimal use of biomass within the German heat sector. The heat sector is divided into 19 sub-sectors. For each sub-sector, a variety of representative bioenergy-, fossil- and other renewable (hybrid-) heat technology concepts are described, see data publication (https://data.mendeley.com/datasets/v2c93n28rj/2). Within scenarios, the optimal use of bioenergy is determined. A systematic uncertainty assessment can be conducted by applying a global sensitivity analysis. The model runs in Matlab and needs to be coupled with GAMS, where the actual optimization is conducted.
For a detailed description of the model, have a look at the Wiki page.

Running scenarios:
==================

The model consists of a user interface and six main modules (five MATLAB functions and the optimization module in GAMS). With the user interface data can be imported from Excel files and stored in .mat files (xlsx2mat.m). In the user interface scenarios can be customized and executed. When the buttom "Optimize" is pushed, the main function is called, which calls all necessary functions to set the parameters (SetParamter.m), run the optimization module in GAMS (OptimizationModule.gms) and start the plotting of the results (Plotting.m). The optimization results can be saved and plotted later with the user interface.

Running a global sensitivity analysis (Sobol'):
===============================================

Running a sensitivity analysis requires a model server grid or similar to execute the following steps:
- Detemine the range of uncertainty (Sobol_ParameterRange.xlsx)
- Calculate random samples (Sobol_LatinHypercubeSampling.m)
- Import the range of possible price developments etc. based on a literature research (Sobol_ImportDataLimits.m)
- Generate multiple optimization modules for parallel computing (Sobol_generate_gms_files.m)
- Calculate N(k+2) optimization results (Sobol_Main.m), for a detailed description see https://doi.org/10.1016/j.apenergy.2020.114534 
- Calculate the Sobol' indices based on a defined model output (e.g. Sobol_IndexOnGHGReductionReached.m or Sobol_IndexOnBiomassConsumed.m or Sobol_IndexOnMarketShareTechTypes.m)
- Further analysis can be conducted as e.g. scatter plots (Sobol_ScatterPlotsExample.m) or calculating a solution space (Sobol_SolutionSpaceExample.m)


License:
========


BENOPT-HEAT - Optimizing bioenergy use in the German heat sector 
Copyright (C) 2017 - 2020 Matthias Jordan

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

contact: matthias.jordan@ufz.de
