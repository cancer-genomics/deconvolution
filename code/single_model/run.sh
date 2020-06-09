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

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.5 0.2
echo done

#Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/groups_simulation.R 0.5 0.1
echo done

#Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/groups_simulation.R 0.1 0.2
echo done

#Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/groups_simulation.R 0.1 0.1
echo done
