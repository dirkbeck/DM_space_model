%% Figure 3f. (Synchrony plot)
% 1st step
extractNeuronsFromSameSession('twdb_control', 'PL');
extractNeuronsFromSameSession('twdb_control', 'FSI');
extractNeuronsFromSameSession('twdb_control', 'Matrix');
extractNeuronsFromSameSession('twdb_control', 'Striosome');

% 2nd step
covAndBinCtMatrixOfNeuronsFromSameSession('twdb_control', 'sameSessionPLneuronsINcontrol.mat');
covAndBinCtMatrixOfNeuronsFromSameSession('twdb_control', 'sameSessionFSIneuronsINcontrol.mat');
covAndBinCtMatrixOfNeuronsFromSameSession('twdb_control', 'sameSessionMatrixneuronsINcontrol.mat');
covAndBinCtMatrixOfNeuronsFromSameSession('twdb_control', 'sameSessionStriosomeneuronsINcontrol.mat');

% 3rd step
neuronSynchronyPlot(varargin);

%% Extended Data Figures 4k,l (PLS-FSI firing rate)
% 1st step
differentNeuronPairsInDatabase('twdb_control');
differentNeuronPairsInDatabase('twdb_stress');
differentNeuronPairsInDatabase('twdb_stress2');

% 2nd step
extractFitData('twdb_control', 'PLSvsFSI');
extractFitData('twdb_control', 'PLSvsSTRIO');
extractFitData('twdb_stress', 'PLSvsFSI');
extractFitData('twdb_stress', 'PLSvsSTRIO');
extractFitData('twdb_stress2', 'PLSvsFSI');
extractFitData('twdb_stress2', 'PLSvsSTRIO');

% 3rd step
examplePairedNeuronPLot('twdb_control', 'PLSvsFSI', 54); % subplot 1
examplePairedNeuronPLot('twdb_stress', 'PLSvsFSI', 32); % subplot 2

%% Extended Data Figures 4o,p (Experimental FSI and sSPN projecting cortex correlation)
plotFitParamOfNeuronTriplets;
