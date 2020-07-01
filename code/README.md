##Bottom Line: 
3 components, No Log Scale, w/ intercept (Z or no Z is still TBD) - MOST ADVANCED MODEL WE HAVE
^ this is stored single_model/model/nlog_int.jag and single_model/model/no_z/nlog_int.jag

Possibly our current models are too insensitive. 
How can we borrow information across regions? How can we learn these relations?

One future idea: Have a global p on the z[j]'s.


##What the things in this directory do

#####single_model/ do many group simulations with one call to a jag model - most advanced model we have is here 

deconvolution.data and deconvolution.funs -- getting the real data loaded and processed
mixmodel_jags.R -- turning the 500kb data for all samples into a format jags likes

mixmodel.jag -- simplest jag model, version 1 of what we were thinking of

##a bit of nomenclature
a) simple simultion - one group with n bins with a constant tumor fraction spread across all bins
b) many model simulation - many groups with x bins in each group and y% of groups have a tumor contribution. Each of the groups w/ tumor contribution have z% tumor fraction. Each group is run independently via a call to a jag model
c) single simulation - exactly as (b) but entire jag model executed with one call

2 component - normal and wbc used to deconvolute plasma
3 component - tumor, wbc, and normal used to deconvolute plasma

#####output_sim/ -- results of a bunch of different simulations where (b) was used, (note: done on log scale, with intercept in model, and z w/ 3 components)
groups_simulation.R -- simulating the data necessary for models where many groups are taken i.e. (b) and (c)
format_groups.R -- parsing the output of groups_simulation.R and making plots

runGroup.sh -  shell scripts for executing R scripts
runSim.sh - shell script for executing R scripts

sim.R -- (a) - capabale of doing 2 and 3 component jag models w/ and w/o Z latent var
stan_model.R -- a STAN model we tried where plasma is a mixture of two poissons of unknown mixing and mean. 
Note: stan model picked up on some latent variable as all its tumor fraction estimates were very very similar -- what latent var?


simulation_3* - do modeling on a linear scale, which has more accurate estimates than log scale based jag models. Tested for (a) only. 

#####models/ contains all the jag models with 2 and 3 components and z and w/o z 


