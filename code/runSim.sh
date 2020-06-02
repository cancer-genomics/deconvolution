#!/bin/bash
#$ -cwd
#$ -j y
#$ -R y
#$ -l mem_free=130G
#$ -l h_vmem=131G
#$ -l h_fsize=150G
#$ -l h_rt=48:00:00
#$ -N progress

module load conda_R/devel

#Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/sim.R 2 0.2 woz
echo done

#Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/sim.R 2 0.1 woz
echo done

#Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/sim.R 2 0 woz
echo done

#Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/sim.R 2 0.2 wz
echo done

#Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/sim.R 2 0.1 wz
echo done

#Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/sim.R 2 0 wz
echo done

#Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/sim.R 3 0.2 woz
echo done

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/sim.R 3 0.1 woz
echo done

#Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/sim.R 3 0 woz
echo done

#Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/sim.R 3 0.2 wz
echo done

#Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/sim.R 3 0.1 wz
echo done

#Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/sim.R 3 0 wz
echo done with everything

