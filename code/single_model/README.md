##interested in different variations on the current theme

tried linear scale, w/o intercept
tried linear scale, w/ intercept
tried log scale, w/o intercept
tried log scale, w/ intercept

^^ these models for both z and no_z cases

Overall TF from a simulation - estimate = bias (global estimate, we need to look at more local things like per group esitmates)

biases' of different models across range of simulations in "summary.pdf"

summary.pdf numbers is ranked from least cumulative bias to most cumulative bias

roc.R has code to create ROC curves
    score is the porportion of simulations in a given group that have a tumor frcation estimate beyond what is considered equivalent to 0 (usually anything less than 0.03)
    Use these scores with their appropriate true values to construct AUC to understand how well this score discriminates between groups w/ tumor from groups w/o tumor

sim.R has the simulation code and calls to jag model and write out of results

