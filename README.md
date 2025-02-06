Modeling project on dimensionality reduction in the striatum. Striosome neurons help to select dimensions and matrix neurons map inputs to subject values.
The subdirectories correspond to different topics in the manuscript. Functions used across the topics sit outside the subdirectories. There is also an “Original Functions” folder for preprocessing experimental data.

The topics correspond to the pre-print manuscript (see 10.21203/rs.3.rs-5499511/v1) as follows:
-	model_overview: Figure 1 and Extended Data Figure 1
-	model_tests: Figure 2a-d and Extended Data Figure 2a,o-x
-	disorder_hypotheses: Figure 3 and Extended Data Figure 3m-r
-	dynamic_model_and_neural_net: Figure 4 and Extended Data Figure 4
-	day_to_day_space_sampling: Figure 5 and Extended Data Figure 5
-	circuit_trajectories: Figure 6 and Extended Data Figure 6
-	neuron_pair_analysis: Extended Data Figure 3k-p
-	Cross Correlation Pattern Counts: Extended Data Figure 3b-n, Extended Data Figure 3a-j.

For additional detail on directory<->figure mapping, or for updates on this mapping during the review process, please refer to the METHOD DETAILS section of the manuscript, where the analysis corresponding to each figure is explained and a link is provided to the github.

Most code runs by cloning the repository and running a file corresponding to one or more plots. The exceptions are:
-	To produce Extended Data Figures 3k,l, go to the directory https://github.com/dirkbeck/DM_space_model/tree/main/neuron_pair_analysis and run examplePairedNeuronPLot('twdb_control', 'PLSvsFSI', 54), examplePairedNeuronPLot('twdb_stress', 'PLSvsFSI', 32), respectively.
-	To produce Extended Data Figures 3o,p, go to the directory https://github.com/dirkbeck/DM_space_model/tree/main/neuron_pair_analysis and run plotFitParamOfNeuronTriplets.m.
-	When running neuronSynchronyPlot.m (corresponding to Figure 2f), data files 'sessionDataOf....mat' must first be loaded to memory.
-	To produce Extended Data Figures 2e,f, first follow the steps in runMe.m to generate 'pairsTableControl.mat', 'pairsTableStress.mat', and  'pairsTableStress2.mat'. Then run the following lines of code in MATLAB: examplePairedNeuronPLot('twdb_control', 'PLSvsFSI', 54);
examplePairedNeuronPLot('twdb_stress', 'PLSvsFSI', 32);
