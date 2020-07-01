#!/bin/bash
#$ -cwd
#$ -j y
#$ -R y
#$ -l mem_free=101G
#$ -l h_vmem=101G
#$ -l h_fsize=150G
#$ -l h_rt=48:00:00
#$ -N progress

module load conda_R/devel

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.5 0.2 log int
echo done

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.5 0.1 log int
echo done

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.1 0.2 log int
echo done

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.1 0.1 log int
echo done

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.5 0.2 nlog int
echo done

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.5 0.1 nlog int
echo done

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.1 0.2 nlog int
echo done

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.1 0.1 nlog int
echo done

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.5 0.2 log nint
echo done

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.5 0.1 log nint
echo done

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.1 0.2 log nint
echo done

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.1 0.1 log nint
echo done

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.5 0.2 nlog nint
echo done

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.5 0.1 nlog nint
echo done

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.1 0.2 nlog nint
echo done

Rscript /dcl01/scharpf1/data/aarun/deconvolution/code/single_model/sim.R 0.1 0.1 nlog nint
echo done

